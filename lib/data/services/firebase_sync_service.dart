import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show
        TargetPlatform,
        debugPrint,
        debugPrintStack,
        defaultTargetPlatform,
        kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/app_notification.dart';
import '../../domain/models/app_user.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/income.dart';
import '../../domain/models/room.dart';
import '../../domain/models/villa_model.dart';
import '../repositories/local_database_repository.dart';
import 'connectivity_service.dart';

class FirebaseSyncService {
  static const _pendingSyncKey = 'villabooks_pending_sync_queue';
  static const _lastSyncedAtKey = 'villabooks_last_synced_at';

  FirebaseFirestore? _firestore;
  final ConnectivityService _connectivityService;
  final LocalDatabaseRepository? _localRepository;
  final bool firebaseEnabled;
  StreamSubscription<bool>? _connectivitySubscription;

  FirebaseSyncService({
    FirebaseFirestore? firestore,
    ConnectivityService? connectivityService,
    LocalDatabaseRepository? localRepository,
    this.firebaseEnabled = true,
  })  : _firestore = firestore,
        _localRepository = localRepository,
        _connectivityService = connectivityService ?? ConnectivityService();

  void startAutoSync() {
    debugPrint(
      '[FirebaseSync] startAutoSync platform=$defaultTargetPlatform, '
      'firebaseEnabled=$firebaseEnabled, firestoreEnabled=$_isFirestoreEnabled',
    );

    if (!_isFirestoreEnabled) {
      debugPrint(
        '[FirebaseSync] Firestore sync disabled on $defaultTargetPlatform. '
        'Run flutterfire configure for this platform before enabling cloud sync.',
      );
      return;
    }

    _connectivitySubscription ??=
        _connectivityService.onlineStatus.listen((isOnline) {
      if (isOnline) {
        _syncAllPendingDataInBackground('connectivity-change');
      }
    }, onError: (Object error, StackTrace stackTrace) {
      debugPrint('[FirebaseSync] connectivity listener failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    });

    _syncAllPendingDataInBackground('startup');
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  Future<void> queueVilla({
    required VillaModel villa,
    required String userId,
    bool isDeleted = false,
  }) {
    return _queueRecord(
      collection: 'villas',
      id: villa.id,
      data: _villaToJson(villa),
      userId: userId,
      isDeleted: isDeleted,
    );
  }

  Future<void> queueRoom({
    required Room room,
    required String userId,
    bool isDeleted = false,
  }) {
    return _queueRecord(
      collection: 'rooms',
      id: room.id,
      data: _roomToJson(room),
      userId: userId,
      isDeleted: isDeleted,
    );
  }

  Future<void> queueIncome({
    required Income income,
    required String userId,
    bool isDeleted = false,
  }) {
    return _queueRecord(
      collection: 'incomes',
      id: income.id,
      data: _incomeToJson(income),
      userId: userId,
      isDeleted: isDeleted,
    );
  }

  Future<void> queueExpense({
    required Expense expense,
    required String userId,
    bool isDeleted = false,
  }) {
    return _queueRecord(
      collection: 'expenses',
      id: expense.id,
      data: _expenseToJson(expense),
      userId: userId,
      isDeleted: isDeleted,
    );
  }

  Future<void> queueUser({
    required AppUser user,
    required String userId,
    bool isDeleted = false,
  }) {
    return _queueRecord(
      collection: 'users',
      id: user.id,
      data: _appUserToJson(user),
      userId: userId,
      isDeleted: isDeleted,
    );
  }

  Future<void> queueNotification({
    required AppNotification notification,
    required String userId,
    bool isDeleted = false,
  }) {
    return _queueRecord(
      collection: 'notifications',
      id: notification.id,
      data: notification.toJson(),
      userId: userId,
      isDeleted: isDeleted,
    );
  }

  Future<void> queueDelete({
    required String collection,
    required String id,
    required String userId,
  }) {
    return _queueRecord(
      collection: collection,
      id: id,
      data: const {},
      userId: userId,
      isDeleted: true,
    );
  }

  Future<void> syncPendingVillas() => _syncCollection('villas');
  Future<void> syncPendingRooms() => _syncCollection('rooms');
  Future<void> syncPendingIncomes() => _syncCollection('incomes');
  Future<void> syncPendingExpenses() => _syncCollection('expenses');
  Future<void> syncPendingUsers() => _syncCollection('users');
  Future<void> syncPendingNotifications() => _syncCollection('notifications');

  Future<void> syncPendingDeletes() async {
    final localRepository = _localRepository;
    if (localRepository == null) return;
    if (!await _connectivityService.isOnline) return;

    final pendingDeletes = await localRepository.getPendingDeleteRecords();
    if (pendingDeletes.isEmpty) return;

    for (final record in pendingDeletes) {
      final now = DateTime.now();
      final payload = {
        'id': record.id,
        'isDeleted': true,
        'syncStatus': 'synced',
        'deletedAt': (record.deletedAt ?? now).toIso8601String(),
        'deletedBy': record.deletedBy,
        'updatedAt': now.toIso8601String(),
        'lastSyncedAt': now.toIso8601String(),
      };

      try {
        if (_usesRestSync) {
          await _setDocumentWithRest(
            record.collection,
            record.id,
            payload,
            serverDeletedAt: true,
          );
        } else {
          final firestore = _safeFirestore;
          if (firestore == null) return;
          await firestore.collection(record.collection).doc(record.id).set(
            {
              ...payload,
              'deletedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        }
        await localRepository.markSyncRecordSynced(
          collection: record.collection,
          id: record.id,
        );
      } catch (error, stackTrace) {
        debugPrint(
          '[FirebaseSync] failed pending delete ${record.collection}/${record.id}: $error',
        );
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  Future<void> syncAllPendingData() async {
    if (!_isFirestoreEnabled) {
      debugPrint('[FirebaseSync] sync skipped: Firestore sync is disabled.');
      return;
    }
    if (!await _connectivityService.isOnline) {
      debugPrint('[FirebaseSync] sync skipped: device is offline.');
      return;
    }

    final pendingCount = await getPendingSyncCount();
    debugPrint('[FirebaseSync] syncAllPendingData pending=$pendingCount');

    await syncPendingVillas();
    await syncPendingRooms();
    await syncPendingIncomes();
    await syncPendingExpenses();
    await syncPendingDeletes();
    await syncPendingUsers();
    await syncPendingNotifications();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _lastSyncedAtKey,
      DateTime.now().toIso8601String(),
    );
  }

  void _syncAllPendingDataInBackground(String reason) {
    unawaited(
      syncAllPendingData().catchError((Object error, StackTrace stackTrace) {
        debugPrint('[FirebaseSync] background sync failed ($reason): $error');
        debugPrintStack(stackTrace: stackTrace);
      }),
    );
  }

  Stream<List<VillaModel>> watchCloudVillas() {
    if (_usesRestSync) {
      debugPrint(
          '[FirebaseSync] cloud villa stream disabled on Windows REST sync.');
      return Stream.value(const []);
    }

    final firestore = _safeFirestore;
    if (firestore == null) {
      debugPrint('[FirebaseSync] cloud villa stream disabled on desktop.');
      return Stream.value(const []);
    }

    return firestore
        .collection('villas')
        .snapshots()
        .asyncMap((snapshot) async {
      await _applyDeletedDocsToLocal('villas', snapshot.docs);
      final activeDocs = snapshot.docs
          .where((doc) => doc.data()['isDeleted'] != true)
          .toList();
      final activeVillas = activeDocs
          .map((doc) => _villaFromJson(_withDocumentId(doc)))
          .toList();
      final localRepository = _localRepository;
      if (localRepository != null) {
        for (final villa in activeVillas) {
          await localRepository.upsertVilla(villa);
        }
      }
      debugPrint(
        '[FirebaseSync] cloud villas snapshot raw=${snapshot.docs.length}, active=${activeDocs.length}',
      );
      return activeVillas;
    });
  }

  Stream<List<Room>> watchCloudRooms() {
    if (_usesRestSync) {
      debugPrint(
          '[FirebaseSync] cloud room stream disabled on Windows REST sync.');
      return Stream.value(const []);
    }

    final firestore = _safeFirestore;
    if (firestore == null) {
      debugPrint('[FirebaseSync] cloud room stream disabled on desktop.');
      return Stream.value(const []);
    }

    return firestore.collection('rooms').snapshots().asyncMap((snapshot) async {
      await _applyDeletedDocsToLocal('rooms', snapshot.docs);
      final activeDocs = snapshot.docs
          .where((doc) => doc.data()['isDeleted'] != true)
          .toList();
      final activeRooms =
          activeDocs.map((doc) => _roomFromJson(_withDocumentId(doc))).toList();
      final localRepository = _localRepository;
      if (localRepository != null) {
        for (final room in activeRooms) {
          await localRepository.upsertRoom(room);
        }
      }
      debugPrint(
        '[FirebaseSync] cloud rooms snapshot raw=${snapshot.docs.length}, active=${activeDocs.length}',
      );
      return activeRooms;
    });
  }

  Stream<List<Income>> watchCloudIncomes() {
    if (_usesRestSync) {
      debugPrint(
          '[FirebaseSync] cloud income stream disabled on Windows REST sync.');
      return Stream.value(const []);
    }

    final firestore = _safeFirestore;
    if (firestore == null) {
      debugPrint('[FirebaseSync] cloud income stream disabled on desktop.');
      return Stream.value(const []);
    }

    return firestore
        .collection('incomes')
        .snapshots()
        .asyncMap((snapshot) async {
      await _applyDeletedDocsToLocal('incomes', snapshot.docs);
      final activeDocs = snapshot.docs
          .where((doc) => doc.data()['isDeleted'] != true)
          .toList();
      final activeIncomes = activeDocs
          .map((doc) => _incomeFromJson(_withDocumentId(doc)))
          .toList();
      final localRepository = _localRepository;
      if (localRepository != null) {
        for (final income in activeIncomes) {
          await localRepository.upsertIncome(income);
        }
      }
      debugPrint(
        '[FirebaseSync] cloud incomes snapshot raw=${snapshot.docs.length}, active=${activeDocs.length}',
      );
      return activeIncomes;
    });
  }

  Stream<List<Expense>> watchCloudExpenses() {
    if (_usesRestSync) {
      debugPrint(
          '[FirebaseSync] cloud expense stream disabled on Windows REST sync.');
      return Stream.value(const []);
    }

    final firestore = _safeFirestore;
    if (firestore == null) {
      debugPrint('[FirebaseSync] cloud expense stream disabled on desktop.');
      return Stream.value(const []);
    }

    return firestore
        .collection('expenses')
        .snapshots()
        .asyncMap((snapshot) async {
      await _applyDeletedDocsToLocal('expenses', snapshot.docs);
      final activeDocs = snapshot.docs
          .where((doc) => doc.data()['isDeleted'] != true)
          .toList();
      final activeExpenses = activeDocs
          .map((doc) => _expenseFromJson(_withDocumentId(doc)))
          .toList();
      final localRepository = _localRepository;
      if (localRepository != null) {
        for (final expense in activeExpenses) {
          await localRepository.upsertExpense(expense);
        }
      }
      debugPrint(
        '[FirebaseSync] cloud expenses snapshot raw=${snapshot.docs.length}, active=${activeDocs.length}',
      );
      return activeExpenses;
    });
  }

  Future<void> initialPullFromFirestore() async {
    final localRepository = _localRepository;
    if (localRepository == null) {
      debugPrint(
        '[FirebaseSync] initial pull skipped: local repository is not wired.',
      );
      return;
    }
    if (!_isFirestoreEnabled) {
      debugPrint('[FirebaseSync] initial pull skipped: Firestore disabled.');
      return;
    }
    if (!await _connectivityService.isOnline) {
      debugPrint('[FirebaseSync] initial pull skipped: device is offline.');
      return;
    }

    final firestore = _safeFirestore;
    if (firestore == null) {
      debugPrint('[FirebaseSync] initial pull skipped: no Firestore.');
      return;
    }

    debugPrint('[FirebaseSync] initial pull started.');

    final snapshots = await Future.wait([
      firestore.collection('villas').get(),
      firestore.collection('rooms').get(),
      firestore.collection('incomes').get(),
      firestore.collection('expenses').get(),
      firestore.collection('notifications').get(),
      firestore.collection('users').get(),
    ]);

    final villaDocs = snapshots[0].docs;
    final roomDocs = snapshots[1].docs;
    final incomeDocs = snapshots[2].docs;
    final expenseDocs = snapshots[3].docs;
    final notificationDocs = snapshots[4].docs;
    final userDocs = snapshots[5].docs;

    for (final doc in villaDocs) {
      final data = _withDocumentId(doc);
      if (_isDeleted(data)) {
        await localRepository.markRecordDeletedFromCloud(
          collection: 'villas',
          id: doc.id,
          deletedAt: _readNullableDateTime(data['deletedAt']),
          deletedBy: data['deletedBy'] as String?,
        );
        continue;
      }
      await localRepository.upsertVilla(_villaFromJson(data));
    }

    for (final doc in roomDocs) {
      final data = _withDocumentId(doc);
      if (_isDeleted(data)) {
        await localRepository.markRecordDeletedFromCloud(
          collection: 'rooms',
          id: doc.id,
          deletedAt: _readNullableDateTime(data['deletedAt']),
          deletedBy: data['deletedBy'] as String?,
        );
        continue;
      }
      await localRepository.upsertRoom(_roomFromJson(data));
    }

    for (final doc in incomeDocs) {
      final data = _withDocumentId(doc);
      if (_isDeleted(data)) {
        await localRepository.markRecordDeletedFromCloud(
          collection: 'incomes',
          id: doc.id,
          deletedAt: _readNullableDateTime(data['deletedAt']),
          deletedBy: data['deletedBy'] as String?,
        );
        continue;
      }
      await localRepository.upsertIncome(_incomeFromJson(data));
    }

    for (final doc in expenseDocs) {
      final data = _withDocumentId(doc);
      if (_isDeleted(data)) {
        await localRepository.markRecordDeletedFromCloud(
          collection: 'expenses',
          id: doc.id,
          deletedAt: _readNullableDateTime(data['deletedAt']),
          deletedBy: data['deletedBy'] as String?,
        );
        continue;
      }
      await localRepository.upsertExpense(_expenseFromJson(data));
    }

    for (final doc in notificationDocs) {
      final data = _withDocumentId(doc);
      if (_isDeleted(data)) continue;
      await localRepository.upsertNotification(AppNotification.fromJson(data));
    }

    for (final doc in userDocs) {
      final data = _withDocumentId(doc);
      if (_isDeleted(data)) continue;
      await localRepository.upsertUser(_appUserFromJson(data));
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _lastSyncedAtKey,
      DateTime.now().toIso8601String(),
    );

    debugPrint(
      '[FirebaseSync] initial pull completed: '
      'villas=${villaDocs.length}, rooms=${roomDocs.length}, '
      'incomes=${incomeDocs.length}, expenses=${expenseDocs.length}, '
      'notifications=${notificationDocs.length}, users=${userDocs.length}',
    );
  }

  Future<void> pullCloudDataToLocal() => initialPullFromFirestore();

  Future<void> _applyDeletedDocsToLocal(
    String collection,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final localRepository = _localRepository;
    if (localRepository == null) return;

    for (final doc in docs) {
      final data = _withDocumentId(doc);
      if (!_isDeleted(data)) continue;
      await localRepository.markRecordDeletedFromCloud(
        collection: collection,
        id: doc.id,
        deletedAt: _readNullableDateTime(data['deletedAt']),
        deletedBy: data['deletedBy'] as String?,
      );
    }
  }

  Map<String, dynamic> _withDocumentId(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return {
      ...doc.data(),
      'id': doc.data()['id'] as String? ?? doc.id,
    };
  }

  Map<String, dynamic> resolveConflict({
    required Map<String, dynamic> local,
    required Map<String, dynamic> cloud,
  }) {
    final localUpdatedAt = _readDateTime(local['updatedAt']);
    final cloudUpdatedAt = _readDateTime(cloud['updatedAt']);
    if (cloudUpdatedAt.isAfter(localUpdatedAt)) return cloud;
    return local;
  }

  Future<int> getPendingSyncCount() async {
    final queue = await _loadQueue();
    return queue.length;
  }

  Future<DateTime?> getLastSyncedAt() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(_lastSyncedAtKey);
    return value == null ? null : DateTime.tryParse(value);
  }

  Future<int> getPendingDeleteCount() {
    return _localRepository?.getPendingDeleteCount() ?? Future.value(0);
  }

  Future<void> _queueRecord({
    required String collection,
    required String id,
    required Map<String, dynamic> data,
    required String userId,
    required bool isDeleted,
  }) async {
    final now = DateTime.now();
    final queue = await _loadQueue();
    final record = _SyncRecord(
      collection: collection,
      id: id,
      data: {
        ...data,
        'id': id,
        'updatedBy': userId,
        'updatedAt': now.toIso8601String(),
        'isDeleted': isDeleted,
        'syncStatus': 'pending',
        'lastSyncedAt': null,
        if (!data.containsKey('createdBy')) 'createdBy': userId,
        if (!data.containsKey('createdAt')) 'createdAt': now.toIso8601String(),
      },
      queuedAt: now,
    );

    queue.removeWhere(
      (item) => item.collection == collection && item.id == id,
    );
    queue.add(record);
    await _saveQueue(queue);
    debugPrint(
      '[FirebaseSync] queued $collection/$id, queueSize=${queue.length}',
    );

    if (await _connectivityService.isOnline) {
      await _syncCollection(collection);
    } else {
      debugPrint('[FirebaseSync] queued $collection/$id for later: offline');
    }
  }

  Future<void> _syncCollection(String collection) async {
    if (_usesRestSync) {
      await _syncCollectionWithRest(collection);
      return;
    }

    final firestore = _safeFirestore;
    if (firestore == null) {
      debugPrint('[FirebaseSync] $collection sync skipped: no Firestore.');
      return;
    }
    if (!await _connectivityService.isOnline) {
      debugPrint('[FirebaseSync] $collection sync skipped: offline.');
      return;
    }

    final queue = await _loadQueue();
    final collectionQueue =
        queue.where((record) => record.collection == collection).length;
    debugPrint(
      '[FirebaseSync] syncing $collection queued=$collectionQueue total=${queue.length}',
    );
    final remaining = <_SyncRecord>[];

    for (final record in queue) {
      if (record.collection != collection) {
        remaining.add(record);
        continue;
      }

      try {
        final now = DateTime.now();
        final payload = {
          ...record.data,
          'syncStatus': 'synced',
          'lastSyncedAt': now.toIso8601String(),
          if (record.data['isDeleted'] == true)
            'deletedAt': FieldValue.serverTimestamp(),
        };
        await firestore
            .collection(record.collection)
            .doc(record.id)
            .set(payload, SetOptions(merge: true));
        debugPrint(
          '[FirebaseSync] synced ${record.collection}/${record.id}',
        );
      } catch (error) {
        debugPrint(
          '[FirebaseSync] failed ${record.collection}/${record.id}: $error',
        );
        remaining.add(record);
      }
    }

    await _saveQueue(remaining);
  }

  Future<void> _syncCollectionWithRest(String collection) async {
    if (!await _connectivityService.isOnline) {
      debugPrint('[FirebaseSync] $collection REST sync skipped: offline.');
      return;
    }

    final queue = await _loadQueue();
    final collectionQueue =
        queue.where((record) => record.collection == collection).length;
    debugPrint(
      '[FirebaseSync] REST syncing $collection queued=$collectionQueue total=${queue.length}',
    );

    final remaining = <_SyncRecord>[];
    for (final record in queue) {
      if (record.collection != collection) {
        remaining.add(record);
        continue;
      }

      try {
        final now = DateTime.now();
        final payload = {
          ...record.data,
          'syncStatus': 'synced',
          'lastSyncedAt': now.toIso8601String(),
        };
        await _setDocumentWithRest(
          record.collection,
          record.id,
          payload,
          serverDeletedAt: record.data['isDeleted'] == true,
        );
        debugPrint(
          '[FirebaseSync] REST synced ${record.collection}/${record.id}',
        );
      } catch (error, stackTrace) {
        debugPrint(
          '[FirebaseSync] REST failed ${record.collection}/${record.id}: $error',
        );
        debugPrintStack(stackTrace: stackTrace);
        remaining.add(record);
      }
    }

    await _saveQueue(remaining);
  }

  Future<void> _setDocumentWithRest(
    String collection,
    String id,
    Map<String, dynamic> data, {
    bool serverDeletedAt = false,
  }) async {
    final appOptions = Firebase.app().options;
    if (serverDeletedAt) {
      await _setDeletedDocumentWithRest(collection, id, data);
      return;
    }

    final encodedCollection = Uri.encodeComponent(collection);
    final encodedId = Uri.encodeComponent(id);
    final uri = Uri.https(
      'firestore.googleapis.com',
      '/v1/projects/${appOptions.projectId}/databases/(default)/documents/$encodedCollection/$encodedId',
      {'key': appOptions.apiKey},
    );
    final response = await http.patch(
      uri,
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'fields': _toFirestoreFields(data)}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Firestore REST write failed with HTTP ${response.statusCode}: ${response.body}',
      );
    }
  }

  Future<void> _setDeletedDocumentWithRest(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    final appOptions = Firebase.app().options;
    final documentPath =
        '${Uri.encodeComponent(collection)}/${Uri.encodeComponent(id)}';
    final documentName =
        'projects/${appOptions.projectId}/databases/(default)/documents/$documentPath';
    final fields = Map<String, dynamic>.from(data)..remove('deletedAt');
    final uri = Uri.https(
      'firestore.googleapis.com',
      '/v1/projects/${appOptions.projectId}/databases/(default)/documents:commit',
      {'key': appOptions.apiKey},
    );
    final response = await http.post(
      uri,
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'writes': [
          {
            'update': {
              'name': documentName,
              'fields': _toFirestoreFields(fields),
            },
            'updateMask': {
              'fieldPaths': fields.keys.toList(),
            },
            'updateTransforms': [
              {
                'fieldPath': 'deletedAt',
                'setToServerValue': 'REQUEST_TIME',
              },
            ],
          },
        ],
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Firestore REST delete write failed with HTTP ${response.statusCode}: ${response.body}',
      );
    }
  }

  Map<String, dynamic> _toFirestoreFields(Map<String, dynamic> data) {
    return data.map((key, value) => MapEntry(key, _toFirestoreValue(value)));
  }

  Map<String, dynamic> _toFirestoreValue(Object? value) {
    if (value == null) return {'nullValue': null};
    if (value is bool) return {'booleanValue': value};
    if (value is int) return {'integerValue': value.toString()};
    if (value is double) return {'doubleValue': value};
    if (value is String) return {'stringValue': value};
    if (value is DateTime) {
      return {'timestampValue': value.toUtc().toIso8601String()};
    }
    if (value is Iterable) {
      return {
        'arrayValue': {
          'values': value.map(_toFirestoreValue).toList(),
        },
      };
    }
    if (value is Map) {
      return {
        'mapValue': {
          'fields': value.map(
            (key, nestedValue) =>
                MapEntry(key.toString(), _toFirestoreValue(nestedValue)),
          ),
        },
      };
    }
    return {'stringValue': value.toString()};
  }

  Future<List<_SyncRecord>> _loadQueue() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_pendingSyncKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => _SyncRecord.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveQueue(List<_SyncRecord> queue) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(queue.map((item) => item.toJson()).toList());
    await preferences.setString(_pendingSyncKey, encoded);
  }

  Map<String, dynamic> _villaToJson(VillaModel villa) {
    return {
      'id': villa.id,
      'villaName': villa.villaName,
      'villaNumber': villa.villaNumber,
      'location': villa.location,
      'notes': villa.notes,
      'createdAt': villa.createdAt.toIso8601String(),
      'updatedAt': villa.updatedAt?.toIso8601String(),
      'isDeleted': villa.isDeleted,
      'syncStatus': villa.syncStatus,
      'deletedAt': villa.deletedAt?.toIso8601String(),
      'deletedBy': villa.deletedBy,
      'createdBy': villa.createdBy,
      'updatedBy': villa.updatedBy,
      'lastSyncedAt': villa.lastSyncedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> _roomToJson(Room room) {
    return {
      'id': room.id,
      'villaId': room.villaId,
      'villaName': room.villaName,
      'roomName': room.roomName,
      'roomNumber': room.roomNumber,
      'tenantName': room.tenantName,
      'tenantPhone': room.tenantPhone,
      'monthlyRent': room.monthlyRent,
      'contractStartDate': room.contractStartDate?.toIso8601String(),
      'contractEndDate': room.contractEndDate?.toIso8601String(),
      'paymentDueDay': room.paymentDueDay,
      'status': room.status,
      'createdAt': room.createdAt.toIso8601String(),
      'updatedAt': room.updatedAt?.toIso8601String(),
      'isDeleted': room.isDeleted,
      'syncStatus': room.syncStatus,
      'deletedAt': room.deletedAt?.toIso8601String(),
      'deletedBy': room.deletedBy,
      'createdBy': room.createdBy,
      'updatedBy': room.updatedBy,
      'lastSyncedAt': room.lastSyncedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> _incomeToJson(Income income) {
    return {
      'id': income.id,
      'villaId': income.villaId,
      'villaName': income.villaName,
      'roomId': income.roomId,
      'roomName': income.roomName,
      'incomeType': income.incomeType,
      'amount': income.amount,
      'paymentDate': income.paymentDate.toIso8601String(),
      'paymentMethod': income.paymentMethod,
      'monthCovered': income.monthCovered.toIso8601String(),
      'notes': income.notes,
      'createdAt': income.createdAt.toIso8601String(),
      'updatedAt': income.updatedAt?.toIso8601String(),
      'isDeleted': income.isDeleted,
      'syncStatus': income.syncStatus,
      'deletedAt': income.deletedAt?.toIso8601String(),
      'deletedBy': income.deletedBy,
      'createdBy': income.createdBy,
      'updatedBy': income.updatedBy,
      'lastSyncedAt': income.lastSyncedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> _expenseToJson(Expense expense) {
    return {
      'id': expense.id,
      'villaId': expense.villaId,
      'villaName': expense.villaName,
      'roomId': expense.roomId,
      'roomName': expense.roomName,
      'category': expense.category,
      'amount': expense.amount,
      'expenseDate': expense.expenseDate.toIso8601String(),
      'paidTo': expense.paidTo,
      'paymentMethod': expense.paymentMethod,
      'notes': expense.notes,
      'createdAt': expense.createdAt.toIso8601String(),
      'updatedAt': expense.updatedAt?.toIso8601String(),
      'isDeleted': expense.isDeleted,
      'syncStatus': expense.syncStatus,
      'deletedAt': expense.deletedAt?.toIso8601String(),
      'deletedBy': expense.deletedBy,
      'createdBy': expense.createdBy,
      'updatedBy': expense.updatedBy,
      'lastSyncedAt': expense.lastSyncedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> _appUserToJson(AppUser user) {
    return {
      'id': user.id,
      'username': user.username,
      'role': user.role,
      'isActive': true,
      'createdAt': user.createdAt.toIso8601String(),
      'updatedAt': user.updatedAt?.toIso8601String(),
    };
  }

  VillaModel _villaFromJson(Map<String, dynamic> json) {
    return VillaModel(
      id: json['id'] as String,
      villaName: json['villaName'] as String? ?? '',
      villaNumber: json['villaNumber'] as String? ?? '',
      location: json['location'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      createdAt: _readDateTime(json['createdAt']),
      updatedAt: _readDateTime(json['updatedAt']),
      isDeleted: _isDeleted(json),
      syncStatus: json['syncStatus'] as String? ?? 'synced',
      deletedAt: _readNullableDateTime(json['deletedAt']),
      deletedBy: json['deletedBy'] as String?,
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
      lastSyncedAt: _readNullableDateTime(json['lastSyncedAt']),
    );
  }

  Room _roomFromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      villaId: json['villaId'] as String? ?? '',
      villaName: json['villaName'] as String? ?? '',
      roomName: json['roomName'] as String? ?? '',
      roomNumber: json['roomNumber'] as String? ?? '',
      tenantName: json['tenantName'] as String? ?? '',
      tenantPhone: json['tenantPhone'] as String? ?? '',
      monthlyRent: (json['monthlyRent'] as num?)?.toDouble() ?? 0,
      contractStartDate: _readNullableDateTime(json['contractStartDate']),
      contractEndDate: _readNullableDateTime(json['contractEndDate']),
      paymentDueDay: (json['paymentDueDay'] as num?)?.toInt() ?? 1,
      status: json['status'] as String? ?? RoomStatuses.vacant,
      createdAt: _readDateTime(json['createdAt']),
      updatedAt: _readNullableDateTime(json['updatedAt']),
      isDeleted: _isDeleted(json),
      syncStatus: json['syncStatus'] as String? ?? 'synced',
      deletedAt: _readNullableDateTime(json['deletedAt']),
      deletedBy: json['deletedBy'] as String?,
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
      lastSyncedAt: _readNullableDateTime(json['lastSyncedAt']),
    );
  }

  Income _incomeFromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'] as String,
      villaId: json['villaId'] as String? ?? '',
      villaName: json['villaName'] as String? ?? '',
      roomId: json['roomId'] as String? ?? '',
      roomName: json['roomName'] as String? ?? '',
      incomeType: json['incomeType'] as String? ?? IncomeTypes.other,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      paymentDate: _readDateTime(json['paymentDate']),
      paymentMethod:
          json['paymentMethod'] as String? ?? IncomePaymentMethods.other,
      monthCovered: _readDateTime(json['monthCovered']),
      notes: json['notes'] as String? ?? '',
      createdAt: _readDateTime(json['createdAt']),
      updatedAt: _readNullableDateTime(json['updatedAt']),
      isDeleted: _isDeleted(json),
      syncStatus: json['syncStatus'] as String? ?? 'synced',
      deletedAt: _readNullableDateTime(json['deletedAt']),
      deletedBy: json['deletedBy'] as String?,
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
      lastSyncedAt: _readNullableDateTime(json['lastSyncedAt']),
    );
  }

  Expense _expenseFromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      villaId: json['villaId'] as String?,
      villaName: json['villaName'] as String? ?? 'General Expense',
      roomId: json['roomId'] as String?,
      roomName: json['roomName'] as String?,
      category: json['category'] as String? ?? ExpenseCategories.other,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      expenseDate: _readDateTime(json['expenseDate']),
      paidTo: json['paidTo'] as String? ?? '',
      paymentMethod:
          json['paymentMethod'] as String? ?? ExpensePaymentMethods.other,
      notes: json['notes'] as String? ?? '',
      createdAt: _readDateTime(json['createdAt']),
      updatedAt: _readNullableDateTime(json['updatedAt']),
      isDeleted: _isDeleted(json),
      syncStatus: json['syncStatus'] as String? ?? 'synced',
      deletedAt: _readNullableDateTime(json['deletedAt']),
      deletedBy: json['deletedBy'] as String?,
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
      lastSyncedAt: _readNullableDateTime(json['lastSyncedAt']),
    );
  }

  AppUser _appUserFromJson(Map<String, dynamic> json) {
    final createdAt = _readDateTime(json['createdAt']);
    return AppUser(
      id: json['id'] as String,
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      role: json['role'] as String? ?? 'viewer',
      createdAt: createdAt,
      updatedAt: _readNullableDateTime(json['updatedAt']),
    );
  }

  bool _isDeleted(Map<String, dynamic> json) => json['isDeleted'] == true;

  DateTime _readDateTime(Object? value) {
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  DateTime? _readNullableDateTime(Object? value) {
    if (value == null) return null;
    return _readDateTime(value);
  }

  FirebaseFirestore? get _safeFirestore {
    if (_usesRestSync) return null;
    if (!_isFirestoreEnabled) return null;

    try {
      return _firestore ??= FirebaseFirestore.instance;
    } catch (error, stackTrace) {
      debugPrint('[FirebaseSync] Firestore unavailable: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  bool get _isFirestoreEnabled {
    if (!firebaseEnabled) {
      debugPrint(
        '[FirebaseSync] Firestore sync disabled because Firebase did not initialize.',
      );
      return false;
    }

    if (kIsWeb) return true;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return true;
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return false;
    }
  }

  bool get _usesRestSync {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
  }
}

class _SyncRecord {
  final String collection;
  final String id;
  final Map<String, dynamic> data;
  final DateTime queuedAt;

  const _SyncRecord({
    required this.collection,
    required this.id,
    required this.data,
    required this.queuedAt,
  });

  factory _SyncRecord.fromJson(Map<String, dynamic> json) {
    return _SyncRecord(
      collection: json['collection'] as String,
      id: json['id'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      queuedAt: DateTime.parse(json['queuedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'collection': collection,
      'id': id,
      'data': data,
      'queuedAt': queuedAt.toIso8601String(),
    };
  }
}

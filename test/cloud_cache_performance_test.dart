import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:villabooks/data/local/database.dart';
import 'package:villabooks/data/repositories/local_database_repository.dart';
import 'package:villabooks/data/services/firebase_sync_service.dart';
import 'package:villabooks/domain/models/villa_model.dart';

// Test doubles for the Firestore SDK boundary; no live Firebase is used.
// ignore: subtype_of_sealed_class
class _Document implements QueryDocumentSnapshot<Map<String, dynamic>> {
  _Document(this.id, this.values);
  @override
  final String id;
  final Map<String, dynamic> values;
  @override
  Map<String, dynamic> data() => values;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Change implements DocumentChange<Map<String, dynamic>> {
  _Change(this.doc);
  @override
  final _Document doc;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Snapshot implements QuerySnapshot<Map<String, dynamic>> {
  _Snapshot(this.docs, List<_Document> changed)
      : docChanges = changed.map(_Change.new).toList();
  @override
  final List<_Document> docs;
  @override
  final List<_Change> docChanges;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ignore: subtype_of_sealed_class
class _Collection implements CollectionReference<Map<String, dynamic>> {
  final updates = StreamController<QuerySnapshot<Map<String, dynamic>>>();
  @override
  Query<Map<String, dynamic>> where(Object field,
          {Object? isEqualTo,
          Object? isNotEqualTo,
          Object? isLessThan,
          Object? isLessThanOrEqualTo,
          Object? isGreaterThan,
          Object? isGreaterThanOrEqualTo,
          Object? arrayContains,
          Iterable<Object?>? arrayContainsAny,
          Iterable<Object?>? whereIn,
          Iterable<Object?>? whereNotIn,
          bool? isNull}) =>
      this;
  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> snapshots(
          {bool includeMetadataChanges = false,
          ListenSource source = ListenSource.defaultSource}) =>
      updates.stream;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Firestore implements FirebaseFirestore {
  final villas = _Collection();
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) => villas;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CountingRepository extends LocalDatabaseRepository {
  _CountingRepository(super.database);
  int villaWrites = 0;
  @override
  Future<void> upsertVilla(VillaModel villa) {
    villaWrites++;
    return super.upsertVilla(villa);
  }
}

_Document _villa(int id, {String? name, bool deleted = false}) => _Document(
      '$id',
      {
        'villaName': name ?? 'Villa $id',
        'location': 'Doha',
        'orgId': 'default_org',
        'createdAt': DateTime(2026).toIso8601String(),
        'updatedAt': DateTime(2026, 2).toIso8601String(),
        'isDeleted': deleted,
        'syncStatus': 'synced',
      },
    );

void main() {
  late AppDatabase database;
  late _CountingRepository repository;
  late _Firestore firestore;
  late StreamIterator<List<VillaModel>> cloud;

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = _CountingRepository(database);
    firestore = _Firestore();
    cloud = StreamIterator(FirebaseSyncService(
      firestore: firestore,
      localRepository: repository,
    ).watchCloudVillas());
  });
  tearDown(() async {
    await cloud.cancel();
    await firestore.villas.updates.close();
    await database.close();
    debugDefaultTargetPlatformOverride = null;
  });

  test('100 cloud rows publish once; a one-row change only writes one row',
      () async {
    final localSizes = <int>[];
    final firstLocal = Completer<void>();
    final subscription = database.watchAllVillas().listen((rows) {
      localSizes.add(rows.length);
      if (!firstLocal.isCompleted) firstLocal.complete();
    });
    addTearDown(subscription.cancel);
    await firstLocal.future;
    final docs = List.generate(100, _villa);
    firestore.villas.updates.add(_Snapshot(docs, docs));
    expect(await cloud.moveNext(), isTrue);
    await database.getAllVillas();
    await Future<void>.delayed(Duration.zero);
    expect(localSizes, [0, 100]);
    expect(repository.villaWrites, 100);

    docs[0] = _villa(0, name: 'Renamed');
    firestore.villas.updates.add(_Snapshot(docs, [docs[0]]));
    expect(await cloud.moveNext(), isTrue);
    expect(repository.villaWrites, 101);
    expect((await database.getVillaById('0'))!.villaName, 'Renamed');

    docs[0] = _villa(0, deleted: true);
    firestore.villas.updates.add(_Snapshot(docs, [docs[0]]));
    expect(await cloud.moveNext(), isTrue);
    expect(cloud.current.length, 99);
    expect((await database.getVillaById('0'))!.isDeleted, 1);
    expect((await database.getAllVillas()).length, 99);
    expect(repository.villaWrites, 101);
  });

  test('a failed cloud batch rolls back all rows', () async {
    final valid = _villa(1);
    final invalid = _Document('2', {..._villa(2).values, 'villaName': 42});
    firestore.villas.updates.add(_Snapshot([valid, invalid], [valid, invalid]));
    await expectLater(cloud.moveNext(), throwsA(isA<TypeError>()));
    expect(await database.getAllVillas(), isEmpty);
  });

  test('batched cloud updates preserve newer pending local edits', () async {
    await repository.upsertVilla(VillaModel(
      id: '1',
      villaName: 'Offline edit',
      location: 'Doha',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026, 3),
      syncStatus: 'pending',
    ));
    final remote = _villa(1);
    firestore.villas.updates.add(_Snapshot([remote], [remote]));
    expect(await cloud.moveNext(), isTrue);
    final local = await database.getVillaById('1');
    expect(local!.villaName, 'Offline edit');
    expect(local.syncStatus, 'pending');
  });
}

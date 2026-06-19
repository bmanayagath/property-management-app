import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../core/constants/default_organization.dart';
import '../../core/constants/app_roles.dart';
import '../../domain/models/organization_model.dart';

class OrganizationRepository {
  OrganizationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore;

  FirebaseFirestore? _firestore;

  FirebaseFirestore? get _safeFirestore {
    if (Firebase.apps.isEmpty) return null;
    return _firestore ??= FirebaseFirestore.instance;
  }

  CollectionReference<Map<String, dynamic>>? get _collection {
    return _safeFirestore?.collection('organizations');
  }

  static const legacyOrganizationName = 'Adorn Villas';

  Stream<List<OrganizationModel>> watchOrganizations() {
    final collection = _collection;
    if (collection == null) return Stream.value(const []);
    return collection.snapshots().map((snapshot) {
      final organizations = snapshot.docs
          .map((doc) => OrganizationModel.fromJson({
                ...doc.data(),
                'id': doc.data()['id'] as String? ?? doc.id,
              }))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      return organizations;
    });
  }

  Future<List<OrganizationModel>> fetchOrganizations() async {
    final collection = _collection;
    if (collection == null) return const [];
    final snapshot = await collection.get();
    return snapshot.docs
        .map((doc) => OrganizationModel.fromJson({
              ...doc.data(),
              'id': doc.data()['id'] as String? ?? doc.id,
            }))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<OrganizationModel?> getOrganization(String orgId) async {
    final collection = _collection;
    if (collection == null || orgId.trim().isEmpty) return null;
    final doc = await collection.doc(orgId).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return OrganizationModel.fromJson({
      ...data,
      'id': data['id'] as String? ?? doc.id,
    });
  }

  Future<void> saveOrganization(OrganizationModel organization) async {
    final collection = _requireCollection();
    await collection.doc(organization.id).set(
          organization.toJson(),
          SetOptions(merge: true),
        );
  }

  Future<void> disableOrganization({
    required String orgId,
    required String updatedBy,
  }) async {
    await setOrganizationActive(
      orgId: orgId,
      isActive: false,
      updatedBy: updatedBy,
    );
  }

  Future<void> setOrganizationActive({
    required String orgId,
    required bool isActive,
    required String updatedBy,
  }) async {
    await _requireCollection().doc(orgId).set(
      {
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': updatedBy,
      },
      SetOptions(merge: true),
    );
  }

  Future<void> ensureDefaultOrganization({String? createdBy}) async {
    final collection = _collection;
    if (collection == null) return;
    final doc = await collection.doc(DefaultOrganization.id).get();
    if (doc.exists) return;
    await collection.doc(DefaultOrganization.id).set(
          OrganizationModel(
            id: DefaultOrganization.id,
            name: DefaultOrganization.name,
            createdAt: DateTime.now(),
            createdBy: createdBy,
          ).toJson(),
        );
  }

  Future<OrganizationUsageSummary> fetchUsageSummary(String orgId) async {
    final firestore = _safeFirestore;
    if (firestore == null) return const OrganizationUsageSummary();
    final snapshots = await Future.wait([
      firestore.collection('users').where('orgId', isEqualTo: orgId).get(),
      firestore
          .collection('villas')
          .where('orgId', isEqualTo: orgId)
          .where('isDeleted', isEqualTo: false)
          .get(),
      firestore
          .collection('rooms')
          .where('orgId', isEqualTo: orgId)
          .where('isDeleted', isEqualTo: false)
          .get(),
    ]);
    return OrganizationUsageSummary(
      usersCount: snapshots[0]
          .docs
          .where((doc) => doc.data()['isDeleted'] != true)
          .length,
      villasCount: snapshots[1].docs.length,
      roomsCount: snapshots[2].docs.length,
    );
  }

  Future<LegacyOrganizationMappingResult> mapLegacyDataToAdornVillas({
    required String updatedBy,
  }) async {
    final firestore = _safeFirestore;
    if (firestore == null) return const LegacyOrganizationMappingResult();

    final organization = await _findOrganizationByName(legacyOrganizationName);
    if (organization == null) {
      return const LegacyOrganizationMappingResult(
        organizationMissing: true,
      );
    }

    final counts = <String, int>{};
    for (final collectionName in const [
      'villas',
      'rooms',
      'incomes',
      'expenses',
      'room_media',
      'notifications',
    ]) {
      counts[collectionName] = await _patchMissingOrgId(
        firestore.collection(collectionName),
        organization.id,
        updatedBy: updatedBy,
      );
    }

    counts['users'] = await _patchUsersMissingOrgId(
      firestore.collection('users'),
      organization.id,
      updatedBy: updatedBy,
    );

    return LegacyOrganizationMappingResult(
      organizationId: organization.id,
      updatedCounts: counts,
    );
  }

  Future<OrganizationModel?> _findOrganizationByName(String name) async {
    final normalizedName = name.trim().toLowerCase();
    final organizations = await fetchOrganizations();
    for (final organization in organizations) {
      if (organization.name.trim().toLowerCase() == normalizedName) {
        return organization;
      }
    }
    return null;
  }

  Future<int> _patchMissingOrgId(
    CollectionReference<Map<String, dynamic>> collection,
    String orgId, {
    required String updatedBy,
  }) async {
    final snapshot = await collection.get();
    final updates = snapshot.docs.where((doc) {
      final data = doc.data();
      return _isMissingOrgId(data['orgId']);
    }).toList();
    await _commitOrgIdUpdates(updates, orgId, updatedBy: updatedBy);
    return updates.length;
  }

  Future<int> _patchUsersMissingOrgId(
    CollectionReference<Map<String, dynamic>> collection,
    String orgId, {
    required String updatedBy,
  }) async {
    final snapshot = await collection.get();
    final updates = snapshot.docs.where((doc) {
      final data = doc.data();
      final role = data['role'] as String?;
      return role != AppRoles.superAdmin && _isMissingOrgId(data['orgId']);
    }).toList();
    await _commitOrgIdUpdates(updates, orgId, updatedBy: updatedBy);
    return updates.length;
  }

  Future<void> _commitOrgIdUpdates(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    String orgId, {
    required String updatedBy,
  }) async {
    if (docs.isEmpty) return;
    final firestore = _safeFirestore;
    if (firestore == null) return;

    const batchLimit = 450;
    for (var index = 0; index < docs.length; index += batchLimit) {
      final batch = firestore.batch();
      final end =
          index + batchLimit > docs.length ? docs.length : index + batchLimit;
      for (final doc in docs.sublist(index, end)) {
        batch.set(
          doc.reference,
          {
            'orgId': orgId,
            'updatedAt': FieldValue.serverTimestamp(),
            'updatedBy': updatedBy,
          },
          SetOptions(merge: true),
        );
      }
      await batch.commit();
    }
  }

  bool _isMissingOrgId(Object? value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    return false;
  }

  CollectionReference<Map<String, dynamic>> _requireCollection() {
    final collection = _collection;
    if (collection == null) throw StateError('Firestore is unavailable.');
    return collection;
  }
}

class OrganizationUsageSummary {
  final int usersCount;
  final int villasCount;
  final int roomsCount;

  const OrganizationUsageSummary({
    this.usersCount = 0,
    this.villasCount = 0,
    this.roomsCount = 0,
  });
}

class LegacyOrganizationMappingResult {
  final String? organizationId;
  final bool organizationMissing;
  final Map<String, int> updatedCounts;

  const LegacyOrganizationMappingResult({
    this.organizationId,
    this.organizationMissing = false,
    this.updatedCounts = const {},
  });

  int get totalUpdated =>
      updatedCounts.values.fold(0, (total, count) => total + count);
}

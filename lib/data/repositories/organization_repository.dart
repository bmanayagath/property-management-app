import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../core/constants/default_organization.dart';
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
    await _requireCollection().doc(orgId).set(
      {
        'isActive': false,
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

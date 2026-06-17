import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../domain/models/villa_model.dart';
import '../../domain/repositories/villa_repository.dart';
import '../local/database.dart';

class VillaRepositoryImpl implements VillaRepository {
  final AppDatabase database;
  final String orgId;

  VillaRepositoryImpl(this.database, {required this.orgId});

  @override
  Future<List<VillaModel>> getAllVillas() async {
    final villas = await database.getAllVillas(orgId: orgId);
    return villas.map((villa) => _mapToModel(villa)).toList();
  }

  @override
  Stream<List<VillaModel>> watchVillas() {
    return database.watchAllVillas(orgId: orgId).map(
          (villas) => villas.map(_mapToModel).toList(),
        );
  }

  @override
  Stream<List<VillaModel>> watchActiveVillas() => watchVillas();

  @override
  Stream<List<VillaModel>> watchAllVillas() => watchVillas();

  @override
  Future<VillaModel?> getVillaById(String id) async {
    final villa = await database.getVillaById(id);
    return villa != null ? _mapToModel(villa) : null;
  }

  @override
  Future<String> addVilla(VillaModel villa) async {
    final id = villa.id.isEmpty ? const Uuid().v4() : villa.id;
    final now = DateTime.now();
    await database.insertVilla(
      VillasCompanion(
        id: Value(id),
        orgId: Value(orgId),
        villaName: Value(villa.villaName),
        villaNumber: Value(villa.villaNumber),
        location: Value(villa.location),
        notes: Value(villa.notes),
        latitude: Value(villa.latitude),
        longitude: Value(villa.longitude),
        mapAddress: Value(villa.mapAddress),
        googleMapsUrl: Value(villa.googleMapsUrl),
        wazeUrl: Value(villa.wazeUrl),
        tenantName: const Value(''),
        tenantPhone: const Value(''),
        monthlyRent: const Value(0),
        contractStartDate: Value(now),
        contractEndDate: Value(now),
        paymentDueDay: const Value(1),
        status: const Value('vacant'),
        createdAt: Value(now),
        updatedAt: Value(now),
        isDeleted: const Value(0),
        syncStatus: const Value('pending'),
      ),
    );
    return id;
  }

  @override
  Future<void> updateVilla(VillaModel villa) async {
    await database.updateVilla(
      VillasCompanion(
        id: Value(villa.id),
        orgId: Value(orgId),
        villaName: Value(villa.villaName),
        villaNumber: Value(villa.villaNumber),
        location: Value(villa.location),
        notes: Value(villa.notes),
        latitude: Value(villa.latitude),
        longitude: Value(villa.longitude),
        mapAddress: Value(villa.mapAddress),
        googleMapsUrl: Value(villa.googleMapsUrl),
        wazeUrl: Value(villa.wazeUrl),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  @override
  Future<void> deleteVilla(String id, {String? deletedBy}) async {
    await database.deleteVilla(id, deletedBy: deletedBy);
  }

  @override
  Future<void> deleteVillaCascade(
    String villaId,
    String currentUserId,
  ) async {
    await database.deleteVillaCascade(villaId, currentUserId);
  }

  VillaModel _mapToModel(Villa villa) {
    return VillaModel(
      id: villa.id,
      orgId: villa.orgId,
      villaName: villa.villaName,
      villaNumber: villa.villaNumber,
      location: villa.location,
      notes: villa.notes,
      createdAt: villa.createdAt,
      updatedAt: villa.updatedAt,
      isDeleted: villa.isDeleted == 1,
      syncStatus: villa.syncStatus,
      deletedAt: villa.deletedAt,
      deletedBy: villa.deletedBy,
      createdBy: villa.createdBy,
      updatedBy: villa.updatedBy,
      lastSyncedAt: villa.lastSyncedAt,
      latitude: villa.latitude,
      longitude: villa.longitude,
      mapAddress: villa.mapAddress,
      googleMapsUrl: villa.googleMapsUrl,
      wazeUrl: villa.wazeUrl,
    );
  }
}

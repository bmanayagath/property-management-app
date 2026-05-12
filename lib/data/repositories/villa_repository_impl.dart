import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../domain/models/villa_model.dart';
import '../../domain/repositories/villa_repository.dart';
import '../local/database.dart';

class VillaRepositoryImpl implements VillaRepository {
  final AppDatabase database;

  VillaRepositoryImpl(this.database);

  @override
  Future<List<VillaModel>> getAllVillas() async {
    final villas = await database.getAllVillas();
    return villas.map((villa) => _mapToModel(villa)).toList();
  }

  @override
  Stream<List<VillaModel>> watchVillas() {
    return database.watchAllVillas().map(
          (villas) => villas.map(_mapToModel).toList(),
        );
  }

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
        villaName: Value(villa.villaName),
        villaNumber: Value(villa.villaNumber),
        location: Value(villa.location),
        notes: Value(villa.notes),
        tenantName: const Value(''),
        tenantPhone: const Value(''),
        monthlyRent: const Value(0),
        contractStartDate: Value(now),
        contractEndDate: Value(now),
        paymentDueDay: const Value(1),
        status: const Value('vacant'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    return id;
  }

  @override
  Future<void> updateVilla(VillaModel villa) async {
    await database.updateVilla(
      VillasCompanion(
        id: Value(villa.id),
        villaName: Value(villa.villaName),
        villaNumber: Value(villa.villaNumber),
        location: Value(villa.location),
        notes: Value(villa.notes),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteVilla(String id, {String? deletedBy}) async {
    await database.deleteVilla(id, deletedBy: deletedBy);
  }

  VillaModel _mapToModel(Villa villa) {
    return VillaModel(
      id: villa.id,
      villaName: villa.villaName,
      villaNumber: villa.villaNumber,
      location: villa.location,
      notes: villa.notes,
      createdAt: villa.createdAt,
      updatedAt: villa.updatedAt,
    );
  }
}

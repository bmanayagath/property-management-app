import '../models/villa_model.dart';

abstract class VillaRepository {
  Future<List<VillaModel>> getAllVillas();
  Stream<List<VillaModel>> watchVillas();
  Stream<List<VillaModel>> watchAllVillas();
  Future<VillaModel?> getVillaById(String id);
  Future<String> addVilla(VillaModel villa);
  Future<void> updateVilla(VillaModel villa);
  Future<void> deleteVilla(String id, {String? deletedBy});
}

import '../../domain/models/room.dart';
import '../../domain/models/villa_model.dart';

List<VillaModel> activeVillasOnly(List<VillaModel> villas) {
  return villas.where((villa) => !villa.isDeleted).toList();
}

Set<String> activeVillaIdsFor(List<VillaModel> villas) {
  return activeVillasOnly(villas).map((villa) => villa.id).toSet();
}

List<Room> activeRoomsForVillas({
  required List<Room> rooms,
  required List<VillaModel> villas,
}) {
  final activeVillaIds = activeVillaIdsFor(villas);
  return rooms
      .where((room) => !room.isDeleted && activeVillaIds.contains(room.villaId))
      .toList();
}

List<Room> activeRoomsForSelectedVilla({
  required List<Room> rooms,
  required List<VillaModel> villas,
  required String? selectedVillaId,
}) {
  if (selectedVillaId == null || selectedVillaId.isEmpty) return const [];
  return activeRoomsForVillas(rooms: rooms, villas: villas)
      .where((room) => room.villaId == selectedVillaId)
      .toList();
}

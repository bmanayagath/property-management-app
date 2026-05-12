import '../models/room.dart';

abstract class RoomRepository {
  Future<List<Room>> getAllRooms();
  Stream<List<Room>> watchRooms();
  Stream<List<Room>> watchActiveRooms();
  Stream<List<Room>> watchAllRooms();
  Future<Room?> getRoomById(String id);
  Future<List<Room>> getRoomsByVillaId(String villaId);
  Stream<List<Room>> watchRoomsByVillaId(String villaId);
  Future<List<Room>> getOccupiedRooms();
  Future<List<Room>> getVacantRooms();
  Future<String> addRoom(Room room);
  Future<void> updateRoom(Room room);
  Future<void> deleteRoom(String id, {String? deletedBy});
  Future<double> getTotalExpectedRentForVilla(String villaId);
  Future<double> getTotalExpectedRentForAllVillas();
}

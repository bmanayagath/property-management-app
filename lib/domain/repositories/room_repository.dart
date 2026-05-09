import '../models/room.dart';

abstract class RoomRepository {
  Future<List<Room>> getAllRooms();
  Future<Room?> getRoomById(String id);
  Future<List<Room>> getRoomsByVillaId(String villaId);
  Stream<List<Room>> watchRoomsByVillaId(String villaId);
  Future<List<Room>> getOccupiedRooms();
  Future<List<Room>> getVacantRooms();
  Future<String> addRoom(Room room);
  Future<void> updateRoom(Room room);
  Future<void> deleteRoom(String id);
  Future<double> getTotalExpectedRentForVilla(String villaId);
  Future<double> getTotalExpectedRentForAllVillas();
}

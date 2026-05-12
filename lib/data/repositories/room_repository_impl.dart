import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../domain/models/room.dart';
import '../../domain/repositories/room_repository.dart';
import '../local/database.dart' as db;

class RoomRepositoryImpl implements RoomRepository {
  final db.AppDatabase database;

  RoomRepositoryImpl(this.database);

  @override
  Future<List<Room>> getAllRooms() async {
    final rooms = await database.getAllRooms();
    return rooms.map(_mapToModel).toList();
  }

  @override
  Stream<List<Room>> watchRooms() {
    return database.watchAllRooms().map(
          (rooms) => rooms.map(_mapToModel).toList(),
        );
  }

  @override
  Stream<List<Room>> watchActiveRooms() => watchRooms();

  @override
  Stream<List<Room>> watchAllRooms() => watchRooms();

  @override
  Future<Room?> getRoomById(String id) async {
    final room = await database.getRoomById(id);
    return room == null ? null : _mapToModel(room);
  }

  @override
  Future<List<Room>> getRoomsByVillaId(String villaId) async {
    final rooms = await database.getRoomsByVillaId(villaId);
    return rooms.map(_mapToModel).toList();
  }

  @override
  Stream<List<Room>> watchRoomsByVillaId(String villaId) =>
      database.watchRoomsByVillaId(villaId).map(
            (rooms) => rooms.map(_mapToModel).toList(),
          );

  @override
  Future<List<Room>> getOccupiedRooms() async {
    final allRooms = await getAllRooms();
    return allRooms.where((room) => room.isOccupied).toList();
  }

  @override
  Future<List<Room>> getVacantRooms() async {
    final allRooms = await getAllRooms();
    return allRooms.where((room) => room.isVacant).toList();
  }

  @override
  Future<String> addRoom(Room room) async {
    final id = room.id.isEmpty ? const Uuid().v4() : room.id;
    final now = DateTime.now();

    await database.insertRoom(
      db.RoomsCompanion(
        id: Value(id),
        villaId: Value(room.villaId),
        villaName: Value(room.villaName),
        roomName: Value(room.roomName),
        roomNumber: Value(room.roomNumber),
        tenantName: Value(room.tenantName.isEmpty ? null : room.tenantName),
        tenantPhone: Value(room.tenantPhone.isEmpty ? null : room.tenantPhone),
        monthlyRent: Value(room.monthlyRent),
        contractStartDate: Value(room.contractStartDate),
        contractEndDate: Value(room.contractEndDate),
        paymentDueDay: Value(room.paymentDueDay),
        status: Value(room.status),
        createdAt: Value(room.createdAt.isAtSameMomentAs(DateTime(1970))
            ? now
            : room.createdAt),
        updatedAt: Value(now),
        isDeleted: const Value(0),
        syncStatus: const Value('pending'),
      ),
    );

    return id;
  }

  @override
  Future<void> updateRoom(Room room) async {
    final now = DateTime.now();

    await database.updateRoom(
      db.RoomsCompanion(
        id: Value(room.id),
        villaId: Value(room.villaId),
        villaName: Value(room.villaName),
        roomName: Value(room.roomName),
        roomNumber: Value(room.roomNumber),
        tenantName: Value(room.tenantName.isEmpty ? null : room.tenantName),
        tenantPhone: Value(room.tenantPhone.isEmpty ? null : room.tenantPhone),
        monthlyRent: Value(room.monthlyRent),
        contractStartDate: Value(room.contractStartDate),
        contractEndDate: Value(room.contractEndDate),
        paymentDueDay: Value(room.paymentDueDay),
        status: Value(room.status),
        createdAt: Value(room.createdAt),
        updatedAt: Value(now),
        syncStatus: const Value('pending'),
      ),
    );
  }

  @override
  Future<void> deleteRoom(String id, {String? deletedBy}) =>
      database.deleteRoom(id, deletedBy: deletedBy);

  @override
  Future<double> getTotalExpectedRentForVilla(String villaId) async {
    final rooms = await database.getRoomsByVillaId(villaId);
    return rooms
        .map(_mapToModel)
        .where((room) => room.isOccupied)
        .fold<double>(0, (sum, room) => sum + room.monthlyRent);
  }

  @override
  Future<double> getTotalExpectedRentForAllVillas() async {
    final rooms = await database.getAllRooms();
    return rooms
        .map(_mapToModel)
        .where((room) => room.isOccupied)
        .fold<double>(0, (sum, room) => sum + room.monthlyRent);
  }

  Room _mapToModel(db.Room room) {
    return Room(
      id: room.id,
      villaId: room.villaId,
      villaName: room.villaName,
      roomName: room.roomName,
      roomNumber: room.roomNumber,
      tenantName: room.tenantName ?? '',
      tenantPhone: room.tenantPhone ?? '',
      monthlyRent: room.monthlyRent,
      contractStartDate: room.contractStartDate,
      contractEndDate: room.contractEndDate,
      paymentDueDay: room.paymentDueDay,
      status: room.status,
      createdAt: room.createdAt,
      updatedAt: room.updatedAt,
      isDeleted: room.isDeleted == 1,
      syncStatus: room.syncStatus,
      deletedAt: room.deletedAt,
      deletedBy: room.deletedBy,
      createdBy: room.createdBy,
      updatedBy: room.updatedBy,
      lastSyncedAt: room.lastSyncedAt,
    );
  }
}

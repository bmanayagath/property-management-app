import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/room.dart';
import 'auth_provider.dart';
import 'repository_provider.dart';
import 'sync_provider.dart';

final allRoomsProvider = StreamProvider<List<Room>>((ref) {
  final repository = ref.watch(roomRepositoryProvider);
  return repository.watchAllRooms();
});

final roomByIdProvider = FutureProvider.family<Room?, String>((ref, id) async {
  final repository = ref.watch(roomRepositoryProvider);
  return repository.getRoomById(id);
});

final roomsByVillaProvider =
    FutureProvider.family<List<Room>, String>((ref, villaId) async {
  final repository = ref.watch(roomRepositoryProvider);
  return repository.getRoomsByVillaId(villaId);
});

final watchRoomsByVillaProvider =
    StreamProvider.family<List<Room>, String>((ref, villaId) {
  final repository = ref.watch(roomRepositoryProvider);
  return repository.watchRoomsByVillaId(villaId);
});

final occupiedRoomsProvider = FutureProvider<List<Room>>((ref) async {
  final repository = ref.watch(roomRepositoryProvider);
  return repository.getOccupiedRooms();
});

final vacantRoomsProvider = FutureProvider<List<Room>>((ref) async {
  final repository = ref.watch(roomRepositoryProvider);
  return repository.getVacantRooms();
});

final totalExpectedRentForVillaProvider =
    FutureProvider.family<double, String>((ref, villaId) async {
  final repository = ref.watch(roomRepositoryProvider);
  return repository.getTotalExpectedRentForVilla(villaId);
});

final totalExpectedRentProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(roomRepositoryProvider);
  return repository.getTotalExpectedRentForAllVillas();
});

final addRoomProvider = FutureProvider.family<String, Room>((ref, room) async {
  final repository = ref.watch(roomRepositoryProvider);
  final id = await repository.addRoom(room);
  final currentUser = ref.read(authProvider).currentUser;
  if (currentUser != null) {
    await ref.read(firebaseSyncServiceProvider).queueRoom(
          room: room.copyWith(id: id),
          userId: currentUser.id,
        );
    ref.read(syncRefreshProvider.notifier).state++;
  }
  ref.invalidate(allRoomsProvider);
  ref.invalidate(roomsByVillaProvider(room.villaId));
  ref.invalidate(occupiedRoomsProvider);
  ref.invalidate(vacantRoomsProvider);
  ref.invalidate(totalExpectedRentProvider);
  return id;
});

final updateRoomProvider = FutureProvider.family<void, Room>((ref, room) async {
  final repository = ref.watch(roomRepositoryProvider);
  await repository.updateRoom(room);
  final currentUser = ref.read(authProvider).currentUser;
  if (currentUser != null) {
    await ref.read(firebaseSyncServiceProvider).queueRoom(
          room: room,
          userId: currentUser.id,
        );
    ref.read(syncRefreshProvider.notifier).state++;
  }
  ref.invalidate(allRoomsProvider);
  ref.invalidate(roomsByVillaProvider(room.villaId));
  ref.invalidate(occupiedRoomsProvider);
  ref.invalidate(vacantRoomsProvider);
  ref.invalidate(totalExpectedRentProvider);
});

final deleteRoomProvider = FutureProvider.family<void, String>((ref, id) async {
  final repository = ref.watch(roomRepositoryProvider);
  final room = await repository.getRoomById(id);
  await repository.deleteRoom(id);
  final currentUser = ref.read(authProvider).currentUser;
  if (currentUser != null) {
    await ref.read(firebaseSyncServiceProvider).queueDelete(
          collection: 'rooms',
          id: id,
          userId: currentUser.id,
        );
    ref.read(syncRefreshProvider.notifier).state++;
  }
  ref.invalidate(allRoomsProvider);
  if (room != null) {
    ref.invalidate(roomsByVillaProvider(room.villaId));
  }
  ref.invalidate(occupiedRoomsProvider);
  ref.invalidate(vacantRoomsProvider);
  ref.invalidate(totalExpectedRentProvider);
});

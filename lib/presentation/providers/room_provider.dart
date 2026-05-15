import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/app_notification.dart';
import '../../domain/models/room.dart';
import '../../domain/models/villa_model.dart';
import 'active_data_helpers.dart';
import 'auth_provider.dart';
import 'dashboard_provider.dart';
import 'expense_provider.dart';
import 'income_provider.dart';
import 'notification_provider.dart';
import 'repository_provider.dart';
import 'sync_provider.dart';

List<Room> activeRoomsOnly({
  required List<Room> rooms,
  required List<VillaModel> villas,
}) {
  return activeRoomsForVillas(rooms: rooms, villas: villas);
}

final allRoomsProvider = StreamProvider<List<Room>>((ref) {
  final repository = ref.watch(roomRepositoryProvider);
  final syncService = ref.watch(firebaseSyncServiceProvider);
  return _mergeRoomStreams(
    localStream: repository.watchActiveRooms(),
    cloudStream: syncService.watchCloudRooms(),
  );
});

final roomListProvider = allRoomsProvider;
final activeRoomListProvider = roomListProvider;

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
  return repository.watchActiveRoomsByVilla(villaId);
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
    final syncedRoom = room.copyWith(id: id);
    await ref.read(firebaseSyncServiceProvider).queueRoom(
          room: syncedRoom,
          userId: currentUser.id,
        );
    await _createRoomNotification(
      ref,
      room: syncedRoom,
      type: NotificationTypes.roomAdded,
      title: 'Room added',
      body:
          '${_roomLabel(syncedRoom)} added to ${_villaLabel(syncedRoom)} by ${currentUser.username}',
    );
    ref.read(syncRefreshProvider.notifier).state++;
  }
  ref.invalidate(allRoomsProvider);
  ref.invalidate(roomListProvider);
  ref.invalidate(activeRoomListProvider);
  ref.invalidate(roomsByVillaProvider(room.villaId));
  ref.invalidate(watchRoomsByVillaProvider(room.villaId));
  ref.invalidate(dashboardSummaryProvider);
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
    await _createRoomNotification(
      ref,
      room: room,
      type: NotificationTypes.roomUpdated,
      title: 'Room updated',
      body:
          '${_roomLabel(room)} in ${_villaLabel(room)} was updated by ${currentUser.username}',
    );
    ref.read(syncRefreshProvider.notifier).state++;
  }
  ref.invalidate(allRoomsProvider);
  ref.invalidate(roomListProvider);
  ref.invalidate(activeRoomListProvider);
  ref.invalidate(roomsByVillaProvider(room.villaId));
  ref.invalidate(watchRoomsByVillaProvider(room.villaId));
  ref.invalidate(dashboardSummaryProvider);
  ref.invalidate(occupiedRoomsProvider);
  ref.invalidate(vacantRoomsProvider);
  ref.invalidate(totalExpectedRentProvider);
});

final deleteRoomProvider = FutureProvider.family<void, String>((ref, id) async {
  final repository = ref.watch(roomRepositoryProvider);
  final room = await repository.getRoomById(id);
  final currentUser = ref.read(authProvider).currentUser;
  if (currentUser == null) {
    await repository.deleteRoom(id);
  } else {
    await repository.deleteRoomCascade(id, currentUser.id);
  }
  if (currentUser != null) {
    await ref.read(firebaseSyncServiceProvider).syncPendingDeletes();
    if (room != null) {
      await _createRoomNotification(
        ref,
        room: room,
        type: NotificationTypes.roomDeleted,
        title: 'Room deleted',
        body:
            '${_roomLabel(room)} removed from ${_villaLabel(room)} by ${currentUser.username}',
      );
    }
    ref.read(syncRefreshProvider.notifier).state++;
  }
  ref.invalidate(allRoomsProvider);
  ref.invalidate(roomListProvider);
  ref.invalidate(activeRoomListProvider);
  if (room != null) {
    ref.invalidate(roomsByVillaProvider(room.villaId));
    ref.invalidate(watchRoomsByVillaProvider(room.villaId));
  }
  ref.invalidate(incomeListProvider);
  ref.invalidate(expenseListProvider);
  ref.invalidate(expenseProvider);
  ref.invalidate(dashboardSummaryProvider);
  ref.invalidate(occupiedRoomsProvider);
  ref.invalidate(vacantRoomsProvider);
  ref.invalidate(totalExpectedRentProvider);
});

Future<void> _createRoomNotification(
  Ref ref, {
  required Room room,
  required String type,
  required String title,
  required String body,
}) async {
  final authState = ref.read(authProvider);
  final currentUser = authState.currentUser;
  if (currentUser == null) return;

  final targetUserIds = authState.users
      .where((user) => user.id != currentUser.id)
      .map((user) => user.id)
      .toList();

  debugPrint('[Notifications] room change target user ids=$targetUserIds');
  if (targetUserIds.isEmpty) return;

  final notification = AppNotification(
    id: const Uuid().v4(),
    title: title,
    body: body,
    type: type,
    createdByUserId: currentUser.id,
    createdByUsername: currentUser.username,
    targetUserIds: targetUserIds,
    targetRole: null,
    createdAt: DateTime.now(),
    isReadMap: {
      for (final userId in targetUserIds) userId: false,
    },
  );

  await ref.read(notificationControllerProvider).createNotification(
        notification,
      );
  debugPrint('[Notifications] room notification created id=${notification.id}');
}

String _roomLabel(Room room) {
  return room.roomName.trim().isEmpty ? 'Room' : room.roomName.trim();
}

String _villaLabel(Room room) {
  return room.villaName.trim().isEmpty ? 'Villa' : room.villaName.trim();
}

Stream<List<Room>> _mergeRoomStreams({
  required Stream<List<Room>> localStream,
  required Stream<List<Room>> cloudStream,
}) {
  late StreamController<List<Room>> controller;
  StreamSubscription<List<Room>>? localSubscription;
  StreamSubscription<List<Room>>? cloudSubscription;
  var localRooms = <Room>[];
  var cloudRooms = <Room>[];

  void emitMerged() {
    final byId = <String, Room>{};
    for (final room in localRooms) {
      byId[room.id] = room;
    }
    for (final room in cloudRooms) {
      byId[room.id] = room;
    }

    final merged = byId.values.toList()
      ..sort((a, b) {
        final villaCompare = a.villaName.compareTo(b.villaName);
        if (villaCompare != 0) return villaCompare;
        return a.roomName.compareTo(b.roomName);
      });
    controller.add(merged);
    debugPrint(
      '[RoomProvider] loaded local=${localRooms.length}, cloud=${cloudRooms.length}, merged=${merged.length}',
    );
  }

  controller = StreamController<List<Room>>(
    onListen: () {
      localSubscription = localStream.listen(
        (rooms) {
          localRooms = rooms;
          emitMerged();
        },
        onError: controller.addError,
      );

      cloudSubscription = cloudStream.listen(
        (rooms) {
          cloudRooms = rooms;
          emitMerged();
        },
        onError: (error, stackTrace) {
          debugPrint('[RoomProvider] cloud room stream failed: $error');
          emitMerged();
        },
      );
    },
    onCancel: () async {
      await localSubscription?.cancel();
      await cloudSubscription?.cancel();
    },
  );

  return controller.stream;
}

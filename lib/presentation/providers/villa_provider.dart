import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/app_notification.dart';
import '../../domain/models/villa_model.dart';
import 'auth_provider.dart';
import 'dashboard_provider.dart';
import 'expense_provider.dart';
import 'income_provider.dart';
import 'notification_provider.dart';
import 'repository_provider.dart';
import 'room_provider.dart';
import 'sync_provider.dart';

final villasProvider = StreamProvider<List<VillaModel>>((ref) {
  final repository = ref.watch(villaRepositoryProvider);
  final syncService = ref.watch(firebaseSyncServiceProvider);
  return _mergeVillaStreams(
    localStream: repository.watchActiveVillas(),
    cloudStream: syncService.watchCloudVillas(),
  );
});

final villaListProvider = villasProvider;
final activeVillaListProvider = villaListProvider;

final villaByIdProvider =
    FutureProvider.family<VillaModel?, String>((ref, id) async {
  final repository = ref.watch(villaRepositoryProvider);
  return repository.getVillaById(id);
});

final addVillaProvider =
    FutureProvider.family<String, VillaModel>((ref, villa) async {
  final repository = ref.watch(villaRepositoryProvider);
  final id = await repository.addVilla(villa);
  final currentUser = ref.read(authProvider).currentUser;
  if (currentUser != null) {
    final syncedVilla = villa.copyWith(id: id);
    await ref.read(firebaseSyncServiceProvider).queueVilla(
          villa: syncedVilla,
          userId: currentUser.id,
        );
    await _createVillaNotification(
      ref,
      villa: syncedVilla,
      type: NotificationTypes.villaAdded,
      title: 'Villa added',
      body: '${_villaLabel(syncedVilla)} was added by ${currentUser.username}',
    );
    ref.read(syncRefreshProvider.notifier).state++;
  }
  ref.invalidate(villasProvider);
  ref.invalidate(villaListProvider);
  ref.invalidate(activeVillaListProvider);
  ref.invalidate(roomListProvider);
  ref.invalidate(activeRoomListProvider);
  ref.invalidate(dashboardSummaryProvider);
  return id;
});

final updateVillaProvider =
    FutureProvider.family<void, VillaModel>((ref, villa) async {
  final repository = ref.watch(villaRepositoryProvider);
  await repository.updateVilla(villa);
  final currentUser = ref.read(authProvider).currentUser;
  if (currentUser != null) {
    await ref.read(firebaseSyncServiceProvider).queueVilla(
          villa: villa,
          userId: currentUser.id,
        );
    await _createVillaNotification(
      ref,
      villa: villa,
      type: NotificationTypes.villaUpdated,
      title: 'Villa updated',
      body: '${_villaLabel(villa)} was updated by ${currentUser.username}',
    );
    ref.read(syncRefreshProvider.notifier).state++;
  }
  ref.invalidate(villasProvider);
  ref.invalidate(villaListProvider);
  ref.invalidate(activeVillaListProvider);
  ref.invalidate(allRoomsProvider);
  ref.invalidate(roomListProvider);
  ref.invalidate(activeRoomListProvider);
  ref.invalidate(incomeListProvider);
  ref.invalidate(expenseListProvider);
  ref.invalidate(dashboardSummaryProvider);
});

final deleteVillaProvider =
    FutureProvider.family<void, String>((ref, id) async {
  final repository = ref.watch(villaRepositoryProvider);
  final villa = await repository.getVillaById(id);
  final currentUser = ref.read(authProvider).currentUser;
  if (currentUser == null) {
    await repository.deleteVilla(id);
  } else {
    await repository.deleteVillaCascade(id, currentUser.id);
  }
  if (currentUser != null) {
    await ref.read(firebaseSyncServiceProvider).syncPendingDeletes();
    if (villa != null) {
      await _createVillaNotification(
        ref,
        villa: villa,
        type: NotificationTypes.villaDeleted,
        title: 'Villa deleted',
        body: '${_villaLabel(villa)} was removed by ${currentUser.username}',
      );
    }
    ref.read(syncRefreshProvider.notifier).state++;
  }
  ref.invalidate(villasProvider);
  ref.invalidate(villaListProvider);
  ref.invalidate(activeVillaListProvider);
  ref.invalidate(allRoomsProvider);
  ref.invalidate(roomListProvider);
  ref.invalidate(activeRoomListProvider);
  ref.invalidate(incomeListProvider);
  ref.invalidate(expenseListProvider);
  ref.invalidate(expenseProvider);
  ref.invalidate(dashboardSummaryProvider);
  ref.invalidate(occupiedRoomsProvider);
  ref.invalidate(vacantRoomsProvider);
  ref.invalidate(totalExpectedRentProvider);
});

Future<void> _createVillaNotification(
  Ref ref, {
  required VillaModel villa,
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

  debugPrint('[Notifications] villa change target user ids=$targetUserIds');
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
  debugPrint(
      '[Notifications] villa notification created id=${notification.id}');
}

String _villaLabel(VillaModel villa) {
  return villa.villaName.trim().isEmpty ? 'Villa' : villa.villaName.trim();
}

Stream<List<VillaModel>> _mergeVillaStreams({
  required Stream<List<VillaModel>> localStream,
  required Stream<List<VillaModel>> cloudStream,
}) {
  late StreamController<List<VillaModel>> controller;
  StreamSubscription<List<VillaModel>>? localSubscription;
  StreamSubscription<List<VillaModel>>? cloudSubscription;
  var localVillas = <VillaModel>[];
  var cloudVillas = <VillaModel>[];

  void emitMerged() {
    final byId = <String, VillaModel>{};
    for (final villa in localVillas) {
      byId[villa.id] = villa;
    }
    for (final villa in cloudVillas) {
      byId[villa.id] = villa;
    }

    final merged = byId.values.toList()
      ..sort((a, b) => a.villaName.compareTo(b.villaName));
    controller.add(merged);
    debugPrint(
      '[VillaProvider] loaded local=${localVillas.length}, cloud=${cloudVillas.length}, merged=${merged.length}',
    );
  }

  controller = StreamController<List<VillaModel>>(
    onListen: () {
      localSubscription = localStream.listen(
        (villas) {
          localVillas = villas;
          emitMerged();
        },
        onError: controller.addError,
      );

      cloudSubscription = cloudStream.listen(
        (villas) {
          cloudVillas = villas;
          emitMerged();
        },
        onError: (error, stackTrace) {
          debugPrint('[VillaProvider] cloud villa stream failed: $error');
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

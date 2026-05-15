import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/notification_service.dart';
import '../../domain/models/app_notification.dart';
import 'auth_provider.dart';
import 'sync_provider.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final userNotificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final currentUser = ref.watch(authProvider).currentUser;
  if (currentUser == null) return const Stream.empty();

  final service = ref.watch(notificationServiceProvider);
  final syncService = ref.watch(firebaseSyncServiceProvider);

  return _mergeNotificationStreams(
    localStream: service.watchNotificationsForUser(currentUser.id),
    cloudStream: syncService.watchCloudNotificationsForUser(currentUser.id),
  );
});

final unreadNotificationCountProvider = Provider<AsyncValue<int>>((ref) {
  final currentUser = ref.watch(authProvider).currentUser;
  if (currentUser == null) return const AsyncData(0);

  final notificationsAsync = ref.watch(userNotificationsProvider);
  return notificationsAsync.whenData((notifications) {
    return notifications
        .where((notification) => !notification.isReadBy(currentUser.id))
        .length;
  });
});

final notificationControllerProvider = Provider<NotificationController>((ref) {
  return NotificationController(ref);
});

class NotificationController {
  final Ref _ref;

  const NotificationController(this._ref);

  Future<void> createNotification(AppNotification notification) async {
    await _ref
        .read(notificationServiceProvider)
        .createNotification(notification);
    await _queueNotificationSync(notification);
    _ref.invalidate(userNotificationsProvider);
  }

  Future<void> markAsRead(String notificationId) async {
    final currentUser = _ref.read(authProvider).currentUser;
    if (currentUser == null) return;

    await _ref
        .read(notificationServiceProvider)
        .markAsRead(notificationId, currentUser.id);
    await _queueUpdatedNotification(notificationId);
    _ref.invalidate(userNotificationsProvider);
  }

  Future<void> markAllAsRead() async {
    final currentUser = _ref.read(authProvider).currentUser;
    if (currentUser == null) return;

    await _ref.read(notificationServiceProvider).markAllAsRead(currentUser.id);
    final notifications =
        _ref.read(userNotificationsProvider).valueOrNull ?? const [];
    for (final notification in notifications) {
      if (notification.targetUserIds.contains(currentUser.id)) {
        await _queueUpdatedNotification(notification.id);
      }
    }
    _ref.invalidate(userNotificationsProvider);
  }

  Future<void> _queueNotificationSync(AppNotification notification) async {
    final currentUser = _ref.read(authProvider).currentUser;
    if (currentUser == null) return;

    await _ref.read(firebaseSyncServiceProvider).queueNotification(
          notification: notification,
          userId: currentUser.id,
        );
    await _ref.read(firebaseSyncServiceProvider).syncPendingNotifications();
    _ref.read(syncRefreshProvider.notifier).state++;
    debugPrint('[Notifications] queued notification id=${notification.id}');
  }

  Future<void> _queueUpdatedNotification(String notificationId) async {
    final currentUser = _ref.read(authProvider).currentUser;
    if (currentUser == null) return;

    final notification = await _ref
        .read(notificationServiceProvider)
        .getNotificationById(notificationId);
    if (notification == null) return;

    await _queueNotificationSync(notification);
  }
}

Stream<List<AppNotification>> _mergeNotificationStreams({
  required Stream<List<AppNotification>> localStream,
  required Stream<List<AppNotification>> cloudStream,
}) {
  late StreamController<List<AppNotification>> controller;
  StreamSubscription<List<AppNotification>>? localSubscription;
  StreamSubscription<List<AppNotification>>? cloudSubscription;
  var localNotifications = <AppNotification>[];
  var cloudNotifications = <AppNotification>[];

  void emitMerged() {
    final byId = <String, AppNotification>{};
    for (final notification in localNotifications) {
      byId[notification.id] = notification;
    }
    for (final notification in cloudNotifications) {
      byId[notification.id] = notification;
    }

    final merged = byId.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    controller.add(merged);
    debugPrint(
      '[NotificationProvider] loaded local=${localNotifications.length}, cloud=${cloudNotifications.length}, merged=${merged.length}',
    );
  }

  controller = StreamController<List<AppNotification>>(
    onListen: () {
      localSubscription = localStream.listen(
        (notifications) {
          localNotifications = notifications;
          emitMerged();
        },
        onError: controller.addError,
      );

      cloudSubscription = cloudStream.listen(
        (notifications) {
          cloudNotifications = notifications;
          emitMerged();
        },
        onError: (error, stackTrace) {
          debugPrint(
            '[NotificationProvider] cloud notification stream failed: $error',
          );
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

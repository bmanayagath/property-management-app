import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/notification_card.dart';
import '../../widgets/premium_widgets.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider).currentUser;
    final notificationsAsync = ref.watch(userNotificationsProvider);
    final unreadCount =
        ref.watch(unreadNotificationCountProvider).valueOrNull ?? 0;
    final controller = ref.watch(notificationControllerProvider);

    return PremiumScaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: const [],
      ),
      body: currentUser == null
          ? const _EmptyNotifications()
          : notificationsAsync.when(
              data: (notifications) {
                final visibleNotifications = notifications
                    .where(
                        (item) => item.targetUserIds.contains(currentUser.id))
                    .toList();

                if (visibleNotifications.isEmpty) {
                  return const _EmptyNotifications();
                }

                return ListView(
                  padding: PremiumTokens.pagePadding,
                  children: [
                    PremiumPageHeader(
                      title: unreadCount == 0
                          ? 'Notifications'
                          : 'Notifications ($unreadCount)',
                      subtitle: 'Updates from activity across VillaBooks',
                      actions: [
                        if (unreadCount > 0)
                          PremiumButton(
                            onPressed: controller.markAllAsRead,
                            icon: Icons.done_all_rounded,
                            label: 'Mark all read',
                            filled: false,
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ...List.generate(visibleNotifications.length, (index) {
                      final notification = visibleNotifications[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: NotificationCard(
                          notification: notification,
                          currentUserId: currentUser.id,
                          onTap: () => controller.markAsRead(notification.id),
                        ),
                      );
                    }),
                  ],
                );
              },
              error: (error, _) => Center(child: Text(error.toString())),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: PremiumTokens.pagePadding,
      child: EmptyStateCard(
        icon: Icons.notifications_none_rounded,
        title: 'No notifications yet',
        subtitle:
            'Updates from income, expenses, villas, rent, and leases will appear here.',
      ),
    );
  }
}

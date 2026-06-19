import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_permissions.dart';
import '../../../core/constants/app_roles.dart';
import '../../../data/services/logger_service.dart';
import '../../../domain/models/app_user.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/destructive_action_dialog.dart';
import '../../widgets/premium_widgets.dart';
import '../common/access_denied_screen.dart';
import 'add_edit_user_screen.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (!authState.hasPermission(AppPermissions.manageUsers)) {
      return const AccessDeniedScreen();
    }

    final users = [...authState.users]
      ..sort((a, b) => a.username.compareTo(b.username));

    return PremiumScaffold(
      appBar: AppBar(
        title: const Text('Users'),
        elevation: 0,
      ),
      body: ListView.separated(
        padding: PremiumTokens.pagePadding,
        itemCount: users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final user = users[index];
          final isCurrentUser = user.id == authState.currentUser?.id;
          final isLastAdmin = user.role == AppRoles.admin &&
              authState.users
                      .where((item) => item.role == AppRoles.admin)
                      .length <=
                  1;

          return _UserTile(
            user: user,
            isCurrentUser: isCurrentUser,
            canDelete: !isCurrentUser && !isLastAdmin,
            onEdit: () => _openEditUser(context, user),
            onDelete: () => _confirmDelete(context, ref, user),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 88),
        child: FloatingActionButton.extended(
          heroTag: 'add-user-fab',
          onPressed: () => _openAddUser(context),
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Add User'),
        ),
      ),
    );
  }

  void _openAddUser(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditUserScreen(),
      ),
    );
  }

  void _openEditUser(BuildContext context, AppUser user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditUserScreen(user: user),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, AppUser user) {
    final authState = ref.read(authProvider);
    final isCurrentUser = user.id == authState.currentUser?.id;
    final isLastAdmin = user.role == AppRoles.admin &&
        authState.users.where((item) => item.role == AppRoles.admin).length <=
            1;

    if (isCurrentUser) {
      _showMessage(context, 'You cannot delete the logged-in user.');
      return;
    }

    if (isLastAdmin) {
      _showMessage(context, 'You cannot delete the last admin user.');
      return;
    }

    _disableUser(context, ref, user);
  }

  Future<void> _disableUser(
    BuildContext context,
    WidgetRef ref,
    AppUser user,
  ) async {
    final confirmed = await showDestructiveActionDialog(
      context: context,
      title: 'Disable User?',
      message: disableUserConfirmationMessage,
      confirmLabel: 'Disable User',
    );
    if (!confirmed) return;

    try {
      await ref.read(authProvider.notifier).deleteUser(user.id);
      await LoggerService.logInfo(
        screenName: 'UsersScreen',
        operation: 'DisableUser',
        message: 'User disabled.',
        details: 'userId: ${user.id}\nemail: ${user.username}',
      );
      if (!context.mounted) return;
      _showMessage(context, 'User disabled.');
    } catch (error, stackTrace) {
      await LoggerService.logError(
        screenName: 'UsersScreen',
        operation: 'DisableUser',
        message: 'User disable failed.',
        details: 'userId: ${user.id}\n$error',
        stackTrace: stackTrace.toString(),
      );
      if (!context.mounted) return;
      _showMessage(context, 'Unable to disable user.');
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _UserTile extends StatelessWidget {
  final AppUser user;
  final bool isCurrentUser;
  final bool canDelete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UserTile({
    required this.user,
    required this.isCurrentUser,
    required this.canDelete,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EAF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: _roleColor(user.role).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_rounded,
              color: _roleColor(user.role),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF060B26),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      const _CurrentUserChip(),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  user.role,
                  style: TextStyle(
                    color: _roleColor(user.role),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded),
            color: const Color(0xFF5549DE),
          ),
          IconButton(
            tooltip: 'Disable',
            onPressed: canDelete ? onDelete : null,
            icon: const Icon(Icons.delete_outline_rounded),
            color: const Color(0xFFF04438),
          ),
        ],
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case AppRoles.admin:
        return const Color(0xFF5549DE);
      case AppRoles.contributor:
        return const Color(0xFF12B76A);
      case AppRoles.reader:
      default:
        return const Color(0xFF667085);
    }
  }
}

class _CurrentUserChip extends StatelessWidget {
  const _CurrentUserChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'You',
        style: TextStyle(
          color: Color(0xFF2563EB),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

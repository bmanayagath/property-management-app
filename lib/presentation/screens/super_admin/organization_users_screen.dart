import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_roles.dart';
import '../../../data/services/logger_service.dart';
import '../../../domain/models/app_user.dart';
import '../../../domain/models/organization_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/destructive_action_dialog.dart';

class OrganizationUsersScreen extends ConsumerWidget {
  final OrganizationModel organization;

  const OrganizationUsersScreen({
    super.key,
    required this.organization,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final users = authState.users
        .where((user) => user.orgId == organization.id)
        .toList()
      ..sort((a, b) => a.username.compareTo(b.username));

    return Scaffold(
      appBar: AppBar(title: Text('${organization.name} Users')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateAdminDialog(context, ref),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Admin'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(authProvider.notifier).loadUsers(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person_rounded),
                ),
                title: Text(
                  user.displayName.trim().isEmpty
                      ? user.username
                      : user.displayName,
                ),
                subtitle: Text('${user.username} • ${user.role}'),
                trailing: user.isActive
                    ? IconButton(
                        tooltip: 'Disable',
                        icon: const Icon(Icons.block_rounded),
                        onPressed: () => _confirmDisableUser(
                          context,
                          ref,
                          user,
                        ),
                      )
                    : const Icon(Icons.block_rounded),
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: users.length,
          ),
        ),
      ),
    );
  }

  Future<void> _showCreateAdminDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final displayNameController = TextEditingController();
    final passwordController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Admin'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Email is required.'
                      : null,
                ),
                TextFormField(
                  controller: displayNameController,
                  decoration: const InputDecoration(labelText: 'Display name'),
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Temporary password'),
                  validator: (value) => value == null || value.length < 6
                      ? 'Use at least 6 characters.'
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final user = AppUser(
                  id: '',
                  username: emailController.text.trim().toLowerCase(),
                  displayName: displayNameController.text.trim(),
                  role: AppRoles.admin,
                  orgId: organization.id,
                  createdAt: DateTime.now(),
                  createdBy: ref.read(authProvider).currentUser?.id,
                );
                final created = await ref.read(authProvider.notifier).addUser(
                      user,
                      password: passwordController.text,
                    );
                if (created && context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    emailController.dispose();
    displayNameController.dispose();
    passwordController.dispose();
  }

  Future<void> _confirmDisableUser(
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
        screenName: 'OrganizationUsersScreen',
        operation: 'DisableUser',
        message: 'Organization user disabled.',
        details:
            'userId: ${user.id}\nemail: ${user.username}\norgId: ${organization.id}',
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User disabled.')),
      );
    } catch (error, stackTrace) {
      await LoggerService.logError(
        screenName: 'OrganizationUsersScreen',
        operation: 'DisableUser',
        message: 'Organization user disable failed.',
        details: 'userId: ${user.id}\n$error',
        stackTrace: stackTrace.toString(),
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to disable user.')),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_roles.dart';
import '../../../data/services/logger_service.dart';
import '../../../domain/models/app_user.dart';
import '../../../domain/models/organization_membership.dart';
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
    final membersAsync = ref.watch(organizationMembersProvider(
      organization.id,
    ));

    return Scaffold(
      appBar: AppBar(title: Text('${organization.name} Users')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateAdminDialog(context, ref),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Admin'),
      ),
      body: SafeArea(
        child: membersAsync.when(
          data: (members) => RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(organizationMembersProvider(organization.id));
              await ref.read(authProvider.notifier).loadUsers();
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final member = members[index];
                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person_rounded),
                  ),
                  title: Text(
                    member.displayName.trim().isEmpty
                        ? member.email
                        : member.displayName,
                  ),
                  subtitle: Text(
                    '${member.email} | ${member.role} | ${member.status}',
                  ),
                  trailing: _MemberActions(
                    member: member,
                    onApprove: member.status == MembershipStatus.pending &&
                            !member.uid.startsWith('pending_')
                        ? () => _approveMembership(context, ref, member)
                        : null,
                    onDisable: member.status == MembershipStatus.active
                        ? () => _confirmDisableMember(context, ref, member)
                        : null,
                  ),
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemCount: members.length,
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text(error.toString())),
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
                final message = ref.read(authProvider).infoMessage;
                if (context.mounted && message != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                }
                if (created && context.mounted) Navigator.of(context).pop();
                ref.invalidate(organizationMembersProvider(organization.id));
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

  Future<void> _approveMembership(
    BuildContext context,
    WidgetRef ref,
    OrganizationMembership member,
  ) async {
    try {
      await ref.read(authProvider.notifier).activateMembership(member);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Membership activated.')),
      );
    } catch (error, stackTrace) {
      await LoggerService.logError(
        screenName: 'OrganizationUsersScreen',
        operation: 'ActivateMembership',
        message: 'Membership activation failed.',
        details: 'uid: ${member.uid}\n$error',
        stackTrace: stackTrace.toString(),
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to activate membership.')),
      );
    }
  }

  Future<void> _confirmDisableMember(
    BuildContext context,
    WidgetRef ref,
    OrganizationMembership member,
  ) async {
    final confirmed = await showDestructiveActionDialog(
      context: context,
      title: 'Disable User?',
      message: disableUserConfirmationMessage,
      confirmLabel: 'Disable User',
    );
    if (!confirmed) return;

    try {
      await ref.read(authProvider.notifier).disableMembership(member);
      await LoggerService.logInfo(
        screenName: 'OrganizationUsersScreen',
        operation: 'DisableMembership',
        message: 'Organization membership disabled.',
        details:
            'uid: ${member.uid}\nemail: ${member.email}\norgId: ${organization.id}',
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User disabled.')),
      );
    } catch (error, stackTrace) {
      await LoggerService.logError(
        screenName: 'OrganizationUsersScreen',
        operation: 'DisableMembership',
        message: 'Organization membership disable failed.',
        details: 'uid: ${member.uid}\n$error',
        stackTrace: stackTrace.toString(),
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to disable user.')),
      );
    }
  }
}

class _MemberActions extends StatelessWidget {
  final OrganizationMembership member;
  final VoidCallback? onApprove;
  final VoidCallback? onDisable;

  const _MemberActions({
    required this.member,
    required this.onApprove,
    required this.onDisable,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: [
        if (onApprove != null)
          IconButton(
            tooltip: 'Approve',
            onPressed: onApprove,
            icon: const Icon(Icons.check_circle_rounded),
          ),
        if (onDisable != null)
          IconButton(
            tooltip: 'Disable',
            onPressed: onDisable,
            icon: const Icon(Icons.block_rounded),
          ),
        if (member.status == MembershipStatus.disabled)
          const Icon(Icons.block_rounded),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Variable;

import '../../../core/constants/app_permissions.dart';
import '../../../core/constants/app_roles.dart';
import '../../../domain/models/expense.dart';
import '../../../domain/models/income.dart';
import '../../providers/auth_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/sync_provider.dart';
import '../../widgets/premium_widgets.dart';
import 'developer_logs_screen.dart';
import 'legal_screen.dart';
import 'sync_status_widget.dart';
import 'users_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.currentUser;

    return PremiumScaffold(
      body: ListView(
        padding: PremiumTokens.pagePadding,
        children: [
          const PremiumPageHeader(
            title: 'Settings',
            subtitle: 'Account, permissions, sync, and app diagnostics',
          ),
          const SizedBox(height: 18),
          PremiumCard(
            child: Row(
              children: [
                Container(
                  height: 54,
                  width: 54,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF0FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Color(0xFF2563EB),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.username ?? 'Unknown user',
                        style: const TextStyle(
                          color: Color(0xFF060B26),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.role ?? 'No role',
                        style: const TextStyle(
                          color: Color(0xFF646B7A),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SettingsTile(
            icon: Icons.admin_panel_settings_outlined,
            title: 'Role',
            subtitle: user?.role ?? AppRoles.reader,
          ),
          const SizedBox(height: 10),
          _SettingsTile(
            icon: Icons.verified_user_outlined,
            title: 'Permissions',
            subtitle:
                '${user == null ? 0 : AppRoles.permissionsForRole(user.role).length} enabled',
          ),
          const SizedBox(height: 10),
          const SyncStatusWidget(),
          const SizedBox(height: 10),
          _SettingsActionTile(
            icon: Icons.cleaning_services_outlined,
            title: 'Cleanup Orphan Records',
            subtitle: 'Soft delete rooms without an active villa',
            onTap: () => _cleanupOrphanRecords(context, ref),
          ),
          if (authState.hasPermission(AppPermissions.manageSettings)) ...[
            const SizedBox(height: 10),
            _SettingsActionTile(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Remove Auto-created Deposit Income/Expense',
              subtitle: 'Soft delete generated deposit accounting records',
              onTap: () => _cleanupAutoDepositRecords(context, ref),
            ),
          ],
          if (authState.hasPermission(AppPermissions.manageUsers)) ...[
            const SizedBox(height: 10),
            _SettingsActionTile(
              icon: Icons.group_rounded,
              title: 'Manage Users',
              subtitle: 'Manage Firebase role profiles',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UsersScreen(),
                  ),
                );
              },
            ),
          ],
          if (user?.role == AppRoles.admin) ...[
            const SizedBox(height: 10),
            _SettingsActionTile(
              icon: Icons.terminal_outlined,
              title: 'Developer Logs',
              subtitle: 'View diagnostics, upload failures, and sync issues',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DeveloperLogsScreen(),
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 10),
          _SettingsActionTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Terms & Privacy',
            subtitle: 'Review app terms and privacy information',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LegalScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF04438),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cleanupOrphanRecords(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final count =
          await ref.read(syncControllerProvider).cleanupOrphanRecords();
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Cleanup complete: $count orphan room(s) deleted.'),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Cleanup failed: $error')),
      );
    }
  }

  Future<void> _cleanupAutoDepositRecords(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remove auto-created deposit records?'),
            content: const Text(
              'This will soft delete only generated Deposit income and Deposit Refund expense records. Manual records are left untouched.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Remove'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;

    final messenger = ScaffoldMessenger.of(context);
    final database = ref.read(databaseProvider);
    final now = DateTime.now();
    final currentUser = ref.read(authProvider).currentUser;
    try {
      final incomeCount = await database.customUpdate(
        '''
        UPDATE incomes
        SET is_deleted = 1,
            sync_status = 'pending',
            deleted_at = ?,
            deleted_by = ?,
            updated_at = ?,
            updated_by = ?
        WHERE is_deleted = 0
          AND LOWER(income_type) = LOWER(?)
          AND (
            LOWER(COALESCE(notes, '')) LIKE '%deposit collected%'
            OR LOWER(COALESCE(notes, '')) LIKE 'tenant deposit for%'
          )
        ''',
        variables: [
          Variable<DateTime>(now),
          Variable<String>(currentUser?.id),
          Variable<DateTime>(now),
          Variable<String>(currentUser?.id),
          Variable<String>(IncomeTypes.deposit),
        ],
        updates: {database.incomes},
      );
      final expenseCount = await database.customUpdate(
        '''
        UPDATE expenses
        SET is_deleted = 1,
            sync_status = 'pending',
            deleted_at = ?,
            deleted_by = ?,
            updated_at = ?,
            updated_by = ?
        WHERE is_deleted = 0
          AND LOWER(category) = LOWER(?)
          AND (
            LOWER(COALESCE(notes, '')) LIKE '%deposit refund%'
            OR LOWER(COALESCE(notes, '')) LIKE 'tenant deposit refund%'
          )
        ''',
        variables: [
          Variable<DateTime>(now),
          Variable<String>(currentUser?.id),
          Variable<DateTime>(now),
          Variable<String>(currentUser?.id),
          Variable<String>(ExpenseCategories.depositRefund),
        ],
        updates: {database.expenses},
      );
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Deposit cleanup complete: $incomeCount income and $expenseCount expense record(s) soft deleted.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Deposit cleanup failed: $error')),
      );
    }
  }
}

class _SettingsActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8EAF0)),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF5549DE)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF060B26),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF646B7A),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF98A2B3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAF0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF5549DE)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF060B26),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF646B7A),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

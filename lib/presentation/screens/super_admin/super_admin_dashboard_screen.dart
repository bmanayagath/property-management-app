import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/organization_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/organization_provider.dart';
import 'add_edit_organization_screen.dart';
import 'organization_users_screen.dart';

class SuperAdminDashboardScreen extends ConsumerStatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  ConsumerState<SuperAdminDashboardScreen> createState() =>
      _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState
    extends ConsumerState<SuperAdminDashboardScreen> {
  final _searchController = TextEditingController();
  String _statusFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final organizationsAsync = ref.watch(organizationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SuperAdmin'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add_business_rounded),
        label: const Text('Organization'),
      ),
      body: SafeArea(
        child: organizationsAsync.when(
          data: (organizations) {
            final filtered = _filterOrganizations(organizations);
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search organizations',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'all',
                        label: Text('All'),
                        icon: Icon(Icons.list_rounded),
                      ),
                      ButtonSegment(
                        value: 'active',
                        label: Text('Active'),
                        icon: Icon(Icons.verified_rounded),
                      ),
                      ButtonSegment(
                        value: 'inactive',
                        label: Text('Inactive'),
                        icon: Icon(Icons.block_rounded),
                      ),
                    ],
                    selected: {_statusFilter},
                    onSelectionChanged: (values) {
                      setState(() => _statusFilter = values.first);
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final organization = filtered[index];
                      return _OrganizationCard(
                        organization: organization,
                        onEdit: () => _openEditor(context, organization),
                        onToggleStatus: () => _toggleOrganization(organization),
                        onUsers: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => OrganizationUsersScreen(
                              organization: organization,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text(error.toString())),
        ),
      ),
    );
  }

  List<OrganizationModel> _filterOrganizations(
    List<OrganizationModel> organizations,
  ) {
    final query = _searchController.text.trim().toLowerCase();
    return organizations.where((organization) {
      if (_statusFilter == 'active' && !organization.isActive) return false;
      if (_statusFilter == 'inactive' && organization.isActive) return false;
      if (query.isEmpty) return true;
      return organization.name.toLowerCase().contains(query) ||
          organization.contactPerson.toLowerCase().contains(query) ||
          organization.contactEmail.toLowerCase().contains(query);
    }).toList();
  }

  void _openEditor(
    BuildContext context, [
    OrganizationModel? organization,
  ]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditOrganizationScreen(
          organization: organization,
        ),
      ),
    );
  }

  Future<void> _toggleOrganization(OrganizationModel organization) async {
    final currentUser = ref.read(authProvider).currentUser;
    if (currentUser == null) return;
    await ref.read(organizationRepositoryProvider).setOrganizationActive(
          orgId: organization.id,
          isActive: !organization.isActive,
          updatedBy: currentUser.id,
        );
  }
}

class _OrganizationCard extends ConsumerWidget {
  final OrganizationModel organization;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onUsers;

  const _OrganizationCard({
    required this.organization,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onUsers,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usage = ref.watch(organizationUsageProvider(organization.id));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    organization.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text(organization.isActive ? 'Active' : 'Inactive'),
                  avatar: Icon(
                    organization.isActive
                        ? Icons.verified_rounded
                        : Icons.block_rounded,
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(organization.contactPerson),
            Text(organization.contactEmail),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetricChip(
                  icon: Icons.people_rounded,
                  label: 'Users ${usage.valueOrNull?.usersCount ?? 0}',
                ),
                _MetricChip(
                  icon: Icons.home_rounded,
                  label: 'Villas ${usage.valueOrNull?.villasCount ?? 0}',
                ),
                _MetricChip(
                  icon: Icons.meeting_room_rounded,
                  label: 'Rooms ${usage.valueOrNull?.roomsCount ?? 0}',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  tooltip: 'Manage Users',
                  onPressed: onUsers,
                  icon: const Icon(Icons.group_rounded),
                ),
                IconButton(
                  tooltip: 'Edit',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded),
                ),
                IconButton(
                  tooltip: organization.isActive ? 'Disable' : 'Enable',
                  onPressed: onToggleStatus,
                  icon: Icon(
                    organization.isActive
                        ? Icons.block_rounded
                        : Icons.check_circle_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

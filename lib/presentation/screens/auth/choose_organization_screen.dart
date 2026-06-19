import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';

class ChooseOrganizationScreen extends ConsumerWidget {
  const ChooseOrganizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final memberships = authState.activeMemberships;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Organization'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: memberships.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final membership = memberships[index];
            return ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.business_rounded),
              ),
              title: Text(membership.orgId),
              subtitle: Text(membership.role),
              onTap: () => ref
                  .read(authProvider.notifier)
                  .chooseOrganization(membership.orgId),
            );
          },
        ),
      ),
    );
  }
}

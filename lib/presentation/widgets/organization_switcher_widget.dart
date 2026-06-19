import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/active_org_provider.dart';
import '../providers/organization_provider.dart';

class OrganizationSwitcherWidget extends ConsumerWidget {
  const OrganizationSwitcherWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizationsAsync = ref.watch(organizationsProvider);
    final selectedOrgId = ref.watch(activeOrgProvider);

    return organizationsAsync.when(
      data: (organizations) {
        final active = organizations.where((org) => org.isActive).toList();
        return DropdownButtonFormField<String>(
          initialValue: active.any((org) => org.id == selectedOrgId)
              ? selectedOrgId
              : null,
          decoration: const InputDecoration(
            labelText: 'Organization',
            prefixIcon: Icon(Icons.business_rounded),
          ),
          items: [
            for (final organization in active)
              DropdownMenuItem(
                value: organization.id,
                child: Text(organization.name),
              ),
          ],
          onChanged: null,
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, _) => Text('Organizations unavailable: $error'),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/organization_repository.dart';
import '../../domain/models/organization_model.dart';

final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  return OrganizationRepository();
});

final organizationsProvider = StreamProvider<List<OrganizationModel>>((ref) {
  return ref.watch(organizationRepositoryProvider).watchOrganizations();
});

final organizationUsageProvider =
    FutureProvider.family<OrganizationUsageSummary, String>((ref, orgId) {
  return ref.watch(organizationRepositoryProvider).fetchUsageSummary(orgId);
});

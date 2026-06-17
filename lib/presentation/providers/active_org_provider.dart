import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_roles.dart';
import '../../core/constants/default_organization.dart';
import 'auth_provider.dart';

final selectedOrgProvider = StateProvider<String?>((ref) => null);

final activeOrgProvider = Provider<String>((ref) {
  final currentUser = ref.watch(authProvider).currentUser;
  if (currentUser == null) return DefaultOrganization.id;
  if (currentUser.role == AppRoles.superAdmin) {
    return ref.watch(selectedOrgProvider) ?? DefaultOrganization.id;
  }
  return currentUser.orgId ?? DefaultOrganization.id;
});

final hasSelectedSuperAdminOrgProvider = Provider<bool>((ref) {
  final currentUser = ref.watch(authProvider).currentUser;
  if (currentUser?.role != AppRoles.superAdmin) return true;
  return ref.watch(selectedOrgProvider) != null;
});

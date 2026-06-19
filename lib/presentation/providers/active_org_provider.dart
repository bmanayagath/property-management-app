import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/default_organization.dart';
import 'auth_provider.dart';

final activeOrgProvider = Provider<String>((ref) {
  final currentUser = ref.watch(authProvider).currentUser;
  if (currentUser == null) return DefaultOrganization.id;
  return currentUser.orgId ?? DefaultOrganization.id;
});

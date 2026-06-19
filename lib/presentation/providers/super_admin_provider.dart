import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_roles.dart';
import '../../data/repositories/cleanup_repository.dart';
import 'auth_provider.dart';

final cleanupRepositoryProvider = Provider<CleanupRepository>((ref) {
  return CleanupRepository();
});

final superAdminToolsProvider = Provider<SuperAdminTools>((ref) {
  return SuperAdminTools(ref);
});

class SuperAdminTools {
  final Ref _ref;

  const SuperAdminTools(this._ref);

  Future<DeletedRecordsCleanupResult> hardDeleteDeletedRecords() async {
    final currentUser = _ref.read(authProvider).currentUser;
    if (currentUser?.role != AppRoles.superAdmin) {
      throw StateError('Only SuperAdmin can hard delete deleted records.');
    }

    return _ref.read(cleanupRepositoryProvider).hardDeleteDeletedRecords(
          deletedBy: currentUser!.id,
        );
  }
}

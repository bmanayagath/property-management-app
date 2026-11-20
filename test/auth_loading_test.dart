import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:villabooks/core/constants/app_roles.dart';
import 'package:villabooks/core/startup/startup_status.dart';
import 'package:villabooks/data/services/auth_service.dart';
import 'package:villabooks/data/services/firebase_sync_service.dart';
import 'package:villabooks/domain/models/app_user.dart';
import 'package:villabooks/presentation/providers/auth_provider.dart';
import 'package:villabooks/presentation/providers/sync_provider.dart';

class _UnusedAuth implements firebase_auth.FirebaseAuth {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedFirestore implements FirebaseFirestore {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SlowUserService extends AuthService {
  _SlowUserService()
      : super(firebaseAuth: _UnusedAuth(), firestore: _UnusedFirestore());

  final users = Completer<List<AppUser>>();
  String? requestedOrgId;
  final user = AppUser(
    id: 'admin',
    username: 'admin@example.com',
    role: AppRoles.superAdmin,
    orgId: 'existing-villas',
    createdAt: DateTime(2026),
  );

  @override
  Stream<firebase_auth.User?> authStateChanges() => const Stream.empty();

  @override
  Future<AuthSession> login(
          {required String email, required String password}) async =>
      AuthSession(user: user, activeMemberships: const []);

  @override
  Future<AuthSession?> getCurrentSession() async =>
      AuthSession(user: user, activeMemberships: const []);

  @override
  Future<List<AppUser>> fetchUsersForOrg(String orgId) {
    requestedOrgId = orgId;
    return users.future;
  }
}

class _SlowSyncService extends FirebaseSyncService {
  final pull = Completer<void>();
  String? requestedOrgId;
  int pullCount = 0;

  @override
  Future<void> initialPullFromFirestore({String? orgId}) {
    requestedOrgId = orgId;
    pullCount++;
    return pull.future;
  }
}

void main() {
  late _SlowUserService service;
  late _SlowSyncService sync;
  late ProviderContainer container;

  setUp(() {
    service = _SlowUserService();
    sync = _SlowSyncService();
    container = ProviderContainer(overrides: [
      authServiceProvider.overrideWithValue(service),
      firebaseSyncServiceProvider.overrideWithValue(sync),
      startupStatusProvider.overrideWithValue(
        const StartupStatus(firebaseInitialized: true),
      ),
    ]);
  });
  tearDown(() => container.dispose());

  test('sign-in opens the app before the organization user list arrives',
      () async {
    final notifier = container.read(authProvider.notifier);
    expect(await notifier.login('admin@example.com', 'password'), isTrue);
    expect(container.read(authProvider).isLoading, isFalse);
    expect(container.read(authProvider).currentUser, service.user);
    expect(service.users.isCompleted, isFalse);
    expect(service.requestedOrgId, 'existing-villas');
    expect(sync.requestedOrgId, 'existing-villas');
    expect(sync.pull.isCompleted, isFalse);

    service.users.complete([service.user]);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(authProvider).users, [service.user]);
    sync.pull.complete();
    await Future<void>.delayed(Duration.zero);
    expect(container.read(syncRefreshProvider), 1);
  });

  test('restoring a session also avoids waiting for users', () async {
    await container.read(authProvider.notifier).loadSession();
    expect(container.read(authProvider).isLoggedIn, isTrue);
    expect(container.read(authProvider).isLoading, isFalse);
    expect(service.users.isCompleted, isFalse);
    expect(sync.requestedOrgId, 'existing-villas');
    // Duplicate auth notifications should not start another initial pull.
    await container.read(authProvider.notifier).loadSession();
    expect(sync.pullCount, 1);
    sync.pull.completeError(StateError('Cloud temporarily unavailable'));
    service.users.completeError(StateError('User list unavailable'));
    await Future<void>.delayed(Duration.zero);
    expect(container.read(authProvider).isLoggedIn, isTrue);
  });

  test('a user list arriving after disposal is ignored', () async {
    await container
        .read(authProvider.notifier)
        .login('admin@example.com', 'password');
    container.dispose();
    service.users.complete([service.user]);
    sync.pull.complete();
    await Future<void>.delayed(Duration.zero);
  });
}

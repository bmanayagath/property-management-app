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
  final authEvents = StreamController<firebase_auth.User?>.broadcast();
  Completer<AuthSession?>? sessionRestore;
  Completer<AuthSession>? loginResult;
  int sessionLoads = 0;
  String? requestedOrgId;
  final user = AppUser(
    id: 'admin',
    username: 'admin@example.com',
    role: AppRoles.superAdmin,
    orgId: 'existing-villas',
    createdAt: DateTime(2026),
  );

  @override
  Stream<firebase_auth.User?> authStateChanges() => authEvents.stream;

  @override
  Future<AuthSession> login(
          {required String email, required String password}) =>
      loginResult?.future ??
      Future.value(AuthSession(user: user, activeMemberships: const []));

  @override
  Future<AuthSession?> getCurrentSession() {
    sessionLoads++;
    return sessionRestore?.future ??
        Future.value(AuthSession(user: user, activeMemberships: const []));
  }

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
  tearDown(() async {
    container.dispose();
    await service.authEvents.close();
  });

  test('a stale restore failure cannot replace a successful login', () async {
    service.sessionRestore = Completer<AuthSession?>();
    final notifier = container.read(authProvider.notifier);
    final restoring = notifier.loadSession();
    expect(await notifier.login('admin@example.com', 'password'), isTrue);
    service.sessionRestore!.completeError(StateError('Old restore failed'));
    await restoring;
    expect(container.read(authProvider).currentUser, service.user);
    expect(container.read(authProvider).errorMessage, isNull);
  });

  test('a stale signed-out result cannot replace a successful login', () async {
    service.sessionRestore = Completer<AuthSession?>();
    final notifier = container.read(authProvider.notifier);
    final restoring = notifier.loadSession();
    expect(await notifier.login('admin@example.com', 'password'), isTrue);
    service.sessionRestore!.complete(null);
    await restoring;
    expect(container.read(authProvider).isLoggedIn, isTrue);
  });

  test('auth events do not load a second session during explicit login',
      () async {
    service.loginResult = Completer<AuthSession>();
    final loggingIn = container
        .read(authProvider.notifier)
        .login('admin@example.com', 'password');
    service.authEvents.add(null);
    await Future<void>.delayed(Duration.zero);
    expect(service.sessionLoads, 0);
    service.loginResult!
        .complete(AuthSession(user: service.user, activeMemberships: const []));
    expect(await loggingIn, isTrue);
  });

  test('restoring a session preserves the Firestore error code and details',
      () async {
    service.sessionRestore = Completer<AuthSession?>();
    final restoring = container.read(authProvider.notifier).loadSession();
    service.sessionRestore!.completeError(AuthService.firestoreAuthException(
      FirebaseException(
          plugin: 'cloud_firestore',
          code: 'failed-precondition',
          message: 'The query requires an index.'),
      permissionDenied: 'Access denied.',
    ));
    await restoring;
    final state = container.read(authProvider);
    expect(state.isLoggedIn, isFalse);
    expect(state.errorMessage, contains('failed-precondition'));
    expect(state.errorMessage, contains('The query requires an index.'));
    expect(state.errorMessage, contains('configuration update'));
  });

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

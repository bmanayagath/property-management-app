import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_permissions.dart';
import '../../core/constants/app_roles.dart';
import '../../core/startup/startup_status.dart';
import '../../data/services/auth_service.dart';
import '../../domain/models/app_user.dart';
import 'dashboard_provider.dart';
import 'expense_provider.dart';
import 'income_provider.dart';
import 'notification_provider.dart';
import 'room_media_provider.dart';
import 'room_provider.dart';
import 'sync_provider.dart';
import 'villa_provider.dart';

final authServiceProvider = Provider<AuthService?>((ref) {
  final startupStatus = ref.watch(startupStatusProvider);
  if (!startupStatus.firebaseInitialized || Firebase.apps.isEmpty) {
    return null;
  }
  return AuthService(
    firebaseSyncService: ref.read(firebaseSyncServiceProvider),
  );
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref: ref,
    service: ref.watch(authServiceProvider),
    startupStatus: ref.watch(startupStatusProvider),
  );
});

class AuthState {
  final bool isLoading;
  final AppUser? currentUser;
  final List<AppUser> users;
  final String? errorMessage;

  const AuthState({
    required this.isLoading,
    required this.users,
    this.currentUser,
    this.errorMessage,
  });

  const AuthState.loading({
    List<AppUser> users = const [],
    AppUser? currentUser,
  }) : this(
          isLoading: true,
          users: users,
          currentUser: currentUser,
        );

  const AuthState.ready({
    required List<AppUser> users,
    AppUser? currentUser,
    String? errorMessage,
  }) : this(
          isLoading: false,
          users: users,
          currentUser: currentUser,
          errorMessage: errorMessage,
        );

  bool get isLoggedIn => currentUser != null;

  bool hasPermission(String permission) {
    final user = currentUser;
    if (user == null || !user.isActive) return false;
    return AppRoles.permissionsForRole(user.role).contains(permission);
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({
    required Ref ref,
    required AuthService? service,
    required StartupStatus startupStatus,
  })  : _ref = ref,
        _service = service,
        _startupStatus = startupStatus,
        super(const AuthState.loading()) {
    _listenToFirebaseAuth();
  }

  final Ref _ref;
  final AuthService? _service;
  final StartupStatus _startupStatus;
  StreamSubscription<Object?>? _authSubscription;

  Future<bool> login(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || password.isEmpty) {
      state = AuthState.ready(
        users: state.users,
        currentUser: state.currentUser,
        errorMessage: 'Enter your email and password.',
      );
      return false;
    }

    final service = _service;
    if (service == null) {
      state = AuthState.ready(
        users: const [],
        errorMessage: _startupStatus.hasFirebaseError
            ? 'Firebase is unavailable. Connect to Firebase to sign in.'
            : 'Firebase Auth is required to sign in.',
      );
      return false;
    }

    state = AuthState.loading(
      users: state.users,
      currentUser: state.currentUser,
    );

    try {
      final user = await service.login(
        email: normalizedEmail,
        password: password,
      );
      final users = await _loadUsersForCurrentRole(service, user);
      state = AuthState.ready(users: users, currentUser: user);
      return true;
    } on AuthServiceException catch (error) {
      state = AuthState.ready(
        users: state.users,
        errorMessage: error.displayMessage,
      );
      return false;
    } catch (error, stackTrace) {
      debugPrint('[Auth] Login failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      state = AuthState.ready(
        users: state.users,
        errorMessage: 'Unable to log in. Please try again.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    debugPrint('[Auth] logout started.');
    try {
      await _cancelFirestoreProviderListeners();
      await _service?.logout();
      _invalidateAppProviders();
      debugPrint('[Auth] providers invalidated.');
    } catch (error, stackTrace) {
      debugPrint('[Auth] Logout failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      state = const AuthState.ready(users: []);
    }
  }

  Future<void> _cancelFirestoreProviderListeners() async {
    _ref.invalidate(roomMediaProvider);
    _ref.invalidate(villasProvider);
    _ref.invalidate(villaListProvider);
    _ref.invalidate(activeVillaListProvider);
    _ref.invalidate(allRoomsProvider);
    _ref.invalidate(roomListProvider);
    _ref.invalidate(activeRoomListProvider);
    _ref.invalidate(incomeListProvider);
    _ref.invalidate(expenseListProvider);
    _ref.invalidate(userNotificationsProvider);
    _ref.invalidate(unreadNotificationCountProvider);
    _ref.invalidate(pendingSyncCountProvider);
    _ref.invalidate(pendingDeleteCountProvider);
    _ref.invalidate(lastSyncedAtProvider);
    _ref.invalidate(firebaseSyncServiceProvider);
    await Future<void>.delayed(Duration.zero);
  }

  void _invalidateAppProviders() {
    _ref.invalidate(roomMediaProvider);
    _ref.invalidate(roomMediaAuthStateProvider);
    _ref.invalidate(villasProvider);
    _ref.invalidate(villaListProvider);
    _ref.invalidate(activeVillaListProvider);
    _ref.invalidate(villaByIdProvider);
    _ref.invalidate(allRoomsProvider);
    _ref.invalidate(roomListProvider);
    _ref.invalidate(activeRoomListProvider);
    _ref.invalidate(roomByIdProvider);
    _ref.invalidate(roomsByVillaProvider);
    _ref.invalidate(watchRoomsByVillaProvider);
    _ref.invalidate(incomeListProvider);
    _ref.invalidate(expenseListProvider);
    _ref.invalidate(expenseProvider);
    _ref.invalidate(dashboardSummaryProvider);
    _ref.invalidate(userNotificationsProvider);
    _ref.invalidate(unreadNotificationCountProvider);
    _ref.invalidate(syncRefreshProvider);
    _ref.invalidate(pendingSyncCountProvider);
    _ref.invalidate(pendingDeleteCountProvider);
    _ref.invalidate(lastSyncedAtProvider);
    _ref.invalidate(firebaseSyncServiceProvider);
  }

  Future<void> loadSession() async {
    await _refreshFromFirebaseUser();
  }

  Future<List<AppUser>> loadUsers() async {
    final service = _service;
    final currentUser = state.currentUser;
    if (service == null || currentUser == null) return const [];

    final users = await _loadUsersForCurrentRole(service, currentUser);
    state = AuthState.ready(users: users, currentUser: currentUser);
    return users;
  }

  Future<bool> addUser(AppUser user, {required String password}) async {
    final service = _service;
    if (service == null || !canManageUsers()) {
      state = AuthState.ready(
        users: state.users,
        currentUser: state.currentUser,
        errorMessage: 'Only admins can create Firebase users.',
      );
      return false;
    }

    try {
      final savedUser = await service.createUser(
        email: user.username,
        password: password,
        role: user.role,
        displayName: user.displayName,
      );
      final users = [...state.users, savedUser]
        ..sort((a, b) => a.username.compareTo(b.username));
      state = AuthState.ready(users: users, currentUser: state.currentUser);
      return true;
    } on AuthServiceException catch (error) {
      state = AuthState.ready(
        users: state.users,
        currentUser: state.currentUser,
        errorMessage: error.message,
      );
      return false;
    } catch (error, stackTrace) {
      debugPrint('[Auth] User creation failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      state = AuthState.ready(
        users: state.users,
        currentUser: state.currentUser,
        errorMessage: 'Unable to create user. Please try again.',
      );
      return false;
    }
  }

  Future<void> updateUser(AppUser user) async {
    final service = _service;
    if (service == null || !canManageUsers()) return;

    final existing =
        state.users.where((item) => item.id == user.id).firstOrNull;
    if (existing == null) return;

    if (existing.role == AppRoles.admin && user.role != AppRoles.admin) {
      final adminCount =
          state.users.where((item) => item.role == AppRoles.admin).length;
      if (adminCount <= 1) return;
    }

    final updatedUser = user.copyWith(
      username: user.username.trim().toLowerCase(),
      updatedAt: DateTime.now(),
    );
    await service.saveUserProfile(updatedUser);
    final users = [
      for (final existing in state.users)
        if (existing.id == user.id) updatedUser else existing,
    ]..sort((a, b) => a.username.compareTo(b.username));
    final currentUser = state.currentUser?.id == updatedUser.id
        ? updatedUser
        : state.currentUser;
    state = AuthState.ready(users: users, currentUser: currentUser);
  }

  Future<void> deleteUser(String id) async {
    final service = _service;
    if (service == null || !canManageUsers()) return;
    if (state.currentUser?.id == id) return;

    final target = state.users.where((user) => user.id == id).firstOrNull;
    if (target == null) return;

    if (target.role == AppRoles.admin) {
      final adminCount =
          state.users.where((user) => user.role == AppRoles.admin).length;
      if (adminCount <= 1) return;
    }

    await service.disableUser(target);
    final users = state.users.where((user) => user.id != id).toList();
    state = AuthState.ready(users: users, currentUser: state.currentUser);
  }

  Future<void> resetPassword(String email) async {
    await _service?.resetPassword(email);
  }

  bool hasPermission(String permission) {
    return state.hasPermission(permission);
  }

  bool canManageUsers() {
    return hasPermission(AppPermissions.manageUsers);
  }

  bool isAdmin() {
    return state.currentUser?.role == AppRoles.admin;
  }

  void _listenToFirebaseAuth() {
    final service = _service;
    if (service == null) {
      state = AuthState.ready(
        users: const [],
        errorMessage: _startupStatus.firebaseError,
      );
      return;
    }

    _authSubscription = service.authStateChanges().listen(
      (_) => _refreshFromFirebaseUser(),
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('[Auth] Auth state stream failed: $error');
        debugPrintStack(stackTrace: stackTrace);
        state = AuthState.ready(
          users: state.users,
          currentUser: state.currentUser,
          errorMessage: 'Authentication state could not be loaded.',
        );
      },
    );
  }

  Future<void> _refreshFromFirebaseUser() async {
    final service = _service;
    if (service == null) return;

    try {
      final currentUser = await service.getCurrentUser();
      if (currentUser == null) {
        state = const AuthState.ready(users: []);
        return;
      }
      final users = await _loadUsersForCurrentRole(service, currentUser);
      state = AuthState.ready(users: users, currentUser: currentUser);
    } on AuthServiceException catch (error) {
      state = AuthState.ready(
        users: const [],
        errorMessage: error.message,
      );
    } catch (error, stackTrace) {
      debugPrint('[Auth] Failed to load Firebase session: $error');
      debugPrintStack(stackTrace: stackTrace);
      state = AuthState.ready(
        users: const [],
        errorMessage: 'Authentication state could not be loaded.',
      );
    }
  }

  Future<List<AppUser>> _loadUsersForCurrentRole(
    AuthService service,
    AppUser currentUser,
  ) async {
    if (currentUser.role != AppRoles.admin) return [currentUser];
    return service.fetchUsers();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}

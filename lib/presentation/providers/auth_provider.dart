import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_permissions.dart';
import '../../core/constants/app_roles.dart';
import '../../core/startup/startup_status.dart';
import '../../domain/models/app_user.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(startupStatusProvider));
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

  const AuthState.loading()
      : this(
          isLoading: true,
          users: const [],
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
    if (user == null) return false;
    return AppRoles.permissionsForRole(user.role).contains(permission);
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._startupStatus) : super(const AuthState.loading()) {
    loadSession();
  }

  final StartupStatus _startupStatus;
  static const usersKey = 'villabooks_users';
  static const loggedInUserIdKey = 'villabooks_logged_in_user_id';

  Future<bool> login(String email, String password) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      if (normalizedEmail.isEmpty || password.isEmpty) {
        state = AuthState.ready(
          users: state.users,
          errorMessage: 'Enter your email and password.',
        );
        return false;
      }

      final auth = _firebaseAuth;
      if (auth == null) {
        return _loginWithCachedUser(normalizedEmail, password);
      }

      final credential = await auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        state = AuthState.ready(
          users: state.users,
          errorMessage: 'Unable to sign in. Please try again.',
        );
        return false;
      }

      final appUser = await _loadCloudUserProfile(firebaseUser);
      final users = await _mergeAndSaveUser(appUser);
      debugPrint('[Auth] Firebase login succeeded for "${appUser.username}".');
      state = AuthState.ready(users: users, currentUser: appUser);
      return true;
    } on firebase_auth.FirebaseAuthException catch (error) {
      debugPrint('[Auth] Firebase login failed: ${error.code}');
      state = AuthState.ready(
        users: state.users,
        errorMessage: _friendlyAuthMessage(error),
      );
      return false;
    } catch (error, stackTrace) {
      debugPrint('[Auth] Login failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      state = AuthState.ready(
        users: state.users,
        errorMessage: 'Unable to log in. Please restart the app and try again.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth?.signOut();
      final preferences = await SharedPreferences.getInstance();
      await preferences.remove(loggedInUserIdKey);
    } catch (error, stackTrace) {
      debugPrint('[Auth] Logout persistence failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      state = AuthState.ready(users: state.users);
    }
  }

  Future<void> loadSession() async {
    try {
      debugPrint('[Auth] Loading saved session.');
      final users = await loadUsers();
      AppUser? currentUser;

      final firebaseUser = _firebaseAuth?.currentUser;
      if (firebaseUser != null) {
        currentUser = await _loadCloudUserProfile(firebaseUser);
        await _mergeAndSaveUser(currentUser);
      } else {
        final preferences = await SharedPreferences.getInstance();
        final loggedInUserId = preferences.getString(loggedInUserIdKey);
        currentUser = loggedInUserId == null
            ? null
            : users.where((user) => user.id == loggedInUserId).firstOrNull;
      }

      debugPrint(
        '[Auth] Session loaded. users=${users.length}, loggedIn=${currentUser != null}',
      );
      state = AuthState.ready(
        users: currentUser == null ? users : await loadUsers(),
        currentUser: currentUser,
      );
    } catch (error, stackTrace) {
      debugPrint('[Auth] Failed to load session: $error');
      debugPrintStack(stackTrace: stackTrace);
      state = AuthState.ready(
        users: const [],
        errorMessage: 'Local session could not be loaded.',
      );
    }
  }

  Future<List<AppUser>> loadUsers() async {
    try {
      final cachedUsers = await _loadUsersFromPrefs();
      final cloudUsers = await _loadCloudUsers();
      final users = cloudUsers.isEmpty ? cachedUsers : cloudUsers;
      if (cloudUsers.isNotEmpty) {
        await _saveUsers(cloudUsers);
      }
      debugPrint(
        '[Auth] Users ready. count=${users.length}, usernames=${_usernamesForLog(users)}',
      );
      return users;
    } catch (error, stackTrace) {
      debugPrint('[Auth] Failed to load users: $error');
      debugPrintStack(stackTrace: stackTrace);
      return _loadUsersFromPrefs();
    }
  }

  Future<void> resetLocalAuthForDevelopment() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(usersKey);
    await preferences.remove(loggedInUserIdKey);
    debugPrint(
      '[Auth] Cleared local auth keys: $usersKey, $loggedInUserIdKey.',
    );
    await loadSession();
  }

  Future<void> addUser(AppUser user) async {
    final savedUser = user.copyWith(
      id: user.id.isEmpty ? const Uuid().v4() : user.id,
      password: '',
      createdAt: user.createdAt,
    );
    await _saveCloudUser(savedUser);
    final users = [...state.users, savedUser];
    await _saveAndSetUsers(users);
  }

  Future<void> updateUser(AppUser user) async {
    final existing =
        state.users.where((item) => item.id == user.id).firstOrNull;
    if (existing == null) return;

    if (existing.role == AppRoles.admin && user.role != AppRoles.admin) {
      final adminCount =
          state.users.where((item) => item.role == AppRoles.admin).length;
      if (adminCount <= 1) return;
    }

    final updatedUser = user.copyWith(password: '', updatedAt: DateTime.now());
    await _saveCloudUser(updatedUser);
    final users = [
      for (final existing in state.users)
        if (existing.id == user.id) updatedUser else existing,
    ];
    await _saveAndSetUsers(users);
  }

  Future<void> deleteUser(String id) async {
    if (state.currentUser?.id == id) return;
    final target = state.users.where((user) => user.id == id).firstOrNull;
    if (target == null) return;

    if (target.role == AppRoles.admin) {
      final adminCount =
          state.users.where((user) => user.role == AppRoles.admin).length;
      if (adminCount <= 1) return;
    }

    await _softDeleteCloudUser(target);
    final users = state.users.where((user) => user.id != id).toList();
    await _saveAndSetUsers(users);
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

  Future<List<AppUser>> _loadUsersFromPrefs() async {
    final preferences = await SharedPreferences.getInstance();
    final rawUsers = preferences.getString(usersKey);
    if (rawUsers == null || rawUsers.isEmpty) {
      debugPrint('[Auth] Loaded users count=0, usernames=[]');
      return [];
    }

    final decoded = jsonDecode(rawUsers) as List<dynamic>;
    final users = decoded
        .map((json) => AppUser.fromJson(json as Map<String, dynamic>))
        .toList();
    debugPrint(
      '[Auth] Loaded users count=${users.length}, usernames=${_usernamesForLog(users)}',
    );
    return users;
  }

  Future<void> _saveAndSetUsers(List<AppUser> users) async {
    await _saveUsers(users);
    final currentUser = state.currentUser == null
        ? null
        : users.where((user) => user.id == state.currentUser!.id).firstOrNull;
    state = AuthState.ready(users: users, currentUser: currentUser);
  }

  Future<void> _saveUsers(List<AppUser> users) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(users.map((user) => user.toJson()).toList());
    await preferences.setString(usersKey, encoded);
    debugPrint(
      '[Auth] Saved users count=${users.length}, usernames=${_usernamesForLog(users)}',
    );
  }

  String _usernamesForLog(List<AppUser> users) {
    return users.map((user) => user.username).join(', ');
  }

  firebase_auth.FirebaseAuth? get _firebaseAuth {
    if (!_startupStatus.firebaseInitialized || Firebase.apps.isEmpty) {
      return null;
    }
    try {
      return firebase_auth.FirebaseAuth.instance;
    } catch (error, stackTrace) {
      debugPrint('[Auth] Firebase Auth unavailable: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  FirebaseFirestore? get _firestore {
    if (!_startupStatus.firebaseInitialized || Firebase.apps.isEmpty) {
      return null;
    }
    try {
      return FirebaseFirestore.instance;
    } catch (error, stackTrace) {
      debugPrint('[Auth] Firestore unavailable: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  Future<bool> _loginWithCachedUser(String email, String password) async {
    final users = state.users.isEmpty ? await loadUsers() : state.users;
    debugPrint(
      '[Auth] Firebase Auth unavailable for "$email"; local password login is disabled.',
    );
    state = AuthState.ready(
      users: users,
      errorMessage: _startupStatus.hasFirebaseError
          ? 'Firebase is unavailable. Connect to Firebase to sign in.'
          : 'Firebase Auth is required to sign in.',
    );
    return false;
  }

  Future<AppUser> _loadCloudUserProfile(
    firebase_auth.User firebaseUser,
  ) async {
    final firestore = _firestore;
    final now = DateTime.now();
    if (firestore == null) {
      return AppUser(
        id: firebaseUser.uid,
        username: firebaseUser.email ?? firebaseUser.uid,
        role: AppRoles.reader,
        createdAt: now,
      );
    }

    final doc = await firestore.collection('users').doc(firebaseUser.uid).get();
    final data = doc.data();
    if (data == null) {
      final user = AppUser(
        id: firebaseUser.uid,
        username: firebaseUser.email ?? firebaseUser.uid,
        role: AppRoles.reader,
        createdAt: now,
      );
      await _tryRepairCloudUserProfile(user);
      return user;
    }

    final user = _appUserFromCloud(firebaseUser.uid, data);
    if (data['isDeleted'] == true || data['isActive'] == false) {
      await _tryRepairCloudUserProfile(user);
    }

    return user;
  }

  Future<List<AppUser>> _loadCloudUsers() async {
    final firestore = _firestore;
    final currentUser = _firebaseAuth?.currentUser;
    if (firestore == null || currentUser == null) return const [];

    final snapshot = await firestore
        .collection('users')
        .where('isDeleted', isEqualTo: false)
        .get();
    return snapshot.docs
        .map((doc) => _appUserFromCloud(doc.id, doc.data()))
        .toList();
  }

  AppUser _appUserFromCloud(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      username: data['username'] as String? ?? data['email'] as String? ?? '',
      role: data['role'] as String? ?? AppRoles.reader,
      createdAt: _readCloudDate(data['createdAt']) ?? DateTime.now(),
      updatedAt: _readCloudDate(data['updatedAt']),
    );
  }

  Future<List<AppUser>> _mergeAndSaveUser(AppUser user) async {
    final users = [
      for (final existing in await _loadUsersFromPrefs())
        if (existing.id == user.id) user else existing,
    ];
    if (!users.any((existing) => existing.id == user.id)) users.add(user);
    await _saveUsers(users);
    return users;
  }

  Future<void> _saveCloudUser(AppUser user) async {
    final firestore = _firestore;
    if (firestore == null) return;
    await firestore.collection('users').doc(user.id).set(
      {
        'id': user.id,
        'username': user.username,
        'email': user.username,
        'role': user.role,
        'isActive': true,
        'isDeleted': false,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': user.createdAt.toIso8601String(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> _reactivateOwnCloudUser(AppUser user) async {
    final firestore = _firestore;
    if (firestore == null) return;
    await firestore.collection('users').doc(user.id).set(
      {
        'id': user.id,
        'username': user.username,
        'email': user.username,
        'role': user.role,
        'isActive': true,
        'isDeleted': false,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> _tryRepairCloudUserProfile(AppUser user) async {
    try {
      await _reactivateOwnCloudUser(user);
    } on FirebaseException catch (error, stackTrace) {
      debugPrint(
        '[Auth] Profile repair skipped for ${user.id}: ${error.code}',
      );
      debugPrintStack(stackTrace: stackTrace);
    } catch (error, stackTrace) {
      debugPrint('[Auth] Profile repair skipped for ${user.id}: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _softDeleteCloudUser(AppUser user) async {
    final firestore = _firestore;
    if (firestore == null) return;
    await firestore.collection('users').doc(user.id).set(
      {
        'isActive': false,
        'isDeleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  DateTime? _readCloudDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    if (value is DateTime) return value;
    return null;
  }

  String _friendlyAuthMessage(firebase_auth.FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'network-request-failed':
        return 'No internet connection. Try again when you are online.';
      default:
        return 'Unable to sign in. Please try again.';
    }
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}

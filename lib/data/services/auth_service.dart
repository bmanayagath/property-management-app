import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_roles.dart';
import '../../core/constants/default_organization.dart';
import '../../domain/models/app_user.dart';
import '../repositories/organization_repository.dart';
import 'firebase_sync_service.dart';
import 'logger_service.dart';

class AuthServiceException implements Exception {
  final String message;
  final String? code;
  final String? firebaseMessage;

  const AuthServiceException(
    this.message, {
    this.code,
    this.firebaseMessage,
  });

  String get displayMessage {
    if (code == null && firebaseMessage == null) return message;
    final details = [
      if (code != null && code!.isNotEmpty) 'code: $code',
      if (firebaseMessage != null && firebaseMessage!.isNotEmpty)
        'message: $firebaseMessage',
    ].join(', ');
    return '$message\nFirebase Auth error: $details';
  }

  @override
  String toString() => message;
}

class AuthService {
  AuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    FirebaseSyncService? firebaseSyncService,
  })  : _auth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseSyncService = firebaseSyncService,
        _organizationRepository = OrganizationRepository(
          firestore: firestore ?? FirebaseFirestore.instance,
        );

  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseSyncService? _firebaseSyncService;
  final OrganizationRepository _organizationRepository;
  bool _legacyDataMappingAttempted = false;

  Stream<firebase_auth.User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return _loadProfile(firebaseUser);
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final projectId = Firebase.app().options.projectId;
    await _logLoginDebug(
      message: 'Login started',
      details: {
        'enteredEmail': normalizedEmail,
        'firebaseProjectId': projectId,
        'currentFirebaseUserBeforeLogin': _firebaseUserDebug(_auth.currentUser),
      },
    );

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthServiceException(
            'Unable to sign in. Please try again.');
      }
      await _logLoginDebug(
        message: 'Firebase authentication succeeded',
        details: {
          'enteredEmail': normalizedEmail,
          'firebaseProjectId': projectId,
          'currentFirebaseUserAfterLogin': _firebaseUserDebug(
            _auth.currentUser,
          ),
        },
      );
      return _loadProfile(firebaseUser);
    } on firebase_auth.FirebaseAuthException catch (error, stackTrace) {
      await LoggerService.logAuth(
        screenName: 'AuthService',
        operation: 'Login',
        message: 'Firebase authentication failed',
        details: _formatDebugDetails({
          'enteredEmail': normalizedEmail,
          'firebaseProjectId': projectId,
          'firebaseAuthExceptionCode': error.code,
          'firebaseAuthExceptionMessage': error.message ?? '',
          'currentFirebaseUserAfterFailure': _firebaseUserDebug(
            _auth.currentUser,
          ),
        }),
        stackTrace: stackTrace.toString(),
        level: 'ERROR',
      );
      throw AuthServiceException(
        friendlyAuthMessage(error),
        code: error.code,
        firebaseMessage: error.message,
      );
    }
  }

  Future<void> logout() async {
    debugPrint('[AuthService] logout started.');
    await _firebaseSyncService?.stopAllListeners();
    await _auth.signOut();
    debugPrint('[AuthService] Firebase signOut completed.');
  }

  Future<AppUser> createUser({
    required String email,
    required String password,
    required String role,
    String displayName = '',
    String? orgId,
  }) async {
    firebase_auth.FirebaseAuth? secondaryAuth;
    firebase_auth.User? createdFirebaseUser;

    try {
      secondaryAuth = await _secondaryFirebaseAuth();
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      createdFirebaseUser = credential.user;
      if (createdFirebaseUser == null) {
        throw const AuthServiceException('Unable to create user.');
      }

      final appUser = AppUser(
        id: createdFirebaseUser.uid,
        username: email.trim().toLowerCase(),
        displayName: displayName.trim(),
        role: role,
        orgId: role == AppRoles.superAdmin
            ? null
            : orgId ?? DefaultOrganization.id,
        isActive: true,
        createdAt: DateTime.now(),
        createdBy: _auth.currentUser?.uid,
      );
      await saveUserProfile(appUser);
      return appUser;
    } on firebase_auth.FirebaseAuthException catch (error, stackTrace) {
      await LoggerService.logAuth(
        screenName: 'AuthService',
        operation: 'CreateUser',
        message: 'Firebase user creation failed',
        details: '${error.code}: ${error.message}',
        stackTrace: stackTrace.toString(),
        level: 'ERROR',
      );
      throw AuthServiceException(friendlyCreateUserMessage(error));
    } catch (_) {
      if (createdFirebaseUser != null) {
        try {
          await createdFirebaseUser.delete();
        } catch (error, stackTrace) {
          debugPrint('[AuthService] Created auth user cleanup failed: $error');
          debugPrintStack(stackTrace: stackTrace);
        }
      }
      rethrow;
    } finally {
      await secondaryAuth?.signOut();
      await secondaryAuth?.app.delete();
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
    } on firebase_auth.FirebaseAuthException catch (error, stackTrace) {
      await LoggerService.logAuth(
        screenName: 'AuthService',
        operation: 'ResetPassword',
        message: 'Firebase password reset failed',
        details: '${error.code}: ${error.message}',
        stackTrace: stackTrace.toString(),
        level: 'ERROR',
      );
      throw AuthServiceException(friendlyAuthMessage(error));
    }
  }

  Future<List<AppUser>> fetchUsers() async {
    final snapshot = await _firestore.collection('users').get();
    final users = snapshot.docs
        .map((doc) => _appUserFromCloud(doc.id, doc.data()))
        .where((user) => user.isActive)
        .toList()
      ..sort((a, b) => a.username.compareTo(b.username));
    return users;
  }

  Future<List<AppUser>> fetchUsersForOrg(String orgId) async {
    final snapshot = await _firestore
        .collection('users')
        .where('orgId', isEqualTo: orgId)
        .get();
    final users = snapshot.docs
        .map((doc) => _appUserFromCloud(doc.id, doc.data()))
        .where((user) => user.isActive)
        .toList()
      ..sort((a, b) => a.username.compareTo(b.username));
    return users;
  }

  Future<void> saveUserProfile(AppUser user) async {
    await _firestore.collection('users').doc(user.id).set(
          _profileData(user),
          SetOptions(merge: true),
        );
  }

  Future<void> disableUser(AppUser user) async {
    await _firestore.collection('users').doc(user.id).set(
      {
        'isActive': false,
        'isDeleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<AppUser> _loadProfile(firebase_auth.User firebaseUser) async {
    DocumentSnapshot<Map<String, dynamic>> doc;
    try {
      doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    } on FirebaseException catch (error, stackTrace) {
      await LoggerService.logAuth(
        screenName: 'AuthService',
        operation: 'LoadUserProfile',
        message: 'Unable to read Firestore user profile',
        details: _formatDebugDetails({
          'firebaseProjectId': Firebase.app().options.projectId,
          'currentFirebaseUserAfterLogin': _firebaseUserDebug(
            _auth.currentUser,
          ),
          'usersDocumentPath': 'users/${firebaseUser.uid}',
          'usersDocumentExists': 'unknown',
          'firestoreExceptionCode': error.code,
          'firestoreExceptionMessage': error.message ?? '',
        }),
        stackTrace: stackTrace.toString(),
        level: 'ERROR',
      );
      if (error.code == 'permission-denied') {
        await _auth.signOut();
        throw const AuthServiceException(
          'User profile cannot be accessed. Contact admin.',
        );
      }
      rethrow;
    }

    await _logLoginDebug(
      message: 'Firestore user profile read',
      details: {
        'firebaseProjectId': Firebase.app().options.projectId,
        'currentFirebaseUserAfterLogin': _firebaseUserDebug(_auth.currentUser),
        'usersDocumentPath': 'users/${firebaseUser.uid}',
        'usersDocumentExists': doc.exists,
        'isActive': doc.data()?['isActive'] ?? '',
        'role': doc.data()?['role'] ?? '',
      },
    );

    if (doc.exists && doc.data() != null) {
      final user = _appUserFromCloud(doc.id, doc.data()!);
      if (!user.isActive) {
        await _auth.signOut();
        throw const AuthServiceException(
          'This account is disabled. Contact admin.',
        );
      }
      if (user.role == AppRoles.superAdmin) {
        await _mapLegacyDataToAdornVillas(user.id);
      }
      if (user.role != AppRoles.superAdmin) {
        final orgId = user.orgId ?? DefaultOrganization.id;
        final organization =
            await _organizationRepository.getOrganization(orgId);
        if (organization != null && !organization.isActive) {
          await _auth.signOut();
          throw const AuthServiceException(
            'Your organization is inactive. Please contact support.',
          );
        }
      }
      return user;
    }

    if (await _canCreateFirstAdmin()) {
      return _createFirstAdminProfile(firebaseUser);
    }

    await _auth.signOut();
    throw const AuthServiceException(
      'Your login is valid, but no VillaBooks user profile was found.',
    );
  }

  Future<bool> _canCreateFirstAdmin() async {
    final marker = await _firestore.collection('appConfig').doc('auth').get();
    if (marker.exists) return false;

    final users = await _firestore.collection('users').limit(1).get();
    return users.docs.isEmpty;
  }

  Future<AppUser> _createFirstAdminProfile(
    firebase_auth.User firebaseUser,
  ) async {
    final email = firebaseUser.email ?? '';
    final user = AppUser(
      id: firebaseUser.uid,
      username: email,
      displayName: firebaseUser.displayName ?? 'Admin',
      role: AppRoles.admin,
      isActive: true,
      createdAt: DateTime.now(),
    );

    final batch = _firestore.batch();
    batch.set(
        _firestore.collection('organizations').doc(DefaultOrganization.id), {
      'id': DefaultOrganization.id,
      'name': DefaultOrganization.name,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': user.id,
    });
    batch.set(_firestore.collection('users').doc(user.id), _profileData(user));
    batch.set(_firestore.collection('appConfig').doc('auth'), {
      'firstAdminUid': user.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
    return user;
  }

  Map<String, Object?> _profileData(AppUser user) {
    return {
      'uid': user.id,
      'id': user.id,
      'email': user.username,
      'username': user.username,
      'displayName': user.displayName,
      'role': user.role,
      'orgId': user.role == AppRoles.superAdmin
          ? null
          : user.orgId ?? DefaultOrganization.id,
      'isActive': user.isActive,
      'isDeleted': !user.isActive,
      'createdAt': Timestamp.fromDate(user.createdAt),
      'createdBy': user.createdBy,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Future<void> _mapLegacyDataToAdornVillas(String updatedBy) async {
    if (_legacyDataMappingAttempted) return;
    _legacyDataMappingAttempted = true;
    try {
      final result = await _organizationRepository.mapLegacyDataToAdornVillas(
        updatedBy: updatedBy,
      );
      if (result.organizationMissing) {
        await LoggerService.logWarning(
          screenName: 'AuthService',
          operation: 'MapLegacyDataToOrganization',
          message: 'Adorn Villas organization was not found.',
        );
        return;
      }
      await LoggerService.logAuth(
        screenName: 'AuthService',
        operation: 'MapLegacyDataToOrganization',
        message: 'Legacy data mapping completed.',
        details:
            'organizationId: ${result.organizationId}\nupdated: ${result.updatedCounts}',
      );
    } catch (error, stackTrace) {
      await LoggerService.logError(
        screenName: 'AuthService',
        operation: 'MapLegacyDataToOrganization',
        message: 'Legacy data mapping failed.',
        details: error.toString(),
        stackTrace: stackTrace.toString(),
      );
    }
  }

  AppUser _appUserFromCloud(String id, Map<String, dynamic> data) {
    final email = data['email'] as String? ?? data['username'] as String? ?? '';
    return AppUser(
      id: data['uid'] as String? ?? data['id'] as String? ?? id,
      username: email,
      displayName: data['displayName'] as String? ?? '',
      role: data['role'] as String? ?? AppRoles.reader,
      orgId: data['role'] == AppRoles.superAdmin
          ? null
          : data['orgId'] as String? ?? DefaultOrganization.id,
      isActive: data['isActive'] as bool? ?? data['isDeleted'] != true,
      createdAt: _readCloudDate(data['createdAt']) ?? DateTime.now(),
      updatedAt: _readCloudDate(data['updatedAt']),
      createdBy: data['createdBy'] as String?,
    );
  }

  DateTime? _readCloudDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    if (value is DateTime) return value;
    return null;
  }

  Future<firebase_auth.FirebaseAuth> _secondaryFirebaseAuth() async {
    final app = await Firebase.initializeApp(
      name: 'user-creation-${const Uuid().v4()}',
      options: Firebase.app().options,
    );
    return firebase_auth.FirebaseAuth.instanceFor(app: app);
  }

  static String friendlyAuthMessage(firebase_auth.FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-disabled':
        return 'This account is disabled. Contact admin.';
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'network-request-failed':
        return 'Network error. Check internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      default:
        return 'Unable to sign in. Please try again.';
    }
  }

  static String friendlyCreateUserMessage(
    firebase_auth.FirebaseAuthException error,
  ) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'That email already has a Firebase login.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'No internet connection. Try again when you are online.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      default:
        return 'Unable to create user. Please try again.';
    }
  }

  Future<void> _logLoginDebug({
    required String message,
    required Map<String, Object?> details,
  }) {
    return LoggerService.logAuth(
      screenName: 'AuthService',
      operation: 'LoginDebug',
      message: message,
      details: _formatDebugDetails(details),
    );
  }

  static String _firebaseUserDebug(firebase_auth.User? user) {
    if (user == null) return 'null';
    return 'uid=${user.uid}, email=${user.email ?? ''}';
  }

  static String _formatDebugDetails(Map<String, Object?> details) {
    return details.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');
  }
}

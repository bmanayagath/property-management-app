import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_roles.dart';
import '../../core/constants/default_organization.dart';
import '../../domain/models/app_user.dart';
import '../../domain/models/organization_membership.dart';
import '../../domain/models/organization_model.dart';
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

class AuthSession {
  final AppUser user;
  final List<OrganizationMembership> activeMemberships;

  const AuthSession({
    required this.user,
    required this.activeMemberships,
  });
}

class CreateUserResult {
  final AppUser? user;
  final bool invitationCreated;
  final String? message;

  const CreateUserResult({
    this.user,
    this.invitationCreated = false,
    this.message,
  });
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

  Future<AuthSession?> getCurrentSession() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return _loadSession(firebaseUser);
  }

  Future<AuthSession> login({
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
      return _loadSession(firebaseUser);
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

  Future<CreateUserResult> createUser({
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

      final effectiveOrgId =
          role == AppRoles.superAdmin ? null : orgId ?? DefaultOrganization.id;
      final appUser = AppUser(
        id: createdFirebaseUser.uid,
        username: email.trim().toLowerCase(),
        displayName: displayName.trim(),
        role: role,
        orgId: effectiveOrgId,
        isActive: true,
        createdAt: DateTime.now(),
        createdBy: _auth.currentUser?.uid,
      );
      await saveUserProfile(appUser);
      if (effectiveOrgId != null) {
        await _setMembership(
          orgId: effectiveOrgId,
          uid: appUser.id,
          email: appUser.username,
          displayName: appUser.displayName,
          role: appUser.role,
          status: MembershipStatus.active,
          invitedBy: _auth.currentUser?.uid,
          approvedBy: _auth.currentUser?.uid,
        );
      }
      return CreateUserResult(user: appUser);
    } on firebase_auth.FirebaseAuthException catch (error, stackTrace) {
      if (error.code == 'email-already-in-use') {
        final invitation = await _createPendingMembershipForExistingEmail(
          email: email.trim().toLowerCase(),
          displayName: displayName.trim(),
          role: role,
          orgId: orgId ?? DefaultOrganization.id,
        );
        if (invitation) {
          return const CreateUserResult(
            invitationCreated: true,
            message:
                'This email already exists. Invitation created and requires approval.',
          );
        }
      }
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
    final members = await fetchMembersForOrg(orgId);
    final users = members
        .map((member) => AppUser(
              id: member.uid,
              username: member.email,
              displayName: member.displayName,
              role: member.role,
              orgId: member.orgId,
              isActive: member.status == MembershipStatus.active,
              createdAt: member.createdAt,
              updatedAt: member.activatedAt,
              createdBy: member.invitedBy,
            ))
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
    final orgId = user.orgId;
    if (orgId == null || orgId.trim().isEmpty) return;
    await _setMembership(
      orgId: orgId,
      uid: user.id,
      email: user.username,
      displayName: user.displayName,
      role: user.role,
      status: MembershipStatus.disabled,
      invitedBy: user.createdBy,
    );
  }

  Future<AuthSession> _loadSession(firebase_auth.User firebaseUser) async {
    final userPath = 'users/${firebaseUser.uid}';
    await _logLoginDebug(
      message: 'Loading authentication state',
      details: {
        'authUid': firebaseUser.uid,
        'email': firebaseUser.email ?? '',
        'userDocumentPath': userPath,
      },
    );

    final doc = await _readUserProfile(firebaseUser);
    if (!doc.exists || doc.data() == null) {
      final membershipSession =
          await _loadSessionFromMembershipOnly(firebaseUser);
      if (membershipSession != null) return membershipSession;

      if (await _canCreateFirstAdmin()) {
        final user = await _createFirstAdminProfile(firebaseUser);
        await _ensureLegacyActiveMembership(user);
        final memberships = await _loadActiveMembershipsForUser(user);
        return AuthSession(
          user: _userForMembership(user, memberships.first),
          activeMemberships: memberships,
        );
      }

      await _auth.signOut();
      throw const AuthServiceException(
        'User profile not found. Contact admin.',
      );
    }

    final data = doc.data()!;
    final user = _appUserFromCloud(doc.id, data);
    final rawRole = (data['role'] as String?)?.trim() ?? '';
    await _logLoginDebug(
      message: 'Firestore user profile loaded',
      details: {
        'authUid': firebaseUser.uid,
        'email': firebaseUser.email ?? user.username,
        'userDocumentPath': userPath,
        'role': rawRole,
        'orgId': user.orgId ?? '',
        'isActive': user.isActive,
      },
    );

    if (!user.isActive) {
      await _auth.signOut();
      throw const AuthServiceException('User account is disabled.');
    }
    if (rawRole.isEmpty) {
      await _auth.signOut();
      throw const AuthServiceException('Organization access not assigned.');
    }
    if (user.role == AppRoles.superAdmin) {
      await _mapLegacyDataToAdornVillas(user.id);
      await _migrateLegacyUsersToMemberships();
      return AuthSession(
        user: user.copyWith(clearOrgId: true),
        activeMemberships: const [],
      );
    }

    await _ensureLegacyActiveMembership(user);
    final memberships = await _loadActiveMembershipsForUser(user);
    final enabledMemberships = await _filterMembershipsWithActiveOrganizations(
      firebaseUser: firebaseUser,
      memberships: memberships,
    );
    if (enabledMemberships.isEmpty) {
      await _auth.signOut();
      throw const AuthServiceException(
        'You do not have active organization access.',
      );
    }

    return AuthSession(
      user: _userForMembership(user, enabledMemberships.first),
      activeMemberships: enabledMemberships,
    );
  }

  Future<AuthSession?> _loadSessionFromMembershipOnly(
    firebase_auth.User firebaseUser,
  ) async {
    final memberships = await _fetchActiveMembershipsWithLogging(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
    );
    if (memberships.isEmpty) return null;
    final enabledMemberships = await _filterMembershipsWithActiveOrganizations(
      firebaseUser: firebaseUser,
      memberships: memberships,
    );
    if (enabledMemberships.isEmpty) return null;
    final membership = enabledMemberships.first;
    final user = AppUser(
      id: firebaseUser.uid,
      username: firebaseUser.email?.trim().toLowerCase() ?? membership.email,
      displayName: firebaseUser.displayName ?? membership.displayName,
      role: membership.role,
      orgId: membership.orgId,
      isActive: true,
      createdAt: DateTime.now(),
      createdBy: membership.invitedBy,
    );
    await saveUserProfile(user);
    return AuthSession(
      user: _userForMembership(user, membership),
      activeMemberships: enabledMemberships,
    );
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _readUserProfile(
    firebase_auth.User firebaseUser,
  ) async {
    final path = 'users/${firebaseUser.uid}';
    try {
      return await _firestore.collection('users').doc(firebaseUser.uid).get();
    } on FirebaseException catch (error, stackTrace) {
      await _logFirestoreAuthError(
        operation: 'LoadUserProfile',
        message: 'Unable to read Firestore user profile',
        firebaseUser: firebaseUser,
        details: {
          'userDocumentPath': path,
          'firestoreExceptionCode': error.code,
          'firestoreExceptionMessage': error.message ?? '',
        },
        stackTrace: stackTrace,
      );
      await _auth.signOut();
      throw AuthServiceException(_firestoreAuthMessage(
        error,
        permissionDenied: 'User profile not found. Contact admin.',
      ));
    }
  }

  Future<List<OrganizationMembership>> _loadActiveMembershipsForUser(
    AppUser user,
  ) async {
    final orgId = user.orgId?.trim() ?? '';
    OrganizationMembership? directMembership;

    if (orgId.isNotEmpty) {
      directMembership = await _readMembershipByPath(
        orgId: orgId,
        uid: user.id,
        email: user.username,
      );
      if (directMembership != null && !directMembership.isActive) {
        await _auth.signOut();
        throw const AuthServiceException(
          'You do not have active organization access.',
        );
      }
    }

    try {
      final memberships = await _fetchActiveMembershipsWithLogging(
        uid: user.id,
        email: user.username,
      );
      final byOrgId = <String, OrganizationMembership>{
        for (final membership in memberships) membership.orgId: membership,
        if (directMembership != null && directMembership.isActive)
          directMembership.orgId: directMembership,
      };
      if (byOrgId.isNotEmpty) return byOrgId.values.toList();
    } on AuthServiceException {
      if (directMembership != null && directMembership.isActive) {
        return [directMembership];
      }
      rethrow;
    }

    await _auth.signOut();
    if (orgId.isEmpty) {
      throw const AuthServiceException('Organization access not assigned.');
    }
    throw const AuthServiceException(
      'You do not have active organization access.',
    );
  }

  Future<OrganizationMembership?> _readMembershipByPath({
    required String orgId,
    required String uid,
    required String email,
  }) async {
    final path = 'organizations/$orgId/members/$uid';
    await _logLoginDebug(
      message: 'Reading organization membership',
      details: {
        'authUid': uid,
        'email': email,
        'membershipLookupPath': path,
      },
    );

    try {
      final doc = await _membershipDoc(orgId, uid).get();
      await _logLoginDebug(
        message: 'Organization membership read',
        details: {
          'authUid': uid,
          'email': email,
          'membershipLookupPath': path,
          'membershipExists': doc.exists,
          'membershipStatus': doc.data()?['status'] ?? '',
          'role': doc.data()?['role'] ?? '',
          'orgId': orgId,
        },
      );
      if (!doc.exists || doc.data() == null) return null;
      return OrganizationMembership.fromJson(orgId: orgId, json: doc.data()!);
    } on FirebaseException catch (error, stackTrace) {
      await _logFirestoreAuthError(
        operation: 'LoadMembership',
        message: 'Unable to read organization membership',
        firebaseUser: _auth.currentUser,
        details: {
          'authUid': uid,
          'email': email,
          'membershipLookupPath': path,
          'role': '',
          'orgId': orgId,
          'firestoreExceptionCode': error.code,
          'firestoreExceptionMessage': error.message ?? '',
        },
        stackTrace: stackTrace,
      );
      await _auth.signOut();
      throw AuthServiceException(_firestoreAuthMessage(
        error,
        permissionDenied: 'You do not have active organization access.',
      ));
    }
  }

  Future<List<OrganizationMembership>> _fetchActiveMembershipsWithLogging({
    required String uid,
    required String email,
  }) async {
    await _logLoginDebug(
      message: 'Querying active organization memberships',
      details: {
        'authUid': uid,
        'email': email,
        'membershipLookupPath':
            'collectionGroup(members) where uid == $uid and status == Active',
      },
    );
    try {
      final memberships = await fetchActiveMemberships(uid);
      await _logLoginDebug(
        message: 'Active organization memberships loaded',
        details: {
          'authUid': uid,
          'email': email,
          'membershipLookupPath':
              'collectionGroup(members) where uid == $uid and status == Active',
          'activeMembershipCount': memberships.length,
          'orgIds': memberships.map((item) => item.orgId).join(', '),
        },
      );
      return memberships;
    } on FirebaseException catch (error, stackTrace) {
      await _logFirestoreAuthError(
        operation: 'LoadActiveMemberships',
        message: 'Unable to query active organization memberships',
        firebaseUser: _auth.currentUser,
        details: {
          'authUid': uid,
          'email': email,
          'membershipLookupPath':
              'collectionGroup(members) where uid == $uid and status == Active',
          'firestoreExceptionCode': error.code,
          'firestoreExceptionMessage': error.message ?? '',
        },
        stackTrace: stackTrace,
      );
      throw AuthServiceException(_firestoreAuthMessage(
        error,
        permissionDenied: 'You do not have active organization access.',
      ));
    }
  }

  Future<List<OrganizationMembership>>
      _filterMembershipsWithActiveOrganizations({
    required firebase_auth.User firebaseUser,
    required List<OrganizationMembership> memberships,
  }) async {
    final enabledMemberships = <OrganizationMembership>[];
    var inactiveOrganizationFound = false;
    var missingOrganizationFound = false;

    for (final membership in memberships) {
      final organization = await _readOrganizationForLogin(
        firebaseUser: firebaseUser,
        membership: membership,
      );
      if (organization == null) {
        missingOrganizationFound = true;
        continue;
      }
      if (!organization.isActive) {
        inactiveOrganizationFound = true;
        continue;
      }
      enabledMemberships.add(membership);
    }

    if (enabledMemberships.isNotEmpty) return enabledMemberships;
    await _auth.signOut();
    if (inactiveOrganizationFound) {
      throw const AuthServiceException('Organization is inactive.');
    }
    if (missingOrganizationFound) {
      throw const AuthServiceException('Organization access not assigned.');
    }
    throw const AuthServiceException(
      'You do not have active organization access.',
    );
  }

  Future<OrganizationModel?> _readOrganizationForLogin({
    required firebase_auth.User firebaseUser,
    required OrganizationMembership membership,
  }) async {
    final path = 'organizations/${membership.orgId}';
    await _logLoginDebug(
      message: 'Reading organization for membership',
      details: {
        'authUid': firebaseUser.uid,
        'email': firebaseUser.email ?? membership.email,
        'role': membership.role,
        'orgId': membership.orgId,
        'organizationLookupPath': path,
        'membershipLookupPath':
            'organizations/${membership.orgId}/members/${membership.uid}',
      },
    );
    try {
      final organization =
          await _organizationRepository.getOrganization(membership.orgId);
      await _logLoginDebug(
        message: 'Organization lookup completed',
        details: {
          'authUid': firebaseUser.uid,
          'email': firebaseUser.email ?? membership.email,
          'role': membership.role,
          'orgId': membership.orgId,
          'organizationLookupPath': path,
          'organizationExists': organization != null,
          'organizationIsActive': organization?.isActive ?? '',
        },
      );
      return organization;
    } on FirebaseException catch (error, stackTrace) {
      await _logFirestoreAuthError(
        operation: 'LoadOrganization',
        message: 'Unable to read organization for membership',
        firebaseUser: firebaseUser,
        details: {
          'authUid': firebaseUser.uid,
          'email': firebaseUser.email ?? membership.email,
          'role': membership.role,
          'orgId': membership.orgId,
          'membershipLookupPath':
              'organizations/${membership.orgId}/members/${membership.uid}',
          'organizationLookupPath': path,
          'firestoreExceptionCode': error.code,
          'firestoreExceptionMessage': error.message ?? '',
        },
        stackTrace: stackTrace,
      );
      await _auth.signOut();
      throw AuthServiceException(_firestoreAuthMessage(
        error,
        permissionDenied: 'Organization access not assigned.',
      ));
    }
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
    batch.set(
      _membershipDoc(DefaultOrganization.id, user.id),
      OrganizationMembership(
        orgId: DefaultOrganization.id,
        uid: user.id,
        email: user.username,
        displayName: user.displayName,
        role: user.role,
        status: MembershipStatus.active,
        invitedBy: user.id,
        approvedBy: user.id,
        createdAt: DateTime.now(),
        activatedAt: DateTime.now(),
      ).toJson(),
    );
    batch.set(_firestore.collection('appConfig').doc('auth'), {
      'firstAdminUid': user.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
    return user;
  }

  Future<List<OrganizationMembership>> fetchActiveMemberships(
    String uid,
  ) async {
    final snapshot = await _firestore
        .collectionGroup('members')
        .where('uid', isEqualTo: uid)
        .where('status', isEqualTo: MembershipStatus.active)
        .get();

    return snapshot.docs
        .map((doc) {
          final orgId = doc.reference.parent.parent?.id ?? '';
          return OrganizationMembership.fromJson(
            orgId: orgId,
            json: doc.data(),
          );
        })
        .where((membership) => membership.orgId.isNotEmpty)
        .toList()
      ..sort((a, b) => a.email.compareTo(b.email));
  }

  Future<List<OrganizationMembership>> fetchMembersForOrg(String orgId) async {
    final snapshot = await _firestore
        .collection('organizations')
        .doc(orgId)
        .collection('members')
        .get();
    return snapshot.docs
        .map((doc) => OrganizationMembership.fromJson(
              orgId: orgId,
              json: doc.data(),
            ))
        .toList()
      ..sort((a, b) => a.email.compareTo(b.email));
  }

  Future<void> activateMembership(OrganizationMembership membership) {
    return _setMembership(
      orgId: membership.orgId,
      uid: membership.uid,
      email: membership.email,
      displayName: membership.displayName,
      role: membership.role,
      status: MembershipStatus.active,
      invitedBy: membership.invitedBy,
      approvedBy: _auth.currentUser?.uid,
    );
  }

  Future<void> disableMembership(OrganizationMembership membership) {
    return _setMembership(
      orgId: membership.orgId,
      uid: membership.uid,
      email: membership.email,
      displayName: membership.displayName,
      role: membership.role,
      status: MembershipStatus.disabled,
      invitedBy: membership.invitedBy,
      approvedBy: membership.approvedBy,
    );
  }

  Future<void> _ensureLegacyActiveMembership(AppUser user) async {
    final orgId = user.orgId;
    if (orgId == null || orgId.trim().isEmpty) return;
    final doc = await _membershipDoc(orgId, user.id).get();
    if (doc.exists) return;
    await _setMembership(
      orgId: orgId,
      uid: user.id,
      email: user.username,
      displayName: user.displayName,
      role: user.role,
      status: MembershipStatus.active,
      invitedBy: user.createdBy,
      approvedBy: user.createdBy,
    );
  }

  Future<void> _migrateLegacyUsersToMemberships() async {
    final snapshot = await _firestore.collection('users').get();
    for (final doc in snapshot.docs) {
      final user = _appUserFromCloud(doc.id, doc.data());
      if (user.role == AppRoles.superAdmin) continue;
      if (!user.isActive) continue;
      final orgId = user.orgId;
      if (orgId == null || orgId.trim().isEmpty) continue;
      final memberDoc = await _membershipDoc(orgId, user.id).get();
      if (memberDoc.exists) continue;
      await _setMembership(
        orgId: orgId,
        uid: user.id,
        email: user.username,
        displayName: user.displayName,
        role: user.role,
        status: MembershipStatus.active,
        invitedBy: user.createdBy,
        approvedBy: user.createdBy,
      );
    }
  }

  Future<bool> _createPendingMembershipForExistingEmail({
    required String email,
    required String displayName,
    required String role,
    required String orgId,
  }) async {
    final existing = await _findUserByEmail(email);
    final uid = existing?.id ?? 'pending_${_safeDocumentId(email)}';
    await _setMembership(
      orgId: orgId,
      uid: uid,
      email: email,
      displayName: displayName,
      role: role,
      status: MembershipStatus.pending,
      invitedBy: _auth.currentUser?.uid,
    );
    return true;
  }

  Future<AppUser?> _findUserByEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: normalized)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return _appUserFromCloud(doc.id, doc.data());
  }

  Future<void> _setMembership({
    required String orgId,
    required String uid,
    required String email,
    required String displayName,
    required String role,
    required String status,
    String? invitedBy,
    String? approvedBy,
  }) async {
    final now = DateTime.now();
    final doc = _membershipDoc(orgId, uid);
    final existing = await doc.get();
    final createdAt = _readCloudDate(existing.data()?['createdAt']) ?? now;
    await doc.set(
      OrganizationMembership(
        orgId: orgId,
        uid: uid,
        email: email,
        displayName: displayName,
        role: role,
        status: status,
        invitedBy: invitedBy,
        approvedBy: approvedBy,
        createdAt: createdAt,
        activatedAt: status == MembershipStatus.active ? now : null,
      ).toJson(),
      SetOptions(merge: true),
    );
  }

  DocumentReference<Map<String, dynamic>> _membershipDoc(
    String orgId,
    String uid,
  ) {
    return _firestore
        .collection('organizations')
        .doc(orgId)
        .collection('members')
        .doc(uid);
  }

  AppUser _userForMembership(AppUser user, OrganizationMembership membership) {
    return user.copyWith(
      orgId: membership.orgId,
      role: membership.role,
      displayName: membership.displayName.trim().isEmpty
          ? user.displayName
          : membership.displayName,
    );
  }

  String _safeDocumentId(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
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

  Future<void> _logFirestoreAuthError({
    required String operation,
    required String message,
    required firebase_auth.User? firebaseUser,
    required Map<String, Object?> details,
    required StackTrace stackTrace,
  }) {
    return LoggerService.logAuth(
      screenName: 'AuthService',
      operation: operation,
      message: message,
      details: _formatDebugDetails({
        'firebaseProjectId': Firebase.app().options.projectId,
        'currentFirebaseUser': _firebaseUserDebug(firebaseUser),
        ...details,
      }),
      stackTrace: stackTrace.toString(),
      level: 'ERROR',
    );
  }

  static String _firestoreAuthMessage(
    FirebaseException error, {
    required String permissionDenied,
  }) {
    switch (error.code) {
      case 'permission-denied':
        return permissionDenied;
      case 'unavailable':
        return 'Unable to load authentication state. Please try again.';
      case 'not-found':
        return 'User profile not found. Contact admin.';
      default:
        return 'Unable to load authentication state. Please try again.';
    }
  }

  static String _formatDebugDetails(Map<String, Object?> details) {
    return details.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');
  }
}

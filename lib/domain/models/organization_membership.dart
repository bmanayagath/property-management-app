import 'package:cloud_firestore/cloud_firestore.dart';

class MembershipStatus {
  MembershipStatus._();

  static const pending = 'Pending';
  static const active = 'Active';
  static const disabled = 'Disabled';
}

class OrganizationMembership {
  final String orgId;
  final String uid;
  final String email;
  final String displayName;
  final String role;
  final String status;
  final String? invitedBy;
  final String? approvedBy;
  final DateTime createdAt;
  final DateTime? activatedAt;

  const OrganizationMembership({
    required this.orgId,
    required this.uid,
    required this.email,
    this.displayName = '',
    required this.role,
    required this.status,
    this.invitedBy,
    this.approvedBy,
    required this.createdAt,
    this.activatedAt,
  });

  bool get isActive => status == MembershipStatus.active;

  factory OrganizationMembership.fromJson({
    required String orgId,
    required Map<String, dynamic> json,
  }) {
    return OrganizationMembership(
      orgId: orgId,
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      role: json['role'] as String? ?? 'Reader',
      status: json['status'] as String? ?? MembershipStatus.pending,
      invitedBy: json['invitedBy'] as String?,
      approvedBy: json['approvedBy'] as String?,
      createdAt: _readDate(json['createdAt']) ?? DateTime.now(),
      activatedAt: _readDate(json['activatedAt']),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
      'status': status,
      'invitedBy': invitedBy,
      'approvedBy': approvedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'activatedAt':
          activatedAt == null ? null : Timestamp.fromDate(activatedAt!),
    };
  }

  OrganizationMembership copyWith({
    String? orgId,
    String? uid,
    String? email,
    String? displayName,
    String? role,
    String? status,
    String? invitedBy,
    String? approvedBy,
    DateTime? createdAt,
    DateTime? activatedAt,
  }) {
    return OrganizationMembership(
      orgId: orgId ?? this.orgId,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      status: status ?? this.status,
      invitedBy: invitedBy ?? this.invitedBy,
      approvedBy: approvedBy ?? this.approvedBy,
      createdAt: createdAt ?? this.createdAt,
      activatedAt: activatedAt ?? this.activatedAt,
    );
  }
}

DateTime? _readDate(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

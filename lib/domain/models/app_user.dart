class AppUser {
  final String id;
  final String username;
  final String password;
  final String displayName;
  final String role;
  final String? orgId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? createdBy;

  const AppUser({
    required this.id,
    required this.username,
    this.password = '',
    this.displayName = '',
    required this.role,
    this.orgId,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      username: json['username'] as String? ?? json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      role: json['role'] as String? ?? 'Reader',
      orgId: json['orgId'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.tryParse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': username,
      'displayName': displayName,
      'role': role,
      'orgId': orgId,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  AppUser copyWith({
    String? id,
    String? username,
    String? password,
    String? displayName,
    String? role,
    String? orgId,
    bool clearOrgId = false,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return AppUser(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      orgId: clearOrgId ? null : orgId ?? this.orgId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}

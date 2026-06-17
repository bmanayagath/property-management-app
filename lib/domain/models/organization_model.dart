import 'package:cloud_firestore/cloud_firestore.dart';

class OrganizationModel {
  final String id;
  final String name;
  final String contactPerson;
  final String contactEmail;
  final String contactPhone;
  final String address;
  final bool isActive;
  final DateTime createdAt;
  final String? createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;

  const OrganizationModel({
    required this.id,
    required this.name,
    this.contactPerson = '',
    this.contactEmail = '',
    this.contactPhone = '',
    this.address = '',
    this.isActive = true,
    required this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      contactPerson: json['contactPerson'] as String? ?? '',
      contactEmail: json['contactEmail'] as String? ?? '',
      contactPhone: json['contactPhone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: _dateFromJson(json['createdAt']) ?? DateTime.now(),
      createdBy: json['createdBy'] as String?,
      updatedAt: _dateFromJson(json['updatedAt']),
      updatedBy: json['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contactPerson': contactPerson,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'address': address,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
      'updatedBy': updatedBy,
    };
  }

  OrganizationModel copyWith({
    String? id,
    String? name,
    String? contactPerson,
    String? contactEmail,
    String? contactPhone,
    String? address,
    bool? isActive,
    DateTime? createdAt,
    String? createdBy,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return OrganizationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}

DateTime? _dateFromJson(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

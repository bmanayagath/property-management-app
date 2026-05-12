// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'villa_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VillaModelImpl _$$VillaModelImplFromJson(Map<String, dynamic> json) =>
    _$VillaModelImpl(
      id: json['id'] as String,
      villaName: json['villaName'] as String,
      location: json['location'] as String,
      villaNumber: json['villaNumber'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
      syncStatus: json['syncStatus'] as String? ?? 'pending',
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      deletedBy: json['deletedBy'] as String?,
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
      lastSyncedAt: json['lastSyncedAt'] == null
          ? null
          : DateTime.parse(json['lastSyncedAt'] as String),
    );

Map<String, dynamic> _$$VillaModelImplToJson(_$VillaModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'villaName': instance.villaName,
      'location': instance.location,
      'villaNumber': instance.villaNumber,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isDeleted': instance.isDeleted,
      'syncStatus': instance.syncStatus,
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'deletedBy': instance.deletedBy,
      'createdBy': instance.createdBy,
      'updatedBy': instance.updatedBy,
      'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
    };

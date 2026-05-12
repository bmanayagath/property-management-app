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
    };

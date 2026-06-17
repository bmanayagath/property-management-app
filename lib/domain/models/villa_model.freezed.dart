// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'villa_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VillaModel _$VillaModelFromJson(Map<String, dynamic> json) {
  return _VillaModel.fromJson(json);
}

/// @nodoc
mixin _$VillaModel {
  String get id => throw _privateConstructorUsedError;
  String get orgId => throw _privateConstructorUsedError;
  String get villaName => throw _privateConstructorUsedError;
  String get location =>
      throw _privateConstructorUsedError; // Legacy compatibility field for old local/Firebase records.
// New UI and validation use villaName for identification.
  String get villaNumber => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;
  String get syncStatus => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  String? get deletedBy => throw _privateConstructorUsedError;
  String? get createdBy => throw _privateConstructorUsedError;
  String? get updatedBy => throw _privateConstructorUsedError;
  DateTime? get lastSyncedAt => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  String? get mapAddress => throw _privateConstructorUsedError;
  String? get googleMapsUrl => throw _privateConstructorUsedError;
  String? get wazeUrl => throw _privateConstructorUsedError;

  /// Serializes this VillaModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VillaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VillaModelCopyWith<VillaModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VillaModelCopyWith<$Res> {
  factory $VillaModelCopyWith(
          VillaModel value, $Res Function(VillaModel) then) =
      _$VillaModelCopyWithImpl<$Res, VillaModel>;
  @useResult
  $Res call(
      {String id,
      String orgId,
      String villaName,
      String location,
      String villaNumber,
      String notes,
      DateTime createdAt,
      DateTime? updatedAt,
      bool isDeleted,
      String syncStatus,
      DateTime? deletedAt,
      String? deletedBy,
      String? createdBy,
      String? updatedBy,
      DateTime? lastSyncedAt,
      double? latitude,
      double? longitude,
      String? mapAddress,
      String? googleMapsUrl,
      String? wazeUrl});
}

/// @nodoc
class _$VillaModelCopyWithImpl<$Res, $Val extends VillaModel>
    implements $VillaModelCopyWith<$Res> {
  _$VillaModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VillaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? villaName = null,
    Object? location = null,
    Object? villaNumber = null,
    Object? notes = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? isDeleted = null,
    Object? syncStatus = null,
    Object? deletedAt = freezed,
    Object? deletedBy = freezed,
    Object? createdBy = freezed,
    Object? updatedBy = freezed,
    Object? lastSyncedAt = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? mapAddress = freezed,
    Object? googleMapsUrl = freezed,
    Object? wazeUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orgId: null == orgId
          ? _value.orgId
          : orgId // ignore: cast_nullable_to_non_nullable
              as String,
      villaName: null == villaName
          ? _value.villaName
          : villaName // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      villaNumber: null == villaNumber
          ? _value.villaNumber
          : villaNumber // ignore: cast_nullable_to_non_nullable
              as String,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as String,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deletedBy: freezed == deletedBy
          ? _value.deletedBy
          : deletedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedBy: freezed == updatedBy
          ? _value.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      lastSyncedAt: freezed == lastSyncedAt
          ? _value.lastSyncedAt
          : lastSyncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      mapAddress: freezed == mapAddress
          ? _value.mapAddress
          : mapAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      googleMapsUrl: freezed == googleMapsUrl
          ? _value.googleMapsUrl
          : googleMapsUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      wazeUrl: freezed == wazeUrl
          ? _value.wazeUrl
          : wazeUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VillaModelImplCopyWith<$Res>
    implements $VillaModelCopyWith<$Res> {
  factory _$$VillaModelImplCopyWith(
          _$VillaModelImpl value, $Res Function(_$VillaModelImpl) then) =
      __$$VillaModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String orgId,
      String villaName,
      String location,
      String villaNumber,
      String notes,
      DateTime createdAt,
      DateTime? updatedAt,
      bool isDeleted,
      String syncStatus,
      DateTime? deletedAt,
      String? deletedBy,
      String? createdBy,
      String? updatedBy,
      DateTime? lastSyncedAt,
      double? latitude,
      double? longitude,
      String? mapAddress,
      String? googleMapsUrl,
      String? wazeUrl});
}

/// @nodoc
class __$$VillaModelImplCopyWithImpl<$Res>
    extends _$VillaModelCopyWithImpl<$Res, _$VillaModelImpl>
    implements _$$VillaModelImplCopyWith<$Res> {
  __$$VillaModelImplCopyWithImpl(
      _$VillaModelImpl _value, $Res Function(_$VillaModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of VillaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? villaName = null,
    Object? location = null,
    Object? villaNumber = null,
    Object? notes = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? isDeleted = null,
    Object? syncStatus = null,
    Object? deletedAt = freezed,
    Object? deletedBy = freezed,
    Object? createdBy = freezed,
    Object? updatedBy = freezed,
    Object? lastSyncedAt = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? mapAddress = freezed,
    Object? googleMapsUrl = freezed,
    Object? wazeUrl = freezed,
  }) {
    return _then(_$VillaModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orgId: null == orgId
          ? _value.orgId
          : orgId // ignore: cast_nullable_to_non_nullable
              as String,
      villaName: null == villaName
          ? _value.villaName
          : villaName // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      villaNumber: null == villaNumber
          ? _value.villaNumber
          : villaNumber // ignore: cast_nullable_to_non_nullable
              as String,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as String,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deletedBy: freezed == deletedBy
          ? _value.deletedBy
          : deletedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedBy: freezed == updatedBy
          ? _value.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      lastSyncedAt: freezed == lastSyncedAt
          ? _value.lastSyncedAt
          : lastSyncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      mapAddress: freezed == mapAddress
          ? _value.mapAddress
          : mapAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      googleMapsUrl: freezed == googleMapsUrl
          ? _value.googleMapsUrl
          : googleMapsUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      wazeUrl: freezed == wazeUrl
          ? _value.wazeUrl
          : wazeUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VillaModelImpl implements _VillaModel {
  const _$VillaModelImpl(
      {required this.id,
      this.orgId = 'default_org',
      required this.villaName,
      required this.location,
      this.villaNumber = '',
      this.notes = '',
      required this.createdAt,
      this.updatedAt,
      this.isDeleted = false,
      this.syncStatus = 'pending',
      this.deletedAt,
      this.deletedBy,
      this.createdBy,
      this.updatedBy,
      this.lastSyncedAt,
      this.latitude,
      this.longitude,
      this.mapAddress,
      this.googleMapsUrl,
      this.wazeUrl});

  factory _$VillaModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$VillaModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final String orgId;
  @override
  final String villaName;
  @override
  final String location;
// Legacy compatibility field for old local/Firebase records.
// New UI and validation use villaName for identification.
  @override
  @JsonKey()
  final String villaNumber;
  @override
  @JsonKey()
  final String notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey()
  final bool isDeleted;
  @override
  @JsonKey()
  final String syncStatus;
  @override
  final DateTime? deletedAt;
  @override
  final String? deletedBy;
  @override
  final String? createdBy;
  @override
  final String? updatedBy;
  @override
  final DateTime? lastSyncedAt;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final String? mapAddress;
  @override
  final String? googleMapsUrl;
  @override
  final String? wazeUrl;

  @override
  String toString() {
    return 'VillaModel(id: $id, orgId: $orgId, villaName: $villaName, location: $location, villaNumber: $villaNumber, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted, syncStatus: $syncStatus, deletedAt: $deletedAt, deletedBy: $deletedBy, createdBy: $createdBy, updatedBy: $updatedBy, lastSyncedAt: $lastSyncedAt, latitude: $latitude, longitude: $longitude, mapAddress: $mapAddress, googleMapsUrl: $googleMapsUrl, wazeUrl: $wazeUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VillaModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orgId, orgId) || other.orgId == orgId) &&
            (identical(other.villaName, villaName) ||
                other.villaName == villaName) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.villaNumber, villaNumber) ||
                other.villaNumber == villaNumber) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.deletedBy, deletedBy) ||
                other.deletedBy == deletedBy) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy) &&
            (identical(other.lastSyncedAt, lastSyncedAt) ||
                other.lastSyncedAt == lastSyncedAt) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.mapAddress, mapAddress) ||
                other.mapAddress == mapAddress) &&
            (identical(other.googleMapsUrl, googleMapsUrl) ||
                other.googleMapsUrl == googleMapsUrl) &&
            (identical(other.wazeUrl, wazeUrl) || other.wazeUrl == wazeUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        orgId,
        villaName,
        location,
        villaNumber,
        notes,
        createdAt,
        updatedAt,
        isDeleted,
        syncStatus,
        deletedAt,
        deletedBy,
        createdBy,
        updatedBy,
        lastSyncedAt,
        latitude,
        longitude,
        mapAddress,
        googleMapsUrl,
        wazeUrl
      ]);

  /// Create a copy of VillaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VillaModelImplCopyWith<_$VillaModelImpl> get copyWith =>
      __$$VillaModelImplCopyWithImpl<_$VillaModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VillaModelImplToJson(
      this,
    );
  }
}

abstract class _VillaModel implements VillaModel {
  const factory _VillaModel(
      {required final String id,
      final String orgId,
      required final String villaName,
      required final String location,
      final String villaNumber,
      final String notes,
      required final DateTime createdAt,
      final DateTime? updatedAt,
      final bool isDeleted,
      final String syncStatus,
      final DateTime? deletedAt,
      final String? deletedBy,
      final String? createdBy,
      final String? updatedBy,
      final DateTime? lastSyncedAt,
      final double? latitude,
      final double? longitude,
      final String? mapAddress,
      final String? googleMapsUrl,
      final String? wazeUrl}) = _$VillaModelImpl;

  factory _VillaModel.fromJson(Map<String, dynamic> json) =
      _$VillaModelImpl.fromJson;

  @override
  String get id;
  @override
  String get orgId;
  @override
  String get villaName;
  @override
  String
      get location; // Legacy compatibility field for old local/Firebase records.
// New UI and validation use villaName for identification.
  @override
  String get villaNumber;
  @override
  String get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  bool get isDeleted;
  @override
  String get syncStatus;
  @override
  DateTime? get deletedAt;
  @override
  String? get deletedBy;
  @override
  String? get createdBy;
  @override
  String? get updatedBy;
  @override
  DateTime? get lastSyncedAt;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  String? get mapAddress;
  @override
  String? get googleMapsUrl;
  @override
  String? get wazeUrl;

  /// Create a copy of VillaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VillaModelImplCopyWith<_$VillaModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

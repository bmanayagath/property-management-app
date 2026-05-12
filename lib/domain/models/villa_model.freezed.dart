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
  String get villaName => throw _privateConstructorUsedError;
  String get location =>
      throw _privateConstructorUsedError; // Legacy compatibility field for old local/Firebase records.
// New UI and validation use villaName for identification.
  String get villaNumber => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

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
      String villaName,
      String location,
      String villaNumber,
      String notes,
      DateTime createdAt,
      DateTime? updatedAt});
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
    Object? villaName = null,
    Object? location = null,
    Object? villaNumber = null,
    Object? notes = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
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
      String villaName,
      String location,
      String villaNumber,
      String notes,
      DateTime createdAt,
      DateTime? updatedAt});
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
    Object? villaName = null,
    Object? location = null,
    Object? villaNumber = null,
    Object? notes = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$VillaModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VillaModelImpl implements _VillaModel {
  const _$VillaModelImpl(
      {required this.id,
      required this.villaName,
      required this.location,
      this.villaNumber = '',
      this.notes = '',
      required this.createdAt,
      this.updatedAt});

  factory _$VillaModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$VillaModelImplFromJson(json);

  @override
  final String id;
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
  String toString() {
    return 'VillaModel(id: $id, villaName: $villaName, location: $location, villaNumber: $villaNumber, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VillaModelImpl &&
            (identical(other.id, id) || other.id == id) &&
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
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, villaName, location,
      villaNumber, notes, createdAt, updatedAt);

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
      required final String villaName,
      required final String location,
      final String villaNumber,
      final String notes,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$VillaModelImpl;

  factory _VillaModel.fromJson(Map<String, dynamic> json) =
      _$VillaModelImpl.fromJson;

  @override
  String get id;
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

  /// Create a copy of VillaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VillaModelImplCopyWith<_$VillaModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

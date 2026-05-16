import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/constants/enums.dart';

part 'villa_model.freezed.dart';
part 'villa_model.g.dart';

@freezed
class VillaModel with _$VillaModel {
  const factory VillaModel({
    required String id,
    required String villaName,
    required String location,
    // Legacy compatibility field for old local/Firebase records.
    // New UI and validation use villaName for identification.
    @Default('') String villaNumber,
    @Default('') String notes,
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default(false) bool isDeleted,
    @Default('pending') String syncStatus,
    DateTime? deletedAt,
    String? deletedBy,
    String? createdBy,
    String? updatedBy,
    DateTime? lastSyncedAt,
    double? latitude,
    double? longitude,
    String? mapAddress,
    String? googleMapsUrl,
    String? wazeUrl,
  }) = _VillaModel;

  factory VillaModel.fromJson(Map<String, dynamic> json) =>
      _$VillaModelFromJson(json);
}

extension VillaModelLegacyRoomFields on VillaModel {
  String get tenantName => '';

  String get tenantPhone => '';

  double get monthlyRent => 0;

  DateTime get contractStartDate => createdAt;

  DateTime get contractEndDate => createdAt;

  int get paymentDueDay => 1;

  VillaStatus get status => VillaStatus.vacant;
}

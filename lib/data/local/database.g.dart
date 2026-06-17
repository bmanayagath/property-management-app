// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $VillasTable extends Villas with TableInfo<$VillasTable, Villa> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VillasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orgIdMeta = const VerificationMeta('orgId');
  @override
  late final GeneratedColumn<String> orgId = GeneratedColumn<String>(
      'org_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('default_org'));
  static const VerificationMeta _villaNameMeta =
      const VerificationMeta('villaName');
  @override
  late final GeneratedColumn<String> villaName = GeneratedColumn<String>(
      'villa_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _villaNumberMeta =
      const VerificationMeta('villaNumber');
  @override
  late final GeneratedColumn<String> villaNumber = GeneratedColumn<String>(
      'villa_number', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _tenantNameMeta =
      const VerificationMeta('tenantName');
  @override
  late final GeneratedColumn<String> tenantName = GeneratedColumn<String>(
      'tenant_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tenantPhoneMeta =
      const VerificationMeta('tenantPhone');
  @override
  late final GeneratedColumn<String> tenantPhone = GeneratedColumn<String>(
      'tenant_phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _monthlyRentMeta =
      const VerificationMeta('monthlyRent');
  @override
  late final GeneratedColumn<double> monthlyRent = GeneratedColumn<double>(
      'monthly_rent', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _contractStartDateMeta =
      const VerificationMeta('contractStartDate');
  @override
  late final GeneratedColumn<DateTime> contractStartDate =
      GeneratedColumn<DateTime>('contract_start_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _contractEndDateMeta =
      const VerificationMeta('contractEndDate');
  @override
  late final GeneratedColumn<DateTime> contractEndDate =
      GeneratedColumn<DateTime>('contract_end_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _paymentDueDayMeta =
      const VerificationMeta('paymentDueDay');
  @override
  late final GeneratedColumn<int> paymentDueDay = GeneratedColumn<int>(
      'payment_due_day', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<int> isDeleted = GeneratedColumn<int>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deletedByMeta =
      const VerificationMeta('deletedBy');
  @override
  late final GeneratedColumn<String> deletedBy = GeneratedColumn<String>(
      'deleted_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedByMeta =
      const VerificationMeta('updatedBy');
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
      'updated_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _mapAddressMeta =
      const VerificationMeta('mapAddress');
  @override
  late final GeneratedColumn<String> mapAddress = GeneratedColumn<String>(
      'map_address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _googleMapsUrlMeta =
      const VerificationMeta('googleMapsUrl');
  @override
  late final GeneratedColumn<String> googleMapsUrl = GeneratedColumn<String>(
      'google_maps_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _wazeUrlMeta =
      const VerificationMeta('wazeUrl');
  @override
  late final GeneratedColumn<String> wazeUrl = GeneratedColumn<String>(
      'waze_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        orgId,
        villaName,
        villaNumber,
        location,
        notes,
        tenantName,
        tenantPhone,
        monthlyRent,
        contractStartDate,
        contractEndDate,
        paymentDueDay,
        status,
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
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'villas';
  @override
  VerificationContext validateIntegrity(Insertable<Villa> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('org_id')) {
      context.handle(
          _orgIdMeta, orgId.isAcceptableOrUnknown(data['org_id']!, _orgIdMeta));
    }
    if (data.containsKey('villa_name')) {
      context.handle(_villaNameMeta,
          villaName.isAcceptableOrUnknown(data['villa_name']!, _villaNameMeta));
    } else if (isInserting) {
      context.missing(_villaNameMeta);
    }
    if (data.containsKey('villa_number')) {
      context.handle(
          _villaNumberMeta,
          villaNumber.isAcceptableOrUnknown(
              data['villa_number']!, _villaNumberMeta));
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('tenant_name')) {
      context.handle(
          _tenantNameMeta,
          tenantName.isAcceptableOrUnknown(
              data['tenant_name']!, _tenantNameMeta));
    } else if (isInserting) {
      context.missing(_tenantNameMeta);
    }
    if (data.containsKey('tenant_phone')) {
      context.handle(
          _tenantPhoneMeta,
          tenantPhone.isAcceptableOrUnknown(
              data['tenant_phone']!, _tenantPhoneMeta));
    } else if (isInserting) {
      context.missing(_tenantPhoneMeta);
    }
    if (data.containsKey('monthly_rent')) {
      context.handle(
          _monthlyRentMeta,
          monthlyRent.isAcceptableOrUnknown(
              data['monthly_rent']!, _monthlyRentMeta));
    } else if (isInserting) {
      context.missing(_monthlyRentMeta);
    }
    if (data.containsKey('contract_start_date')) {
      context.handle(
          _contractStartDateMeta,
          contractStartDate.isAcceptableOrUnknown(
              data['contract_start_date']!, _contractStartDateMeta));
    } else if (isInserting) {
      context.missing(_contractStartDateMeta);
    }
    if (data.containsKey('contract_end_date')) {
      context.handle(
          _contractEndDateMeta,
          contractEndDate.isAcceptableOrUnknown(
              data['contract_end_date']!, _contractEndDateMeta));
    } else if (isInserting) {
      context.missing(_contractEndDateMeta);
    }
    if (data.containsKey('payment_due_day')) {
      context.handle(
          _paymentDueDayMeta,
          paymentDueDay.isAcceptableOrUnknown(
              data['payment_due_day']!, _paymentDueDayMeta));
    } else if (isInserting) {
      context.missing(_paymentDueDayMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('deleted_by')) {
      context.handle(_deletedByMeta,
          deletedBy.isAcceptableOrUnknown(data['deleted_by']!, _deletedByMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    }
    if (data.containsKey('updated_by')) {
      context.handle(_updatedByMeta,
          updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    if (data.containsKey('map_address')) {
      context.handle(
          _mapAddressMeta,
          mapAddress.isAcceptableOrUnknown(
              data['map_address']!, _mapAddressMeta));
    }
    if (data.containsKey('google_maps_url')) {
      context.handle(
          _googleMapsUrlMeta,
          googleMapsUrl.isAcceptableOrUnknown(
              data['google_maps_url']!, _googleMapsUrlMeta));
    }
    if (data.containsKey('waze_url')) {
      context.handle(_wazeUrlMeta,
          wazeUrl.isAcceptableOrUnknown(data['waze_url']!, _wazeUrlMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Villa map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Villa(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      orgId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}org_id'])!,
      villaName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}villa_name'])!,
      villaNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}villa_number'])!,
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      tenantName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_name'])!,
      tenantPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_phone'])!,
      monthlyRent: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monthly_rent'])!,
      contractStartDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}contract_start_date'])!,
      contractEndDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}contract_end_date'])!,
      paymentDueDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}payment_due_day'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_deleted'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      deletedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_by']),
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by']),
      updatedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_by']),
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      mapAddress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}map_address']),
      googleMapsUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}google_maps_url']),
      wazeUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}waze_url']),
    );
  }

  @override
  $VillasTable createAlias(String alias) {
    return $VillasTable(attachedDatabase, alias);
  }
}

class Villa extends DataClass implements Insertable<Villa> {
  final String id;
  final String orgId;
  final String villaName;
  final String villaNumber;
  final String location;
  final String notes;
  final String tenantName;
  final String tenantPhone;
  final double monthlyRent;
  final DateTime contractStartDate;
  final DateTime contractEndDate;
  final int paymentDueDay;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int isDeleted;
  final String syncStatus;
  final DateTime? deletedAt;
  final String? deletedBy;
  final String? createdBy;
  final String? updatedBy;
  final DateTime? lastSyncedAt;
  final double? latitude;
  final double? longitude;
  final String? mapAddress;
  final String? googleMapsUrl;
  final String? wazeUrl;
  const Villa(
      {required this.id,
      required this.orgId,
      required this.villaName,
      required this.villaNumber,
      required this.location,
      required this.notes,
      required this.tenantName,
      required this.tenantPhone,
      required this.monthlyRent,
      required this.contractStartDate,
      required this.contractEndDate,
      required this.paymentDueDay,
      required this.status,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.syncStatus,
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
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['org_id'] = Variable<String>(orgId);
    map['villa_name'] = Variable<String>(villaName);
    map['villa_number'] = Variable<String>(villaNumber);
    map['location'] = Variable<String>(location);
    map['notes'] = Variable<String>(notes);
    map['tenant_name'] = Variable<String>(tenantName);
    map['tenant_phone'] = Variable<String>(tenantPhone);
    map['monthly_rent'] = Variable<double>(monthlyRent);
    map['contract_start_date'] = Variable<DateTime>(contractStartDate);
    map['contract_end_date'] = Variable<DateTime>(contractEndDate);
    map['payment_due_day'] = Variable<int>(paymentDueDay);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<int>(isDeleted);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || deletedBy != null) {
      map['deleted_by'] = Variable<String>(deletedBy);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || mapAddress != null) {
      map['map_address'] = Variable<String>(mapAddress);
    }
    if (!nullToAbsent || googleMapsUrl != null) {
      map['google_maps_url'] = Variable<String>(googleMapsUrl);
    }
    if (!nullToAbsent || wazeUrl != null) {
      map['waze_url'] = Variable<String>(wazeUrl);
    }
    return map;
  }

  VillasCompanion toCompanion(bool nullToAbsent) {
    return VillasCompanion(
      id: Value(id),
      orgId: Value(orgId),
      villaName: Value(villaName),
      villaNumber: Value(villaNumber),
      location: Value(location),
      notes: Value(notes),
      tenantName: Value(tenantName),
      tenantPhone: Value(tenantPhone),
      monthlyRent: Value(monthlyRent),
      contractStartDate: Value(contractStartDate),
      contractEndDate: Value(contractEndDate),
      paymentDueDay: Value(paymentDueDay),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      syncStatus: Value(syncStatus),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deletedBy: deletedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedBy),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      mapAddress: mapAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(mapAddress),
      googleMapsUrl: googleMapsUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(googleMapsUrl),
      wazeUrl: wazeUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(wazeUrl),
    );
  }

  factory Villa.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Villa(
      id: serializer.fromJson<String>(json['id']),
      orgId: serializer.fromJson<String>(json['orgId']),
      villaName: serializer.fromJson<String>(json['villaName']),
      villaNumber: serializer.fromJson<String>(json['villaNumber']),
      location: serializer.fromJson<String>(json['location']),
      notes: serializer.fromJson<String>(json['notes']),
      tenantName: serializer.fromJson<String>(json['tenantName']),
      tenantPhone: serializer.fromJson<String>(json['tenantPhone']),
      monthlyRent: serializer.fromJson<double>(json['monthlyRent']),
      contractStartDate:
          serializer.fromJson<DateTime>(json['contractStartDate']),
      contractEndDate: serializer.fromJson<DateTime>(json['contractEndDate']),
      paymentDueDay: serializer.fromJson<int>(json['paymentDueDay']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<int>(json['isDeleted']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deletedBy: serializer.fromJson<String?>(json['deletedBy']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      mapAddress: serializer.fromJson<String?>(json['mapAddress']),
      googleMapsUrl: serializer.fromJson<String?>(json['googleMapsUrl']),
      wazeUrl: serializer.fromJson<String?>(json['wazeUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'orgId': serializer.toJson<String>(orgId),
      'villaName': serializer.toJson<String>(villaName),
      'villaNumber': serializer.toJson<String>(villaNumber),
      'location': serializer.toJson<String>(location),
      'notes': serializer.toJson<String>(notes),
      'tenantName': serializer.toJson<String>(tenantName),
      'tenantPhone': serializer.toJson<String>(tenantPhone),
      'monthlyRent': serializer.toJson<double>(monthlyRent),
      'contractStartDate': serializer.toJson<DateTime>(contractStartDate),
      'contractEndDate': serializer.toJson<DateTime>(contractEndDate),
      'paymentDueDay': serializer.toJson<int>(paymentDueDay),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<int>(isDeleted),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deletedBy': serializer.toJson<String?>(deletedBy),
      'createdBy': serializer.toJson<String?>(createdBy),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'mapAddress': serializer.toJson<String?>(mapAddress),
      'googleMapsUrl': serializer.toJson<String?>(googleMapsUrl),
      'wazeUrl': serializer.toJson<String?>(wazeUrl),
    };
  }

  Villa copyWith(
          {String? id,
          String? orgId,
          String? villaName,
          String? villaNumber,
          String? location,
          String? notes,
          String? tenantName,
          String? tenantPhone,
          double? monthlyRent,
          DateTime? contractStartDate,
          DateTime? contractEndDate,
          int? paymentDueDay,
          String? status,
          DateTime? createdAt,
          DateTime? updatedAt,
          int? isDeleted,
          String? syncStatus,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> deletedBy = const Value.absent(),
          Value<String?> createdBy = const Value.absent(),
          Value<String?> updatedBy = const Value.absent(),
          Value<DateTime?> lastSyncedAt = const Value.absent(),
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          Value<String?> mapAddress = const Value.absent(),
          Value<String?> googleMapsUrl = const Value.absent(),
          Value<String?> wazeUrl = const Value.absent()}) =>
      Villa(
        id: id ?? this.id,
        orgId: orgId ?? this.orgId,
        villaName: villaName ?? this.villaName,
        villaNumber: villaNumber ?? this.villaNumber,
        location: location ?? this.location,
        notes: notes ?? this.notes,
        tenantName: tenantName ?? this.tenantName,
        tenantPhone: tenantPhone ?? this.tenantPhone,
        monthlyRent: monthlyRent ?? this.monthlyRent,
        contractStartDate: contractStartDate ?? this.contractStartDate,
        contractEndDate: contractEndDate ?? this.contractEndDate,
        paymentDueDay: paymentDueDay ?? this.paymentDueDay,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        syncStatus: syncStatus ?? this.syncStatus,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        deletedBy: deletedBy.present ? deletedBy.value : this.deletedBy,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        mapAddress: mapAddress.present ? mapAddress.value : this.mapAddress,
        googleMapsUrl:
            googleMapsUrl.present ? googleMapsUrl.value : this.googleMapsUrl,
        wazeUrl: wazeUrl.present ? wazeUrl.value : this.wazeUrl,
      );
  Villa copyWithCompanion(VillasCompanion data) {
    return Villa(
      id: data.id.present ? data.id.value : this.id,
      orgId: data.orgId.present ? data.orgId.value : this.orgId,
      villaName: data.villaName.present ? data.villaName.value : this.villaName,
      villaNumber:
          data.villaNumber.present ? data.villaNumber.value : this.villaNumber,
      location: data.location.present ? data.location.value : this.location,
      notes: data.notes.present ? data.notes.value : this.notes,
      tenantName:
          data.tenantName.present ? data.tenantName.value : this.tenantName,
      tenantPhone:
          data.tenantPhone.present ? data.tenantPhone.value : this.tenantPhone,
      monthlyRent:
          data.monthlyRent.present ? data.monthlyRent.value : this.monthlyRent,
      contractStartDate: data.contractStartDate.present
          ? data.contractStartDate.value
          : this.contractStartDate,
      contractEndDate: data.contractEndDate.present
          ? data.contractEndDate.value
          : this.contractEndDate,
      paymentDueDay: data.paymentDueDay.present
          ? data.paymentDueDay.value
          : this.paymentDueDay,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deletedBy: data.deletedBy.present ? data.deletedBy.value : this.deletedBy,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      mapAddress:
          data.mapAddress.present ? data.mapAddress.value : this.mapAddress,
      googleMapsUrl: data.googleMapsUrl.present
          ? data.googleMapsUrl.value
          : this.googleMapsUrl,
      wazeUrl: data.wazeUrl.present ? data.wazeUrl.value : this.wazeUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Villa(')
          ..write('id: $id, ')
          ..write('orgId: $orgId, ')
          ..write('villaName: $villaName, ')
          ..write('villaNumber: $villaNumber, ')
          ..write('location: $location, ')
          ..write('notes: $notes, ')
          ..write('tenantName: $tenantName, ')
          ..write('tenantPhone: $tenantPhone, ')
          ..write('monthlyRent: $monthlyRent, ')
          ..write('contractStartDate: $contractStartDate, ')
          ..write('contractEndDate: $contractEndDate, ')
          ..write('paymentDueDay: $paymentDueDay, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deletedBy: $deletedBy, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('mapAddress: $mapAddress, ')
          ..write('googleMapsUrl: $googleMapsUrl, ')
          ..write('wazeUrl: $wazeUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        orgId,
        villaName,
        villaNumber,
        location,
        notes,
        tenantName,
        tenantPhone,
        monthlyRent,
        contractStartDate,
        contractEndDate,
        paymentDueDay,
        status,
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
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Villa &&
          other.id == this.id &&
          other.orgId == this.orgId &&
          other.villaName == this.villaName &&
          other.villaNumber == this.villaNumber &&
          other.location == this.location &&
          other.notes == this.notes &&
          other.tenantName == this.tenantName &&
          other.tenantPhone == this.tenantPhone &&
          other.monthlyRent == this.monthlyRent &&
          other.contractStartDate == this.contractStartDate &&
          other.contractEndDate == this.contractEndDate &&
          other.paymentDueDay == this.paymentDueDay &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.syncStatus == this.syncStatus &&
          other.deletedAt == this.deletedAt &&
          other.deletedBy == this.deletedBy &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.mapAddress == this.mapAddress &&
          other.googleMapsUrl == this.googleMapsUrl &&
          other.wazeUrl == this.wazeUrl);
}

class VillasCompanion extends UpdateCompanion<Villa> {
  final Value<String> id;
  final Value<String> orgId;
  final Value<String> villaName;
  final Value<String> villaNumber;
  final Value<String> location;
  final Value<String> notes;
  final Value<String> tenantName;
  final Value<String> tenantPhone;
  final Value<double> monthlyRent;
  final Value<DateTime> contractStartDate;
  final Value<DateTime> contractEndDate;
  final Value<int> paymentDueDay;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> isDeleted;
  final Value<String> syncStatus;
  final Value<DateTime?> deletedAt;
  final Value<String?> deletedBy;
  final Value<String?> createdBy;
  final Value<String?> updatedBy;
  final Value<DateTime?> lastSyncedAt;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> mapAddress;
  final Value<String?> googleMapsUrl;
  final Value<String?> wazeUrl;
  final Value<int> rowid;
  const VillasCompanion({
    this.id = const Value.absent(),
    this.orgId = const Value.absent(),
    this.villaName = const Value.absent(),
    this.villaNumber = const Value.absent(),
    this.location = const Value.absent(),
    this.notes = const Value.absent(),
    this.tenantName = const Value.absent(),
    this.tenantPhone = const Value.absent(),
    this.monthlyRent = const Value.absent(),
    this.contractStartDate = const Value.absent(),
    this.contractEndDate = const Value.absent(),
    this.paymentDueDay = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deletedBy = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.mapAddress = const Value.absent(),
    this.googleMapsUrl = const Value.absent(),
    this.wazeUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VillasCompanion.insert({
    required String id,
    this.orgId = const Value.absent(),
    required String villaName,
    this.villaNumber = const Value.absent(),
    required String location,
    this.notes = const Value.absent(),
    required String tenantName,
    required String tenantPhone,
    required double monthlyRent,
    required DateTime contractStartDate,
    required DateTime contractEndDate,
    required int paymentDueDay,
    required String status,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deletedBy = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.mapAddress = const Value.absent(),
    this.googleMapsUrl = const Value.absent(),
    this.wazeUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        villaName = Value(villaName),
        location = Value(location),
        tenantName = Value(tenantName),
        tenantPhone = Value(tenantPhone),
        monthlyRent = Value(monthlyRent),
        contractStartDate = Value(contractStartDate),
        contractEndDate = Value(contractEndDate),
        paymentDueDay = Value(paymentDueDay),
        status = Value(status);
  static Insertable<Villa> custom({
    Expression<String>? id,
    Expression<String>? orgId,
    Expression<String>? villaName,
    Expression<String>? villaNumber,
    Expression<String>? location,
    Expression<String>? notes,
    Expression<String>? tenantName,
    Expression<String>? tenantPhone,
    Expression<double>? monthlyRent,
    Expression<DateTime>? contractStartDate,
    Expression<DateTime>? contractEndDate,
    Expression<int>? paymentDueDay,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? isDeleted,
    Expression<String>? syncStatus,
    Expression<DateTime>? deletedAt,
    Expression<String>? deletedBy,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<DateTime>? lastSyncedAt,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? mapAddress,
    Expression<String>? googleMapsUrl,
    Expression<String>? wazeUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orgId != null) 'org_id': orgId,
      if (villaName != null) 'villa_name': villaName,
      if (villaNumber != null) 'villa_number': villaNumber,
      if (location != null) 'location': location,
      if (notes != null) 'notes': notes,
      if (tenantName != null) 'tenant_name': tenantName,
      if (tenantPhone != null) 'tenant_phone': tenantPhone,
      if (monthlyRent != null) 'monthly_rent': monthlyRent,
      if (contractStartDate != null) 'contract_start_date': contractStartDate,
      if (contractEndDate != null) 'contract_end_date': contractEndDate,
      if (paymentDueDay != null) 'payment_due_day': paymentDueDay,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deletedBy != null) 'deleted_by': deletedBy,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (mapAddress != null) 'map_address': mapAddress,
      if (googleMapsUrl != null) 'google_maps_url': googleMapsUrl,
      if (wazeUrl != null) 'waze_url': wazeUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VillasCompanion copyWith(
      {Value<String>? id,
      Value<String>? orgId,
      Value<String>? villaName,
      Value<String>? villaNumber,
      Value<String>? location,
      Value<String>? notes,
      Value<String>? tenantName,
      Value<String>? tenantPhone,
      Value<double>? monthlyRent,
      Value<DateTime>? contractStartDate,
      Value<DateTime>? contractEndDate,
      Value<int>? paymentDueDay,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? isDeleted,
      Value<String>? syncStatus,
      Value<DateTime?>? deletedAt,
      Value<String?>? deletedBy,
      Value<String?>? createdBy,
      Value<String?>? updatedBy,
      Value<DateTime?>? lastSyncedAt,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<String?>? mapAddress,
      Value<String?>? googleMapsUrl,
      Value<String?>? wazeUrl,
      Value<int>? rowid}) {
    return VillasCompanion(
      id: id ?? this.id,
      orgId: orgId ?? this.orgId,
      villaName: villaName ?? this.villaName,
      villaNumber: villaNumber ?? this.villaNumber,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      tenantName: tenantName ?? this.tenantName,
      tenantPhone: tenantPhone ?? this.tenantPhone,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      contractStartDate: contractStartDate ?? this.contractStartDate,
      contractEndDate: contractEndDate ?? this.contractEndDate,
      paymentDueDay: paymentDueDay ?? this.paymentDueDay,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      mapAddress: mapAddress ?? this.mapAddress,
      googleMapsUrl: googleMapsUrl ?? this.googleMapsUrl,
      wazeUrl: wazeUrl ?? this.wazeUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (orgId.present) {
      map['org_id'] = Variable<String>(orgId.value);
    }
    if (villaName.present) {
      map['villa_name'] = Variable<String>(villaName.value);
    }
    if (villaNumber.present) {
      map['villa_number'] = Variable<String>(villaNumber.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (tenantName.present) {
      map['tenant_name'] = Variable<String>(tenantName.value);
    }
    if (tenantPhone.present) {
      map['tenant_phone'] = Variable<String>(tenantPhone.value);
    }
    if (monthlyRent.present) {
      map['monthly_rent'] = Variable<double>(monthlyRent.value);
    }
    if (contractStartDate.present) {
      map['contract_start_date'] = Variable<DateTime>(contractStartDate.value);
    }
    if (contractEndDate.present) {
      map['contract_end_date'] = Variable<DateTime>(contractEndDate.value);
    }
    if (paymentDueDay.present) {
      map['payment_due_day'] = Variable<int>(paymentDueDay.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<int>(isDeleted.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deletedBy.present) {
      map['deleted_by'] = Variable<String>(deletedBy.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (mapAddress.present) {
      map['map_address'] = Variable<String>(mapAddress.value);
    }
    if (googleMapsUrl.present) {
      map['google_maps_url'] = Variable<String>(googleMapsUrl.value);
    }
    if (wazeUrl.present) {
      map['waze_url'] = Variable<String>(wazeUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VillasCompanion(')
          ..write('id: $id, ')
          ..write('orgId: $orgId, ')
          ..write('villaName: $villaName, ')
          ..write('villaNumber: $villaNumber, ')
          ..write('location: $location, ')
          ..write('notes: $notes, ')
          ..write('tenantName: $tenantName, ')
          ..write('tenantPhone: $tenantPhone, ')
          ..write('monthlyRent: $monthlyRent, ')
          ..write('contractStartDate: $contractStartDate, ')
          ..write('contractEndDate: $contractEndDate, ')
          ..write('paymentDueDay: $paymentDueDay, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deletedBy: $deletedBy, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('mapAddress: $mapAddress, ')
          ..write('googleMapsUrl: $googleMapsUrl, ')
          ..write('wazeUrl: $wazeUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoomsTable extends Rooms with TableInfo<$RoomsTable, Room> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orgIdMeta = const VerificationMeta('orgId');
  @override
  late final GeneratedColumn<String> orgId = GeneratedColumn<String>(
      'org_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('default_org'));
  static const VerificationMeta _villaIdMeta =
      const VerificationMeta('villaId');
  @override
  late final GeneratedColumn<String> villaId = GeneratedColumn<String>(
      'villa_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES villas (id)'));
  static const VerificationMeta _villaNameMeta =
      const VerificationMeta('villaName');
  @override
  late final GeneratedColumn<String> villaName = GeneratedColumn<String>(
      'villa_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roomNameMeta =
      const VerificationMeta('roomName');
  @override
  late final GeneratedColumn<String> roomName = GeneratedColumn<String>(
      'room_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roomNumberMeta =
      const VerificationMeta('roomNumber');
  @override
  late final GeneratedColumn<String> roomNumber = GeneratedColumn<String>(
      'room_number', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _tenantNameMeta =
      const VerificationMeta('tenantName');
  @override
  late final GeneratedColumn<String> tenantName = GeneratedColumn<String>(
      'tenant_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tenantPhoneMeta =
      const VerificationMeta('tenantPhone');
  @override
  late final GeneratedColumn<String> tenantPhone = GeneratedColumn<String>(
      'tenant_phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _monthlyRentMeta =
      const VerificationMeta('monthlyRent');
  @override
  late final GeneratedColumn<double> monthlyRent = GeneratedColumn<double>(
      'monthly_rent', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _contractStartDateMeta =
      const VerificationMeta('contractStartDate');
  @override
  late final GeneratedColumn<DateTime> contractStartDate =
      GeneratedColumn<DateTime>('contract_start_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _contractEndDateMeta =
      const VerificationMeta('contractEndDate');
  @override
  late final GeneratedColumn<DateTime> contractEndDate =
      GeneratedColumn<DateTime>('contract_end_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _paymentDueDayMeta =
      const VerificationMeta('paymentDueDay');
  @override
  late final GeneratedColumn<int> paymentDueDay = GeneratedColumn<int>(
      'payment_due_day', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<int> isDeleted = GeneratedColumn<int>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deletedByMeta =
      const VerificationMeta('deletedBy');
  @override
  late final GeneratedColumn<String> deletedBy = GeneratedColumn<String>(
      'deleted_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedByMeta =
      const VerificationMeta('updatedBy');
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
      'updated_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _depositTypeMeta =
      const VerificationMeta('depositType');
  @override
  late final GeneratedColumn<String> depositType = GeneratedColumn<String>(
      'deposit_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('None'));
  static const VerificationMeta _depositAmountMeta =
      const VerificationMeta('depositAmount');
  @override
  late final GeneratedColumn<double> depositAmount = GeneratedColumn<double>(
      'deposit_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _depositDateMeta =
      const VerificationMeta('depositDate');
  @override
  late final GeneratedColumn<DateTime> depositDate = GeneratedColumn<DateTime>(
      'deposit_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _depositStatusMeta =
      const VerificationMeta('depositStatus');
  @override
  late final GeneratedColumn<String> depositStatus = GeneratedColumn<String>(
      'deposit_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Held'));
  static const VerificationMeta _depositNotesMeta =
      const VerificationMeta('depositNotes');
  @override
  late final GeneratedColumn<String> depositNotes = GeneratedColumn<String>(
      'deposit_notes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _depositIncomeIdMeta =
      const VerificationMeta('depositIncomeId');
  @override
  late final GeneratedColumn<String> depositIncomeId = GeneratedColumn<String>(
      'deposit_income_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _depositRefundExpenseIdMeta =
      const VerificationMeta('depositRefundExpenseId');
  @override
  late final GeneratedColumn<String> depositRefundExpenseId =
      GeneratedColumn<String>('deposit_refund_expense_id', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant(''));
  static const VerificationMeta _moveInDateMeta =
      const VerificationMeta('moveInDate');
  @override
  late final GeneratedColumn<DateTime> moveInDate = GeneratedColumn<DateTime>(
      'move_in_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _moveOutDateMeta =
      const VerificationMeta('moveOutDate');
  @override
  late final GeneratedColumn<DateTime> moveOutDate = GeneratedColumn<DateTime>(
      'move_out_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastTenantNameMeta =
      const VerificationMeta('lastTenantName');
  @override
  late final GeneratedColumn<String> lastTenantName = GeneratedColumn<String>(
      'last_tenant_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _lastTenantPhoneMeta =
      const VerificationMeta('lastTenantPhone');
  @override
  late final GeneratedColumn<String> lastTenantPhone = GeneratedColumn<String>(
      'last_tenant_phone', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _refundAmountMeta =
      const VerificationMeta('refundAmount');
  @override
  late final GeneratedColumn<double> refundAmount = GeneratedColumn<double>(
      'refund_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _retainedAmountMeta =
      const VerificationMeta('retainedAmount');
  @override
  late final GeneratedColumn<double> retainedAmount = GeneratedColumn<double>(
      'retained_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _depositReasonMeta =
      const VerificationMeta('depositReason');
  @override
  late final GeneratedColumn<String> depositReason = GeneratedColumn<String>(
      'deposit_reason', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _tenantHistoryJsonMeta =
      const VerificationMeta('tenantHistoryJson');
  @override
  late final GeneratedColumn<String> tenantHistoryJson =
      GeneratedColumn<String>('tenant_history_json', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        orgId,
        villaId,
        villaName,
        roomName,
        roomNumber,
        tenantName,
        tenantPhone,
        monthlyRent,
        contractStartDate,
        contractEndDate,
        paymentDueDay,
        status,
        createdAt,
        updatedAt,
        isDeleted,
        syncStatus,
        deletedAt,
        deletedBy,
        createdBy,
        updatedBy,
        lastSyncedAt,
        depositType,
        depositAmount,
        depositDate,
        depositStatus,
        depositNotes,
        depositIncomeId,
        depositRefundExpenseId,
        moveInDate,
        moveOutDate,
        lastTenantName,
        lastTenantPhone,
        refundAmount,
        retainedAmount,
        depositReason,
        tenantHistoryJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rooms';
  @override
  VerificationContext validateIntegrity(Insertable<Room> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('org_id')) {
      context.handle(
          _orgIdMeta, orgId.isAcceptableOrUnknown(data['org_id']!, _orgIdMeta));
    }
    if (data.containsKey('villa_id')) {
      context.handle(_villaIdMeta,
          villaId.isAcceptableOrUnknown(data['villa_id']!, _villaIdMeta));
    } else if (isInserting) {
      context.missing(_villaIdMeta);
    }
    if (data.containsKey('villa_name')) {
      context.handle(_villaNameMeta,
          villaName.isAcceptableOrUnknown(data['villa_name']!, _villaNameMeta));
    } else if (isInserting) {
      context.missing(_villaNameMeta);
    }
    if (data.containsKey('room_name')) {
      context.handle(_roomNameMeta,
          roomName.isAcceptableOrUnknown(data['room_name']!, _roomNameMeta));
    } else if (isInserting) {
      context.missing(_roomNameMeta);
    }
    if (data.containsKey('room_number')) {
      context.handle(
          _roomNumberMeta,
          roomNumber.isAcceptableOrUnknown(
              data['room_number']!, _roomNumberMeta));
    }
    if (data.containsKey('tenant_name')) {
      context.handle(
          _tenantNameMeta,
          tenantName.isAcceptableOrUnknown(
              data['tenant_name']!, _tenantNameMeta));
    }
    if (data.containsKey('tenant_phone')) {
      context.handle(
          _tenantPhoneMeta,
          tenantPhone.isAcceptableOrUnknown(
              data['tenant_phone']!, _tenantPhoneMeta));
    }
    if (data.containsKey('monthly_rent')) {
      context.handle(
          _monthlyRentMeta,
          monthlyRent.isAcceptableOrUnknown(
              data['monthly_rent']!, _monthlyRentMeta));
    } else if (isInserting) {
      context.missing(_monthlyRentMeta);
    }
    if (data.containsKey('contract_start_date')) {
      context.handle(
          _contractStartDateMeta,
          contractStartDate.isAcceptableOrUnknown(
              data['contract_start_date']!, _contractStartDateMeta));
    }
    if (data.containsKey('contract_end_date')) {
      context.handle(
          _contractEndDateMeta,
          contractEndDate.isAcceptableOrUnknown(
              data['contract_end_date']!, _contractEndDateMeta));
    }
    if (data.containsKey('payment_due_day')) {
      context.handle(
          _paymentDueDayMeta,
          paymentDueDay.isAcceptableOrUnknown(
              data['payment_due_day']!, _paymentDueDayMeta));
    } else if (isInserting) {
      context.missing(_paymentDueDayMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('deleted_by')) {
      context.handle(_deletedByMeta,
          deletedBy.isAcceptableOrUnknown(data['deleted_by']!, _deletedByMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    }
    if (data.containsKey('updated_by')) {
      context.handle(_updatedByMeta,
          updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    if (data.containsKey('deposit_type')) {
      context.handle(
          _depositTypeMeta,
          depositType.isAcceptableOrUnknown(
              data['deposit_type']!, _depositTypeMeta));
    }
    if (data.containsKey('deposit_amount')) {
      context.handle(
          _depositAmountMeta,
          depositAmount.isAcceptableOrUnknown(
              data['deposit_amount']!, _depositAmountMeta));
    }
    if (data.containsKey('deposit_date')) {
      context.handle(
          _depositDateMeta,
          depositDate.isAcceptableOrUnknown(
              data['deposit_date']!, _depositDateMeta));
    }
    if (data.containsKey('deposit_status')) {
      context.handle(
          _depositStatusMeta,
          depositStatus.isAcceptableOrUnknown(
              data['deposit_status']!, _depositStatusMeta));
    }
    if (data.containsKey('deposit_notes')) {
      context.handle(
          _depositNotesMeta,
          depositNotes.isAcceptableOrUnknown(
              data['deposit_notes']!, _depositNotesMeta));
    }
    if (data.containsKey('deposit_income_id')) {
      context.handle(
          _depositIncomeIdMeta,
          depositIncomeId.isAcceptableOrUnknown(
              data['deposit_income_id']!, _depositIncomeIdMeta));
    }
    if (data.containsKey('deposit_refund_expense_id')) {
      context.handle(
          _depositRefundExpenseIdMeta,
          depositRefundExpenseId.isAcceptableOrUnknown(
              data['deposit_refund_expense_id']!, _depositRefundExpenseIdMeta));
    }
    if (data.containsKey('move_in_date')) {
      context.handle(
          _moveInDateMeta,
          moveInDate.isAcceptableOrUnknown(
              data['move_in_date']!, _moveInDateMeta));
    }
    if (data.containsKey('move_out_date')) {
      context.handle(
          _moveOutDateMeta,
          moveOutDate.isAcceptableOrUnknown(
              data['move_out_date']!, _moveOutDateMeta));
    }
    if (data.containsKey('last_tenant_name')) {
      context.handle(
          _lastTenantNameMeta,
          lastTenantName.isAcceptableOrUnknown(
              data['last_tenant_name']!, _lastTenantNameMeta));
    }
    if (data.containsKey('last_tenant_phone')) {
      context.handle(
          _lastTenantPhoneMeta,
          lastTenantPhone.isAcceptableOrUnknown(
              data['last_tenant_phone']!, _lastTenantPhoneMeta));
    }
    if (data.containsKey('refund_amount')) {
      context.handle(
          _refundAmountMeta,
          refundAmount.isAcceptableOrUnknown(
              data['refund_amount']!, _refundAmountMeta));
    }
    if (data.containsKey('retained_amount')) {
      context.handle(
          _retainedAmountMeta,
          retainedAmount.isAcceptableOrUnknown(
              data['retained_amount']!, _retainedAmountMeta));
    }
    if (data.containsKey('deposit_reason')) {
      context.handle(
          _depositReasonMeta,
          depositReason.isAcceptableOrUnknown(
              data['deposit_reason']!, _depositReasonMeta));
    }
    if (data.containsKey('tenant_history_json')) {
      context.handle(
          _tenantHistoryJsonMeta,
          tenantHistoryJson.isAcceptableOrUnknown(
              data['tenant_history_json']!, _tenantHistoryJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Room map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Room(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      orgId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}org_id'])!,
      villaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}villa_id'])!,
      villaName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}villa_name'])!,
      roomName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room_name'])!,
      roomNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room_number'])!,
      tenantName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_name']),
      tenantPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_phone']),
      monthlyRent: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monthly_rent'])!,
      contractStartDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}contract_start_date']),
      contractEndDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}contract_end_date']),
      paymentDueDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}payment_due_day'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_deleted'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      deletedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_by']),
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by']),
      updatedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_by']),
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
      depositType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deposit_type'])!,
      depositAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}deposit_amount'])!,
      depositDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deposit_date']),
      depositStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deposit_status'])!,
      depositNotes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deposit_notes'])!,
      depositIncomeId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}deposit_income_id'])!,
      depositRefundExpenseId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deposit_refund_expense_id'])!,
      moveInDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}move_in_date']),
      moveOutDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}move_out_date']),
      lastTenantName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_tenant_name'])!,
      lastTenantPhone: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_tenant_phone'])!,
      refundAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}refund_amount'])!,
      retainedAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}retained_amount'])!,
      depositReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deposit_reason'])!,
      tenantHistoryJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}tenant_history_json'])!,
    );
  }

  @override
  $RoomsTable createAlias(String alias) {
    return $RoomsTable(attachedDatabase, alias);
  }
}

class Room extends DataClass implements Insertable<Room> {
  final String id;
  final String orgId;
  final String villaId;
  final String villaName;
  final String roomName;
  final String roomNumber;
  final String? tenantName;
  final String? tenantPhone;
  final double monthlyRent;
  final DateTime? contractStartDate;
  final DateTime? contractEndDate;
  final int paymentDueDay;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int isDeleted;
  final String syncStatus;
  final DateTime? deletedAt;
  final String? deletedBy;
  final String? createdBy;
  final String? updatedBy;
  final DateTime? lastSyncedAt;
  final String depositType;
  final double depositAmount;
  final DateTime? depositDate;
  final String depositStatus;
  final String depositNotes;
  final String depositIncomeId;
  final String depositRefundExpenseId;
  final DateTime? moveInDate;
  final DateTime? moveOutDate;
  final String lastTenantName;
  final String lastTenantPhone;
  final double refundAmount;
  final double retainedAmount;
  final String depositReason;
  final String tenantHistoryJson;
  const Room(
      {required this.id,
      required this.orgId,
      required this.villaId,
      required this.villaName,
      required this.roomName,
      required this.roomNumber,
      this.tenantName,
      this.tenantPhone,
      required this.monthlyRent,
      this.contractStartDate,
      this.contractEndDate,
      required this.paymentDueDay,
      required this.status,
      required this.createdAt,
      this.updatedAt,
      required this.isDeleted,
      required this.syncStatus,
      this.deletedAt,
      this.deletedBy,
      this.createdBy,
      this.updatedBy,
      this.lastSyncedAt,
      required this.depositType,
      required this.depositAmount,
      this.depositDate,
      required this.depositStatus,
      required this.depositNotes,
      required this.depositIncomeId,
      required this.depositRefundExpenseId,
      this.moveInDate,
      this.moveOutDate,
      required this.lastTenantName,
      required this.lastTenantPhone,
      required this.refundAmount,
      required this.retainedAmount,
      required this.depositReason,
      required this.tenantHistoryJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['org_id'] = Variable<String>(orgId);
    map['villa_id'] = Variable<String>(villaId);
    map['villa_name'] = Variable<String>(villaName);
    map['room_name'] = Variable<String>(roomName);
    map['room_number'] = Variable<String>(roomNumber);
    if (!nullToAbsent || tenantName != null) {
      map['tenant_name'] = Variable<String>(tenantName);
    }
    if (!nullToAbsent || tenantPhone != null) {
      map['tenant_phone'] = Variable<String>(tenantPhone);
    }
    map['monthly_rent'] = Variable<double>(monthlyRent);
    if (!nullToAbsent || contractStartDate != null) {
      map['contract_start_date'] = Variable<DateTime>(contractStartDate);
    }
    if (!nullToAbsent || contractEndDate != null) {
      map['contract_end_date'] = Variable<DateTime>(contractEndDate);
    }
    map['payment_due_day'] = Variable<int>(paymentDueDay);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['is_deleted'] = Variable<int>(isDeleted);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || deletedBy != null) {
      map['deleted_by'] = Variable<String>(deletedBy);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['deposit_type'] = Variable<String>(depositType);
    map['deposit_amount'] = Variable<double>(depositAmount);
    if (!nullToAbsent || depositDate != null) {
      map['deposit_date'] = Variable<DateTime>(depositDate);
    }
    map['deposit_status'] = Variable<String>(depositStatus);
    map['deposit_notes'] = Variable<String>(depositNotes);
    map['deposit_income_id'] = Variable<String>(depositIncomeId);
    map['deposit_refund_expense_id'] = Variable<String>(depositRefundExpenseId);
    if (!nullToAbsent || moveInDate != null) {
      map['move_in_date'] = Variable<DateTime>(moveInDate);
    }
    if (!nullToAbsent || moveOutDate != null) {
      map['move_out_date'] = Variable<DateTime>(moveOutDate);
    }
    map['last_tenant_name'] = Variable<String>(lastTenantName);
    map['last_tenant_phone'] = Variable<String>(lastTenantPhone);
    map['refund_amount'] = Variable<double>(refundAmount);
    map['retained_amount'] = Variable<double>(retainedAmount);
    map['deposit_reason'] = Variable<String>(depositReason);
    map['tenant_history_json'] = Variable<String>(tenantHistoryJson);
    return map;
  }

  RoomsCompanion toCompanion(bool nullToAbsent) {
    return RoomsCompanion(
      id: Value(id),
      orgId: Value(orgId),
      villaId: Value(villaId),
      villaName: Value(villaName),
      roomName: Value(roomName),
      roomNumber: Value(roomNumber),
      tenantName: tenantName == null && nullToAbsent
          ? const Value.absent()
          : Value(tenantName),
      tenantPhone: tenantPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(tenantPhone),
      monthlyRent: Value(monthlyRent),
      contractStartDate: contractStartDate == null && nullToAbsent
          ? const Value.absent()
          : Value(contractStartDate),
      contractEndDate: contractEndDate == null && nullToAbsent
          ? const Value.absent()
          : Value(contractEndDate),
      paymentDueDay: Value(paymentDueDay),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      isDeleted: Value(isDeleted),
      syncStatus: Value(syncStatus),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deletedBy: deletedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedBy),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      depositType: Value(depositType),
      depositAmount: Value(depositAmount),
      depositDate: depositDate == null && nullToAbsent
          ? const Value.absent()
          : Value(depositDate),
      depositStatus: Value(depositStatus),
      depositNotes: Value(depositNotes),
      depositIncomeId: Value(depositIncomeId),
      depositRefundExpenseId: Value(depositRefundExpenseId),
      moveInDate: moveInDate == null && nullToAbsent
          ? const Value.absent()
          : Value(moveInDate),
      moveOutDate: moveOutDate == null && nullToAbsent
          ? const Value.absent()
          : Value(moveOutDate),
      lastTenantName: Value(lastTenantName),
      lastTenantPhone: Value(lastTenantPhone),
      refundAmount: Value(refundAmount),
      retainedAmount: Value(retainedAmount),
      depositReason: Value(depositReason),
      tenantHistoryJson: Value(tenantHistoryJson),
    );
  }

  factory Room.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Room(
      id: serializer.fromJson<String>(json['id']),
      orgId: serializer.fromJson<String>(json['orgId']),
      villaId: serializer.fromJson<String>(json['villaId']),
      villaName: serializer.fromJson<String>(json['villaName']),
      roomName: serializer.fromJson<String>(json['roomName']),
      roomNumber: serializer.fromJson<String>(json['roomNumber']),
      tenantName: serializer.fromJson<String?>(json['tenantName']),
      tenantPhone: serializer.fromJson<String?>(json['tenantPhone']),
      monthlyRent: serializer.fromJson<double>(json['monthlyRent']),
      contractStartDate:
          serializer.fromJson<DateTime?>(json['contractStartDate']),
      contractEndDate: serializer.fromJson<DateTime?>(json['contractEndDate']),
      paymentDueDay: serializer.fromJson<int>(json['paymentDueDay']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      isDeleted: serializer.fromJson<int>(json['isDeleted']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deletedBy: serializer.fromJson<String?>(json['deletedBy']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      depositType: serializer.fromJson<String>(json['depositType']),
      depositAmount: serializer.fromJson<double>(json['depositAmount']),
      depositDate: serializer.fromJson<DateTime?>(json['depositDate']),
      depositStatus: serializer.fromJson<String>(json['depositStatus']),
      depositNotes: serializer.fromJson<String>(json['depositNotes']),
      depositIncomeId: serializer.fromJson<String>(json['depositIncomeId']),
      depositRefundExpenseId:
          serializer.fromJson<String>(json['depositRefundExpenseId']),
      moveInDate: serializer.fromJson<DateTime?>(json['moveInDate']),
      moveOutDate: serializer.fromJson<DateTime?>(json['moveOutDate']),
      lastTenantName: serializer.fromJson<String>(json['lastTenantName']),
      lastTenantPhone: serializer.fromJson<String>(json['lastTenantPhone']),
      refundAmount: serializer.fromJson<double>(json['refundAmount']),
      retainedAmount: serializer.fromJson<double>(json['retainedAmount']),
      depositReason: serializer.fromJson<String>(json['depositReason']),
      tenantHistoryJson: serializer.fromJson<String>(json['tenantHistoryJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'orgId': serializer.toJson<String>(orgId),
      'villaId': serializer.toJson<String>(villaId),
      'villaName': serializer.toJson<String>(villaName),
      'roomName': serializer.toJson<String>(roomName),
      'roomNumber': serializer.toJson<String>(roomNumber),
      'tenantName': serializer.toJson<String?>(tenantName),
      'tenantPhone': serializer.toJson<String?>(tenantPhone),
      'monthlyRent': serializer.toJson<double>(monthlyRent),
      'contractStartDate': serializer.toJson<DateTime?>(contractStartDate),
      'contractEndDate': serializer.toJson<DateTime?>(contractEndDate),
      'paymentDueDay': serializer.toJson<int>(paymentDueDay),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'isDeleted': serializer.toJson<int>(isDeleted),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deletedBy': serializer.toJson<String?>(deletedBy),
      'createdBy': serializer.toJson<String?>(createdBy),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'depositType': serializer.toJson<String>(depositType),
      'depositAmount': serializer.toJson<double>(depositAmount),
      'depositDate': serializer.toJson<DateTime?>(depositDate),
      'depositStatus': serializer.toJson<String>(depositStatus),
      'depositNotes': serializer.toJson<String>(depositNotes),
      'depositIncomeId': serializer.toJson<String>(depositIncomeId),
      'depositRefundExpenseId':
          serializer.toJson<String>(depositRefundExpenseId),
      'moveInDate': serializer.toJson<DateTime?>(moveInDate),
      'moveOutDate': serializer.toJson<DateTime?>(moveOutDate),
      'lastTenantName': serializer.toJson<String>(lastTenantName),
      'lastTenantPhone': serializer.toJson<String>(lastTenantPhone),
      'refundAmount': serializer.toJson<double>(refundAmount),
      'retainedAmount': serializer.toJson<double>(retainedAmount),
      'depositReason': serializer.toJson<String>(depositReason),
      'tenantHistoryJson': serializer.toJson<String>(tenantHistoryJson),
    };
  }

  Room copyWith(
          {String? id,
          String? orgId,
          String? villaId,
          String? villaName,
          String? roomName,
          String? roomNumber,
          Value<String?> tenantName = const Value.absent(),
          Value<String?> tenantPhone = const Value.absent(),
          double? monthlyRent,
          Value<DateTime?> contractStartDate = const Value.absent(),
          Value<DateTime?> contractEndDate = const Value.absent(),
          int? paymentDueDay,
          String? status,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent(),
          int? isDeleted,
          String? syncStatus,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> deletedBy = const Value.absent(),
          Value<String?> createdBy = const Value.absent(),
          Value<String?> updatedBy = const Value.absent(),
          Value<DateTime?> lastSyncedAt = const Value.absent(),
          String? depositType,
          double? depositAmount,
          Value<DateTime?> depositDate = const Value.absent(),
          String? depositStatus,
          String? depositNotes,
          String? depositIncomeId,
          String? depositRefundExpenseId,
          Value<DateTime?> moveInDate = const Value.absent(),
          Value<DateTime?> moveOutDate = const Value.absent(),
          String? lastTenantName,
          String? lastTenantPhone,
          double? refundAmount,
          double? retainedAmount,
          String? depositReason,
          String? tenantHistoryJson}) =>
      Room(
        id: id ?? this.id,
        orgId: orgId ?? this.orgId,
        villaId: villaId ?? this.villaId,
        villaName: villaName ?? this.villaName,
        roomName: roomName ?? this.roomName,
        roomNumber: roomNumber ?? this.roomNumber,
        tenantName: tenantName.present ? tenantName.value : this.tenantName,
        tenantPhone: tenantPhone.present ? tenantPhone.value : this.tenantPhone,
        monthlyRent: monthlyRent ?? this.monthlyRent,
        contractStartDate: contractStartDate.present
            ? contractStartDate.value
            : this.contractStartDate,
        contractEndDate: contractEndDate.present
            ? contractEndDate.value
            : this.contractEndDate,
        paymentDueDay: paymentDueDay ?? this.paymentDueDay,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        syncStatus: syncStatus ?? this.syncStatus,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        deletedBy: deletedBy.present ? deletedBy.value : this.deletedBy,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
        depositType: depositType ?? this.depositType,
        depositAmount: depositAmount ?? this.depositAmount,
        depositDate: depositDate.present ? depositDate.value : this.depositDate,
        depositStatus: depositStatus ?? this.depositStatus,
        depositNotes: depositNotes ?? this.depositNotes,
        depositIncomeId: depositIncomeId ?? this.depositIncomeId,
        depositRefundExpenseId:
            depositRefundExpenseId ?? this.depositRefundExpenseId,
        moveInDate: moveInDate.present ? moveInDate.value : this.moveInDate,
        moveOutDate: moveOutDate.present ? moveOutDate.value : this.moveOutDate,
        lastTenantName: lastTenantName ?? this.lastTenantName,
        lastTenantPhone: lastTenantPhone ?? this.lastTenantPhone,
        refundAmount: refundAmount ?? this.refundAmount,
        retainedAmount: retainedAmount ?? this.retainedAmount,
        depositReason: depositReason ?? this.depositReason,
        tenantHistoryJson: tenantHistoryJson ?? this.tenantHistoryJson,
      );
  Room copyWithCompanion(RoomsCompanion data) {
    return Room(
      id: data.id.present ? data.id.value : this.id,
      orgId: data.orgId.present ? data.orgId.value : this.orgId,
      villaId: data.villaId.present ? data.villaId.value : this.villaId,
      villaName: data.villaName.present ? data.villaName.value : this.villaName,
      roomName: data.roomName.present ? data.roomName.value : this.roomName,
      roomNumber:
          data.roomNumber.present ? data.roomNumber.value : this.roomNumber,
      tenantName:
          data.tenantName.present ? data.tenantName.value : this.tenantName,
      tenantPhone:
          data.tenantPhone.present ? data.tenantPhone.value : this.tenantPhone,
      monthlyRent:
          data.monthlyRent.present ? data.monthlyRent.value : this.monthlyRent,
      contractStartDate: data.contractStartDate.present
          ? data.contractStartDate.value
          : this.contractStartDate,
      contractEndDate: data.contractEndDate.present
          ? data.contractEndDate.value
          : this.contractEndDate,
      paymentDueDay: data.paymentDueDay.present
          ? data.paymentDueDay.value
          : this.paymentDueDay,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deletedBy: data.deletedBy.present ? data.deletedBy.value : this.deletedBy,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      depositType:
          data.depositType.present ? data.depositType.value : this.depositType,
      depositAmount: data.depositAmount.present
          ? data.depositAmount.value
          : this.depositAmount,
      depositDate:
          data.depositDate.present ? data.depositDate.value : this.depositDate,
      depositStatus: data.depositStatus.present
          ? data.depositStatus.value
          : this.depositStatus,
      depositNotes: data.depositNotes.present
          ? data.depositNotes.value
          : this.depositNotes,
      depositIncomeId: data.depositIncomeId.present
          ? data.depositIncomeId.value
          : this.depositIncomeId,
      depositRefundExpenseId: data.depositRefundExpenseId.present
          ? data.depositRefundExpenseId.value
          : this.depositRefundExpenseId,
      moveInDate:
          data.moveInDate.present ? data.moveInDate.value : this.moveInDate,
      moveOutDate:
          data.moveOutDate.present ? data.moveOutDate.value : this.moveOutDate,
      lastTenantName: data.lastTenantName.present
          ? data.lastTenantName.value
          : this.lastTenantName,
      lastTenantPhone: data.lastTenantPhone.present
          ? data.lastTenantPhone.value
          : this.lastTenantPhone,
      refundAmount: data.refundAmount.present
          ? data.refundAmount.value
          : this.refundAmount,
      retainedAmount: data.retainedAmount.present
          ? data.retainedAmount.value
          : this.retainedAmount,
      depositReason: data.depositReason.present
          ? data.depositReason.value
          : this.depositReason,
      tenantHistoryJson: data.tenantHistoryJson.present
          ? data.tenantHistoryJson.value
          : this.tenantHistoryJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Room(')
          ..write('id: $id, ')
          ..write('orgId: $orgId, ')
          ..write('villaId: $villaId, ')
          ..write('villaName: $villaName, ')
          ..write('roomName: $roomName, ')
          ..write('roomNumber: $roomNumber, ')
          ..write('tenantName: $tenantName, ')
          ..write('tenantPhone: $tenantPhone, ')
          ..write('monthlyRent: $monthlyRent, ')
          ..write('contractStartDate: $contractStartDate, ')
          ..write('contractEndDate: $contractEndDate, ')
          ..write('paymentDueDay: $paymentDueDay, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deletedBy: $deletedBy, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('depositType: $depositType, ')
          ..write('depositAmount: $depositAmount, ')
          ..write('depositDate: $depositDate, ')
          ..write('depositStatus: $depositStatus, ')
          ..write('depositNotes: $depositNotes, ')
          ..write('depositIncomeId: $depositIncomeId, ')
          ..write('depositRefundExpenseId: $depositRefundExpenseId, ')
          ..write('moveInDate: $moveInDate, ')
          ..write('moveOutDate: $moveOutDate, ')
          ..write('lastTenantName: $lastTenantName, ')
          ..write('lastTenantPhone: $lastTenantPhone, ')
          ..write('refundAmount: $refundAmount, ')
          ..write('retainedAmount: $retainedAmount, ')
          ..write('depositReason: $depositReason, ')
          ..write('tenantHistoryJson: $tenantHistoryJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        orgId,
        villaId,
        villaName,
        roomName,
        roomNumber,
        tenantName,
        tenantPhone,
        monthlyRent,
        contractStartDate,
        contractEndDate,
        paymentDueDay,
        status,
        createdAt,
        updatedAt,
        isDeleted,
        syncStatus,
        deletedAt,
        deletedBy,
        createdBy,
        updatedBy,
        lastSyncedAt,
        depositType,
        depositAmount,
        depositDate,
        depositStatus,
        depositNotes,
        depositIncomeId,
        depositRefundExpenseId,
        moveInDate,
        moveOutDate,
        lastTenantName,
        lastTenantPhone,
        refundAmount,
        retainedAmount,
        depositReason,
        tenantHistoryJson
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Room &&
          other.id == this.id &&
          other.orgId == this.orgId &&
          other.villaId == this.villaId &&
          other.villaName == this.villaName &&
          other.roomName == this.roomName &&
          other.roomNumber == this.roomNumber &&
          other.tenantName == this.tenantName &&
          other.tenantPhone == this.tenantPhone &&
          other.monthlyRent == this.monthlyRent &&
          other.contractStartDate == this.contractStartDate &&
          other.contractEndDate == this.contractEndDate &&
          other.paymentDueDay == this.paymentDueDay &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.syncStatus == this.syncStatus &&
          other.deletedAt == this.deletedAt &&
          other.deletedBy == this.deletedBy &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.depositType == this.depositType &&
          other.depositAmount == this.depositAmount &&
          other.depositDate == this.depositDate &&
          other.depositStatus == this.depositStatus &&
          other.depositNotes == this.depositNotes &&
          other.depositIncomeId == this.depositIncomeId &&
          other.depositRefundExpenseId == this.depositRefundExpenseId &&
          other.moveInDate == this.moveInDate &&
          other.moveOutDate == this.moveOutDate &&
          other.lastTenantName == this.lastTenantName &&
          other.lastTenantPhone == this.lastTenantPhone &&
          other.refundAmount == this.refundAmount &&
          other.retainedAmount == this.retainedAmount &&
          other.depositReason == this.depositReason &&
          other.tenantHistoryJson == this.tenantHistoryJson);
}

class RoomsCompanion extends UpdateCompanion<Room> {
  final Value<String> id;
  final Value<String> orgId;
  final Value<String> villaId;
  final Value<String> villaName;
  final Value<String> roomName;
  final Value<String> roomNumber;
  final Value<String?> tenantName;
  final Value<String?> tenantPhone;
  final Value<double> monthlyRent;
  final Value<DateTime?> contractStartDate;
  final Value<DateTime?> contractEndDate;
  final Value<int> paymentDueDay;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> isDeleted;
  final Value<String> syncStatus;
  final Value<DateTime?> deletedAt;
  final Value<String?> deletedBy;
  final Value<String?> createdBy;
  final Value<String?> updatedBy;
  final Value<DateTime?> lastSyncedAt;
  final Value<String> depositType;
  final Value<double> depositAmount;
  final Value<DateTime?> depositDate;
  final Value<String> depositStatus;
  final Value<String> depositNotes;
  final Value<String> depositIncomeId;
  final Value<String> depositRefundExpenseId;
  final Value<DateTime?> moveInDate;
  final Value<DateTime?> moveOutDate;
  final Value<String> lastTenantName;
  final Value<String> lastTenantPhone;
  final Value<double> refundAmount;
  final Value<double> retainedAmount;
  final Value<String> depositReason;
  final Value<String> tenantHistoryJson;
  final Value<int> rowid;
  const RoomsCompanion({
    this.id = const Value.absent(),
    this.orgId = const Value.absent(),
    this.villaId = const Value.absent(),
    this.villaName = const Value.absent(),
    this.roomName = const Value.absent(),
    this.roomNumber = const Value.absent(),
    this.tenantName = const Value.absent(),
    this.tenantPhone = const Value.absent(),
    this.monthlyRent = const Value.absent(),
    this.contractStartDate = const Value.absent(),
    this.contractEndDate = const Value.absent(),
    this.paymentDueDay = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deletedBy = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.depositType = const Value.absent(),
    this.depositAmount = const Value.absent(),
    this.depositDate = const Value.absent(),
    this.depositStatus = const Value.absent(),
    this.depositNotes = const Value.absent(),
    this.depositIncomeId = const Value.absent(),
    this.depositRefundExpenseId = const Value.absent(),
    this.moveInDate = const Value.absent(),
    this.moveOutDate = const Value.absent(),
    this.lastTenantName = const Value.absent(),
    this.lastTenantPhone = const Value.absent(),
    this.refundAmount = const Value.absent(),
    this.retainedAmount = const Value.absent(),
    this.depositReason = const Value.absent(),
    this.tenantHistoryJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoomsCompanion.insert({
    required String id,
    this.orgId = const Value.absent(),
    required String villaId,
    required String villaName,
    required String roomName,
    this.roomNumber = const Value.absent(),
    this.tenantName = const Value.absent(),
    this.tenantPhone = const Value.absent(),
    required double monthlyRent,
    this.contractStartDate = const Value.absent(),
    this.contractEndDate = const Value.absent(),
    required int paymentDueDay,
    required String status,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deletedBy = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.depositType = const Value.absent(),
    this.depositAmount = const Value.absent(),
    this.depositDate = const Value.absent(),
    this.depositStatus = const Value.absent(),
    this.depositNotes = const Value.absent(),
    this.depositIncomeId = const Value.absent(),
    this.depositRefundExpenseId = const Value.absent(),
    this.moveInDate = const Value.absent(),
    this.moveOutDate = const Value.absent(),
    this.lastTenantName = const Value.absent(),
    this.lastTenantPhone = const Value.absent(),
    this.refundAmount = const Value.absent(),
    this.retainedAmount = const Value.absent(),
    this.depositReason = const Value.absent(),
    this.tenantHistoryJson = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        villaId = Value(villaId),
        villaName = Value(villaName),
        roomName = Value(roomName),
        monthlyRent = Value(monthlyRent),
        paymentDueDay = Value(paymentDueDay),
        status = Value(status);
  static Insertable<Room> custom({
    Expression<String>? id,
    Expression<String>? orgId,
    Expression<String>? villaId,
    Expression<String>? villaName,
    Expression<String>? roomName,
    Expression<String>? roomNumber,
    Expression<String>? tenantName,
    Expression<String>? tenantPhone,
    Expression<double>? monthlyRent,
    Expression<DateTime>? contractStartDate,
    Expression<DateTime>? contractEndDate,
    Expression<int>? paymentDueDay,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? isDeleted,
    Expression<String>? syncStatus,
    Expression<DateTime>? deletedAt,
    Expression<String>? deletedBy,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<DateTime>? lastSyncedAt,
    Expression<String>? depositType,
    Expression<double>? depositAmount,
    Expression<DateTime>? depositDate,
    Expression<String>? depositStatus,
    Expression<String>? depositNotes,
    Expression<String>? depositIncomeId,
    Expression<String>? depositRefundExpenseId,
    Expression<DateTime>? moveInDate,
    Expression<DateTime>? moveOutDate,
    Expression<String>? lastTenantName,
    Expression<String>? lastTenantPhone,
    Expression<double>? refundAmount,
    Expression<double>? retainedAmount,
    Expression<String>? depositReason,
    Expression<String>? tenantHistoryJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orgId != null) 'org_id': orgId,
      if (villaId != null) 'villa_id': villaId,
      if (villaName != null) 'villa_name': villaName,
      if (roomName != null) 'room_name': roomName,
      if (roomNumber != null) 'room_number': roomNumber,
      if (tenantName != null) 'tenant_name': tenantName,
      if (tenantPhone != null) 'tenant_phone': tenantPhone,
      if (monthlyRent != null) 'monthly_rent': monthlyRent,
      if (contractStartDate != null) 'contract_start_date': contractStartDate,
      if (contractEndDate != null) 'contract_end_date': contractEndDate,
      if (paymentDueDay != null) 'payment_due_day': paymentDueDay,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deletedBy != null) 'deleted_by': deletedBy,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (depositType != null) 'deposit_type': depositType,
      if (depositAmount != null) 'deposit_amount': depositAmount,
      if (depositDate != null) 'deposit_date': depositDate,
      if (depositStatus != null) 'deposit_status': depositStatus,
      if (depositNotes != null) 'deposit_notes': depositNotes,
      if (depositIncomeId != null) 'deposit_income_id': depositIncomeId,
      if (depositRefundExpenseId != null)
        'deposit_refund_expense_id': depositRefundExpenseId,
      if (moveInDate != null) 'move_in_date': moveInDate,
      if (moveOutDate != null) 'move_out_date': moveOutDate,
      if (lastTenantName != null) 'last_tenant_name': lastTenantName,
      if (lastTenantPhone != null) 'last_tenant_phone': lastTenantPhone,
      if (refundAmount != null) 'refund_amount': refundAmount,
      if (retainedAmount != null) 'retained_amount': retainedAmount,
      if (depositReason != null) 'deposit_reason': depositReason,
      if (tenantHistoryJson != null) 'tenant_history_json': tenantHistoryJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoomsCompanion copyWith(
      {Value<String>? id,
      Value<String>? orgId,
      Value<String>? villaId,
      Value<String>? villaName,
      Value<String>? roomName,
      Value<String>? roomNumber,
      Value<String?>? tenantName,
      Value<String?>? tenantPhone,
      Value<double>? monthlyRent,
      Value<DateTime?>? contractStartDate,
      Value<DateTime?>? contractEndDate,
      Value<int>? paymentDueDay,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? isDeleted,
      Value<String>? syncStatus,
      Value<DateTime?>? deletedAt,
      Value<String?>? deletedBy,
      Value<String?>? createdBy,
      Value<String?>? updatedBy,
      Value<DateTime?>? lastSyncedAt,
      Value<String>? depositType,
      Value<double>? depositAmount,
      Value<DateTime?>? depositDate,
      Value<String>? depositStatus,
      Value<String>? depositNotes,
      Value<String>? depositIncomeId,
      Value<String>? depositRefundExpenseId,
      Value<DateTime?>? moveInDate,
      Value<DateTime?>? moveOutDate,
      Value<String>? lastTenantName,
      Value<String>? lastTenantPhone,
      Value<double>? refundAmount,
      Value<double>? retainedAmount,
      Value<String>? depositReason,
      Value<String>? tenantHistoryJson,
      Value<int>? rowid}) {
    return RoomsCompanion(
      id: id ?? this.id,
      orgId: orgId ?? this.orgId,
      villaId: villaId ?? this.villaId,
      villaName: villaName ?? this.villaName,
      roomName: roomName ?? this.roomName,
      roomNumber: roomNumber ?? this.roomNumber,
      tenantName: tenantName ?? this.tenantName,
      tenantPhone: tenantPhone ?? this.tenantPhone,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      contractStartDate: contractStartDate ?? this.contractStartDate,
      contractEndDate: contractEndDate ?? this.contractEndDate,
      paymentDueDay: paymentDueDay ?? this.paymentDueDay,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      depositType: depositType ?? this.depositType,
      depositAmount: depositAmount ?? this.depositAmount,
      depositDate: depositDate ?? this.depositDate,
      depositStatus: depositStatus ?? this.depositStatus,
      depositNotes: depositNotes ?? this.depositNotes,
      depositIncomeId: depositIncomeId ?? this.depositIncomeId,
      depositRefundExpenseId:
          depositRefundExpenseId ?? this.depositRefundExpenseId,
      moveInDate: moveInDate ?? this.moveInDate,
      moveOutDate: moveOutDate ?? this.moveOutDate,
      lastTenantName: lastTenantName ?? this.lastTenantName,
      lastTenantPhone: lastTenantPhone ?? this.lastTenantPhone,
      refundAmount: refundAmount ?? this.refundAmount,
      retainedAmount: retainedAmount ?? this.retainedAmount,
      depositReason: depositReason ?? this.depositReason,
      tenantHistoryJson: tenantHistoryJson ?? this.tenantHistoryJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (orgId.present) {
      map['org_id'] = Variable<String>(orgId.value);
    }
    if (villaId.present) {
      map['villa_id'] = Variable<String>(villaId.value);
    }
    if (villaName.present) {
      map['villa_name'] = Variable<String>(villaName.value);
    }
    if (roomName.present) {
      map['room_name'] = Variable<String>(roomName.value);
    }
    if (roomNumber.present) {
      map['room_number'] = Variable<String>(roomNumber.value);
    }
    if (tenantName.present) {
      map['tenant_name'] = Variable<String>(tenantName.value);
    }
    if (tenantPhone.present) {
      map['tenant_phone'] = Variable<String>(tenantPhone.value);
    }
    if (monthlyRent.present) {
      map['monthly_rent'] = Variable<double>(monthlyRent.value);
    }
    if (contractStartDate.present) {
      map['contract_start_date'] = Variable<DateTime>(contractStartDate.value);
    }
    if (contractEndDate.present) {
      map['contract_end_date'] = Variable<DateTime>(contractEndDate.value);
    }
    if (paymentDueDay.present) {
      map['payment_due_day'] = Variable<int>(paymentDueDay.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<int>(isDeleted.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deletedBy.present) {
      map['deleted_by'] = Variable<String>(deletedBy.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (depositType.present) {
      map['deposit_type'] = Variable<String>(depositType.value);
    }
    if (depositAmount.present) {
      map['deposit_amount'] = Variable<double>(depositAmount.value);
    }
    if (depositDate.present) {
      map['deposit_date'] = Variable<DateTime>(depositDate.value);
    }
    if (depositStatus.present) {
      map['deposit_status'] = Variable<String>(depositStatus.value);
    }
    if (depositNotes.present) {
      map['deposit_notes'] = Variable<String>(depositNotes.value);
    }
    if (depositIncomeId.present) {
      map['deposit_income_id'] = Variable<String>(depositIncomeId.value);
    }
    if (depositRefundExpenseId.present) {
      map['deposit_refund_expense_id'] =
          Variable<String>(depositRefundExpenseId.value);
    }
    if (moveInDate.present) {
      map['move_in_date'] = Variable<DateTime>(moveInDate.value);
    }
    if (moveOutDate.present) {
      map['move_out_date'] = Variable<DateTime>(moveOutDate.value);
    }
    if (lastTenantName.present) {
      map['last_tenant_name'] = Variable<String>(lastTenantName.value);
    }
    if (lastTenantPhone.present) {
      map['last_tenant_phone'] = Variable<String>(lastTenantPhone.value);
    }
    if (refundAmount.present) {
      map['refund_amount'] = Variable<double>(refundAmount.value);
    }
    if (retainedAmount.present) {
      map['retained_amount'] = Variable<double>(retainedAmount.value);
    }
    if (depositReason.present) {
      map['deposit_reason'] = Variable<String>(depositReason.value);
    }
    if (tenantHistoryJson.present) {
      map['tenant_history_json'] = Variable<String>(tenantHistoryJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomsCompanion(')
          ..write('id: $id, ')
          ..write('orgId: $orgId, ')
          ..write('villaId: $villaId, ')
          ..write('villaName: $villaName, ')
          ..write('roomName: $roomName, ')
          ..write('roomNumber: $roomNumber, ')
          ..write('tenantName: $tenantName, ')
          ..write('tenantPhone: $tenantPhone, ')
          ..write('monthlyRent: $monthlyRent, ')
          ..write('contractStartDate: $contractStartDate, ')
          ..write('contractEndDate: $contractEndDate, ')
          ..write('paymentDueDay: $paymentDueDay, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deletedBy: $deletedBy, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('depositType: $depositType, ')
          ..write('depositAmount: $depositAmount, ')
          ..write('depositDate: $depositDate, ')
          ..write('depositStatus: $depositStatus, ')
          ..write('depositNotes: $depositNotes, ')
          ..write('depositIncomeId: $depositIncomeId, ')
          ..write('depositRefundExpenseId: $depositRefundExpenseId, ')
          ..write('moveInDate: $moveInDate, ')
          ..write('moveOutDate: $moveOutDate, ')
          ..write('lastTenantName: $lastTenantName, ')
          ..write('lastTenantPhone: $lastTenantPhone, ')
          ..write('refundAmount: $refundAmount, ')
          ..write('retainedAmount: $retainedAmount, ')
          ..write('depositReason: $depositReason, ')
          ..write('tenantHistoryJson: $tenantHistoryJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IncomesTable extends Incomes with TableInfo<$IncomesTable, Income> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IncomesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orgIdMeta = const VerificationMeta('orgId');
  @override
  late final GeneratedColumn<String> orgId = GeneratedColumn<String>(
      'org_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('default_org'));
  static const VerificationMeta _villaIdMeta =
      const VerificationMeta('villaId');
  @override
  late final GeneratedColumn<String> villaId = GeneratedColumn<String>(
      'villa_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES villas (id)'));
  static const VerificationMeta _villaNameMeta =
      const VerificationMeta('villaName');
  @override
  late final GeneratedColumn<String> villaName = GeneratedColumn<String>(
      'villa_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
      'room_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _roomNameMeta =
      const VerificationMeta('roomName');
  @override
  late final GeneratedColumn<String> roomName = GeneratedColumn<String>(
      'room_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _tenantNameMeta =
      const VerificationMeta('tenantName');
  @override
  late final GeneratedColumn<String> tenantName = GeneratedColumn<String>(
      'tenant_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _incomeTypeMeta =
      const VerificationMeta('incomeType');
  @override
  late final GeneratedColumn<String> incomeType = GeneratedColumn<String>(
      'income_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _paymentDateMeta =
      const VerificationMeta('paymentDate');
  @override
  late final GeneratedColumn<DateTime> paymentDate = GeneratedColumn<DateTime>(
      'payment_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _paymentMethodMeta =
      const VerificationMeta('paymentMethod');
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
      'payment_method', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _monthCoveredMeta =
      const VerificationMeta('monthCovered');
  @override
  late final GeneratedColumn<DateTime> monthCovered = GeneratedColumn<DateTime>(
      'month_covered', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<int> isDeleted = GeneratedColumn<int>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deletedByMeta =
      const VerificationMeta('deletedBy');
  @override
  late final GeneratedColumn<String> deletedBy = GeneratedColumn<String>(
      'deleted_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedByMeta =
      const VerificationMeta('updatedBy');
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
      'updated_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        orgId,
        villaId,
        villaName,
        roomId,
        roomName,
        tenantName,
        incomeType,
        amount,
        paymentDate,
        paymentMethod,
        monthCovered,
        notes,
        createdAt,
        updatedAt,
        isDeleted,
        syncStatus,
        deletedAt,
        deletedBy,
        createdBy,
        updatedBy,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'incomes';
  @override
  VerificationContext validateIntegrity(Insertable<Income> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('org_id')) {
      context.handle(
          _orgIdMeta, orgId.isAcceptableOrUnknown(data['org_id']!, _orgIdMeta));
    }
    if (data.containsKey('villa_id')) {
      context.handle(_villaIdMeta,
          villaId.isAcceptableOrUnknown(data['villa_id']!, _villaIdMeta));
    } else if (isInserting) {
      context.missing(_villaIdMeta);
    }
    if (data.containsKey('villa_name')) {
      context.handle(_villaNameMeta,
          villaName.isAcceptableOrUnknown(data['villa_name']!, _villaNameMeta));
    }
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta));
    }
    if (data.containsKey('room_name')) {
      context.handle(_roomNameMeta,
          roomName.isAcceptableOrUnknown(data['room_name']!, _roomNameMeta));
    }
    if (data.containsKey('tenant_name')) {
      context.handle(
          _tenantNameMeta,
          tenantName.isAcceptableOrUnknown(
              data['tenant_name']!, _tenantNameMeta));
    }
    if (data.containsKey('income_type')) {
      context.handle(
          _incomeTypeMeta,
          incomeType.isAcceptableOrUnknown(
              data['income_type']!, _incomeTypeMeta));
    } else if (isInserting) {
      context.missing(_incomeTypeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('payment_date')) {
      context.handle(
          _paymentDateMeta,
          paymentDate.isAcceptableOrUnknown(
              data['payment_date']!, _paymentDateMeta));
    } else if (isInserting) {
      context.missing(_paymentDateMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
          _paymentMethodMeta,
          paymentMethod.isAcceptableOrUnknown(
              data['payment_method']!, _paymentMethodMeta));
    } else if (isInserting) {
      context.missing(_paymentMethodMeta);
    }
    if (data.containsKey('month_covered')) {
      context.handle(
          _monthCoveredMeta,
          monthCovered.isAcceptableOrUnknown(
              data['month_covered']!, _monthCoveredMeta));
    } else if (isInserting) {
      context.missing(_monthCoveredMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('deleted_by')) {
      context.handle(_deletedByMeta,
          deletedBy.isAcceptableOrUnknown(data['deleted_by']!, _deletedByMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    }
    if (data.containsKey('updated_by')) {
      context.handle(_updatedByMeta,
          updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Income map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Income(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      orgId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}org_id'])!,
      villaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}villa_id'])!,
      villaName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}villa_name'])!,
      roomId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room_id'])!,
      roomName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room_name'])!,
      tenantName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_name'])!,
      incomeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}income_type'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      paymentDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}payment_date'])!,
      paymentMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_method'])!,
      monthCovered: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}month_covered'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_deleted'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      deletedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_by']),
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by']),
      updatedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_by']),
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $IncomesTable createAlias(String alias) {
    return $IncomesTable(attachedDatabase, alias);
  }
}

class Income extends DataClass implements Insertable<Income> {
  final String id;
  final String orgId;
  final String villaId;
  final String villaName;
  final String roomId;
  final String roomName;
  final String tenantName;
  final String incomeType;
  final double amount;
  final DateTime paymentDate;
  final String paymentMethod;
  final DateTime monthCovered;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int isDeleted;
  final String syncStatus;
  final DateTime? deletedAt;
  final String? deletedBy;
  final String? createdBy;
  final String? updatedBy;
  final DateTime? lastSyncedAt;
  const Income(
      {required this.id,
      required this.orgId,
      required this.villaId,
      required this.villaName,
      required this.roomId,
      required this.roomName,
      required this.tenantName,
      required this.incomeType,
      required this.amount,
      required this.paymentDate,
      required this.paymentMethod,
      required this.monthCovered,
      this.notes,
      required this.createdAt,
      this.updatedAt,
      required this.isDeleted,
      required this.syncStatus,
      this.deletedAt,
      this.deletedBy,
      this.createdBy,
      this.updatedBy,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['org_id'] = Variable<String>(orgId);
    map['villa_id'] = Variable<String>(villaId);
    map['villa_name'] = Variable<String>(villaName);
    map['room_id'] = Variable<String>(roomId);
    map['room_name'] = Variable<String>(roomName);
    map['tenant_name'] = Variable<String>(tenantName);
    map['income_type'] = Variable<String>(incomeType);
    map['amount'] = Variable<double>(amount);
    map['payment_date'] = Variable<DateTime>(paymentDate);
    map['payment_method'] = Variable<String>(paymentMethod);
    map['month_covered'] = Variable<DateTime>(monthCovered);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['is_deleted'] = Variable<int>(isDeleted);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || deletedBy != null) {
      map['deleted_by'] = Variable<String>(deletedBy);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  IncomesCompanion toCompanion(bool nullToAbsent) {
    return IncomesCompanion(
      id: Value(id),
      orgId: Value(orgId),
      villaId: Value(villaId),
      villaName: Value(villaName),
      roomId: Value(roomId),
      roomName: Value(roomName),
      tenantName: Value(tenantName),
      incomeType: Value(incomeType),
      amount: Value(amount),
      paymentDate: Value(paymentDate),
      paymentMethod: Value(paymentMethod),
      monthCovered: Value(monthCovered),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      isDeleted: Value(isDeleted),
      syncStatus: Value(syncStatus),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deletedBy: deletedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedBy),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory Income.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Income(
      id: serializer.fromJson<String>(json['id']),
      orgId: serializer.fromJson<String>(json['orgId']),
      villaId: serializer.fromJson<String>(json['villaId']),
      villaName: serializer.fromJson<String>(json['villaName']),
      roomId: serializer.fromJson<String>(json['roomId']),
      roomName: serializer.fromJson<String>(json['roomName']),
      tenantName: serializer.fromJson<String>(json['tenantName']),
      incomeType: serializer.fromJson<String>(json['incomeType']),
      amount: serializer.fromJson<double>(json['amount']),
      paymentDate: serializer.fromJson<DateTime>(json['paymentDate']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      monthCovered: serializer.fromJson<DateTime>(json['monthCovered']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      isDeleted: serializer.fromJson<int>(json['isDeleted']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deletedBy: serializer.fromJson<String?>(json['deletedBy']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'orgId': serializer.toJson<String>(orgId),
      'villaId': serializer.toJson<String>(villaId),
      'villaName': serializer.toJson<String>(villaName),
      'roomId': serializer.toJson<String>(roomId),
      'roomName': serializer.toJson<String>(roomName),
      'tenantName': serializer.toJson<String>(tenantName),
      'incomeType': serializer.toJson<String>(incomeType),
      'amount': serializer.toJson<double>(amount),
      'paymentDate': serializer.toJson<DateTime>(paymentDate),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'monthCovered': serializer.toJson<DateTime>(monthCovered),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'isDeleted': serializer.toJson<int>(isDeleted),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deletedBy': serializer.toJson<String?>(deletedBy),
      'createdBy': serializer.toJson<String?>(createdBy),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  Income copyWith(
          {String? id,
          String? orgId,
          String? villaId,
          String? villaName,
          String? roomId,
          String? roomName,
          String? tenantName,
          String? incomeType,
          double? amount,
          DateTime? paymentDate,
          String? paymentMethod,
          DateTime? monthCovered,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent(),
          int? isDeleted,
          String? syncStatus,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> deletedBy = const Value.absent(),
          Value<String?> createdBy = const Value.absent(),
          Value<String?> updatedBy = const Value.absent(),
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      Income(
        id: id ?? this.id,
        orgId: orgId ?? this.orgId,
        villaId: villaId ?? this.villaId,
        villaName: villaName ?? this.villaName,
        roomId: roomId ?? this.roomId,
        roomName: roomName ?? this.roomName,
        tenantName: tenantName ?? this.tenantName,
        incomeType: incomeType ?? this.incomeType,
        amount: amount ?? this.amount,
        paymentDate: paymentDate ?? this.paymentDate,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        monthCovered: monthCovered ?? this.monthCovered,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        syncStatus: syncStatus ?? this.syncStatus,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        deletedBy: deletedBy.present ? deletedBy.value : this.deletedBy,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  Income copyWithCompanion(IncomesCompanion data) {
    return Income(
      id: data.id.present ? data.id.value : this.id,
      orgId: data.orgId.present ? data.orgId.value : this.orgId,
      villaId: data.villaId.present ? data.villaId.value : this.villaId,
      villaName: data.villaName.present ? data.villaName.value : this.villaName,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      roomName: data.roomName.present ? data.roomName.value : this.roomName,
      tenantName:
          data.tenantName.present ? data.tenantName.value : this.tenantName,
      incomeType:
          data.incomeType.present ? data.incomeType.value : this.incomeType,
      amount: data.amount.present ? data.amount.value : this.amount,
      paymentDate:
          data.paymentDate.present ? data.paymentDate.value : this.paymentDate,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      monthCovered: data.monthCovered.present
          ? data.monthCovered.value
          : this.monthCovered,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deletedBy: data.deletedBy.present ? data.deletedBy.value : this.deletedBy,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Income(')
          ..write('id: $id, ')
          ..write('orgId: $orgId, ')
          ..write('villaId: $villaId, ')
          ..write('villaName: $villaName, ')
          ..write('roomId: $roomId, ')
          ..write('roomName: $roomName, ')
          ..write('tenantName: $tenantName, ')
          ..write('incomeType: $incomeType, ')
          ..write('amount: $amount, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('monthCovered: $monthCovered, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deletedBy: $deletedBy, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        orgId,
        villaId,
        villaName,
        roomId,
        roomName,
        tenantName,
        incomeType,
        amount,
        paymentDate,
        paymentMethod,
        monthCovered,
        notes,
        createdAt,
        updatedAt,
        isDeleted,
        syncStatus,
        deletedAt,
        deletedBy,
        createdBy,
        updatedBy,
        lastSyncedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Income &&
          other.id == this.id &&
          other.orgId == this.orgId &&
          other.villaId == this.villaId &&
          other.villaName == this.villaName &&
          other.roomId == this.roomId &&
          other.roomName == this.roomName &&
          other.tenantName == this.tenantName &&
          other.incomeType == this.incomeType &&
          other.amount == this.amount &&
          other.paymentDate == this.paymentDate &&
          other.paymentMethod == this.paymentMethod &&
          other.monthCovered == this.monthCovered &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.syncStatus == this.syncStatus &&
          other.deletedAt == this.deletedAt &&
          other.deletedBy == this.deletedBy &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class IncomesCompanion extends UpdateCompanion<Income> {
  final Value<String> id;
  final Value<String> orgId;
  final Value<String> villaId;
  final Value<String> villaName;
  final Value<String> roomId;
  final Value<String> roomName;
  final Value<String> tenantName;
  final Value<String> incomeType;
  final Value<double> amount;
  final Value<DateTime> paymentDate;
  final Value<String> paymentMethod;
  final Value<DateTime> monthCovered;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> isDeleted;
  final Value<String> syncStatus;
  final Value<DateTime?> deletedAt;
  final Value<String?> deletedBy;
  final Value<String?> createdBy;
  final Value<String?> updatedBy;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const IncomesCompanion({
    this.id = const Value.absent(),
    this.orgId = const Value.absent(),
    this.villaId = const Value.absent(),
    this.villaName = const Value.absent(),
    this.roomId = const Value.absent(),
    this.roomName = const Value.absent(),
    this.tenantName = const Value.absent(),
    this.incomeType = const Value.absent(),
    this.amount = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.monthCovered = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deletedBy = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IncomesCompanion.insert({
    required String id,
    this.orgId = const Value.absent(),
    required String villaId,
    this.villaName = const Value.absent(),
    this.roomId = const Value.absent(),
    this.roomName = const Value.absent(),
    this.tenantName = const Value.absent(),
    required String incomeType,
    required double amount,
    required DateTime paymentDate,
    required String paymentMethod,
    required DateTime monthCovered,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deletedBy = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        villaId = Value(villaId),
        incomeType = Value(incomeType),
        amount = Value(amount),
        paymentDate = Value(paymentDate),
        paymentMethod = Value(paymentMethod),
        monthCovered = Value(monthCovered);
  static Insertable<Income> custom({
    Expression<String>? id,
    Expression<String>? orgId,
    Expression<String>? villaId,
    Expression<String>? villaName,
    Expression<String>? roomId,
    Expression<String>? roomName,
    Expression<String>? tenantName,
    Expression<String>? incomeType,
    Expression<double>? amount,
    Expression<DateTime>? paymentDate,
    Expression<String>? paymentMethod,
    Expression<DateTime>? monthCovered,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? isDeleted,
    Expression<String>? syncStatus,
    Expression<DateTime>? deletedAt,
    Expression<String>? deletedBy,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orgId != null) 'org_id': orgId,
      if (villaId != null) 'villa_id': villaId,
      if (villaName != null) 'villa_name': villaName,
      if (roomId != null) 'room_id': roomId,
      if (roomName != null) 'room_name': roomName,
      if (tenantName != null) 'tenant_name': tenantName,
      if (incomeType != null) 'income_type': incomeType,
      if (amount != null) 'amount': amount,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (monthCovered != null) 'month_covered': monthCovered,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deletedBy != null) 'deleted_by': deletedBy,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IncomesCompanion copyWith(
      {Value<String>? id,
      Value<String>? orgId,
      Value<String>? villaId,
      Value<String>? villaName,
      Value<String>? roomId,
      Value<String>? roomName,
      Value<String>? tenantName,
      Value<String>? incomeType,
      Value<double>? amount,
      Value<DateTime>? paymentDate,
      Value<String>? paymentMethod,
      Value<DateTime>? monthCovered,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? isDeleted,
      Value<String>? syncStatus,
      Value<DateTime?>? deletedAt,
      Value<String?>? deletedBy,
      Value<String?>? createdBy,
      Value<String?>? updatedBy,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return IncomesCompanion(
      id: id ?? this.id,
      orgId: orgId ?? this.orgId,
      villaId: villaId ?? this.villaId,
      villaName: villaName ?? this.villaName,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      tenantName: tenantName ?? this.tenantName,
      incomeType: incomeType ?? this.incomeType,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      monthCovered: monthCovered ?? this.monthCovered,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (orgId.present) {
      map['org_id'] = Variable<String>(orgId.value);
    }
    if (villaId.present) {
      map['villa_id'] = Variable<String>(villaId.value);
    }
    if (villaName.present) {
      map['villa_name'] = Variable<String>(villaName.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (roomName.present) {
      map['room_name'] = Variable<String>(roomName.value);
    }
    if (tenantName.present) {
      map['tenant_name'] = Variable<String>(tenantName.value);
    }
    if (incomeType.present) {
      map['income_type'] = Variable<String>(incomeType.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<DateTime>(paymentDate.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (monthCovered.present) {
      map['month_covered'] = Variable<DateTime>(monthCovered.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<int>(isDeleted.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deletedBy.present) {
      map['deleted_by'] = Variable<String>(deletedBy.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncomesCompanion(')
          ..write('id: $id, ')
          ..write('orgId: $orgId, ')
          ..write('villaId: $villaId, ')
          ..write('villaName: $villaName, ')
          ..write('roomId: $roomId, ')
          ..write('roomName: $roomName, ')
          ..write('tenantName: $tenantName, ')
          ..write('incomeType: $incomeType, ')
          ..write('amount: $amount, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('monthCovered: $monthCovered, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deletedBy: $deletedBy, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orgIdMeta = const VerificationMeta('orgId');
  @override
  late final GeneratedColumn<String> orgId = GeneratedColumn<String>(
      'org_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('default_org'));
  static const VerificationMeta _villaIdMeta =
      const VerificationMeta('villaId');
  @override
  late final GeneratedColumn<String> villaId = GeneratedColumn<String>(
      'villa_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES villas (id)'));
  static const VerificationMeta _villaNameMeta =
      const VerificationMeta('villaName');
  @override
  late final GeneratedColumn<String> villaName = GeneratedColumn<String>(
      'villa_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
      'room_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _roomNameMeta =
      const VerificationMeta('roomName');
  @override
  late final GeneratedColumn<String> roomName = GeneratedColumn<String>(
      'room_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _expenseDateMeta =
      const VerificationMeta('expenseDate');
  @override
  late final GeneratedColumn<DateTime> expenseDate = GeneratedColumn<DateTime>(
      'expense_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _paidToMeta = const VerificationMeta('paidTo');
  @override
  late final GeneratedColumn<String> paidTo = GeneratedColumn<String>(
      'paid_to', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _paymentMethodMeta =
      const VerificationMeta('paymentMethod');
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
      'payment_method', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<int> isDeleted = GeneratedColumn<int>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deletedByMeta =
      const VerificationMeta('deletedBy');
  @override
  late final GeneratedColumn<String> deletedBy = GeneratedColumn<String>(
      'deleted_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedByMeta =
      const VerificationMeta('updatedBy');
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
      'updated_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        orgId,
        villaId,
        villaName,
        roomId,
        roomName,
        category,
        amount,
        expenseDate,
        paidTo,
        paymentMethod,
        notes,
        createdAt,
        updatedAt,
        isDeleted,
        syncStatus,
        deletedAt,
        deletedBy,
        createdBy,
        updatedBy,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(Insertable<Expense> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('org_id')) {
      context.handle(
          _orgIdMeta, orgId.isAcceptableOrUnknown(data['org_id']!, _orgIdMeta));
    }
    if (data.containsKey('villa_id')) {
      context.handle(_villaIdMeta,
          villaId.isAcceptableOrUnknown(data['villa_id']!, _villaIdMeta));
    }
    if (data.containsKey('villa_name')) {
      context.handle(_villaNameMeta,
          villaName.isAcceptableOrUnknown(data['villa_name']!, _villaNameMeta));
    }
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta));
    }
    if (data.containsKey('room_name')) {
      context.handle(_roomNameMeta,
          roomName.isAcceptableOrUnknown(data['room_name']!, _roomNameMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('expense_date')) {
      context.handle(
          _expenseDateMeta,
          expenseDate.isAcceptableOrUnknown(
              data['expense_date']!, _expenseDateMeta));
    } else if (isInserting) {
      context.missing(_expenseDateMeta);
    }
    if (data.containsKey('paid_to')) {
      context.handle(_paidToMeta,
          paidTo.isAcceptableOrUnknown(data['paid_to']!, _paidToMeta));
    } else if (isInserting) {
      context.missing(_paidToMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
          _paymentMethodMeta,
          paymentMethod.isAcceptableOrUnknown(
              data['payment_method']!, _paymentMethodMeta));
    } else if (isInserting) {
      context.missing(_paymentMethodMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('deleted_by')) {
      context.handle(_deletedByMeta,
          deletedBy.isAcceptableOrUnknown(data['deleted_by']!, _deletedByMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    }
    if (data.containsKey('updated_by')) {
      context.handle(_updatedByMeta,
          updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      orgId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}org_id'])!,
      villaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}villa_id']),
      villaName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}villa_name'])!,
      roomId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room_id']),
      roomName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room_name']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      expenseDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expense_date'])!,
      paidTo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}paid_to'])!,
      paymentMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_method'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_deleted'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      deletedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_by']),
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by']),
      updatedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_by']),
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final String id;
  final String orgId;
  final String? villaId;
  final String villaName;
  final String? roomId;
  final String? roomName;
  final String category;
  final double amount;
  final DateTime expenseDate;
  final String paidTo;
  final String paymentMethod;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int isDeleted;
  final String syncStatus;
  final DateTime? deletedAt;
  final String? deletedBy;
  final String? createdBy;
  final String? updatedBy;
  final DateTime? lastSyncedAt;
  const Expense(
      {required this.id,
      required this.orgId,
      this.villaId,
      required this.villaName,
      this.roomId,
      this.roomName,
      required this.category,
      required this.amount,
      required this.expenseDate,
      required this.paidTo,
      required this.paymentMethod,
      this.notes,
      required this.createdAt,
      this.updatedAt,
      required this.isDeleted,
      required this.syncStatus,
      this.deletedAt,
      this.deletedBy,
      this.createdBy,
      this.updatedBy,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['org_id'] = Variable<String>(orgId);
    if (!nullToAbsent || villaId != null) {
      map['villa_id'] = Variable<String>(villaId);
    }
    map['villa_name'] = Variable<String>(villaName);
    if (!nullToAbsent || roomId != null) {
      map['room_id'] = Variable<String>(roomId);
    }
    if (!nullToAbsent || roomName != null) {
      map['room_name'] = Variable<String>(roomName);
    }
    map['category'] = Variable<String>(category);
    map['amount'] = Variable<double>(amount);
    map['expense_date'] = Variable<DateTime>(expenseDate);
    map['paid_to'] = Variable<String>(paidTo);
    map['payment_method'] = Variable<String>(paymentMethod);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['is_deleted'] = Variable<int>(isDeleted);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || deletedBy != null) {
      map['deleted_by'] = Variable<String>(deletedBy);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      orgId: Value(orgId),
      villaId: villaId == null && nullToAbsent
          ? const Value.absent()
          : Value(villaId),
      villaName: Value(villaName),
      roomId:
          roomId == null && nullToAbsent ? const Value.absent() : Value(roomId),
      roomName: roomName == null && nullToAbsent
          ? const Value.absent()
          : Value(roomName),
      category: Value(category),
      amount: Value(amount),
      expenseDate: Value(expenseDate),
      paidTo: Value(paidTo),
      paymentMethod: Value(paymentMethod),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      isDeleted: Value(isDeleted),
      syncStatus: Value(syncStatus),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deletedBy: deletedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedBy),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory Expense.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<String>(json['id']),
      orgId: serializer.fromJson<String>(json['orgId']),
      villaId: serializer.fromJson<String?>(json['villaId']),
      villaName: serializer.fromJson<String>(json['villaName']),
      roomId: serializer.fromJson<String?>(json['roomId']),
      roomName: serializer.fromJson<String?>(json['roomName']),
      category: serializer.fromJson<String>(json['category']),
      amount: serializer.fromJson<double>(json['amount']),
      expenseDate: serializer.fromJson<DateTime>(json['expenseDate']),
      paidTo: serializer.fromJson<String>(json['paidTo']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      isDeleted: serializer.fromJson<int>(json['isDeleted']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deletedBy: serializer.fromJson<String?>(json['deletedBy']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'orgId': serializer.toJson<String>(orgId),
      'villaId': serializer.toJson<String?>(villaId),
      'villaName': serializer.toJson<String>(villaName),
      'roomId': serializer.toJson<String?>(roomId),
      'roomName': serializer.toJson<String?>(roomName),
      'category': serializer.toJson<String>(category),
      'amount': serializer.toJson<double>(amount),
      'expenseDate': serializer.toJson<DateTime>(expenseDate),
      'paidTo': serializer.toJson<String>(paidTo),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'isDeleted': serializer.toJson<int>(isDeleted),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deletedBy': serializer.toJson<String?>(deletedBy),
      'createdBy': serializer.toJson<String?>(createdBy),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  Expense copyWith(
          {String? id,
          String? orgId,
          Value<String?> villaId = const Value.absent(),
          String? villaName,
          Value<String?> roomId = const Value.absent(),
          Value<String?> roomName = const Value.absent(),
          String? category,
          double? amount,
          DateTime? expenseDate,
          String? paidTo,
          String? paymentMethod,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent(),
          int? isDeleted,
          String? syncStatus,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> deletedBy = const Value.absent(),
          Value<String?> createdBy = const Value.absent(),
          Value<String?> updatedBy = const Value.absent(),
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      Expense(
        id: id ?? this.id,
        orgId: orgId ?? this.orgId,
        villaId: villaId.present ? villaId.value : this.villaId,
        villaName: villaName ?? this.villaName,
        roomId: roomId.present ? roomId.value : this.roomId,
        roomName: roomName.present ? roomName.value : this.roomName,
        category: category ?? this.category,
        amount: amount ?? this.amount,
        expenseDate: expenseDate ?? this.expenseDate,
        paidTo: paidTo ?? this.paidTo,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        syncStatus: syncStatus ?? this.syncStatus,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        deletedBy: deletedBy.present ? deletedBy.value : this.deletedBy,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      orgId: data.orgId.present ? data.orgId.value : this.orgId,
      villaId: data.villaId.present ? data.villaId.value : this.villaId,
      villaName: data.villaName.present ? data.villaName.value : this.villaName,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      roomName: data.roomName.present ? data.roomName.value : this.roomName,
      category: data.category.present ? data.category.value : this.category,
      amount: data.amount.present ? data.amount.value : this.amount,
      expenseDate:
          data.expenseDate.present ? data.expenseDate.value : this.expenseDate,
      paidTo: data.paidTo.present ? data.paidTo.value : this.paidTo,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deletedBy: data.deletedBy.present ? data.deletedBy.value : this.deletedBy,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('orgId: $orgId, ')
          ..write('villaId: $villaId, ')
          ..write('villaName: $villaName, ')
          ..write('roomId: $roomId, ')
          ..write('roomName: $roomName, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('paidTo: $paidTo, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deletedBy: $deletedBy, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        orgId,
        villaId,
        villaName,
        roomId,
        roomName,
        category,
        amount,
        expenseDate,
        paidTo,
        paymentMethod,
        notes,
        createdAt,
        updatedAt,
        isDeleted,
        syncStatus,
        deletedAt,
        deletedBy,
        createdBy,
        updatedBy,
        lastSyncedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.orgId == this.orgId &&
          other.villaId == this.villaId &&
          other.villaName == this.villaName &&
          other.roomId == this.roomId &&
          other.roomName == this.roomName &&
          other.category == this.category &&
          other.amount == this.amount &&
          other.expenseDate == this.expenseDate &&
          other.paidTo == this.paidTo &&
          other.paymentMethod == this.paymentMethod &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.syncStatus == this.syncStatus &&
          other.deletedAt == this.deletedAt &&
          other.deletedBy == this.deletedBy &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<String> id;
  final Value<String> orgId;
  final Value<String?> villaId;
  final Value<String> villaName;
  final Value<String?> roomId;
  final Value<String?> roomName;
  final Value<String> category;
  final Value<double> amount;
  final Value<DateTime> expenseDate;
  final Value<String> paidTo;
  final Value<String> paymentMethod;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> isDeleted;
  final Value<String> syncStatus;
  final Value<DateTime?> deletedAt;
  final Value<String?> deletedBy;
  final Value<String?> createdBy;
  final Value<String?> updatedBy;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.orgId = const Value.absent(),
    this.villaId = const Value.absent(),
    this.villaName = const Value.absent(),
    this.roomId = const Value.absent(),
    this.roomName = const Value.absent(),
    this.category = const Value.absent(),
    this.amount = const Value.absent(),
    this.expenseDate = const Value.absent(),
    this.paidTo = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deletedBy = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    required String id,
    this.orgId = const Value.absent(),
    this.villaId = const Value.absent(),
    this.villaName = const Value.absent(),
    this.roomId = const Value.absent(),
    this.roomName = const Value.absent(),
    required String category,
    required double amount,
    required DateTime expenseDate,
    required String paidTo,
    required String paymentMethod,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deletedBy = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        category = Value(category),
        amount = Value(amount),
        expenseDate = Value(expenseDate),
        paidTo = Value(paidTo),
        paymentMethod = Value(paymentMethod);
  static Insertable<Expense> custom({
    Expression<String>? id,
    Expression<String>? orgId,
    Expression<String>? villaId,
    Expression<String>? villaName,
    Expression<String>? roomId,
    Expression<String>? roomName,
    Expression<String>? category,
    Expression<double>? amount,
    Expression<DateTime>? expenseDate,
    Expression<String>? paidTo,
    Expression<String>? paymentMethod,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? isDeleted,
    Expression<String>? syncStatus,
    Expression<DateTime>? deletedAt,
    Expression<String>? deletedBy,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orgId != null) 'org_id': orgId,
      if (villaId != null) 'villa_id': villaId,
      if (villaName != null) 'villa_name': villaName,
      if (roomId != null) 'room_id': roomId,
      if (roomName != null) 'room_name': roomName,
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
      if (expenseDate != null) 'expense_date': expenseDate,
      if (paidTo != null) 'paid_to': paidTo,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deletedBy != null) 'deleted_by': deletedBy,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith(
      {Value<String>? id,
      Value<String>? orgId,
      Value<String?>? villaId,
      Value<String>? villaName,
      Value<String?>? roomId,
      Value<String?>? roomName,
      Value<String>? category,
      Value<double>? amount,
      Value<DateTime>? expenseDate,
      Value<String>? paidTo,
      Value<String>? paymentMethod,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? isDeleted,
      Value<String>? syncStatus,
      Value<DateTime?>? deletedAt,
      Value<String?>? deletedBy,
      Value<String?>? createdBy,
      Value<String?>? updatedBy,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return ExpensesCompanion(
      id: id ?? this.id,
      orgId: orgId ?? this.orgId,
      villaId: villaId ?? this.villaId,
      villaName: villaName ?? this.villaName,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      expenseDate: expenseDate ?? this.expenseDate,
      paidTo: paidTo ?? this.paidTo,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (orgId.present) {
      map['org_id'] = Variable<String>(orgId.value);
    }
    if (villaId.present) {
      map['villa_id'] = Variable<String>(villaId.value);
    }
    if (villaName.present) {
      map['villa_name'] = Variable<String>(villaName.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (roomName.present) {
      map['room_name'] = Variable<String>(roomName.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (expenseDate.present) {
      map['expense_date'] = Variable<DateTime>(expenseDate.value);
    }
    if (paidTo.present) {
      map['paid_to'] = Variable<String>(paidTo.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<int>(isDeleted.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deletedBy.present) {
      map['deleted_by'] = Variable<String>(deletedBy.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('orgId: $orgId, ')
          ..write('villaId: $villaId, ')
          ..write('villaName: $villaName, ')
          ..write('roomId: $roomId, ')
          ..write('roomName: $roomName, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('paidTo: $paidTo, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deletedBy: $deletedBy, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppLogsTable extends AppLogs with TableInfo<$AppLogsTable, AppLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<String> timestamp = GeneratedColumn<String>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
      'level', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _screenNameMeta =
      const VerificationMeta('screenName');
  @override
  late final GeneratedColumn<String> screenName = GeneratedColumn<String>(
      'screen_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _detailsMeta =
      const VerificationMeta('details');
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
      'details', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _stackTraceMeta =
      const VerificationMeta('stackTrace');
  @override
  late final GeneratedColumn<String> stackTrace = GeneratedColumn<String>(
      'stack_trace', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _userEmailMeta =
      const VerificationMeta('userEmail');
  @override
  late final GeneratedColumn<String> userEmail = GeneratedColumn<String>(
      'user_email', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _devicePlatformMeta =
      const VerificationMeta('devicePlatform');
  @override
  late final GeneratedColumn<String> devicePlatform = GeneratedColumn<String>(
      'device_platform', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _appVersionMeta =
      const VerificationMeta('appVersion');
  @override
  late final GeneratedColumn<String> appVersion = GeneratedColumn<String>(
      'app_version', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        timestamp,
        category,
        level,
        screenName,
        operation,
        message,
        details,
        stackTrace,
        userId,
        userEmail,
        devicePlatform,
        appVersion
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_logs';
  @override
  VerificationContext validateIntegrity(Insertable<AppLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
          _levelMeta, level.isAcceptableOrUnknown(data['level']!, _levelMeta));
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('screen_name')) {
      context.handle(
          _screenNameMeta,
          screenName.isAcceptableOrUnknown(
              data['screen_name']!, _screenNameMeta));
    } else if (isInserting) {
      context.missing(_screenNameMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('details')) {
      context.handle(_detailsMeta,
          details.isAcceptableOrUnknown(data['details']!, _detailsMeta));
    }
    if (data.containsKey('stack_trace')) {
      context.handle(
          _stackTraceMeta,
          stackTrace.isAcceptableOrUnknown(
              data['stack_trace']!, _stackTraceMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('user_email')) {
      context.handle(_userEmailMeta,
          userEmail.isAcceptableOrUnknown(data['user_email']!, _userEmailMeta));
    }
    if (data.containsKey('device_platform')) {
      context.handle(
          _devicePlatformMeta,
          devicePlatform.isAcceptableOrUnknown(
              data['device_platform']!, _devicePlatformMeta));
    }
    if (data.containsKey('app_version')) {
      context.handle(
          _appVersionMeta,
          appVersion.isAcceptableOrUnknown(
              data['app_version']!, _appVersionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timestamp'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      level: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}level'])!,
      screenName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}screen_name'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message'])!,
      details: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}details'])!,
      stackTrace: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}stack_trace'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      userEmail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_email'])!,
      devicePlatform: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}device_platform'])!,
      appVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}app_version'])!,
    );
  }

  @override
  $AppLogsTable createAlias(String alias) {
    return $AppLogsTable(attachedDatabase, alias);
  }
}

class AppLog extends DataClass implements Insertable<AppLog> {
  final String id;
  final String timestamp;
  final String category;
  final String level;
  final String screenName;
  final String operation;
  final String message;
  final String details;
  final String stackTrace;
  final String userId;
  final String userEmail;
  final String devicePlatform;
  final String appVersion;
  const AppLog(
      {required this.id,
      required this.timestamp,
      required this.category,
      required this.level,
      required this.screenName,
      required this.operation,
      required this.message,
      required this.details,
      required this.stackTrace,
      required this.userId,
      required this.userEmail,
      required this.devicePlatform,
      required this.appVersion});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['timestamp'] = Variable<String>(timestamp);
    map['category'] = Variable<String>(category);
    map['level'] = Variable<String>(level);
    map['screen_name'] = Variable<String>(screenName);
    map['operation'] = Variable<String>(operation);
    map['message'] = Variable<String>(message);
    map['details'] = Variable<String>(details);
    map['stack_trace'] = Variable<String>(stackTrace);
    map['user_id'] = Variable<String>(userId);
    map['user_email'] = Variable<String>(userEmail);
    map['device_platform'] = Variable<String>(devicePlatform);
    map['app_version'] = Variable<String>(appVersion);
    return map;
  }

  AppLogsCompanion toCompanion(bool nullToAbsent) {
    return AppLogsCompanion(
      id: Value(id),
      timestamp: Value(timestamp),
      category: Value(category),
      level: Value(level),
      screenName: Value(screenName),
      operation: Value(operation),
      message: Value(message),
      details: Value(details),
      stackTrace: Value(stackTrace),
      userId: Value(userId),
      userEmail: Value(userEmail),
      devicePlatform: Value(devicePlatform),
      appVersion: Value(appVersion),
    );
  }

  factory AppLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppLog(
      id: serializer.fromJson<String>(json['id']),
      timestamp: serializer.fromJson<String>(json['timestamp']),
      category: serializer.fromJson<String>(json['category']),
      level: serializer.fromJson<String>(json['level']),
      screenName: serializer.fromJson<String>(json['screenName']),
      operation: serializer.fromJson<String>(json['operation']),
      message: serializer.fromJson<String>(json['message']),
      details: serializer.fromJson<String>(json['details']),
      stackTrace: serializer.fromJson<String>(json['stackTrace']),
      userId: serializer.fromJson<String>(json['userId']),
      userEmail: serializer.fromJson<String>(json['userEmail']),
      devicePlatform: serializer.fromJson<String>(json['devicePlatform']),
      appVersion: serializer.fromJson<String>(json['appVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'timestamp': serializer.toJson<String>(timestamp),
      'category': serializer.toJson<String>(category),
      'level': serializer.toJson<String>(level),
      'screenName': serializer.toJson<String>(screenName),
      'operation': serializer.toJson<String>(operation),
      'message': serializer.toJson<String>(message),
      'details': serializer.toJson<String>(details),
      'stackTrace': serializer.toJson<String>(stackTrace),
      'userId': serializer.toJson<String>(userId),
      'userEmail': serializer.toJson<String>(userEmail),
      'devicePlatform': serializer.toJson<String>(devicePlatform),
      'appVersion': serializer.toJson<String>(appVersion),
    };
  }

  AppLog copyWith(
          {String? id,
          String? timestamp,
          String? category,
          String? level,
          String? screenName,
          String? operation,
          String? message,
          String? details,
          String? stackTrace,
          String? userId,
          String? userEmail,
          String? devicePlatform,
          String? appVersion}) =>
      AppLog(
        id: id ?? this.id,
        timestamp: timestamp ?? this.timestamp,
        category: category ?? this.category,
        level: level ?? this.level,
        screenName: screenName ?? this.screenName,
        operation: operation ?? this.operation,
        message: message ?? this.message,
        details: details ?? this.details,
        stackTrace: stackTrace ?? this.stackTrace,
        userId: userId ?? this.userId,
        userEmail: userEmail ?? this.userEmail,
        devicePlatform: devicePlatform ?? this.devicePlatform,
        appVersion: appVersion ?? this.appVersion,
      );
  AppLog copyWithCompanion(AppLogsCompanion data) {
    return AppLog(
      id: data.id.present ? data.id.value : this.id,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      category: data.category.present ? data.category.value : this.category,
      level: data.level.present ? data.level.value : this.level,
      screenName:
          data.screenName.present ? data.screenName.value : this.screenName,
      operation: data.operation.present ? data.operation.value : this.operation,
      message: data.message.present ? data.message.value : this.message,
      details: data.details.present ? data.details.value : this.details,
      stackTrace:
          data.stackTrace.present ? data.stackTrace.value : this.stackTrace,
      userId: data.userId.present ? data.userId.value : this.userId,
      userEmail: data.userEmail.present ? data.userEmail.value : this.userEmail,
      devicePlatform: data.devicePlatform.present
          ? data.devicePlatform.value
          : this.devicePlatform,
      appVersion:
          data.appVersion.present ? data.appVersion.value : this.appVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppLog(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('category: $category, ')
          ..write('level: $level, ')
          ..write('screenName: $screenName, ')
          ..write('operation: $operation, ')
          ..write('message: $message, ')
          ..write('details: $details, ')
          ..write('stackTrace: $stackTrace, ')
          ..write('userId: $userId, ')
          ..write('userEmail: $userEmail, ')
          ..write('devicePlatform: $devicePlatform, ')
          ..write('appVersion: $appVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      timestamp,
      category,
      level,
      screenName,
      operation,
      message,
      details,
      stackTrace,
      userId,
      userEmail,
      devicePlatform,
      appVersion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppLog &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.category == this.category &&
          other.level == this.level &&
          other.screenName == this.screenName &&
          other.operation == this.operation &&
          other.message == this.message &&
          other.details == this.details &&
          other.stackTrace == this.stackTrace &&
          other.userId == this.userId &&
          other.userEmail == this.userEmail &&
          other.devicePlatform == this.devicePlatform &&
          other.appVersion == this.appVersion);
}

class AppLogsCompanion extends UpdateCompanion<AppLog> {
  final Value<String> id;
  final Value<String> timestamp;
  final Value<String> category;
  final Value<String> level;
  final Value<String> screenName;
  final Value<String> operation;
  final Value<String> message;
  final Value<String> details;
  final Value<String> stackTrace;
  final Value<String> userId;
  final Value<String> userEmail;
  final Value<String> devicePlatform;
  final Value<String> appVersion;
  final Value<int> rowid;
  const AppLogsCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.category = const Value.absent(),
    this.level = const Value.absent(),
    this.screenName = const Value.absent(),
    this.operation = const Value.absent(),
    this.message = const Value.absent(),
    this.details = const Value.absent(),
    this.stackTrace = const Value.absent(),
    this.userId = const Value.absent(),
    this.userEmail = const Value.absent(),
    this.devicePlatform = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppLogsCompanion.insert({
    required String id,
    required String timestamp,
    required String category,
    required String level,
    required String screenName,
    required String operation,
    required String message,
    this.details = const Value.absent(),
    this.stackTrace = const Value.absent(),
    this.userId = const Value.absent(),
    this.userEmail = const Value.absent(),
    this.devicePlatform = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        timestamp = Value(timestamp),
        category = Value(category),
        level = Value(level),
        screenName = Value(screenName),
        operation = Value(operation),
        message = Value(message);
  static Insertable<AppLog> custom({
    Expression<String>? id,
    Expression<String>? timestamp,
    Expression<String>? category,
    Expression<String>? level,
    Expression<String>? screenName,
    Expression<String>? operation,
    Expression<String>? message,
    Expression<String>? details,
    Expression<String>? stackTrace,
    Expression<String>? userId,
    Expression<String>? userEmail,
    Expression<String>? devicePlatform,
    Expression<String>? appVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
      if (category != null) 'category': category,
      if (level != null) 'level': level,
      if (screenName != null) 'screen_name': screenName,
      if (operation != null) 'operation': operation,
      if (message != null) 'message': message,
      if (details != null) 'details': details,
      if (stackTrace != null) 'stack_trace': stackTrace,
      if (userId != null) 'user_id': userId,
      if (userEmail != null) 'user_email': userEmail,
      if (devicePlatform != null) 'device_platform': devicePlatform,
      if (appVersion != null) 'app_version': appVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? timestamp,
      Value<String>? category,
      Value<String>? level,
      Value<String>? screenName,
      Value<String>? operation,
      Value<String>? message,
      Value<String>? details,
      Value<String>? stackTrace,
      Value<String>? userId,
      Value<String>? userEmail,
      Value<String>? devicePlatform,
      Value<String>? appVersion,
      Value<int>? rowid}) {
    return AppLogsCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      level: level ?? this.level,
      screenName: screenName ?? this.screenName,
      operation: operation ?? this.operation,
      message: message ?? this.message,
      details: details ?? this.details,
      stackTrace: stackTrace ?? this.stackTrace,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      devicePlatform: devicePlatform ?? this.devicePlatform,
      appVersion: appVersion ?? this.appVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<String>(timestamp.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (screenName.present) {
      map['screen_name'] = Variable<String>(screenName.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (stackTrace.present) {
      map['stack_trace'] = Variable<String>(stackTrace.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (userEmail.present) {
      map['user_email'] = Variable<String>(userEmail.value);
    }
    if (devicePlatform.present) {
      map['device_platform'] = Variable<String>(devicePlatform.value);
    }
    if (appVersion.present) {
      map['app_version'] = Variable<String>(appVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppLogsCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('category: $category, ')
          ..write('level: $level, ')
          ..write('screenName: $screenName, ')
          ..write('operation: $operation, ')
          ..write('message: $message, ')
          ..write('details: $details, ')
          ..write('stackTrace: $stackTrace, ')
          ..write('userId: $userId, ')
          ..write('userEmail: $userEmail, ')
          ..write('devicePlatform: $devicePlatform, ')
          ..write('appVersion: $appVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VillasTable villas = $VillasTable(this);
  late final $RoomsTable rooms = $RoomsTable(this);
  late final $IncomesTable incomes = $IncomesTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $AppLogsTable appLogs = $AppLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [villas, rooms, incomes, expenses, appLogs];
}

typedef $$VillasTableCreateCompanionBuilder = VillasCompanion Function({
  required String id,
  Value<String> orgId,
  required String villaName,
  Value<String> villaNumber,
  required String location,
  Value<String> notes,
  required String tenantName,
  required String tenantPhone,
  required double monthlyRent,
  required DateTime contractStartDate,
  required DateTime contractEndDate,
  required int paymentDueDay,
  required String status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> isDeleted,
  Value<String> syncStatus,
  Value<DateTime?> deletedAt,
  Value<String?> deletedBy,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<DateTime?> lastSyncedAt,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> mapAddress,
  Value<String?> googleMapsUrl,
  Value<String?> wazeUrl,
  Value<int> rowid,
});
typedef $$VillasTableUpdateCompanionBuilder = VillasCompanion Function({
  Value<String> id,
  Value<String> orgId,
  Value<String> villaName,
  Value<String> villaNumber,
  Value<String> location,
  Value<String> notes,
  Value<String> tenantName,
  Value<String> tenantPhone,
  Value<double> monthlyRent,
  Value<DateTime> contractStartDate,
  Value<DateTime> contractEndDate,
  Value<int> paymentDueDay,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> isDeleted,
  Value<String> syncStatus,
  Value<DateTime?> deletedAt,
  Value<String?> deletedBy,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<DateTime?> lastSyncedAt,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> mapAddress,
  Value<String?> googleMapsUrl,
  Value<String?> wazeUrl,
  Value<int> rowid,
});

final class $$VillasTableReferences
    extends BaseReferences<_$AppDatabase, $VillasTable, Villa> {
  $$VillasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RoomsTable, List<Room>> _roomsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.rooms,
          aliasName: $_aliasNameGenerator(db.villas.id, db.rooms.villaId));

  $$RoomsTableProcessedTableManager get roomsRefs {
    final manager = $$RoomsTableTableManager($_db, $_db.rooms)
        .filter((f) => f.villaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_roomsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$IncomesTable, List<Income>> _incomesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.incomes,
          aliasName: $_aliasNameGenerator(db.villas.id, db.incomes.villaId));

  $$IncomesTableProcessedTableManager get incomesRefs {
    final manager = $$IncomesTableTableManager($_db, $_db.incomes)
        .filter((f) => f.villaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_incomesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.expenses,
          aliasName: $_aliasNameGenerator(db.villas.id, db.expenses.villaId));

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager($_db, $_db.expenses)
        .filter((f) => f.villaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$VillasTableFilterComposer
    extends Composer<_$AppDatabase, $VillasTable> {
  $$VillasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get orgId => $composableBuilder(
      column: $table.orgId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get villaName => $composableBuilder(
      column: $table.villaName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get villaNumber => $composableBuilder(
      column: $table.villaNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantName => $composableBuilder(
      column: $table.tenantName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantPhone => $composableBuilder(
      column: $table.tenantPhone, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get monthlyRent => $composableBuilder(
      column: $table.monthlyRent, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get contractStartDate => $composableBuilder(
      column: $table.contractStartDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get contractEndDate => $composableBuilder(
      column: $table.contractEndDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get paymentDueDay => $composableBuilder(
      column: $table.paymentDueDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedBy => $composableBuilder(
      column: $table.deletedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mapAddress => $composableBuilder(
      column: $table.mapAddress, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get googleMapsUrl => $composableBuilder(
      column: $table.googleMapsUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wazeUrl => $composableBuilder(
      column: $table.wazeUrl, builder: (column) => ColumnFilters(column));

  Expression<bool> roomsRefs(
      Expression<bool> Function($$RoomsTableFilterComposer f) f) {
    final $$RoomsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.rooms,
        getReferencedColumn: (t) => t.villaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomsTableFilterComposer(
              $db: $db,
              $table: $db.rooms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> incomesRefs(
      Expression<bool> Function($$IncomesTableFilterComposer f) f) {
    final $$IncomesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.incomes,
        getReferencedColumn: (t) => t.villaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$IncomesTableFilterComposer(
              $db: $db,
              $table: $db.incomes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> expensesRefs(
      Expression<bool> Function($$ExpensesTableFilterComposer f) f) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.villaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableFilterComposer(
              $db: $db,
              $table: $db.expenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$VillasTableOrderingComposer
    extends Composer<_$AppDatabase, $VillasTable> {
  $$VillasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get orgId => $composableBuilder(
      column: $table.orgId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get villaName => $composableBuilder(
      column: $table.villaName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get villaNumber => $composableBuilder(
      column: $table.villaNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantName => $composableBuilder(
      column: $table.tenantName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantPhone => $composableBuilder(
      column: $table.tenantPhone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get monthlyRent => $composableBuilder(
      column: $table.monthlyRent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get contractStartDate => $composableBuilder(
      column: $table.contractStartDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get contractEndDate => $composableBuilder(
      column: $table.contractEndDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get paymentDueDay => $composableBuilder(
      column: $table.paymentDueDay,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedBy => $composableBuilder(
      column: $table.deletedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mapAddress => $composableBuilder(
      column: $table.mapAddress, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get googleMapsUrl => $composableBuilder(
      column: $table.googleMapsUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wazeUrl => $composableBuilder(
      column: $table.wazeUrl, builder: (column) => ColumnOrderings(column));
}

class $$VillasTableAnnotationComposer
    extends Composer<_$AppDatabase, $VillasTable> {
  $$VillasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get orgId =>
      $composableBuilder(column: $table.orgId, builder: (column) => column);

  GeneratedColumn<String> get villaName =>
      $composableBuilder(column: $table.villaName, builder: (column) => column);

  GeneratedColumn<String> get villaNumber => $composableBuilder(
      column: $table.villaNumber, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get tenantName => $composableBuilder(
      column: $table.tenantName, builder: (column) => column);

  GeneratedColumn<String> get tenantPhone => $composableBuilder(
      column: $table.tenantPhone, builder: (column) => column);

  GeneratedColumn<double> get monthlyRent => $composableBuilder(
      column: $table.monthlyRent, builder: (column) => column);

  GeneratedColumn<DateTime> get contractStartDate => $composableBuilder(
      column: $table.contractStartDate, builder: (column) => column);

  GeneratedColumn<DateTime> get contractEndDate => $composableBuilder(
      column: $table.contractEndDate, builder: (column) => column);

  GeneratedColumn<int> get paymentDueDay => $composableBuilder(
      column: $table.paymentDueDay, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedBy =>
      $composableBuilder(column: $table.deletedBy, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get mapAddress => $composableBuilder(
      column: $table.mapAddress, builder: (column) => column);

  GeneratedColumn<String> get googleMapsUrl => $composableBuilder(
      column: $table.googleMapsUrl, builder: (column) => column);

  GeneratedColumn<String> get wazeUrl =>
      $composableBuilder(column: $table.wazeUrl, builder: (column) => column);

  Expression<T> roomsRefs<T extends Object>(
      Expression<T> Function($$RoomsTableAnnotationComposer a) f) {
    final $$RoomsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.rooms,
        getReferencedColumn: (t) => t.villaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomsTableAnnotationComposer(
              $db: $db,
              $table: $db.rooms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> incomesRefs<T extends Object>(
      Expression<T> Function($$IncomesTableAnnotationComposer a) f) {
    final $$IncomesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.incomes,
        getReferencedColumn: (t) => t.villaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$IncomesTableAnnotationComposer(
              $db: $db,
              $table: $db.incomes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> expensesRefs<T extends Object>(
      Expression<T> Function($$ExpensesTableAnnotationComposer a) f) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.villaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableAnnotationComposer(
              $db: $db,
              $table: $db.expenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$VillasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VillasTable,
    Villa,
    $$VillasTableFilterComposer,
    $$VillasTableOrderingComposer,
    $$VillasTableAnnotationComposer,
    $$VillasTableCreateCompanionBuilder,
    $$VillasTableUpdateCompanionBuilder,
    (Villa, $$VillasTableReferences),
    Villa,
    PrefetchHooks Function(
        {bool roomsRefs, bool incomesRefs, bool expensesRefs})> {
  $$VillasTableTableManager(_$AppDatabase db, $VillasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VillasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VillasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VillasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> orgId = const Value.absent(),
            Value<String> villaName = const Value.absent(),
            Value<String> villaNumber = const Value.absent(),
            Value<String> location = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<String> tenantName = const Value.absent(),
            Value<String> tenantPhone = const Value.absent(),
            Value<double> monthlyRent = const Value.absent(),
            Value<DateTime> contractStartDate = const Value.absent(),
            Value<DateTime> contractEndDate = const Value.absent(),
            Value<int> paymentDueDay = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> isDeleted = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> deletedBy = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<String?> updatedBy = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String?> mapAddress = const Value.absent(),
            Value<String?> googleMapsUrl = const Value.absent(),
            Value<String?> wazeUrl = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VillasCompanion(
            id: id,
            orgId: orgId,
            villaName: villaName,
            villaNumber: villaNumber,
            location: location,
            notes: notes,
            tenantName: tenantName,
            tenantPhone: tenantPhone,
            monthlyRent: monthlyRent,
            contractStartDate: contractStartDate,
            contractEndDate: contractEndDate,
            paymentDueDay: paymentDueDay,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            syncStatus: syncStatus,
            deletedAt: deletedAt,
            deletedBy: deletedBy,
            createdBy: createdBy,
            updatedBy: updatedBy,
            lastSyncedAt: lastSyncedAt,
            latitude: latitude,
            longitude: longitude,
            mapAddress: mapAddress,
            googleMapsUrl: googleMapsUrl,
            wazeUrl: wazeUrl,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> orgId = const Value.absent(),
            required String villaName,
            Value<String> villaNumber = const Value.absent(),
            required String location,
            Value<String> notes = const Value.absent(),
            required String tenantName,
            required String tenantPhone,
            required double monthlyRent,
            required DateTime contractStartDate,
            required DateTime contractEndDate,
            required int paymentDueDay,
            required String status,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> isDeleted = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> deletedBy = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<String?> updatedBy = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String?> mapAddress = const Value.absent(),
            Value<String?> googleMapsUrl = const Value.absent(),
            Value<String?> wazeUrl = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VillasCompanion.insert(
            id: id,
            orgId: orgId,
            villaName: villaName,
            villaNumber: villaNumber,
            location: location,
            notes: notes,
            tenantName: tenantName,
            tenantPhone: tenantPhone,
            monthlyRent: monthlyRent,
            contractStartDate: contractStartDate,
            contractEndDate: contractEndDate,
            paymentDueDay: paymentDueDay,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            syncStatus: syncStatus,
            deletedAt: deletedAt,
            deletedBy: deletedBy,
            createdBy: createdBy,
            updatedBy: updatedBy,
            lastSyncedAt: lastSyncedAt,
            latitude: latitude,
            longitude: longitude,
            mapAddress: mapAddress,
            googleMapsUrl: googleMapsUrl,
            wazeUrl: wazeUrl,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$VillasTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {roomsRefs = false, incomesRefs = false, expensesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (roomsRefs) db.rooms,
                if (incomesRefs) db.incomes,
                if (expensesRefs) db.expenses
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (roomsRefs)
                    await $_getPrefetchedData<Villa, $VillasTable, Room>(
                        currentTable: table,
                        referencedTable:
                            $$VillasTableReferences._roomsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$VillasTableReferences(db, table, p0).roomsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.villaId == item.id),
                        typedResults: items),
                  if (incomesRefs)
                    await $_getPrefetchedData<Villa, $VillasTable, Income>(
                        currentTable: table,
                        referencedTable:
                            $$VillasTableReferences._incomesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$VillasTableReferences(db, table, p0).incomesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.villaId == item.id),
                        typedResults: items),
                  if (expensesRefs)
                    await $_getPrefetchedData<Villa, $VillasTable, Expense>(
                        currentTable: table,
                        referencedTable:
                            $$VillasTableReferences._expensesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$VillasTableReferences(db, table, p0).expensesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.villaId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$VillasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VillasTable,
    Villa,
    $$VillasTableFilterComposer,
    $$VillasTableOrderingComposer,
    $$VillasTableAnnotationComposer,
    $$VillasTableCreateCompanionBuilder,
    $$VillasTableUpdateCompanionBuilder,
    (Villa, $$VillasTableReferences),
    Villa,
    PrefetchHooks Function(
        {bool roomsRefs, bool incomesRefs, bool expensesRefs})>;
typedef $$RoomsTableCreateCompanionBuilder = RoomsCompanion Function({
  required String id,
  Value<String> orgId,
  required String villaId,
  required String villaName,
  required String roomName,
  Value<String> roomNumber,
  Value<String?> tenantName,
  Value<String?> tenantPhone,
  required double monthlyRent,
  Value<DateTime?> contractStartDate,
  Value<DateTime?> contractEndDate,
  required int paymentDueDay,
  required String status,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> isDeleted,
  Value<String> syncStatus,
  Value<DateTime?> deletedAt,
  Value<String?> deletedBy,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<DateTime?> lastSyncedAt,
  Value<String> depositType,
  Value<double> depositAmount,
  Value<DateTime?> depositDate,
  Value<String> depositStatus,
  Value<String> depositNotes,
  Value<String> depositIncomeId,
  Value<String> depositRefundExpenseId,
  Value<DateTime?> moveInDate,
  Value<DateTime?> moveOutDate,
  Value<String> lastTenantName,
  Value<String> lastTenantPhone,
  Value<double> refundAmount,
  Value<double> retainedAmount,
  Value<String> depositReason,
  Value<String> tenantHistoryJson,
  Value<int> rowid,
});
typedef $$RoomsTableUpdateCompanionBuilder = RoomsCompanion Function({
  Value<String> id,
  Value<String> orgId,
  Value<String> villaId,
  Value<String> villaName,
  Value<String> roomName,
  Value<String> roomNumber,
  Value<String?> tenantName,
  Value<String?> tenantPhone,
  Value<double> monthlyRent,
  Value<DateTime?> contractStartDate,
  Value<DateTime?> contractEndDate,
  Value<int> paymentDueDay,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> isDeleted,
  Value<String> syncStatus,
  Value<DateTime?> deletedAt,
  Value<String?> deletedBy,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<DateTime?> lastSyncedAt,
  Value<String> depositType,
  Value<double> depositAmount,
  Value<DateTime?> depositDate,
  Value<String> depositStatus,
  Value<String> depositNotes,
  Value<String> depositIncomeId,
  Value<String> depositRefundExpenseId,
  Value<DateTime?> moveInDate,
  Value<DateTime?> moveOutDate,
  Value<String> lastTenantName,
  Value<String> lastTenantPhone,
  Value<double> refundAmount,
  Value<double> retainedAmount,
  Value<String> depositReason,
  Value<String> tenantHistoryJson,
  Value<int> rowid,
});

final class $$RoomsTableReferences
    extends BaseReferences<_$AppDatabase, $RoomsTable, Room> {
  $$RoomsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VillasTable _villaIdTable(_$AppDatabase db) => db.villas
      .createAlias($_aliasNameGenerator(db.rooms.villaId, db.villas.id));

  $$VillasTableProcessedTableManager get villaId {
    final $_column = $_itemColumn<String>('villa_id')!;

    final manager = $$VillasTableTableManager($_db, $_db.villas)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_villaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RoomsTableFilterComposer extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get orgId => $composableBuilder(
      column: $table.orgId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get villaName => $composableBuilder(
      column: $table.villaName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get roomName => $composableBuilder(
      column: $table.roomName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get roomNumber => $composableBuilder(
      column: $table.roomNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantName => $composableBuilder(
      column: $table.tenantName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantPhone => $composableBuilder(
      column: $table.tenantPhone, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get monthlyRent => $composableBuilder(
      column: $table.monthlyRent, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get contractStartDate => $composableBuilder(
      column: $table.contractStartDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get contractEndDate => $composableBuilder(
      column: $table.contractEndDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get paymentDueDay => $composableBuilder(
      column: $table.paymentDueDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedBy => $composableBuilder(
      column: $table.deletedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get depositType => $composableBuilder(
      column: $table.depositType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get depositAmount => $composableBuilder(
      column: $table.depositAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get depositDate => $composableBuilder(
      column: $table.depositDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get depositStatus => $composableBuilder(
      column: $table.depositStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get depositNotes => $composableBuilder(
      column: $table.depositNotes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get depositIncomeId => $composableBuilder(
      column: $table.depositIncomeId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get depositRefundExpenseId => $composableBuilder(
      column: $table.depositRefundExpenseId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get moveInDate => $composableBuilder(
      column: $table.moveInDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get moveOutDate => $composableBuilder(
      column: $table.moveOutDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastTenantName => $composableBuilder(
      column: $table.lastTenantName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastTenantPhone => $composableBuilder(
      column: $table.lastTenantPhone,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get refundAmount => $composableBuilder(
      column: $table.refundAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get retainedAmount => $composableBuilder(
      column: $table.retainedAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get depositReason => $composableBuilder(
      column: $table.depositReason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantHistoryJson => $composableBuilder(
      column: $table.tenantHistoryJson,
      builder: (column) => ColumnFilters(column));

  $$VillasTableFilterComposer get villaId {
    final $$VillasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.villaId,
        referencedTable: $db.villas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VillasTableFilterComposer(
              $db: $db,
              $table: $db.villas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RoomsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get orgId => $composableBuilder(
      column: $table.orgId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get villaName => $composableBuilder(
      column: $table.villaName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get roomName => $composableBuilder(
      column: $table.roomName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get roomNumber => $composableBuilder(
      column: $table.roomNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantName => $composableBuilder(
      column: $table.tenantName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantPhone => $composableBuilder(
      column: $table.tenantPhone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get monthlyRent => $composableBuilder(
      column: $table.monthlyRent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get contractStartDate => $composableBuilder(
      column: $table.contractStartDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get contractEndDate => $composableBuilder(
      column: $table.contractEndDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get paymentDueDay => $composableBuilder(
      column: $table.paymentDueDay,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedBy => $composableBuilder(
      column: $table.deletedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get depositType => $composableBuilder(
      column: $table.depositType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get depositAmount => $composableBuilder(
      column: $table.depositAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get depositDate => $composableBuilder(
      column: $table.depositDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get depositStatus => $composableBuilder(
      column: $table.depositStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get depositNotes => $composableBuilder(
      column: $table.depositNotes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get depositIncomeId => $composableBuilder(
      column: $table.depositIncomeId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get depositRefundExpenseId => $composableBuilder(
      column: $table.depositRefundExpenseId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get moveInDate => $composableBuilder(
      column: $table.moveInDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get moveOutDate => $composableBuilder(
      column: $table.moveOutDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastTenantName => $composableBuilder(
      column: $table.lastTenantName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastTenantPhone => $composableBuilder(
      column: $table.lastTenantPhone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get refundAmount => $composableBuilder(
      column: $table.refundAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get retainedAmount => $composableBuilder(
      column: $table.retainedAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get depositReason => $composableBuilder(
      column: $table.depositReason,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantHistoryJson => $composableBuilder(
      column: $table.tenantHistoryJson,
      builder: (column) => ColumnOrderings(column));

  $$VillasTableOrderingComposer get villaId {
    final $$VillasTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.villaId,
        referencedTable: $db.villas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VillasTableOrderingComposer(
              $db: $db,
              $table: $db.villas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RoomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get orgId =>
      $composableBuilder(column: $table.orgId, builder: (column) => column);

  GeneratedColumn<String> get villaName =>
      $composableBuilder(column: $table.villaName, builder: (column) => column);

  GeneratedColumn<String> get roomName =>
      $composableBuilder(column: $table.roomName, builder: (column) => column);

  GeneratedColumn<String> get roomNumber => $composableBuilder(
      column: $table.roomNumber, builder: (column) => column);

  GeneratedColumn<String> get tenantName => $composableBuilder(
      column: $table.tenantName, builder: (column) => column);

  GeneratedColumn<String> get tenantPhone => $composableBuilder(
      column: $table.tenantPhone, builder: (column) => column);

  GeneratedColumn<double> get monthlyRent => $composableBuilder(
      column: $table.monthlyRent, builder: (column) => column);

  GeneratedColumn<DateTime> get contractStartDate => $composableBuilder(
      column: $table.contractStartDate, builder: (column) => column);

  GeneratedColumn<DateTime> get contractEndDate => $composableBuilder(
      column: $table.contractEndDate, builder: (column) => column);

  GeneratedColumn<int> get paymentDueDay => $composableBuilder(
      column: $table.paymentDueDay, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedBy =>
      $composableBuilder(column: $table.deletedBy, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  GeneratedColumn<String> get depositType => $composableBuilder(
      column: $table.depositType, builder: (column) => column);

  GeneratedColumn<double> get depositAmount => $composableBuilder(
      column: $table.depositAmount, builder: (column) => column);

  GeneratedColumn<DateTime> get depositDate => $composableBuilder(
      column: $table.depositDate, builder: (column) => column);

  GeneratedColumn<String> get depositStatus => $composableBuilder(
      column: $table.depositStatus, builder: (column) => column);

  GeneratedColumn<String> get depositNotes => $composableBuilder(
      column: $table.depositNotes, builder: (column) => column);

  GeneratedColumn<String> get depositIncomeId => $composableBuilder(
      column: $table.depositIncomeId, builder: (column) => column);

  GeneratedColumn<String> get depositRefundExpenseId => $composableBuilder(
      column: $table.depositRefundExpenseId, builder: (column) => column);

  GeneratedColumn<DateTime> get moveInDate => $composableBuilder(
      column: $table.moveInDate, builder: (column) => column);

  GeneratedColumn<DateTime> get moveOutDate => $composableBuilder(
      column: $table.moveOutDate, builder: (column) => column);

  GeneratedColumn<String> get lastTenantName => $composableBuilder(
      column: $table.lastTenantName, builder: (column) => column);

  GeneratedColumn<String> get lastTenantPhone => $composableBuilder(
      column: $table.lastTenantPhone, builder: (column) => column);

  GeneratedColumn<double> get refundAmount => $composableBuilder(
      column: $table.refundAmount, builder: (column) => column);

  GeneratedColumn<double> get retainedAmount => $composableBuilder(
      column: $table.retainedAmount, builder: (column) => column);

  GeneratedColumn<String> get depositReason => $composableBuilder(
      column: $table.depositReason, builder: (column) => column);

  GeneratedColumn<String> get tenantHistoryJson => $composableBuilder(
      column: $table.tenantHistoryJson, builder: (column) => column);

  $$VillasTableAnnotationComposer get villaId {
    final $$VillasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.villaId,
        referencedTable: $db.villas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VillasTableAnnotationComposer(
              $db: $db,
              $table: $db.villas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RoomsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RoomsTable,
    Room,
    $$RoomsTableFilterComposer,
    $$RoomsTableOrderingComposer,
    $$RoomsTableAnnotationComposer,
    $$RoomsTableCreateCompanionBuilder,
    $$RoomsTableUpdateCompanionBuilder,
    (Room, $$RoomsTableReferences),
    Room,
    PrefetchHooks Function({bool villaId})> {
  $$RoomsTableTableManager(_$AppDatabase db, $RoomsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> orgId = const Value.absent(),
            Value<String> villaId = const Value.absent(),
            Value<String> villaName = const Value.absent(),
            Value<String> roomName = const Value.absent(),
            Value<String> roomNumber = const Value.absent(),
            Value<String?> tenantName = const Value.absent(),
            Value<String?> tenantPhone = const Value.absent(),
            Value<double> monthlyRent = const Value.absent(),
            Value<DateTime?> contractStartDate = const Value.absent(),
            Value<DateTime?> contractEndDate = const Value.absent(),
            Value<int> paymentDueDay = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> isDeleted = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> deletedBy = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<String?> updatedBy = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<String> depositType = const Value.absent(),
            Value<double> depositAmount = const Value.absent(),
            Value<DateTime?> depositDate = const Value.absent(),
            Value<String> depositStatus = const Value.absent(),
            Value<String> depositNotes = const Value.absent(),
            Value<String> depositIncomeId = const Value.absent(),
            Value<String> depositRefundExpenseId = const Value.absent(),
            Value<DateTime?> moveInDate = const Value.absent(),
            Value<DateTime?> moveOutDate = const Value.absent(),
            Value<String> lastTenantName = const Value.absent(),
            Value<String> lastTenantPhone = const Value.absent(),
            Value<double> refundAmount = const Value.absent(),
            Value<double> retainedAmount = const Value.absent(),
            Value<String> depositReason = const Value.absent(),
            Value<String> tenantHistoryJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoomsCompanion(
            id: id,
            orgId: orgId,
            villaId: villaId,
            villaName: villaName,
            roomName: roomName,
            roomNumber: roomNumber,
            tenantName: tenantName,
            tenantPhone: tenantPhone,
            monthlyRent: monthlyRent,
            contractStartDate: contractStartDate,
            contractEndDate: contractEndDate,
            paymentDueDay: paymentDueDay,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            syncStatus: syncStatus,
            deletedAt: deletedAt,
            deletedBy: deletedBy,
            createdBy: createdBy,
            updatedBy: updatedBy,
            lastSyncedAt: lastSyncedAt,
            depositType: depositType,
            depositAmount: depositAmount,
            depositDate: depositDate,
            depositStatus: depositStatus,
            depositNotes: depositNotes,
            depositIncomeId: depositIncomeId,
            depositRefundExpenseId: depositRefundExpenseId,
            moveInDate: moveInDate,
            moveOutDate: moveOutDate,
            lastTenantName: lastTenantName,
            lastTenantPhone: lastTenantPhone,
            refundAmount: refundAmount,
            retainedAmount: retainedAmount,
            depositReason: depositReason,
            tenantHistoryJson: tenantHistoryJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> orgId = const Value.absent(),
            required String villaId,
            required String villaName,
            required String roomName,
            Value<String> roomNumber = const Value.absent(),
            Value<String?> tenantName = const Value.absent(),
            Value<String?> tenantPhone = const Value.absent(),
            required double monthlyRent,
            Value<DateTime?> contractStartDate = const Value.absent(),
            Value<DateTime?> contractEndDate = const Value.absent(),
            required int paymentDueDay,
            required String status,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> isDeleted = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> deletedBy = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<String?> updatedBy = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<String> depositType = const Value.absent(),
            Value<double> depositAmount = const Value.absent(),
            Value<DateTime?> depositDate = const Value.absent(),
            Value<String> depositStatus = const Value.absent(),
            Value<String> depositNotes = const Value.absent(),
            Value<String> depositIncomeId = const Value.absent(),
            Value<String> depositRefundExpenseId = const Value.absent(),
            Value<DateTime?> moveInDate = const Value.absent(),
            Value<DateTime?> moveOutDate = const Value.absent(),
            Value<String> lastTenantName = const Value.absent(),
            Value<String> lastTenantPhone = const Value.absent(),
            Value<double> refundAmount = const Value.absent(),
            Value<double> retainedAmount = const Value.absent(),
            Value<String> depositReason = const Value.absent(),
            Value<String> tenantHistoryJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoomsCompanion.insert(
            id: id,
            orgId: orgId,
            villaId: villaId,
            villaName: villaName,
            roomName: roomName,
            roomNumber: roomNumber,
            tenantName: tenantName,
            tenantPhone: tenantPhone,
            monthlyRent: monthlyRent,
            contractStartDate: contractStartDate,
            contractEndDate: contractEndDate,
            paymentDueDay: paymentDueDay,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            syncStatus: syncStatus,
            deletedAt: deletedAt,
            deletedBy: deletedBy,
            createdBy: createdBy,
            updatedBy: updatedBy,
            lastSyncedAt: lastSyncedAt,
            depositType: depositType,
            depositAmount: depositAmount,
            depositDate: depositDate,
            depositStatus: depositStatus,
            depositNotes: depositNotes,
            depositIncomeId: depositIncomeId,
            depositRefundExpenseId: depositRefundExpenseId,
            moveInDate: moveInDate,
            moveOutDate: moveOutDate,
            lastTenantName: lastTenantName,
            lastTenantPhone: lastTenantPhone,
            refundAmount: refundAmount,
            retainedAmount: retainedAmount,
            depositReason: depositReason,
            tenantHistoryJson: tenantHistoryJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$RoomsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({villaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (villaId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.villaId,
                    referencedTable: $$RoomsTableReferences._villaIdTable(db),
                    referencedColumn:
                        $$RoomsTableReferences._villaIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RoomsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RoomsTable,
    Room,
    $$RoomsTableFilterComposer,
    $$RoomsTableOrderingComposer,
    $$RoomsTableAnnotationComposer,
    $$RoomsTableCreateCompanionBuilder,
    $$RoomsTableUpdateCompanionBuilder,
    (Room, $$RoomsTableReferences),
    Room,
    PrefetchHooks Function({bool villaId})>;
typedef $$IncomesTableCreateCompanionBuilder = IncomesCompanion Function({
  required String id,
  Value<String> orgId,
  required String villaId,
  Value<String> villaName,
  Value<String> roomId,
  Value<String> roomName,
  Value<String> tenantName,
  required String incomeType,
  required double amount,
  required DateTime paymentDate,
  required String paymentMethod,
  required DateTime monthCovered,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> isDeleted,
  Value<String> syncStatus,
  Value<DateTime?> deletedAt,
  Value<String?> deletedBy,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$IncomesTableUpdateCompanionBuilder = IncomesCompanion Function({
  Value<String> id,
  Value<String> orgId,
  Value<String> villaId,
  Value<String> villaName,
  Value<String> roomId,
  Value<String> roomName,
  Value<String> tenantName,
  Value<String> incomeType,
  Value<double> amount,
  Value<DateTime> paymentDate,
  Value<String> paymentMethod,
  Value<DateTime> monthCovered,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> isDeleted,
  Value<String> syncStatus,
  Value<DateTime?> deletedAt,
  Value<String?> deletedBy,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

final class $$IncomesTableReferences
    extends BaseReferences<_$AppDatabase, $IncomesTable, Income> {
  $$IncomesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VillasTable _villaIdTable(_$AppDatabase db) => db.villas
      .createAlias($_aliasNameGenerator(db.incomes.villaId, db.villas.id));

  $$VillasTableProcessedTableManager get villaId {
    final $_column = $_itemColumn<String>('villa_id')!;

    final manager = $$VillasTableTableManager($_db, $_db.villas)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_villaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$IncomesTableFilterComposer
    extends Composer<_$AppDatabase, $IncomesTable> {
  $$IncomesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get orgId => $composableBuilder(
      column: $table.orgId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get villaName => $composableBuilder(
      column: $table.villaName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get roomId => $composableBuilder(
      column: $table.roomId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get roomName => $composableBuilder(
      column: $table.roomName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantName => $composableBuilder(
      column: $table.tenantName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get incomeType => $composableBuilder(
      column: $table.incomeType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get monthCovered => $composableBuilder(
      column: $table.monthCovered, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedBy => $composableBuilder(
      column: $table.deletedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  $$VillasTableFilterComposer get villaId {
    final $$VillasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.villaId,
        referencedTable: $db.villas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VillasTableFilterComposer(
              $db: $db,
              $table: $db.villas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$IncomesTableOrderingComposer
    extends Composer<_$AppDatabase, $IncomesTable> {
  $$IncomesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get orgId => $composableBuilder(
      column: $table.orgId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get villaName => $composableBuilder(
      column: $table.villaName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get roomId => $composableBuilder(
      column: $table.roomId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get roomName => $composableBuilder(
      column: $table.roomName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantName => $composableBuilder(
      column: $table.tenantName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get incomeType => $composableBuilder(
      column: $table.incomeType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get monthCovered => $composableBuilder(
      column: $table.monthCovered,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedBy => $composableBuilder(
      column: $table.deletedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  $$VillasTableOrderingComposer get villaId {
    final $$VillasTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.villaId,
        referencedTable: $db.villas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VillasTableOrderingComposer(
              $db: $db,
              $table: $db.villas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$IncomesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IncomesTable> {
  $$IncomesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get orgId =>
      $composableBuilder(column: $table.orgId, builder: (column) => column);

  GeneratedColumn<String> get villaName =>
      $composableBuilder(column: $table.villaName, builder: (column) => column);

  GeneratedColumn<String> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<String> get roomName =>
      $composableBuilder(column: $table.roomName, builder: (column) => column);

  GeneratedColumn<String> get tenantName => $composableBuilder(
      column: $table.tenantName, builder: (column) => column);

  GeneratedColumn<String> get incomeType => $composableBuilder(
      column: $table.incomeType, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => column);

  GeneratedColumn<DateTime> get monthCovered => $composableBuilder(
      column: $table.monthCovered, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedBy =>
      $composableBuilder(column: $table.deletedBy, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  $$VillasTableAnnotationComposer get villaId {
    final $$VillasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.villaId,
        referencedTable: $db.villas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VillasTableAnnotationComposer(
              $db: $db,
              $table: $db.villas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$IncomesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $IncomesTable,
    Income,
    $$IncomesTableFilterComposer,
    $$IncomesTableOrderingComposer,
    $$IncomesTableAnnotationComposer,
    $$IncomesTableCreateCompanionBuilder,
    $$IncomesTableUpdateCompanionBuilder,
    (Income, $$IncomesTableReferences),
    Income,
    PrefetchHooks Function({bool villaId})> {
  $$IncomesTableTableManager(_$AppDatabase db, $IncomesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IncomesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IncomesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IncomesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> orgId = const Value.absent(),
            Value<String> villaId = const Value.absent(),
            Value<String> villaName = const Value.absent(),
            Value<String> roomId = const Value.absent(),
            Value<String> roomName = const Value.absent(),
            Value<String> tenantName = const Value.absent(),
            Value<String> incomeType = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<DateTime> paymentDate = const Value.absent(),
            Value<String> paymentMethod = const Value.absent(),
            Value<DateTime> monthCovered = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> isDeleted = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> deletedBy = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<String?> updatedBy = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              IncomesCompanion(
            id: id,
            orgId: orgId,
            villaId: villaId,
            villaName: villaName,
            roomId: roomId,
            roomName: roomName,
            tenantName: tenantName,
            incomeType: incomeType,
            amount: amount,
            paymentDate: paymentDate,
            paymentMethod: paymentMethod,
            monthCovered: monthCovered,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            syncStatus: syncStatus,
            deletedAt: deletedAt,
            deletedBy: deletedBy,
            createdBy: createdBy,
            updatedBy: updatedBy,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> orgId = const Value.absent(),
            required String villaId,
            Value<String> villaName = const Value.absent(),
            Value<String> roomId = const Value.absent(),
            Value<String> roomName = const Value.absent(),
            Value<String> tenantName = const Value.absent(),
            required String incomeType,
            required double amount,
            required DateTime paymentDate,
            required String paymentMethod,
            required DateTime monthCovered,
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> isDeleted = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> deletedBy = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<String?> updatedBy = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              IncomesCompanion.insert(
            id: id,
            orgId: orgId,
            villaId: villaId,
            villaName: villaName,
            roomId: roomId,
            roomName: roomName,
            tenantName: tenantName,
            incomeType: incomeType,
            amount: amount,
            paymentDate: paymentDate,
            paymentMethod: paymentMethod,
            monthCovered: monthCovered,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            syncStatus: syncStatus,
            deletedAt: deletedAt,
            deletedBy: deletedBy,
            createdBy: createdBy,
            updatedBy: updatedBy,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$IncomesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({villaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (villaId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.villaId,
                    referencedTable: $$IncomesTableReferences._villaIdTable(db),
                    referencedColumn:
                        $$IncomesTableReferences._villaIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$IncomesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $IncomesTable,
    Income,
    $$IncomesTableFilterComposer,
    $$IncomesTableOrderingComposer,
    $$IncomesTableAnnotationComposer,
    $$IncomesTableCreateCompanionBuilder,
    $$IncomesTableUpdateCompanionBuilder,
    (Income, $$IncomesTableReferences),
    Income,
    PrefetchHooks Function({bool villaId})>;
typedef $$ExpensesTableCreateCompanionBuilder = ExpensesCompanion Function({
  required String id,
  Value<String> orgId,
  Value<String?> villaId,
  Value<String> villaName,
  Value<String?> roomId,
  Value<String?> roomName,
  required String category,
  required double amount,
  required DateTime expenseDate,
  required String paidTo,
  required String paymentMethod,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> isDeleted,
  Value<String> syncStatus,
  Value<DateTime?> deletedAt,
  Value<String?> deletedBy,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$ExpensesTableUpdateCompanionBuilder = ExpensesCompanion Function({
  Value<String> id,
  Value<String> orgId,
  Value<String?> villaId,
  Value<String> villaName,
  Value<String?> roomId,
  Value<String?> roomName,
  Value<String> category,
  Value<double> amount,
  Value<DateTime> expenseDate,
  Value<String> paidTo,
  Value<String> paymentMethod,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> isDeleted,
  Value<String> syncStatus,
  Value<DateTime?> deletedAt,
  Value<String?> deletedBy,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

final class $$ExpensesTableReferences
    extends BaseReferences<_$AppDatabase, $ExpensesTable, Expense> {
  $$ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VillasTable _villaIdTable(_$AppDatabase db) => db.villas
      .createAlias($_aliasNameGenerator(db.expenses.villaId, db.villas.id));

  $$VillasTableProcessedTableManager? get villaId {
    final $_column = $_itemColumn<String>('villa_id');
    if ($_column == null) return null;
    final manager = $$VillasTableTableManager($_db, $_db.villas)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_villaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get orgId => $composableBuilder(
      column: $table.orgId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get villaName => $composableBuilder(
      column: $table.villaName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get roomId => $composableBuilder(
      column: $table.roomId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get roomName => $composableBuilder(
      column: $table.roomName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expenseDate => $composableBuilder(
      column: $table.expenseDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paidTo => $composableBuilder(
      column: $table.paidTo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedBy => $composableBuilder(
      column: $table.deletedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  $$VillasTableFilterComposer get villaId {
    final $$VillasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.villaId,
        referencedTable: $db.villas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VillasTableFilterComposer(
              $db: $db,
              $table: $db.villas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get orgId => $composableBuilder(
      column: $table.orgId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get villaName => $composableBuilder(
      column: $table.villaName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get roomId => $composableBuilder(
      column: $table.roomId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get roomName => $composableBuilder(
      column: $table.roomName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expenseDate => $composableBuilder(
      column: $table.expenseDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paidTo => $composableBuilder(
      column: $table.paidTo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedBy => $composableBuilder(
      column: $table.deletedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  $$VillasTableOrderingComposer get villaId {
    final $$VillasTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.villaId,
        referencedTable: $db.villas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VillasTableOrderingComposer(
              $db: $db,
              $table: $db.villas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get orgId =>
      $composableBuilder(column: $table.orgId, builder: (column) => column);

  GeneratedColumn<String> get villaName =>
      $composableBuilder(column: $table.villaName, builder: (column) => column);

  GeneratedColumn<String> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<String> get roomName =>
      $composableBuilder(column: $table.roomName, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get expenseDate => $composableBuilder(
      column: $table.expenseDate, builder: (column) => column);

  GeneratedColumn<String> get paidTo =>
      $composableBuilder(column: $table.paidTo, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedBy =>
      $composableBuilder(column: $table.deletedBy, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  $$VillasTableAnnotationComposer get villaId {
    final $$VillasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.villaId,
        referencedTable: $db.villas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VillasTableAnnotationComposer(
              $db: $db,
              $table: $db.villas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExpensesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExpensesTable,
    Expense,
    $$ExpensesTableFilterComposer,
    $$ExpensesTableOrderingComposer,
    $$ExpensesTableAnnotationComposer,
    $$ExpensesTableCreateCompanionBuilder,
    $$ExpensesTableUpdateCompanionBuilder,
    (Expense, $$ExpensesTableReferences),
    Expense,
    PrefetchHooks Function({bool villaId})> {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> orgId = const Value.absent(),
            Value<String?> villaId = const Value.absent(),
            Value<String> villaName = const Value.absent(),
            Value<String?> roomId = const Value.absent(),
            Value<String?> roomName = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<DateTime> expenseDate = const Value.absent(),
            Value<String> paidTo = const Value.absent(),
            Value<String> paymentMethod = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> isDeleted = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> deletedBy = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<String?> updatedBy = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpensesCompanion(
            id: id,
            orgId: orgId,
            villaId: villaId,
            villaName: villaName,
            roomId: roomId,
            roomName: roomName,
            category: category,
            amount: amount,
            expenseDate: expenseDate,
            paidTo: paidTo,
            paymentMethod: paymentMethod,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            syncStatus: syncStatus,
            deletedAt: deletedAt,
            deletedBy: deletedBy,
            createdBy: createdBy,
            updatedBy: updatedBy,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> orgId = const Value.absent(),
            Value<String?> villaId = const Value.absent(),
            Value<String> villaName = const Value.absent(),
            Value<String?> roomId = const Value.absent(),
            Value<String?> roomName = const Value.absent(),
            required String category,
            required double amount,
            required DateTime expenseDate,
            required String paidTo,
            required String paymentMethod,
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> isDeleted = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> deletedBy = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<String?> updatedBy = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpensesCompanion.insert(
            id: id,
            orgId: orgId,
            villaId: villaId,
            villaName: villaName,
            roomId: roomId,
            roomName: roomName,
            category: category,
            amount: amount,
            expenseDate: expenseDate,
            paidTo: paidTo,
            paymentMethod: paymentMethod,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            syncStatus: syncStatus,
            deletedAt: deletedAt,
            deletedBy: deletedBy,
            createdBy: createdBy,
            updatedBy: updatedBy,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ExpensesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({villaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (villaId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.villaId,
                    referencedTable:
                        $$ExpensesTableReferences._villaIdTable(db),
                    referencedColumn:
                        $$ExpensesTableReferences._villaIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ExpensesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExpensesTable,
    Expense,
    $$ExpensesTableFilterComposer,
    $$ExpensesTableOrderingComposer,
    $$ExpensesTableAnnotationComposer,
    $$ExpensesTableCreateCompanionBuilder,
    $$ExpensesTableUpdateCompanionBuilder,
    (Expense, $$ExpensesTableReferences),
    Expense,
    PrefetchHooks Function({bool villaId})>;
typedef $$AppLogsTableCreateCompanionBuilder = AppLogsCompanion Function({
  required String id,
  required String timestamp,
  required String category,
  required String level,
  required String screenName,
  required String operation,
  required String message,
  Value<String> details,
  Value<String> stackTrace,
  Value<String> userId,
  Value<String> userEmail,
  Value<String> devicePlatform,
  Value<String> appVersion,
  Value<int> rowid,
});
typedef $$AppLogsTableUpdateCompanionBuilder = AppLogsCompanion Function({
  Value<String> id,
  Value<String> timestamp,
  Value<String> category,
  Value<String> level,
  Value<String> screenName,
  Value<String> operation,
  Value<String> message,
  Value<String> details,
  Value<String> stackTrace,
  Value<String> userId,
  Value<String> userEmail,
  Value<String> devicePlatform,
  Value<String> appVersion,
  Value<int> rowid,
});

class $$AppLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AppLogsTable> {
  $$AppLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get screenName => $composableBuilder(
      column: $table.screenName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get details => $composableBuilder(
      column: $table.details, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stackTrace => $composableBuilder(
      column: $table.stackTrace, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userEmail => $composableBuilder(
      column: $table.userEmail, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get devicePlatform => $composableBuilder(
      column: $table.devicePlatform,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get appVersion => $composableBuilder(
      column: $table.appVersion, builder: (column) => ColumnFilters(column));
}

class $$AppLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppLogsTable> {
  $$AppLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get screenName => $composableBuilder(
      column: $table.screenName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get details => $composableBuilder(
      column: $table.details, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stackTrace => $composableBuilder(
      column: $table.stackTrace, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userEmail => $composableBuilder(
      column: $table.userEmail, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get devicePlatform => $composableBuilder(
      column: $table.devicePlatform,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get appVersion => $composableBuilder(
      column: $table.appVersion, builder: (column) => ColumnOrderings(column));
}

class $$AppLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppLogsTable> {
  $$AppLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get screenName => $composableBuilder(
      column: $table.screenName, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);

  GeneratedColumn<String> get stackTrace => $composableBuilder(
      column: $table.stackTrace, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get userEmail =>
      $composableBuilder(column: $table.userEmail, builder: (column) => column);

  GeneratedColumn<String> get devicePlatform => $composableBuilder(
      column: $table.devicePlatform, builder: (column) => column);

  GeneratedColumn<String> get appVersion => $composableBuilder(
      column: $table.appVersion, builder: (column) => column);
}

class $$AppLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppLogsTable,
    AppLog,
    $$AppLogsTableFilterComposer,
    $$AppLogsTableOrderingComposer,
    $$AppLogsTableAnnotationComposer,
    $$AppLogsTableCreateCompanionBuilder,
    $$AppLogsTableUpdateCompanionBuilder,
    (AppLog, BaseReferences<_$AppDatabase, $AppLogsTable, AppLog>),
    AppLog,
    PrefetchHooks Function()> {
  $$AppLogsTableTableManager(_$AppDatabase db, $AppLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> timestamp = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> level = const Value.absent(),
            Value<String> screenName = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String> message = const Value.absent(),
            Value<String> details = const Value.absent(),
            Value<String> stackTrace = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> userEmail = const Value.absent(),
            Value<String> devicePlatform = const Value.absent(),
            Value<String> appVersion = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppLogsCompanion(
            id: id,
            timestamp: timestamp,
            category: category,
            level: level,
            screenName: screenName,
            operation: operation,
            message: message,
            details: details,
            stackTrace: stackTrace,
            userId: userId,
            userEmail: userEmail,
            devicePlatform: devicePlatform,
            appVersion: appVersion,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String timestamp,
            required String category,
            required String level,
            required String screenName,
            required String operation,
            required String message,
            Value<String> details = const Value.absent(),
            Value<String> stackTrace = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> userEmail = const Value.absent(),
            Value<String> devicePlatform = const Value.absent(),
            Value<String> appVersion = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppLogsCompanion.insert(
            id: id,
            timestamp: timestamp,
            category: category,
            level: level,
            screenName: screenName,
            operation: operation,
            message: message,
            details: details,
            stackTrace: stackTrace,
            userId: userId,
            userEmail: userEmail,
            devicePlatform: devicePlatform,
            appVersion: appVersion,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppLogsTable,
    AppLog,
    $$AppLogsTableFilterComposer,
    $$AppLogsTableOrderingComposer,
    $$AppLogsTableAnnotationComposer,
    $$AppLogsTableCreateCompanionBuilder,
    $$AppLogsTableUpdateCompanionBuilder,
    (AppLog, BaseReferences<_$AppDatabase, $AppLogsTable, AppLog>),
    AppLog,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VillasTableTableManager get villas =>
      $$VillasTableTableManager(_db, _db.villas);
  $$RoomsTableTableManager get rooms =>
      $$RoomsTableTableManager(_db, _db.rooms);
  $$IncomesTableTableManager get incomes =>
      $$IncomesTableTableManager(_db, _db.incomes);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$AppLogsTableTableManager get appLogs =>
      $$AppLogsTableTableManager(_db, _db.appLogs);
}

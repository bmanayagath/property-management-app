class Room {
  final String id;
  final String villaId;
  final String villaName;
  final String roomName;
  // Legacy compatibility field for old local/Firebase records.
  // New UI and validation use roomName for identification.
  final String roomNumber;
  final String tenantName;
  final String tenantPhone;
  final double monthlyRent;
  final DateTime? contractStartDate;
  final DateTime? contractEndDate;
  final int paymentDueDay;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;
  final String syncStatus;
  final DateTime? deletedAt;
  final String? deletedBy;
  final String? createdBy;
  final String? updatedBy;
  final DateTime? lastSyncedAt;

  const Room({
    required this.id,
    required this.villaId,
    required this.villaName,
    required this.roomName,
    this.roomNumber = '',
    required this.tenantName,
    required this.tenantPhone,
    required this.monthlyRent,
    required this.contractStartDate,
    required this.contractEndDate,
    required this.paymentDueDay,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.syncStatus = 'pending',
    this.deletedAt,
    this.deletedBy,
    this.createdBy,
    this.updatedBy,
    this.lastSyncedAt,
  });

  factory Room.empty({
    String id = '',
    String villaId = '',
    String villaName = '',
  }) {
    return Room(
      id: id,
      villaId: villaId,
      villaName: villaName,
      roomName: '',
      roomNumber: '',
      tenantName: '',
      tenantPhone: '',
      monthlyRent: 0,
      contractStartDate: null,
      contractEndDate: null,
      paymentDueDay: 1,
      status: RoomStatuses.vacant,
      createdAt: DateTime.now(),
      updatedAt: null,
      isDeleted: false,
      syncStatus: 'pending',
    );
  }

  bool get isOccupied => status.toLowerCase() == RoomStatuses.occupiedLower;

  bool get isVacant => status.toLowerCase() == RoomStatuses.vacantLower;

  String get displayName => roomName.trim().isEmpty ? 'Room' : roomName.trim();

  Room assignVilla({
    required String villaId,
    required String villaName,
  }) {
    return copyWith(
      villaId: villaId,
      villaName: villaName,
    );
  }

  Room copyWith({
    String? id,
    String? villaId,
    String? villaName,
    String? roomName,
    String? roomNumber,
    String? tenantName,
    String? tenantPhone,
    double? monthlyRent,
    DateTime? contractStartDate,
    bool clearContractStartDate = false,
    DateTime? contractEndDate,
    bool clearContractEndDate = false,
    int? paymentDueDay,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearUpdatedAt = false,
    bool? isDeleted,
    String? syncStatus,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
    String? deletedBy,
    bool clearDeletedBy = false,
    String? createdBy,
    bool clearCreatedBy = false,
    String? updatedBy,
    bool clearUpdatedBy = false,
    DateTime? lastSyncedAt,
    bool clearLastSyncedAt = false,
  }) {
    return Room(
      id: id ?? this.id,
      villaId: villaId ?? this.villaId,
      villaName: villaName ?? this.villaName,
      roomName: roomName ?? this.roomName,
      roomNumber: roomNumber ?? this.roomNumber,
      tenantName: tenantName ?? this.tenantName,
      tenantPhone: tenantPhone ?? this.tenantPhone,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      contractStartDate: clearContractStartDate
          ? null
          : contractStartDate ?? this.contractStartDate,
      contractEndDate:
          clearContractEndDate ? null : contractEndDate ?? this.contractEndDate,
      paymentDueDay: paymentDueDay ?? this.paymentDueDay,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: clearUpdatedAt ? null : updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
      deletedBy: clearDeletedBy ? null : deletedBy ?? this.deletedBy,
      createdBy: clearCreatedBy ? null : createdBy ?? this.createdBy,
      updatedBy: clearUpdatedBy ? null : updatedBy ?? this.updatedBy,
      lastSyncedAt:
          clearLastSyncedAt ? null : lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}

class RoomStatuses {
  RoomStatuses._();

  static const occupied = 'Occupied';
  static const vacant = 'Vacant';
  static const occupiedLower = 'occupied';
  static const vacantLower = 'vacant';

  static const values = [
    occupied,
    vacant,
  ];
}

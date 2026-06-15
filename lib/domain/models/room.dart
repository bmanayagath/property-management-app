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
  final List<TenantHistory> tenantHistory;

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
    this.depositType = DepositTypes.none,
    this.depositAmount = 0,
    this.depositDate,
    this.depositStatus = DepositStatuses.held,
    this.depositNotes = '',
    this.depositIncomeId = '',
    this.depositRefundExpenseId = '',
    this.moveInDate,
    this.moveOutDate,
    this.lastTenantName = '',
    this.lastTenantPhone = '',
    this.refundAmount = 0,
    this.retainedAmount = 0,
    this.depositReason = '',
    this.tenantHistory = const [],
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
    String? depositType,
    double? depositAmount,
    DateTime? depositDate,
    bool clearDepositDate = false,
    String? depositStatus,
    String? depositNotes,
    String? depositIncomeId,
    bool clearDepositIncomeId = false,
    String? depositRefundExpenseId,
    bool clearDepositRefundExpenseId = false,
    DateTime? moveInDate,
    bool clearMoveInDate = false,
    DateTime? moveOutDate,
    bool clearMoveOutDate = false,
    String? lastTenantName,
    String? lastTenantPhone,
    double? refundAmount,
    double? retainedAmount,
    String? depositReason,
    List<TenantHistory>? tenantHistory,
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
      depositType: depositType ?? this.depositType,
      depositAmount: depositAmount ?? this.depositAmount,
      depositDate: clearDepositDate ? null : depositDate ?? this.depositDate,
      depositStatus: depositStatus ?? this.depositStatus,
      depositNotes: depositNotes ?? this.depositNotes,
      depositIncomeId:
          clearDepositIncomeId ? '' : depositIncomeId ?? this.depositIncomeId,
      depositRefundExpenseId: clearDepositRefundExpenseId
          ? ''
          : depositRefundExpenseId ?? this.depositRefundExpenseId,
      moveInDate: clearMoveInDate ? null : moveInDate ?? this.moveInDate,
      moveOutDate: clearMoveOutDate ? null : moveOutDate ?? this.moveOutDate,
      lastTenantName: lastTenantName ?? this.lastTenantName,
      lastTenantPhone: lastTenantPhone ?? this.lastTenantPhone,
      refundAmount: refundAmount ?? this.refundAmount,
      retainedAmount: retainedAmount ?? this.retainedAmount,
      depositReason: depositReason ?? this.depositReason,
      tenantHistory: tenantHistory ?? this.tenantHistory,
    );
  }
}

class TenantHistory {
  final String roomId;
  final String villaId;
  final String tenantName;
  final String tenantPhone;
  final DateTime? moveInDate;
  final DateTime moveOutDate;
  final String depositType;
  final double depositAmount;
  final String depositStatus;
  final double refundAmount;
  final double retainedAmount;
  final String notes;

  const TenantHistory({
    required this.roomId,
    required this.villaId,
    required this.tenantName,
    required this.tenantPhone,
    required this.moveInDate,
    required this.moveOutDate,
    required this.depositType,
    required this.depositAmount,
    required this.depositStatus,
    required this.refundAmount,
    required this.retainedAmount,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
        'roomId': roomId,
        'villaId': villaId,
        'tenantName': tenantName,
        'tenantPhone': tenantPhone,
        'moveInDate': moveInDate?.toIso8601String(),
        'moveOutDate': moveOutDate.toIso8601String(),
        'depositType': depositType,
        'depositAmount': depositAmount,
        'depositStatus': depositStatus,
        'refundAmount': refundAmount,
        'retainedAmount': retainedAmount,
        'notes': notes,
      };

  factory TenantHistory.fromJson(Map<String, dynamic> json) => TenantHistory(
        roomId: json['roomId'] as String? ?? '',
        villaId: json['villaId'] as String? ?? '',
        tenantName: json['tenantName'] as String? ?? '',
        tenantPhone: json['tenantPhone'] as String? ?? '',
        moveInDate: DateTime.tryParse(json['moveInDate'] as String? ?? ''),
        moveOutDate: DateTime.tryParse(json['moveOutDate'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        depositType: json['depositType'] as String? ?? DepositTypes.none,
        depositAmount: (json['depositAmount'] as num?)?.toDouble() ?? 0,
        depositStatus: json['depositStatus'] as String? ?? DepositStatuses.held,
        refundAmount: (json['refundAmount'] as num?)?.toDouble() ?? 0,
        retainedAmount: (json['retainedAmount'] as num?)?.toDouble() ?? 0,
        notes: json['notes'] as String? ?? '',
      );
}

class DepositTypes {
  DepositTypes._();
  static const cash = 'Cash';
  static const cheque = 'Cheque';
  static const none = 'None';
  static const values = [cash, cheque, none];
}

class DepositStatuses {
  DepositStatuses._();
  static const held = 'Held';
  static const refunded = 'Refunded';
  static const partiallyRefunded = 'Partially Refunded';
  static const forfeited = 'Forfeited';
  static const values = [held, refunded, partiallyRefunded, forfeited];
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

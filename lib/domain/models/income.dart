class Income {
  final String id;
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
  final String notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;
  final String syncStatus;
  final DateTime? deletedAt;
  final String? deletedBy;
  final String? createdBy;
  final String? updatedBy;
  final DateTime? lastSyncedAt;

  const Income({
    required this.id,
    required this.villaId,
    required this.villaName,
    required this.roomId,
    required this.roomName,
    this.tenantName = '',
    required this.incomeType,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    required this.monthCovered,
    required this.notes,
    required this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
    this.syncStatus = 'pending',
    this.deletedAt,
    this.deletedBy,
    this.createdBy,
    this.updatedBy,
    this.lastSyncedAt,
  });

  Income copyWith({
    String? id,
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
    String? notes,
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
    return Income(
      id: id ?? this.id,
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

class IncomeTypes {
  IncomeTypes._();

  static const rent = 'Rent';
  static const deposit = 'Deposit';
  static const maintenanceCharge = 'Maintenance Charge';
  static const penalty = 'Penalty';
  static const other = 'Other';

  static const values = [
    rent,
    deposit,
    maintenanceCharge,
    penalty,
    other,
  ];
}

class IncomePaymentMethods {
  IncomePaymentMethods._();

  static const cash = 'Cash';
  static const bankTransfer = 'Bank Transfer';
  static const card = 'Card';
  static const cheque = 'Cheque';
  static const other = 'Other';

  static const values = [
    cash,
    bankTransfer,
    card,
    cheque,
    other,
  ];
}

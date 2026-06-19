class Expense {
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

  const Expense({
    required this.id,
    this.orgId = 'default_org',
    required this.villaId,
    required this.villaName,
    required this.roomId,
    required this.roomName,
    required this.category,
    required this.amount,
    required this.expenseDate,
    required this.paidTo,
    required this.paymentMethod,
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

  Expense copyWith({
    String? id,
    String? orgId,
    String? villaId,
    bool clearVillaId = false,
    String? villaName,
    String? roomId,
    bool clearRoomId = false,
    String? roomName,
    bool clearRoomName = false,
    String? category,
    double? amount,
    DateTime? expenseDate,
    String? paidTo,
    String? paymentMethod,
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
    return Expense(
      id: id ?? this.id,
      orgId: orgId ?? this.orgId,
      villaId: clearVillaId ? null : villaId ?? this.villaId,
      villaName: villaName ?? this.villaName,
      roomId: clearRoomId ? null : roomId ?? this.roomId,
      roomName: clearRoomName ? null : roomName ?? this.roomName,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      expenseDate: expenseDate ?? this.expenseDate,
      paidTo: paidTo ?? this.paidTo,
      paymentMethod: paymentMethod ?? this.paymentMethod,
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

class ExpenseCategories {
  ExpenseCategories._();

  static const maintenance = 'Maintenance';
  static const repair = 'Repair';
  static const electricity = 'Electricity';
  static const water = 'Water';
  static const internet = 'Internet';
  static const cleaning = 'Cleaning';
  static const petrol = 'Petrol';
  static const commission = 'Commission';
  static const insurance = 'Insurance';
  static const governmentFee = 'Government Fee';
  static const loan = 'Loan';
  static const ownerRent = 'Owner Rent';
  static const depositRefund = 'Deposit Refund';
  static const other = 'Other';

  static const values = [
    maintenance,
    repair,
    electricity,
    water,
    internet,
    cleaning,
    petrol,
    commission,
    insurance,
    governmentFee,
    loan,
    ownerRent,
    depositRefund,
    other,
  ];
}

class ExpensePaymentMethods {
  ExpensePaymentMethods._();

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

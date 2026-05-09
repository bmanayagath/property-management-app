class Room {
  final String id;
  final String villaId;
  final String villaName;
  final String roomName;
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

  const Room({
    required this.id,
    required this.villaId,
    required this.villaName,
    required this.roomName,
    required this.roomNumber,
    required this.tenantName,
    required this.tenantPhone,
    required this.monthlyRent,
    required this.contractStartDate,
    required this.contractEndDate,
    required this.paymentDueDay,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOccupied => status == RoomStatuses.occupied;

  bool get isVacant => status == RoomStatuses.vacant;

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
    );
  }
}

class RoomStatuses {
  RoomStatuses._();

  static const occupied = 'Occupied';
  static const vacant = 'Vacant';

  static const values = [
    occupied,
    vacant,
  ];
}

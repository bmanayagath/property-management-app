import 'room.dart';

enum RoomRentFilter {
  all,
  overdue,
  paid,
  vacant,
}

extension RoomRentFilterLabel on RoomRentFilter {
  String get label {
    switch (this) {
      case RoomRentFilter.all:
        return 'All';
      case RoomRentFilter.overdue:
        return 'Overdue';
      case RoomRentFilter.paid:
        return 'Paid';
      case RoomRentFilter.vacant:
        return 'Vacant';
    }
  }
}

class RoomRentStatus {
  final Room room;
  final double rentReceived;
  final double pendingRent;
  final DateTime dueDate;
  final bool isOverdue;
  final int overdueDays;

  const RoomRentStatus({
    required this.room,
    required this.rentReceived,
    required this.pendingRent,
    required this.dueDate,
    required this.isOverdue,
    required this.overdueDays,
  });

  bool get isPaid =>
      room.isOccupied && room.monthlyRent > 0 && pendingRent <= 0;
}

class VillaRentStatus {
  final String villaId;
  final List<RoomRentStatus> rooms;
  final int overdueRoomCount;
  final double overduePendingAmount;
  final int oldestOverdueDays;

  const VillaRentStatus({
    required this.villaId,
    required this.rooms,
    required this.overdueRoomCount,
    required this.overduePendingAmount,
    required this.oldestOverdueDays,
  });

  factory VillaRentStatus.empty(String villaId) {
    return VillaRentStatus(
      villaId: villaId,
      rooms: const [],
      overdueRoomCount: 0,
      overduePendingAmount: 0,
      oldestOverdueDays: 0,
    );
  }

  bool get hasOverdueRent => overdueRoomCount > 0;
}

class RentStatusSummary {
  final DateTime calculatedAt;
  final List<RoomRentStatus> rooms;
  final Map<String, RoomRentStatus> byRoomId;
  final Map<String, VillaRentStatus> byVillaId;

  const RentStatusSummary({
    required this.calculatedAt,
    required this.rooms,
    required this.byRoomId,
    required this.byVillaId,
  });

  factory RentStatusSummary.empty(DateTime calculatedAt) {
    return RentStatusSummary(
      calculatedAt: calculatedAt,
      rooms: const [],
      byRoomId: const {},
      byVillaId: const {},
    );
  }

  List<RoomRentStatus> get overdueRooms =>
      rooms.where((status) => status.isOverdue).toList(growable: false);

  int get overdueRoomCount => rooms.where((status) => status.isOverdue).length;

  int get overdueVillaCount =>
      byVillaId.values.where((status) => status.hasOverdueRent).length;

  double get overduePendingAmount => rooms
      .where((status) => status.isOverdue)
      .fold<double>(0, (sum, status) => sum + status.pendingRent);

  VillaRentStatus forVilla(String villaId) {
    return byVillaId[villaId] ?? VillaRentStatus.empty(villaId);
  }

  List<RoomRentStatus> filtered(
    RoomRentFilter filter, {
    String? villaId,
  }) {
    return rooms.where((status) {
      if (villaId != null && status.room.villaId != villaId) return false;
      switch (filter) {
        case RoomRentFilter.all:
          return true;
        case RoomRentFilter.overdue:
          return status.isOverdue;
        case RoomRentFilter.paid:
          return status.isPaid;
        case RoomRentFilter.vacant:
          return status.room.isVacant;
      }
    }).toList(growable: false);
  }
}

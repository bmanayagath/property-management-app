import 'dart:math' as math;

import '../../domain/models/income.dart';
import '../../domain/models/room.dart';
import '../../domain/models/room_rent_status.dart';
import 'income_calculation_service.dart';

class RentStatusCalculationService {
  const RentStatusCalculationService();

  static const _incomeCalculation = IncomeCalculationService();

  RentStatusSummary buildSummary({
    required List<Room> rooms,
    required List<Income> incomes,
    required DateTime now,
  }) {
    final today = _dateOnly(now);
    final activeRooms = rooms.where((room) => !room.isDeleted).toList();
    final activeRoomIds = activeRooms.map((room) => room.id).toSet();
    final rentReceivedByRoom = <String, double>{};

    for (final income in incomes.where(
      (income) =>
          !income.isDeleted &&
          activeRoomIds.contains(income.roomId) &&
          _incomeCalculation.isRentIncome(income) &&
          _isSameMonth(income.monthCovered, today),
    )) {
      rentReceivedByRoom.update(
        income.roomId,
        (value) => value + income.amount,
        ifAbsent: () => income.amount,
      );
    }

    final statuses = activeRooms
        .map(
          (room) => calculateRoomStatus(
            room: room,
            rentReceived: rentReceivedByRoom[room.id] ?? 0,
            now: today,
          ),
        )
        .toList()
      ..sort(compareRoomStatuses);

    final byRoomId = <String, RoomRentStatus>{
      for (final status in statuses) status.room.id: status,
    };
    final roomsByVilla = <String, List<RoomRentStatus>>{};
    for (final status in statuses) {
      roomsByVilla
          .putIfAbsent(status.room.villaId, () => <RoomRentStatus>[])
          .add(status);
    }

    final byVillaId = <String, VillaRentStatus>{};
    for (final entry in roomsByVilla.entries) {
      final overdueRooms = entry.value.where((status) => status.isOverdue);
      byVillaId[entry.key] = VillaRentStatus(
        villaId: entry.key,
        rooms: List.unmodifiable(entry.value),
        overdueRoomCount: overdueRooms.length,
        overduePendingAmount: overdueRooms.fold<double>(
          0,
          (sum, status) => sum + status.pendingRent,
        ),
        oldestOverdueDays: overdueRooms.fold<int>(
          0,
          (oldest, status) => math.max(oldest, status.overdueDays),
        ),
      );
    }

    return RentStatusSummary(
      calculatedAt: today,
      rooms: List.unmodifiable(statuses),
      byRoomId: Map.unmodifiable(byRoomId),
      byVillaId: Map.unmodifiable(byVillaId),
    );
  }

  RoomRentStatus calculateRoomStatus({
    required Room room,
    required double rentReceived,
    required DateTime now,
  }) {
    final today = _dateOnly(now);
    final dueDate = dueDateFor(room.paymentDueDay, today);
    final pendingRent = room.isOccupied
        ? math.max(room.monthlyRent - rentReceived, 0).toDouble()
        : 0.0;
    final isOverdue =
        room.isOccupied && today.isAfter(dueDate) && pendingRent > 0;

    return RoomRentStatus(
      room: room,
      rentReceived: rentReceived,
      pendingRent: pendingRent,
      dueDate: dueDate,
      isOverdue: isOverdue,
      overdueDays: isOverdue ? today.difference(dueDate).inDays : 0,
    );
  }

  DateTime dueDateFor(int dueDay, DateTime month) {
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    final validDueDay = dueDay.clamp(1, lastDay);
    return DateTime(month.year, month.month, validDueDay);
  }

  DateTime referenceDateForMonth({
    required DateTime month,
    required DateTime now,
  }) {
    final selectedMonth = DateTime(month.year, month.month);
    final currentMonth = DateTime(now.year, now.month);
    if (selectedMonth.isBefore(currentMonth)) {
      return DateTime(month.year, month.month + 1, 0);
    }
    if (selectedMonth.isAfter(currentMonth)) {
      return DateTime(month.year, month.month, 1);
    }
    return _dateOnly(now);
  }

  int compareRoomStatuses(RoomRentStatus left, RoomRentStatus right) {
    final overdueComparison = _compareTrueFirst(
      left.isOverdue,
      right.isOverdue,
    );
    if (overdueComparison != 0) return overdueComparison;

    final pendingComparison = right.pendingRent.compareTo(left.pendingRent);
    if (pendingComparison != 0) return pendingComparison;

    final dueDateComparison = left.dueDate.compareTo(right.dueDate);
    if (dueDateComparison != 0) return dueDateComparison;

    final roomComparison = _naturalCompare(
      left.room.displayName,
      right.room.displayName,
    );
    if (roomComparison != 0) return roomComparison;

    return _naturalCompare(left.room.villaName, right.room.villaName);
  }

  int _compareTrueFirst(bool left, bool right) {
    if (left == right) return 0;
    return left ? -1 : 1;
  }

  int _naturalCompare(String left, String right) {
    final leftNumber = _firstNumber(left);
    final rightNumber = _firstNumber(right);
    if (leftNumber != null && rightNumber != null) {
      final numberComparison = leftNumber.compareTo(rightNumber);
      if (numberComparison != 0) return numberComparison;
    }
    return left.toLowerCase().compareTo(right.toLowerCase());
  }

  int? _firstNumber(String value) {
    final match = RegExp(r'\d+').firstMatch(value);
    return match == null ? null : int.tryParse(match.group(0)!);
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  bool _isSameMonth(DateTime date, DateTime month) {
    return date.year == month.year && date.month == month.month;
  }
}

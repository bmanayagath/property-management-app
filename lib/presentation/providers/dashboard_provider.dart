import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:math' as math;

import '../../domain/models/expense.dart';
import '../../domain/models/income.dart';
import '../../domain/models/room.dart';
import '../../domain/models/villa_model.dart';
import 'expense_provider.dart';
import 'income_provider.dart';
import 'room_provider.dart';
import 'villa_provider.dart';

final selectedMonthProvider = StateProvider<DateTime>((ref) {
  return DateTime(DateTime.now().year, DateTime.now().month, 1);
});

final dashboardSummaryProvider = Provider<AsyncValue<DashboardSummary>>((ref) {
  final selectedMonth = ref.watch(selectedMonthProvider);
  final villasAsync = ref.watch(villasProvider);
  final roomsAsync = ref.watch(allRoomsProvider);
  final incomesAsync = ref.watch(incomeListProvider);
  final expensesAsync = ref.watch(expenseListProvider);

  final error = _firstError([
    villasAsync,
    roomsAsync,
    incomesAsync,
    expensesAsync,
  ]);
  if (error != null) {
    return AsyncError(error.error, error.stackTrace);
  }

  final villas = villasAsync.valueOrNull;
  final rooms = roomsAsync.valueOrNull;
  final incomes = incomesAsync.valueOrNull;
  final expenses = expensesAsync.valueOrNull;

  if (villas == null || rooms == null || incomes == null || expenses == null) {
    return const AsyncLoading();
  }

  return AsyncData(
    DashboardSummary.fromLiveData(
      selectedMonth: selectedMonth,
      villas: villas,
      rooms: rooms,
      incomes: incomes,
      expenses: expenses,
    ),
  );
});

class DashboardSummary {
  final DateTime selectedMonth;
  final List<VillaModel> villas;
  final List<Room> rooms;
  final List<Income> incomes;
  final List<Expense> expenses;
  final Map<String, double> rentReceivedByRoom;
  final Map<String, double> expensesByCategory;
  final DashboardRoomMetrics metrics;
  final double totalIncome;
  final double totalExpense;

  const DashboardSummary({
    required this.selectedMonth,
    required this.villas,
    required this.rooms,
    required this.incomes,
    required this.expenses,
    required this.rentReceivedByRoom,
    required this.expensesByCategory,
    required this.metrics,
    required this.totalIncome,
    required this.totalExpense,
  });

  factory DashboardSummary.fromLiveData({
    required DateTime selectedMonth,
    required List<VillaModel> villas,
    required List<Room> rooms,
    required List<Income> incomes,
    required List<Expense> expenses,
  }) {
    final activeVillaIds = villas.map((villa) => villa.id).toSet();
    final activeRooms = rooms
        .where(
            (room) => !room.isDeleted && activeVillaIds.contains(room.villaId))
        .toList();
    final activeRoomIds = activeRooms.map((room) => room.id).toSet();
    final activeIncomes = incomes.where((income) {
      if (income.isDeleted) return false;
      if (!activeVillaIds.contains(income.villaId)) return false;
      if (income.roomId.trim().isEmpty) return true;
      return activeRoomIds.contains(income.roomId);
    }).toList();
    final activeExpenses = expenses.where((expense) {
      if (expense.isDeleted) return false;
      final villaId = expense.villaId;
      if (villaId == null || villaId.trim().isEmpty) return true;
      if (!activeVillaIds.contains(villaId)) return false;
      final roomId = expense.roomId;
      if (roomId == null || roomId.trim().isEmpty) return true;
      return activeRoomIds.contains(roomId);
    }).toList();

    final rentReceivedByRoom = _rentReceivedByRoom(
      incomes: activeIncomes,
      month: selectedMonth,
    );
    final expensesByCategory = _expensesByCategory(
      expenses: activeExpenses,
      month: selectedMonth,
    );
    final totalIncome = activeIncomes
        .where((income) => _isSameMonth(income.paymentDate, selectedMonth))
        .fold<double>(0, (sum, income) => sum + income.amount);
    final totalExpense = expensesByCategory.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );

    return DashboardSummary(
      selectedMonth: selectedMonth,
      villas: villas,
      rooms: activeRooms,
      incomes: activeIncomes,
      expenses: activeExpenses,
      rentReceivedByRoom: rentReceivedByRoom,
      expensesByCategory: expensesByCategory,
      metrics: DashboardRoomMetrics.fromRooms(
        rooms: activeRooms,
        rentReceivedByRoom: rentReceivedByRoom,
      ),
      totalIncome: totalIncome,
      totalExpense: totalExpense,
    );
  }
}

class DashboardRoomMetrics {
  final int totalRooms;
  final int occupiedRooms;
  final int vacantRooms;
  final int paidRooms;
  final int pendingRooms;
  final double rentReceived;
  final double totalRoomRent;
  final double expectedRent;
  final double pendingRent;
  final double vacancyLoss;

  const DashboardRoomMetrics({
    required this.totalRooms,
    required this.occupiedRooms,
    required this.vacantRooms,
    required this.paidRooms,
    required this.pendingRooms,
    required this.rentReceived,
    required this.totalRoomRent,
    required this.expectedRent,
    required this.pendingRent,
    required this.vacancyLoss,
  });

  double get rentCollectionProgress =>
      expectedRent == 0 ? 0 : (rentReceived / expectedRent).clamp(0.0, 1.0);

  static DashboardRoomMetrics fromRooms({
    required List<Room> rooms,
    required Map<String, double> rentReceivedByRoom,
  }) {
    var occupiedRooms = 0;
    var vacantRooms = 0;
    var paidRooms = 0;
    var pendingRooms = 0;
    var rentReceived = 0.0;
    var totalRoomRent = 0.0;
    var expectedRent = 0.0;
    var pendingRent = 0.0;
    var vacancyLoss = 0.0;

    for (final room in rooms) {
      final received = rentReceivedByRoom[room.id] ?? 0;
      totalRoomRent += room.monthlyRent;

      if (room.isOccupied) {
        occupiedRooms++;
        rentReceived += received;
        expectedRent += room.monthlyRent;
        final pending = _calculatePendingRent(
          expectedRent: room.monthlyRent,
          rentReceived: received,
        );
        pendingRent += pending;
        if (pending <= 0 && room.monthlyRent > 0) {
          paidRooms++;
        } else if (pending > 0) {
          pendingRooms++;
        }
      } else if (room.isVacant) {
        vacantRooms++;
        vacancyLoss += room.monthlyRent;
      }
    }

    return DashboardRoomMetrics(
      totalRooms: rooms.length,
      occupiedRooms: occupiedRooms,
      vacantRooms: vacantRooms,
      paidRooms: paidRooms,
      pendingRooms: pendingRooms,
      rentReceived: rentReceived,
      totalRoomRent: totalRoomRent,
      expectedRent: expectedRent,
      pendingRent: pendingRent,
      vacancyLoss: vacancyLoss,
    );
  }
}

({Object error, StackTrace stackTrace})? _firstError(
  List<AsyncValue<Object?>> values,
) {
  for (final value in values) {
    if (value.hasError) {
      return (
        error: value.error!,
        stackTrace: value.stackTrace ?? StackTrace.current,
      );
    }
  }
  return null;
}

double _calculatePendingRent({
  required double expectedRent,
  required double rentReceived,
}) {
  return math.max(expectedRent - rentReceived, 0).toDouble();
}

Map<String, double> _rentReceivedByRoom({
  required List<Income> incomes,
  required DateTime month,
}) {
  final totals = <String, double>{};
  for (final income in incomes.where(
    (income) =>
        income.incomeType.toLowerCase() == IncomeTypes.rent.toLowerCase() &&
        income.roomId.trim().isNotEmpty &&
        _isSameMonth(income.monthCovered, month),
  )) {
    totals.update(
      income.roomId,
      (value) => value + income.amount,
      ifAbsent: () => income.amount,
    );
  }
  return totals;
}

Map<String, double> _expensesByCategory({
  required List<Expense> expenses,
  required DateTime month,
}) {
  final totals = <String, double>{};
  for (final expense in expenses
      .where((expense) => _isSameMonth(expense.expenseDate, month))) {
    totals.update(
      expense.category,
      (value) => value + expense.amount,
      ifAbsent: () => expense.amount,
    );
  }
  return totals;
}

bool _isSameMonth(DateTime date, DateTime month) {
  return date.year == month.year && date.month == month.month;
}

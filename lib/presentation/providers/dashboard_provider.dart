import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:math' as math;

import '../../data/services/profit_calculation_service.dart';
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

final dashboardSummaryProvider = Provider<DashboardSummary>((ref) {
  final villasAsync = ref.watch(villaListProvider);
  final roomsAsync = ref.watch(roomListProvider);
  final incomesAsync = ref.watch(incomeListProvider);
  final expensesAsync = ref.watch(expenseListProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);

  final villas = villasAsync.valueOrNull ?? const <VillaModel>[];
  final rooms = roomsAsync.valueOrNull ?? const <Room>[];
  final incomes = incomesAsync.valueOrNull ?? const <Income>[];
  final expenses = expensesAsync.valueOrNull ?? const <Expense>[];

  return DashboardSummary.fromLiveData(
    selectedMonth: selectedMonth,
    villas: villas,
    rooms: rooms.where((room) => !room.isDeleted).toList(),
    incomes: incomes.where((income) => !income.isDeleted).toList(),
    expenses: expenses.where((expense) => !expense.isDeleted).toList(),
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
    final monthlySummary =
        const ProfitCalculationService().calculateMonthlySummary(
      villas: villas,
      rooms: rooms,
      incomes: incomes,
      expenses: expenses,
      month: selectedMonth,
    );
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
    return DashboardSummary(
      selectedMonth: selectedMonth,
      villas: villas,
      rooms: activeRooms,
      incomes: activeIncomes,
      expenses: activeExpenses,
      rentReceivedByRoom: rentReceivedByRoom,
      expensesByCategory: expensesByCategory,
      metrics: DashboardRoomMetrics.fromSummary(
        rooms: activeRooms,
        rentReceivedByRoom: rentReceivedByRoom,
        totalRoomRent: monthlySummary.totalRoomRent,
        expectedRent: monthlySummary.expectedRent,
        pendingRent: monthlySummary.pendingRent,
        vacancyLoss: monthlySummary.vacancyLoss,
        rentReceived: monthlySummary.rentReceived,
      ),
      totalIncome: monthlySummary.actualIncome,
      totalExpense: monthlySummary.expensesPaid,
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

  static DashboardRoomMetrics fromSummary({
    required List<Room> rooms,
    required Map<String, double> rentReceivedByRoom,
    required double totalRoomRent,
    required double expectedRent,
    required double pendingRent,
    required double vacancyLoss,
    required double rentReceived,
  }) {
    var occupiedRooms = 0;
    var vacantRooms = 0;
    var paidRooms = 0;
    var pendingRooms = 0;

    for (final room in rooms) {
      final received = rentReceivedByRoom[room.id] ?? 0;

      if (room.isOccupied) {
        occupiedRooms++;
        final pending = _calculatePendingRent(
          expectedRent: room.monthlyRent,
          rentReceived: received,
        );
        if (pending <= 0 && room.monthlyRent > 0) {
          paidRooms++;
        } else if (pending > 0) {
          pendingRooms++;
        }
      } else if (room.isVacant) {
        vacantRooms++;
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

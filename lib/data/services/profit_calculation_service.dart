import '../../domain/models/expense.dart';
import '../../domain/models/income.dart';
import '../../domain/models/room.dart';
import '../../domain/models/room_profit_summary.dart';
import '../../domain/models/villa_model.dart';

class ProfitCalculationService {
  const ProfitCalculationService();

  MonthlyProfitSummary calculateMonthlySummary({
    required List<VillaModel> villas,
    List<Room> rooms = const [],
    required List<Income> incomes,
    required List<Expense> expenses,
    required DateTime month,
  }) {
    final activeVillaIds = villas.map((villa) => villa.id).toSet();
    final activeRooms = _activeRoomsForVillas(rooms, activeVillaIds);
    final activeRoomIds = activeRooms.map((room) => room.id).toSet();
    final activeIncomes =
        _activeIncomes(incomes, activeVillaIds, activeRoomIds);
    final activeExpenses =
        _activeExpenses(expenses, activeVillaIds, activeRoomIds);
    final monthlyCashIncomes = activeIncomes
        .where((income) => _isSameMonth(income.paymentDate, month))
        .toList();
    final monthlyRentIncomes = activeIncomes
        .where((income) =>
            _isRentIncome(income) && _isSameMonth(income.monthCovered, month))
        .toList();
    final monthlyExpenses = activeExpenses
        .where((expense) => _isSameMonth(expense.expenseDate, month))
        .toList();

    final actualIncome = _sumIncome(monthlyCashIncomes);
    final rentReceived = _sumIncome(
      monthlyRentIncomes.where(
        (income) => activeRooms
            .any((room) => room.id == income.roomId && room.isOccupied),
      ),
    );
    final otherIncome = _sumIncome(
      monthlyCashIncomes.where((income) => !_isRentIncome(income)),
    );
    final expensesPaid = _sumExpense(monthlyExpenses);
    final totalRoomRent = calculateTotalMonthlyRent(activeRooms);
    final expectedRent = calculateExpectedRent(activeRooms);
    final pendingRent = calculatePendingRent(
      expectedRent: expectedRent,
      rentReceived: rentReceived,
    );
    final vacancyLoss = calculateVacancyLoss(activeRooms);

    return MonthlyProfitSummary(
      month: DateTime(month.year, month.month, 1),
      actualIncome: actualIncome,
      rentReceived: rentReceived,
      otherIncome: otherIncome,
      expensesPaid: expensesPaid,
      totalRoomRent: totalRoomRent,
      expectedRent: expectedRent,
      pendingRent: pendingRent,
      overpaidAmount: _calculateOverpaidAmount(
        expectedRent: expectedRent,
        rentReceived: rentReceived,
      ),
      actualNetProfit: actualIncome - expensesPaid,
      expectedNetProfit: expectedRent + otherIncome - expensesPaid,
      vacancyLoss: vacancyLoss,
      rentCollectionPercentage:
          expectedRent == 0 ? 0 : (rentReceived / expectedRent) * 100,
    );
  }

  List<VillaProfitCalculation> calculateVillaProfit({
    required List<VillaModel> villas,
    List<Room> rooms = const [],
    required List<Income> incomes,
    required List<Expense> expenses,
    required DateTime month,
  }) {
    final activeVillaIds = villas.map((villa) => villa.id).toSet();
    final activeRooms = _activeRoomsForVillas(rooms, activeVillaIds);
    final activeRoomIds = activeRooms.map((room) => room.id).toSet();
    final activeIncomes =
        _activeIncomes(incomes, activeVillaIds, activeRoomIds);
    final activeExpenses =
        _activeExpenses(expenses, activeVillaIds, activeRoomIds);
    final monthlyCashIncomes = activeIncomes
        .where((income) => _isSameMonth(income.paymentDate, month))
        .toList();
    final monthlyRentIncomes = activeIncomes
        .where((income) =>
            _isRentIncome(income) && _isSameMonth(income.monthCovered, month))
        .toList();
    final monthlyExpenses = activeExpenses
        .where((expense) => _isSameMonth(expense.expenseDate, month))
        .toList();

    return villas.map((villa) {
      final villaRooms =
          activeRooms.where((room) => room.villaId == villa.id).toList();
      final occupiedRooms =
          villaRooms.where((room) => room.isOccupied).toList();
      final vacantRooms = villaRooms.where((room) => room.isVacant).toList();
      final occupiedRoomIds = occupiedRooms.map((room) => room.id).toSet();
      final rentReceived = _sumIncome(
        monthlyRentIncomes
            .where((income) => occupiedRoomIds.contains(income.roomId)),
      );
      final otherVillaIncome = _sumIncome(
        monthlyCashIncomes.where(
          (income) => income.villaId == villa.id && !_isRentIncome(income),
        ),
      );
      final villaExpenses = _sumExpense(
        monthlyExpenses.where((expense) => expense.villaId == villa.id),
      );
      final expectedRent = calculateExpectedRent(villaRooms);
      final pendingRent = calculatePendingRent(
        expectedRent: expectedRent,
        rentReceived: rentReceived,
      );
      final overpaidAmount = _calculateOverpaidAmount(
        expectedRent: expectedRent,
        rentReceived: rentReceived,
      );
      final actualProfit = rentReceived + otherVillaIncome - villaExpenses;
      final expectedProfit = expectedRent + otherVillaIncome - villaExpenses;
      final vacancyLoss = calculateVacancyLoss(villaRooms);
      final tenantNames = occupiedRooms
          .where((room) => room.tenantName.trim().isNotEmpty)
          .map((room) => room.tenantName.trim())
          .toSet();

      return VillaProfitCalculation(
        villaId: villa.id,
        villaName: villa.villaName,
        tenantName: tenantNames.isEmpty
            ? 'No occupied rooms'
            : tenantNames.length == 1
                ? tenantNames.first
                : '${tenantNames.length} tenants',
        isOccupied: occupiedRooms.isNotEmpty,
        isVacant: occupiedRooms.isEmpty && vacantRooms.isNotEmpty,
        expectedRent: expectedRent,
        rentReceived: rentReceived,
        otherIncome: otherVillaIncome,
        expensesPaid: villaExpenses,
        pendingRent: pendingRent,
        overpaidAmount: overpaidAmount,
        vacancyLoss: vacancyLoss,
        actualProfit: actualProfit,
        expectedProfit: expectedProfit,
        dueDay: occupiedRooms.isEmpty ? 1 : occupiedRooms.first.paymentDueDay,
      );
    }).toList();
  }

  List<YearlyProfitSummaryItem> calculateYearlySummary({
    required List<VillaModel> villas,
    List<Room> rooms = const [],
    required List<Income> incomes,
    required List<Expense> expenses,
    required int year,
  }) {
    return List.generate(12, (index) {
      final month = DateTime(year, index + 1, 1);
      final summary = calculateMonthlySummary(
        villas: villas,
        rooms: rooms,
        incomes: incomes,
        expenses: expenses,
        month: month,
      );

      return YearlyProfitSummaryItem(
        month: month,
        actualIncome: summary.actualIncome,
        expensesPaid: summary.expensesPaid,
        actualNetProfit: summary.actualNetProfit,
        expectedRent: summary.expectedRent,
        pendingRent: summary.pendingRent,
        expectedNetProfit: summary.expectedNetProfit,
      );
    });
  }

  List<RoomProfitSummary> calculateRoomProfitSummaries({
    required List<Room> rooms,
    required List<Income> incomes,
    required List<Expense> expenses,
    required DateTime month,
    String? villaId,
    String? roomId,
    String? status,
  }) {
    final normalizedStatus = status?.trim().toLowerCase();
    final activeRooms = rooms.where((room) => !room.isDeleted).toList();
    final activeRoomIds = activeRooms.map((room) => room.id).toSet();
    final activeIncomes = incomes.where((income) {
      if (income.isDeleted) return false;
      if (_isDepositIncome(income)) return false;
      if (income.roomId.trim().isEmpty) return true;
      return activeRoomIds.contains(income.roomId);
    }).toList();
    final activeExpenses = expenses.where((expense) {
      if (expense.isDeleted) return false;
      if (_isDepositRefundExpense(expense)) return false;
      final roomId = expense.roomId;
      if (roomId == null || roomId.trim().isEmpty) return true;
      return activeRoomIds.contains(roomId);
    }).toList();
    final monthlyCashIncomes = activeIncomes
        .where((income) => _isSameMonth(income.paymentDate, month))
        .toList();
    final monthlyRentIncomes = activeIncomes
        .where((income) =>
            _isRentIncome(income) && _isSameMonth(income.monthCovered, month))
        .toList();
    final monthlyExpenses = activeExpenses
        .where((expense) => _isSameMonth(expense.expenseDate, month))
        .toList();

    return activeRooms.where((room) {
      if (villaId != null && villaId.isNotEmpty && room.villaId != villaId) {
        return false;
      }
      if (roomId != null && roomId.isNotEmpty && room.id != roomId) {
        return false;
      }
      if (normalizedStatus != null &&
          normalizedStatus.isNotEmpty &&
          normalizedStatus != 'all' &&
          room.status.toLowerCase() != normalizedStatus) {
        return false;
      }
      return true;
    }).map((room) {
      return _calculateRoomProfitSummary(
        room: room,
        monthlyCashIncomes: monthlyCashIncomes,
        monthlyRentIncomes: monthlyRentIncomes,
        monthlyExpenses: monthlyExpenses,
      );
    }).toList();
  }

  RoomProfitTotals calculateRoomProfitTotals(
    Iterable<RoomProfitSummary> summaries,
  ) {
    final items = summaries.toList();
    final actualIncome = items.fold<double>(
      0,
      (sum, item) => sum + item.totalIncome,
    );
    final expensesPaid = items.fold<double>(
      0,
      (sum, item) => sum + item.totalExpenses,
    );
    final rentReceived = items.fold<double>(
      0,
      (sum, item) => sum + item.rentReceived,
    );
    final expectedRent = items.fold<double>(
      0,
      (sum, item) => sum + item.expectedRent,
    );
    final pendingRent = items.fold<double>(
      0,
      (sum, item) => sum + item.pendingRent,
    );
    final vacancyLoss = items.fold<double>(
      0,
      (sum, item) => sum + item.vacancyLoss,
    );
    final occupiedRooms = items.where((item) => item.isOccupied).length;
    final vacantRooms = items.where((item) => item.isVacant).length;

    return RoomProfitTotals(
      actualIncome: actualIncome,
      expensesPaid: expensesPaid,
      rentReceived: rentReceived,
      expectedRent: expectedRent,
      pendingRent: pendingRent,
      vacancyLoss: vacancyLoss,
      actualNetProfit: actualIncome - expensesPaid,
      expectedNetProfit: expectedRent +
          items.fold<double>(0, (sum, item) => sum + item.otherIncome) -
          expensesPaid,
      totalRooms: items.length,
      occupiedRooms: occupiedRooms,
      vacantRooms: vacantRooms,
      rentCollectionPercentage:
          expectedRent == 0 ? 0 : (rentReceived / expectedRent) * 100,
    );
  }

  List<PendingRentCalculation> calculatePendingRentItems({
    required List<VillaModel> villas,
    List<Room> rooms = const [],
    required List<Income> incomes,
    required DateTime month,
  }) {
    return calculateVillaProfit(
      villas: villas,
      rooms: rooms,
      incomes: incomes,
      expenses: const [],
      month: month,
    )
        .where((item) => item.isOccupied && item.pendingRent > 0)
        .map(
          (item) => PendingRentCalculation(
            villaId: item.villaId,
            villaName: item.villaName,
            tenantName: item.tenantName,
            expectedRent: item.expectedRent,
            rentReceived: item.rentReceived,
            pendingRent: item.pendingRent,
            overpaidAmount: item.overpaidAmount,
            dueDay: item.dueDay,
          ),
        )
        .toList();
  }

  double calculateExpectedRent(List<Room> rooms) {
    return _sumMonthlyRent(
      rooms.where((room) => !room.isDeleted && room.isOccupied),
    );
  }

  double calculateVacancyLoss(List<Room> rooms) {
    return _sumMonthlyRent(
      rooms.where((room) => !room.isDeleted && room.isVacant),
    );
  }

  double calculateTotalMonthlyRent(List<Room> rooms) {
    return _sumMonthlyRent(rooms.where((room) => !room.isDeleted));
  }

  double calculatePendingRent({
    required double expectedRent,
    required double rentReceived,
  }) {
    final pendingRent = expectedRent - rentReceived;
    return pendingRent < 0 ? 0 : pendingRent;
  }

  bool _isRentIncome(Income income) {
    return income.incomeType.toLowerCase() == IncomeTypes.rent.toLowerCase();
  }

  bool _isDepositIncome(Income income) {
    return income.incomeType.toLowerCase() == IncomeTypes.deposit.toLowerCase();
  }

  bool _isDepositRefundExpense(Expense expense) {
    return expense.category.toLowerCase() ==
        ExpenseCategories.depositRefund.toLowerCase();
  }

  RoomProfitSummary _calculateRoomProfitSummary({
    required Room room,
    required List<Income> monthlyCashIncomes,
    required List<Income> monthlyRentIncomes,
    required List<Expense> monthlyExpenses,
  }) {
    final isOccupied = room.isOccupied;
    final roomRentIncomes = monthlyRentIncomes.where(
      (income) => income.roomId == room.id,
    );
    final roomOtherIncomes = monthlyCashIncomes.where(
      (income) => income.roomId == room.id && !_isRentIncome(income),
    );
    final roomExpenses = monthlyExpenses.where(
      (expense) => expense.roomId == room.id,
    );

    final expectedRent = isOccupied ? room.monthlyRent : 0.0;
    final rentReceived = isOccupied ? _sumIncome(roomRentIncomes) : 0.0;
    final otherIncome = _sumIncome(roomOtherIncomes);
    final totalExpenses = _sumExpense(roomExpenses);
    final pendingRent = isOccupied
        ? calculatePendingRent(
            expectedRent: expectedRent,
            rentReceived: rentReceived,
          )
        : 0.0;
    final overpaidAmount = isOccupied
        ? _calculateOverpaidAmount(
            expectedRent: expectedRent,
            rentReceived: rentReceived,
          )
        : 0.0;
    final vacancyLoss = room.isVacant ? room.monthlyRent : 0.0;
    final actualProfit = rentReceived + otherIncome - totalExpenses;
    final expectedProfit = expectedRent + otherIncome - totalExpenses;

    return RoomProfitSummary(
      roomId: room.id,
      villaId: room.villaId,
      villaName: room.villaName,
      roomName: room.roomName,
      tenantName: isOccupied ? room.tenantName : 'Vacant',
      status: room.status,
      paymentDueDay: room.paymentDueDay,
      monthlyRent: room.monthlyRent,
      expectedRent: expectedRent,
      rentReceived: rentReceived,
      otherIncome: otherIncome,
      totalIncome: rentReceived + otherIncome,
      totalExpenses: totalExpenses,
      pendingRent: pendingRent,
      overpaidAmount: overpaidAmount,
      vacancyLoss: vacancyLoss,
      actualProfit: actualProfit,
      expectedProfit: expectedProfit,
      rentCollectionPercentage:
          expectedRent == 0 ? 0 : (rentReceived / expectedRent) * 100,
    );
  }

  bool _isSameMonth(DateTime date, DateTime month) {
    return date.year == month.year && date.month == month.month;
  }

  double _calculateOverpaidAmount({
    required double expectedRent,
    required double rentReceived,
  }) {
    final overpaidAmount = rentReceived - expectedRent;
    return overpaidAmount > 0 ? overpaidAmount : 0;
  }

  double _sumIncome(Iterable<Income> incomes) {
    return incomes.fold<double>(0, (sum, income) => sum + income.amount);
  }

  double _sumExpense(Iterable<Expense> expenses) {
    return expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
  }

  double _sumMonthlyRent(Iterable<Room> rooms) {
    return rooms.fold<double>(0, (sum, room) => sum + room.monthlyRent);
  }

  List<Room> _activeRoomsForVillas(List<Room> rooms, Set<String> villaIds) {
    return rooms
        .where((room) => !room.isDeleted && villaIds.contains(room.villaId))
        .toList();
  }

  List<Income> _activeIncomes(
    List<Income> incomes,
    Set<String> villaIds,
    Set<String> roomIds,
  ) {
    return incomes.where((income) {
      if (income.isDeleted) return false;
      if (_isDepositIncome(income)) return false;
      if (!villaIds.contains(income.villaId)) return false;
      if (income.roomId.trim().isEmpty) return true;
      return roomIds.contains(income.roomId);
    }).toList();
  }

  List<Expense> _activeExpenses(
    List<Expense> expenses,
    Set<String> villaIds,
    Set<String> roomIds,
  ) {
    return expenses.where((expense) {
      if (expense.isDeleted) return false;
      if (_isDepositRefundExpense(expense)) return false;
      final villaId = expense.villaId;
      if (villaId == null || villaId.trim().isEmpty) return true;
      if (!villaIds.contains(villaId)) return false;
      final roomId = expense.roomId;
      if (roomId == null || roomId.trim().isEmpty) return true;
      return roomIds.contains(roomId);
    }).toList();
  }
}

class MonthlyProfitSummary {
  final DateTime month;
  final double actualIncome;
  final double rentReceived;
  final double otherIncome;
  final double expensesPaid;
  final double totalRoomRent;
  final double expectedRent;
  final double pendingRent;
  final double overpaidAmount;
  final double actualNetProfit;
  final double expectedNetProfit;
  final double vacancyLoss;
  final double rentCollectionPercentage;

  const MonthlyProfitSummary({
    required this.month,
    required this.actualIncome,
    required this.rentReceived,
    required this.otherIncome,
    required this.expensesPaid,
    required this.totalRoomRent,
    required this.expectedRent,
    required this.pendingRent,
    required this.overpaidAmount,
    required this.actualNetProfit,
    required this.expectedNetProfit,
    required this.vacancyLoss,
    required this.rentCollectionPercentage,
  });
}

class VillaProfitCalculation {
  final String villaId;
  final String villaName;
  final String tenantName;
  final bool isOccupied;
  final bool isVacant;
  final double expectedRent;
  final double rentReceived;
  final double otherIncome;
  final double expensesPaid;
  final double pendingRent;
  final double overpaidAmount;
  final double vacancyLoss;
  final double actualProfit;
  final double expectedProfit;
  final int dueDay;

  const VillaProfitCalculation({
    required this.villaId,
    required this.villaName,
    required this.tenantName,
    required this.isOccupied,
    required this.isVacant,
    required this.expectedRent,
    required this.rentReceived,
    required this.otherIncome,
    required this.expensesPaid,
    required this.pendingRent,
    required this.overpaidAmount,
    required this.vacancyLoss,
    required this.actualProfit,
    required this.expectedProfit,
    required this.dueDay,
  });
}

class PendingRentCalculation {
  final String villaId;
  final String villaName;
  final String tenantName;
  final double expectedRent;
  final double rentReceived;
  final double pendingRent;
  final double overpaidAmount;
  final int dueDay;

  const PendingRentCalculation({
    required this.villaId,
    required this.villaName,
    required this.tenantName,
    required this.expectedRent,
    required this.rentReceived,
    required this.pendingRent,
    required this.overpaidAmount,
    required this.dueDay,
  });
}

class RoomProfitTotals {
  final double actualIncome;
  final double expensesPaid;
  final double rentReceived;
  final double expectedRent;
  final double pendingRent;
  final double vacancyLoss;
  final double actualNetProfit;
  final double expectedNetProfit;
  final int totalRooms;
  final int occupiedRooms;
  final int vacantRooms;
  final double rentCollectionPercentage;

  const RoomProfitTotals({
    required this.actualIncome,
    required this.expensesPaid,
    required this.rentReceived,
    required this.expectedRent,
    required this.pendingRent,
    required this.vacancyLoss,
    required this.actualNetProfit,
    required this.expectedNetProfit,
    required this.totalRooms,
    required this.occupiedRooms,
    required this.vacantRooms,
    required this.rentCollectionPercentage,
  });
}

class YearlyProfitSummaryItem {
  final DateTime month;
  final double actualIncome;
  final double expensesPaid;
  final double actualNetProfit;
  final double expectedRent;
  final double pendingRent;
  final double expectedNetProfit;

  const YearlyProfitSummaryItem({
    required this.month,
    required this.actualIncome,
    required this.expensesPaid,
    required this.actualNetProfit,
    required this.expectedRent,
    required this.pendingRent,
    required this.expectedNetProfit,
  });
}

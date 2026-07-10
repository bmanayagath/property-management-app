enum ReportType {
  monthlySummary,
  villaWiseProfit,
  roomWiseProfit,
  incomeReport,
  expenseReport,
  pendingRentReport,
  vacancyReport,
  yearlySummary,
  depositReport,
}

extension ReportTypeLabel on ReportType {
  String get label {
    switch (this) {
      case ReportType.monthlySummary:
        return 'Monthly Summary';
      case ReportType.villaWiseProfit:
        return 'Villa-wise Profit';
      case ReportType.roomWiseProfit:
        return 'Room-wise Profit';
      case ReportType.incomeReport:
        return 'Income Report';
      case ReportType.expenseReport:
        return 'Expense Report';
      case ReportType.pendingRentReport:
        return 'Pending Rent Report';
      case ReportType.vacancyReport:
        return 'Vacancy Report';
      case ReportType.yearlySummary:
        return 'Yearly Summary';
      case ReportType.depositReport:
        return 'Deposit Report';
    }
  }
}

class MonthlySummaryReportData {
  final double totalIncome;
  final double totalExpenses;
  final double netProfit;
  final double totalRoomRent;
  final double expectedRent;
  final double pendingRent;
  final double vacancyLoss;
  final double rentCollectionPercentage;

  const MonthlySummaryReportData({
    required this.totalIncome,
    required this.totalExpenses,
    required this.netProfit,
    required this.totalRoomRent,
    required this.expectedRent,
    required this.pendingRent,
    required this.vacancyLoss,
    required this.rentCollectionPercentage,
  });
}

class VillaProfitReportItem {
  final String villaId;
  final String villaName;
  final int totalRooms;
  final int occupiedRooms;
  final int vacantRooms;
  final double expectedRent;
  final double receivedIncome;
  final double totalExpense;
  final double netProfit;
  final double pendingAmount;
  final double vacancyLoss;

  const VillaProfitReportItem({
    required this.villaId,
    required this.villaName,
    required this.totalRooms,
    required this.occupiedRooms,
    required this.vacantRooms,
    required this.expectedRent,
    required this.receivedIncome,
    required this.totalExpense,
    required this.netProfit,
    required this.pendingAmount,
    required this.vacancyLoss,
  });
}

class PendingRentReportItem {
  final String villaName;
  final String tenantName;
  final double expectedRent;
  final double receivedRent;
  final double pendingRent;
  final int dueDay;
  final bool isOverdue;
  final int overdueDays;

  const PendingRentReportItem({
    required this.villaName,
    required this.tenantName,
    required this.expectedRent,
    required this.receivedRent,
    required this.pendingRent,
    required this.dueDay,
    required this.isOverdue,
    required this.overdueDays,
  });
}

class RoomWiseProfitReportItem {
  final String villaId;
  final String villaName;
  final String roomId;
  final String roomName;
  final String tenantName;
  final String status;
  final double expectedRent;
  final double rentReceived;
  final double otherIncome;
  final double totalExpenses;
  final double pendingRent;
  final double vacancyLoss;
  final double actualProfit;
  final double expectedProfit;
  final double rentCollectionPercentage;

  const RoomWiseProfitReportItem({
    required this.villaId,
    required this.villaName,
    required this.roomId,
    required this.roomName,
    required this.tenantName,
    required this.status,
    required this.expectedRent,
    required this.rentReceived,
    required this.otherIncome,
    required this.totalExpenses,
    required this.pendingRent,
    required this.vacancyLoss,
    required this.actualProfit,
    required this.expectedProfit,
    required this.rentCollectionPercentage,
  });

  bool get isOccupied => status.toLowerCase() == 'occupied';

  bool get isVacant => status.toLowerCase() == 'vacant';

  String get displayRoomName =>
      roomName.trim().isEmpty ? 'Room' : roomName.trim();
}

class YearlySummaryReportItem {
  final DateTime month;
  final double income;
  final double expense;
  final double profit;

  const YearlySummaryReportItem({
    required this.month,
    required this.income,
    required this.expense,
    required this.profit,
  });
}

class RoomProfitSummary {
  final String roomId;
  final String villaId;
  final String villaName;
  final String roomName;
  final String tenantName;
  final String status;
  final int paymentDueDay;
  final double monthlyRent;
  final double expectedRent;
  final double rentReceived;
  final double otherIncome;
  final double totalIncome;
  final double totalExpenses;
  final double pendingRent;
  final double overpaidAmount;
  final double vacancyLoss;
  final double actualProfit;
  final double expectedProfit;
  final double rentCollectionPercentage;

  const RoomProfitSummary({
    required this.roomId,
    required this.villaId,
    required this.villaName,
    required this.roomName,
    required this.tenantName,
    required this.status,
    required this.paymentDueDay,
    required this.monthlyRent,
    required this.expectedRent,
    required this.rentReceived,
    required this.otherIncome,
    required this.totalIncome,
    required this.totalExpenses,
    required this.pendingRent,
    required this.overpaidAmount,
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

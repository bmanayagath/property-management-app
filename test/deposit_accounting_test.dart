import 'package:flutter_test/flutter_test.dart';
import 'package:villabooks/data/services/profit_calculation_service.dart';
import 'package:villabooks/domain/models/expense.dart';
import 'package:villabooks/domain/models/income.dart';
import 'package:villabooks/domain/models/room.dart';
import 'package:villabooks/domain/models/villa_model.dart';

void main() {
  const service = ProfitCalculationService();
  final month = DateTime(2026, 6, 1);

  test('deposit income is ignored by profit and rent collection', () {
    final summary = service.calculateMonthlySummary(
      villas: [_villa()],
      rooms: [_room()],
      incomes: [
        _income(
          id: 'deposit-income',
          type: IncomeTypes.deposit,
          amount: 2000,
        ),
      ],
      expenses: const [],
      month: month,
    );

    expect(summary.actualIncome, 0);
    expect(summary.actualNetProfit, 0);
    expect(summary.rentReceived, 0);
    expect(summary.pendingRent, 1750);
    expect(summary.rentCollectionPercentage, 0);
  });

  test('deposit does not inflate income after rent is fully collected', () {
    final summary = service.calculateMonthlySummary(
      villas: [_villa()],
      rooms: [_room()],
      incomes: [
        _income(id: 'rent-income', type: IncomeTypes.rent, amount: 1750),
        _income(
          id: 'deposit-income',
          type: IncomeTypes.deposit,
          amount: 2000,
        ),
      ],
      expenses: const [],
      month: month,
    );

    expect(summary.actualIncome, 1750);
    expect(summary.actualNetProfit, 1750);
    expect(summary.rentReceived, 1750);
    expect(summary.pendingRent, 0);
    expect(summary.rentCollectionPercentage, 100);
  });

  test('deposit refund expense is ignored by profit', () {
    final summary = service.calculateMonthlySummary(
      villas: [_villa()],
      rooms: [_room()],
      incomes: [
        _income(id: 'rent-income', type: IncomeTypes.rent, amount: 1750),
      ],
      expenses: [
        Expense(
          id: 'deposit-refund',
          villaId: 'villa-1',
          villaName: 'Villa 1',
          roomId: 'room-1',
          roomName: 'Room 1',
          category: ExpenseCategories.depositRefund,
          amount: 2000,
          expenseDate: DateTime(2026, 6, 20),
          paidTo: 'Faizan',
          paymentMethod: ExpensePaymentMethods.cash,
          notes: 'Tenant deposit refund for Faizan',
          createdAt: DateTime(2026, 6, 20),
        ),
      ],
      month: month,
    );

    expect(summary.actualIncome, 1750);
    expect(summary.expensesPaid, 0);
    expect(summary.actualNetProfit, 1750);
  });
}

VillaModel _villa() {
  return VillaModel(
    id: 'villa-1',
    villaName: 'Villa 1',
    location: 'Doha',
    createdAt: DateTime(2026, 6, 1),
  );
}

Room _room() {
  return Room(
    id: 'room-1',
    villaId: 'villa-1',
    villaName: 'Villa 1',
    roomName: 'Room 1',
    tenantName: 'Faizan',
    tenantPhone: '77051590',
    monthlyRent: 1750,
    contractStartDate: DateTime(2026, 1, 1),
    contractEndDate: DateTime(2026, 12, 31),
    paymentDueDay: 1,
    status: RoomStatuses.occupied,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: null,
  );
}

Income _income({
  required String id,
  required String type,
  required double amount,
}) {
  return Income(
    id: id,
    villaId: 'villa-1',
    villaName: 'Villa 1',
    roomId: 'room-1',
    roomName: 'Room 1',
    tenantName: 'Faizan',
    incomeType: type,
    amount: amount,
    paymentDate: DateTime(2026, 6, 15),
    paymentMethod: IncomePaymentMethods.cash,
    monthCovered: DateTime(2026, 6, 1),
    notes: '',
    createdAt: DateTime(2026, 6, 15),
  );
}

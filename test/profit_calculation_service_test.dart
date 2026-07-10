import 'package:flutter_test/flutter_test.dart';
import 'package:villabooks/data/services/profit_calculation_service.dart';
import 'package:villabooks/domain/models/expense.dart';
import 'package:villabooks/domain/models/income.dart';
import 'package:villabooks/domain/models/room.dart';
import 'package:villabooks/domain/models/villa_model.dart';

void main() {
  const service = ProfitCalculationService();
  final month = DateTime(2026, 7, 1);

  test('monthly summary uses shared financial rules', () {
    final summary = service.calculateMonthlySummary(
      villas: [_villa(), _villa(id: 'deleted-villa', isDeleted: true)],
      rooms: [
        _room(id: 'room-1', status: RoomStatuses.occupied, rent: 1500),
        _room(id: 'room-2', status: RoomStatuses.vacant, rent: 1200),
        _room(
          id: 'deleted-villa-room',
          villaId: 'deleted-villa',
          status: RoomStatuses.occupied,
          rent: 900,
        ),
      ],
      incomes: [
        _income(
          id: 'rent',
          type: IncomeTypes.rent,
          amount: 1000,
          roomId: 'room-1',
        ),
        _income(
          id: 'other-income',
          type: IncomeTypes.penalty,
          amount: 100,
          roomId: '',
        ),
        _income(
          id: 'deposit',
          type: IncomeTypes.deposit,
          amount: 2000,
          roomId: 'room-1',
        ),
        _income(
          id: 'deleted-villa-income',
          villaId: 'deleted-villa',
          type: IncomeTypes.rent,
          amount: 900,
          roomId: 'deleted-villa-room',
        ),
      ],
      expenses: [
        _expense(
          id: 'maintenance',
          category: ExpenseCategories.maintenance,
          amount: 300,
        ),
        _expense(
          id: 'deposit-refund',
          category: ExpenseCategories.depositRefund,
          amount: 2000,
        ),
        _expense(
          id: 'deleted-villa-expense',
          villaId: 'deleted-villa',
          category: ExpenseCategories.maintenance,
          amount: 400,
        ),
      ],
      month: month,
    );

    expect(summary.expectedRent, 2700);
    expect(summary.rentReceived, 1000);
    expect(summary.pendingRent, 1700);
    expect(summary.vacancyLoss, 1200);
    expect(summary.actualIncome, 1100);
    expect(summary.expensesPaid, 300);
    expect(summary.actualNetProfit, 800);
  });

  test('new expense categories are available', () {
    expect(ExpenseCategories.values, contains(ExpenseCategories.ac));
    expect(ExpenseCategories.values, contains(ExpenseCategories.petrol));
  });
}

VillaModel _villa({String id = 'villa-1', bool isDeleted = false}) {
  return VillaModel(
    id: id,
    villaName: 'Villa 1',
    location: 'Doha',
    createdAt: DateTime(2026, 7, 1),
    isDeleted: isDeleted,
  );
}

Room _room({
  required String id,
  String villaId = 'villa-1',
  required String status,
  required double rent,
}) {
  return Room(
    id: id,
    villaId: villaId,
    villaName: 'Villa 1',
    roomName: id,
    tenantName: status == RoomStatuses.occupied ? 'Tenant' : '',
    tenantPhone: '',
    monthlyRent: rent,
    contractStartDate: DateTime(2026, 1, 1),
    contractEndDate: DateTime(2026, 12, 31),
    paymentDueDay: 1,
    status: status,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: null,
  );
}

Income _income({
  required String id,
  String villaId = 'villa-1',
  required String type,
  required double amount,
  required String roomId,
}) {
  return Income(
    id: id,
    villaId: villaId,
    villaName: 'Villa 1',
    roomId: roomId,
    roomName: roomId,
    incomeType: type,
    amount: amount,
    paymentDate: DateTime(2026, 7, 8),
    paymentMethod: IncomePaymentMethods.cash,
    monthCovered: DateTime(2026, 7, 1),
    notes: '',
    createdAt: DateTime(2026, 7, 8),
  );
}

Expense _expense({
  required String id,
  String villaId = 'villa-1',
  required String category,
  required double amount,
}) {
  return Expense(
    id: id,
    villaId: villaId,
    villaName: 'Villa 1',
    roomId: null,
    roomName: null,
    category: category,
    amount: amount,
    expenseDate: DateTime(2026, 7, 9),
    paidTo: 'Vendor',
    paymentMethod: ExpensePaymentMethods.cash,
    notes: '',
    createdAt: DateTime(2026, 7, 9),
  );
}

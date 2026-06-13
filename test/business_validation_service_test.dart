import 'package:flutter_test/flutter_test.dart';
import 'package:villabooks/data/services/business_validation_service.dart';
import 'package:villabooks/domain/models/income.dart';
import 'package:villabooks/domain/models/room.dart';
import 'package:villabooks/domain/models/villa_model.dart';

void main() {
  const service = BusinessValidationService();

  test('rent validation allows partial payment up to remaining rent', () {
    final room = _room(monthlyRent: 2000);
    final result = service.validateIncome(
      income: _income(amount: 1500),
      existingIncomes: [
        _income(id: 'paid-1', amount: 500),
        _income(
          id: 'deposit-1',
          amount: 1000,
          incomeType: IncomeTypes.deposit,
        ),
      ],
      villas: [_villa()],
      rooms: [room],
      now: DateTime(2026, 6, 6),
    );

    expect(result.isValid, isTrue);
  });

  test('rent validation blocks overpayment above remaining rent', () {
    final room = _room(monthlyRent: 2000);
    final result = service.validateIncome(
      income: _income(amount: 1600),
      existingIncomes: [_income(id: 'paid-1', amount: 500)],
      villas: [_villa()],
      rooms: [room],
      now: DateTime(2026, 6, 6),
    );

    expect(result.isValid, isFalse);
    expect(
      result.message,
      'Amount exceeds pending rent. Remaining rent is 1,500 QAR.',
    );
  });

  test('rent validation blocks fully recorded room month', () {
    final room = _room(monthlyRent: 2000);
    final result = service.validateIncome(
      income: _income(amount: 1),
      existingIncomes: [_income(id: 'paid-1', amount: 2000)],
      villas: [_villa()],
      rooms: [room],
      now: DateTime(2026, 6, 6),
    );

    expect(result.isValid, isFalse);
    expect(
      result.message,
      'Rent is already fully recorded for this room and month.',
    );
  });

  test('rent validation blocks vacant room rent', () {
    final result = service.validateIncome(
      income: _income(amount: 1000),
      existingIncomes: const [],
      villas: [_villa()],
      rooms: [_room(status: RoomStatuses.vacant)],
      now: DateTime(2026, 6, 6),
    );

    expect(result.isValid, isFalse);
    expect(result.message, 'Cannot record rent for a vacant room.');
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

Room _room({
  double monthlyRent = 2000,
  String status = RoomStatuses.occupied,
}) {
  return Room(
    id: 'room-1',
    villaId: 'villa-1',
    villaName: 'Villa 1',
    roomName: 'Room 1',
    tenantName: 'Tenant',
    tenantPhone: '',
    monthlyRent: monthlyRent,
    contractStartDate: null,
    contractEndDate: null,
    paymentDueDay: 1,
    status: status,
    createdAt: DateTime(2026, 6, 1),
    updatedAt: null,
  );
}

Income _income({
  String id = 'income-1',
  double amount = 1000,
  String incomeType = IncomeTypes.rent,
  DateTime? monthCovered,
}) {
  return Income(
    id: id,
    villaId: 'villa-1',
    villaName: 'Villa 1',
    roomId: 'room-1',
    roomName: 'Room 1',
    incomeType: incomeType,
    amount: amount,
    paymentDate: DateTime(2026, 6, 6),
    paymentMethod: IncomePaymentMethods.cash,
    monthCovered: monthCovered ?? DateTime(2026, 6, 1),
    notes: '',
    createdAt: DateTime(2026, 6, 6),
  );
}

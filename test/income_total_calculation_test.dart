import 'package:flutter_test/flutter_test.dart';
import 'package:villabooks/data/services/income_calculation_service.dart';
import 'package:villabooks/domain/models/income.dart';

void main() {
  const service = IncomeCalculationService();
  final month = DateTime(2026, 7, 1);

  test('monthly total includes only active countable income for org and month',
      () {
    final total = service.totalForMonth(
      [
        _income(
          id: 'july-rent-paid-august',
          orgId: 'org-a',
          type: IncomeTypes.rent,
          amount: 1200,
          paymentDate: DateTime(2026, 8, 2),
          monthCovered: DateTime(2026, 7, 1),
        ),
        _income(
          id: 'august-rent-paid-july',
          orgId: 'org-a',
          type: IncomeTypes.rent,
          amount: 1300,
          paymentDate: DateTime(2026, 7, 28),
          monthCovered: DateTime(2026, 8, 1),
        ),
        _income(
          id: 'july-penalty',
          orgId: 'org-a',
          type: IncomeTypes.penalty,
          amount: 100,
          paymentDate: DateTime(2026, 7, 10),
          monthCovered: DateTime(2026, 7, 1),
        ),
        _income(
          id: 'deposit',
          orgId: 'org-a',
          type: IncomeTypes.deposit,
          amount: 2000,
          paymentDate: DateTime(2026, 7, 11),
          monthCovered: DateTime(2026, 7, 1),
        ),
        _income(
          id: 'deleted',
          orgId: 'org-a',
          type: IncomeTypes.rent,
          amount: 900,
          paymentDate: DateTime(2026, 7, 12),
          monthCovered: DateTime(2026, 7, 1),
          isDeleted: true,
        ),
        _income(
          id: 'other-org',
          orgId: 'org-b',
          type: IncomeTypes.rent,
          amount: 800,
          paymentDate: DateTime(2026, 7, 12),
          monthCovered: DateTime(2026, 7, 1),
        ),
        _income(
          id: 'invalid-type',
          orgId: 'org-a',
          type: 'Bonus',
          amount: 700,
          paymentDate: DateTime(2026, 7, 12),
          monthCovered: DateTime(2026, 7, 1),
        ),
      ],
      month,
      orgId: 'org-a',
    );

    expect(total, 1300);
  });
}

Income _income({
  required String id,
  required String orgId,
  required String type,
  required double amount,
  required DateTime paymentDate,
  required DateTime monthCovered,
  bool isDeleted = false,
}) {
  return Income(
    id: id,
    orgId: orgId,
    villaId: 'villa-1',
    villaName: 'Villa 1',
    roomId: 'room-1',
    roomName: 'Room 1',
    incomeType: type,
    amount: amount,
    paymentDate: paymentDate,
    paymentMethod: IncomePaymentMethods.cash,
    monthCovered: monthCovered,
    notes: '',
    createdAt: DateTime(2026, 7, 1),
    isDeleted: isDeleted,
  );
}

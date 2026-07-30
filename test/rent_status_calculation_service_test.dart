import 'package:flutter_test/flutter_test.dart';
import 'package:villabooks/data/services/rent_status_calculation_service.dart';
import 'package:villabooks/domain/models/expense.dart';
import 'package:villabooks/domain/models/income.dart';
import 'package:villabooks/domain/models/room.dart';
import 'package:villabooks/domain/models/room_rent_status.dart';

void main() {
  const service = RentStatusCalculationService();
  final now = DateTime(2026, 7, 10, 15, 30);

  group('overdue rent detection', () {
    test('marks an occupied room overdue after its due day with pending rent',
        () {
      final summary = service.buildSummary(
        rooms: [_room(id: 'room-1', name: 'Room 1', dueDay: 8, rent: 2500)],
        incomes: const [],
        now: now,
      );

      final status = summary.byRoomId['room-1']!;
      expect(status.isOverdue, isTrue);
      expect(status.pendingRent, 2500);
      expect(status.overdueDays, 2);
      expect(status.dueDate, DateTime(2026, 7, 8));
    });

    test('stops overdue status immediately when rent is fully collected', () {
      final summary = service.buildSummary(
        rooms: [_room(id: 'room-1', name: 'Room 1', dueDay: 8, rent: 2500)],
        incomes: [_rentIncome(roomId: 'room-1', amount: 2500)],
        now: now,
      );

      final status = summary.byRoomId['room-1']!;
      expect(status.pendingRent, 0);
      expect(status.isOverdue, isFalse);
      expect(status.isPaid, isTrue);
    });

    test('does not mark rent overdue on the due day or for a vacant room', () {
      final summary = service.buildSummary(
        rooms: [
          _room(id: 'due-today', name: 'Room 1', dueDay: 10, rent: 1000),
          _room(
            id: 'vacant',
            name: 'Room 2',
            dueDay: 1,
            rent: 1000,
            status: RoomStatuses.vacant,
          ),
        ],
        incomes: const [],
        now: now,
      );

      expect(summary.byRoomId['due-today']!.isOverdue, isFalse);
      expect(summary.byRoomId['vacant']!.isOverdue, isFalse);
      expect(summary.byRoomId['vacant']!.pendingRent, 0);
    });

    test('clamps due days to the last valid day of short months', () {
      final status = service.calculateRoomStatus(
        room: _room(id: 'room-1', name: 'Room 1', dueDay: 31, rent: 1000),
        rentReceived: 0,
        now: DateTime(2026, 3, 1),
      );

      expect(status.dueDate, DateTime(2026, 3, 31));
      final februaryDueDate = service.dueDateFor(31, DateTime(2026, 2, 1));
      expect(februaryDueDate, DateTime(2026, 2, 28));
    });

    test('uses today, month end, or month start for selected dashboard month',
        () {
      final current = service.referenceDateForMonth(
        month: DateTime(2026, 7),
        now: now,
      );
      final past = service.referenceDateForMonth(
        month: DateTime(2026, 6),
        now: now,
      );
      final future = service.referenceDateForMonth(
        month: DateTime(2026, 8),
        now: now,
      );

      expect(current, DateTime(2026, 7, 10));
      expect(past, DateTime(2026, 6, 30));
      expect(future, DateTime(2026, 8, 1));
    });
  });

  test('aggregates villas and applies the required room sort order', () {
    final summary = service.buildSummary(
      rooms: [
        _room(id: 'room-8', name: 'Room 8', dueDay: 5, rent: 1000),
        _room(id: 'room-2', name: 'Room 2', dueDay: 8, rent: 2500),
        _room(id: 'room-3', name: 'Room 3', dueDay: 6, rent: 2500),
        _room(
          id: 'paid',
          name: 'Room 1',
          dueDay: 1,
          rent: 900,
          villaId: 'villa-2',
        ),
      ],
      incomes: [_rentIncome(roomId: 'paid', amount: 900, villaId: 'villa-2')],
      now: now,
    );

    expect(
      summary.rooms.map((status) => status.room.id),
      ['room-3', 'room-2', 'room-8', 'paid'],
    );
    expect(summary.overdueRoomCount, 3);
    expect(summary.overdueVillaCount, 1);
    expect(summary.forVilla('villa-1').overduePendingAmount, 6000);
    expect(summary.forVilla('villa-1').oldestOverdueDays, 5);
    expect(summary.filtered(RoomRentFilter.paid).single.room.id, 'paid');
  });

  group('expense location labels', () {
    test('shows villa and room together for room expenses', () {
      final expense = _expense(villaName: 'Villa 71', roomName: 'Room 4');
      expect(expense.locationLabel, 'Villa 71 • Room 4');
      expect(expense.hasRoomAssociation, isTrue);
    });

    test('shows villa or general expense when there is no room', () {
      expect(_expense(villaName: 'Villa 7').locationLabel, 'Villa 7');
      expect(_expense().locationLabel, 'General Expense');
    });
  });
}

Room _room({
  required String id,
  required String name,
  required int dueDay,
  required double rent,
  String villaId = 'villa-1',
  String status = RoomStatuses.occupied,
}) {
  return Room(
    id: id,
    villaId: villaId,
    villaName: villaId == 'villa-1' ? 'Villa 1' : 'Villa 2',
    roomName: name,
    tenantName: status == RoomStatuses.occupied ? 'Tenant' : '',
    tenantPhone: '',
    monthlyRent: rent,
    contractStartDate: DateTime(2026, 1, 1),
    contractEndDate: DateTime(2026, 12, 31),
    paymentDueDay: dueDay,
    status: status,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: null,
  );
}

Income _rentIncome({
  required String roomId,
  required double amount,
  String villaId = 'villa-1',
}) {
  return Income(
    id: 'income-$roomId',
    villaId: villaId,
    villaName: villaId == 'villa-1' ? 'Villa 1' : 'Villa 2',
    roomId: roomId,
    roomName: roomId,
    incomeType: IncomeTypes.rent,
    amount: amount,
    paymentDate: DateTime(2026, 7, 10),
    paymentMethod: IncomePaymentMethods.cash,
    monthCovered: DateTime(2026, 7, 1),
    notes: '',
    createdAt: DateTime(2026, 7, 10),
  );
}

Expense _expense({String villaName = '', String? roomName}) {
  return Expense(
    id: 'expense-1',
    villaId: villaName.isEmpty ? null : 'villa-1',
    villaName: villaName,
    roomId: roomName == null ? null : 'room-1',
    roomName: roomName,
    category: ExpenseCategories.maintenance,
    amount: 100,
    expenseDate: DateTime(2026, 7, 10),
    paidTo: 'Vendor',
    paymentMethod: ExpensePaymentMethods.cash,
    notes: '',
    createdAt: DateTime(2026, 7, 10),
  );
}

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

part 'database.g.dart';

// Villa Table
class Villas extends Table {
  TextColumn get id => text()();
  TextColumn get villaName => text()();
  TextColumn get villaNumber => text()();
  TextColumn get location => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get tenantName => text()();
  TextColumn get tenantPhone => text()();
  RealColumn get monthlyRent => real()();
  DateTimeColumn get contractStartDate => dateTime()();
  DateTimeColumn get contractEndDate => dateTime()();
  IntColumn get paymentDueDay => integer()();
  TextColumn get status => text()(); // occupied, vacant
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// Room Table
class Rooms extends Table {
  TextColumn get id => text()();
  TextColumn get villaId => text().references(Villas, #id)();
  TextColumn get villaName => text()();
  TextColumn get roomName => text()();
  TextColumn get roomNumber => text()();
  TextColumn get tenantName => text().nullable()();
  TextColumn get tenantPhone => text().nullable()();
  RealColumn get monthlyRent => real()();
  DateTimeColumn get contractStartDate => dateTime().nullable()();
  DateTimeColumn get contractEndDate => dateTime().nullable()();
  IntColumn get paymentDueDay => integer()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  IntColumn get isDeleted => integer().withDefault(const Constant(0))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Income Table
class Incomes extends Table {
  TextColumn get id => text()();
  TextColumn get villaId => text().references(Villas, #id)();
  TextColumn get villaName => text().withDefault(const Constant(''))();
  TextColumn get roomId => text().withDefault(const Constant(''))();
  TextColumn get roomName => text().withDefault(const Constant(''))();
  TextColumn get incomeType =>
      text()(); // rent, deposit, maintenanceCharge, penalty, other
  RealColumn get amount => real()();
  DateTimeColumn get paymentDate => dateTime()();
  TextColumn get paymentMethod =>
      text()(); // cash, check, transfer, online, other
  DateTimeColumn get monthCovered => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Expense Table
class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get villaId => text().nullable().references(Villas, #id)();
  TextColumn get villaName => text().withDefault(const Constant(''))();
  TextColumn get roomId => text().nullable()();
  TextColumn get roomName => text().nullable()();
  TextColumn get category =>
      text()(); // maintenance, repair, electricity, water, cleaning, commission, insurance, governmentFee, loan, other
  RealColumn get amount => real()();
  DateTimeColumn get expenseDate => dateTime()();
  TextColumn get paidTo => text()();
  TextColumn get paymentMethod =>
      text()(); // cash, check, transfer, online, other
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Villas, Rooms, Incomes, Expenses])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.addColumn(incomes, incomes.villaName);
            await migrator.addColumn(incomes, incomes.updatedAt);
          }
          if (from < 3) {
            await migrator.addColumn(villas, villas.notes);
            await migrator.createTable(rooms);
            await migrator.addColumn(incomes, incomes.roomId);
            await migrator.addColumn(incomes, incomes.roomName);
            await migrator.addColumn(expenses, expenses.villaName);
            await migrator.addColumn(expenses, expenses.roomId);
            await migrator.addColumn(expenses, expenses.roomName);
            await customStatement('''
              INSERT INTO rooms (
                id,
                villa_id,
                villa_name,
                room_name,
                room_number,
                tenant_name,
                tenant_phone,
                monthly_rent,
                contract_start_date,
                contract_end_date,
                payment_due_day,
                status,
                created_at,
                updated_at
              )
              SELECT
                id || '-main-room',
                id,
                villa_name,
                'Main Room',
                villa_number,
                tenant_name,
                tenant_phone,
                monthly_rent,
                contract_start_date,
                contract_end_date,
                payment_due_day,
                CASE
                  WHEN LOWER(status) = 'occupied' THEN 'Occupied'
                  ELSE 'Vacant'
                END,
                created_at,
                updated_at
              FROM villas
              WHERE monthly_rent > 0
            ''');
          }
        },
      );

  // Villa Queries
  Future<List<Villa>> getAllVillas() => select(villas).get();

  Stream<List<Villa>> watchAllVillas() => select(villas).watch();

  Future<Villa?> getVillaById(String id) =>
      (select(villas)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<int> insertVilla(VillasCompanion villa) => into(villas).insert(villa);

  Future<int> updateVilla(VillasCompanion villa) {
    if (!villa.id.present) {
      throw ArgumentError('Villa id is required to update a villa.');
    }

    return (update(villas)..where((tbl) => tbl.id.equals(villa.id.value)))
        .write(villa.copyWith(id: const Value.absent()));
  }

  Future<int> deleteVilla(String id) =>
      (delete(villas)..where((tbl) => tbl.id.equals(id))).go();

  // Room Queries
  Future<List<Room>> getAllRooms() =>
      (select(rooms)..where((tbl) => tbl.isDeleted.equals(0))).get();

  Stream<List<Room>> watchAllRooms() =>
      (select(rooms)..where((tbl) => tbl.isDeleted.equals(0))).watch();

  Future<Room?> getRoomById(String id) =>
      (select(rooms)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<List<Room>> getRoomsByVillaId(String villaId) => (select(rooms)
        ..where(
          (tbl) => tbl.villaId.equals(villaId) & tbl.isDeleted.equals(0),
        ))
      .get();

  Stream<List<Room>> watchRoomsByVillaId(String villaId) => (select(rooms)
        ..where(
          (tbl) => tbl.villaId.equals(villaId) & tbl.isDeleted.equals(0),
        ))
      .watch();

  Future<int> insertRoom(RoomsCompanion room) => into(rooms).insert(room);

  Future<bool> updateRoom(RoomsCompanion room) => update(rooms).replace(room);

  Future<int> deleteRoom(String id) =>
      (update(rooms)..where((tbl) => tbl.id.equals(id))).write(
        RoomsCompanion(
          isDeleted: const Value(1),
          syncStatus: const Value('pending'),
          updatedAt: Value(DateTime.now()),
        ),
      );

  // Income Queries
  Future<List<Income>> getAllIncomes() => select(incomes).get();

  Stream<List<Income>> watchAllIncomes() => select(incomes).watch();

  Future<List<Income>> getIncomesByVillaId(String villaId) =>
      (select(incomes)..where((tbl) => tbl.villaId.equals(villaId))).get();

  Future<List<Income>> getIncomesByMonth(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);
    return (select(incomes)
          ..where((tbl) =>
              tbl.paymentDate.isBetweenValues(startOfMonth, endOfMonth)))
        .get();
  }

  Future<int> insertIncome(IncomesCompanion income) =>
      into(incomes).insert(income);

  Future<bool> updateIncome(IncomesCompanion income) =>
      update(incomes).replace(income);

  Future<int> deleteIncome(String id) =>
      (delete(incomes)..where((tbl) => tbl.id.equals(id))).go();

  // Expense Queries
  Future<List<Expense>> getAllExpenses() => select(expenses).get();

  Stream<List<Expense>> watchAllExpenses() => select(expenses).watch();

  Future<List<Expense>> getExpensesByVillaId(String villaId) =>
      (select(expenses)..where((tbl) => tbl.villaId.equals(villaId))).get();

  Future<List<Expense>> getExpensesByMonth(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);
    return (select(expenses)
          ..where((tbl) =>
              tbl.expenseDate.isBetweenValues(startOfMonth, endOfMonth)))
        .get();
  }

  Future<int> insertExpense(ExpensesCompanion expense) =>
      into(expenses).insert(expense);

  Future<bool> updateExpense(ExpensesCompanion expense) =>
      update(expenses).replace(expense);

  Future<int> deleteExpense(String id) =>
      (delete(expenses)..where((tbl) => tbl.id.equals(id))).go();

  // Dashboard Queries
  Future<double> getTotalIncomeForMonth(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);
    final result = await (select(incomes)
          ..where((tbl) =>
              tbl.paymentDate.isBetweenValues(startOfMonth, endOfMonth)))
        .map((r) => r.amount)
        .get();
    return result.fold<double>(0, (sum, amount) => sum + amount);
  }

  Future<double> getTotalExpenseForMonth(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);
    final result = await (select(expenses)
          ..where((tbl) =>
              tbl.expenseDate.isBetweenValues(startOfMonth, endOfMonth)))
        .map((r) => r.amount)
        .get();
    return result.fold<double>(0, (sum, amount) => sum + amount);
  }

  Future<Map<String, double>> getExpensesByCategory(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);
    final expenseList = await (select(expenses)
          ..where((tbl) =>
              tbl.expenseDate.isBetweenValues(startOfMonth, endOfMonth)))
        .get();

    final categoryMap = <String, double>{};
    for (var expense in expenseList) {
      categoryMap.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return categoryMap;
  }

  Future<Map<String, double>> getIncomeByVillaSummary(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);
    final incomeList = await (select(incomes)
          ..where((tbl) =>
              tbl.paymentDate.isBetweenValues(startOfMonth, endOfMonth)))
        .get();

    final villaSummary = <String, double>{};
    for (var income in incomeList) {
      villaSummary.update(
        income.villaId,
        (value) => value + income.amount,
        ifAbsent: () => income.amount,
      );
    }
    return villaSummary;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'villabooks.db'));
      debugPrint('[Database] Opening local database at ${file.path}');
      return NativeDatabase(file);
    } catch (error, stackTrace) {
      debugPrint('[Database] Failed to open documents database: $error');
      debugPrintStack(stackTrace: stackTrace);

      try {
        final fallbackFolder = await getTemporaryDirectory();
        final file = File(p.join(fallbackFolder.path, 'villabooks.db'));
        debugPrint('[Database] Opening fallback database at ${file.path}');
        return NativeDatabase(file);
      } catch (fallbackError, fallbackStackTrace) {
        debugPrint(
            '[Database] Failed to open fallback database: $fallbackError');
        debugPrintStack(stackTrace: fallbackStackTrace);
        rethrow;
      }
    }
  });
}

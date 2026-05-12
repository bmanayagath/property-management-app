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
  TextColumn get villaNumber => text().withDefault(const Constant(''))();
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
  IntColumn get isDeleted => integer().withDefault(const Constant(0))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deletedBy => text().nullable()();
  TextColumn get createdBy => text().nullable()();
  TextColumn get updatedBy => text().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Room Table
class Rooms extends Table {
  TextColumn get id => text()();
  TextColumn get villaId => text().references(Villas, #id)();
  TextColumn get villaName => text()();
  TextColumn get roomName => text()();
  TextColumn get roomNumber => text().withDefault(const Constant(''))();
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
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deletedBy => text().nullable()();
  TextColumn get createdBy => text().nullable()();
  TextColumn get updatedBy => text().nullable()();
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
  IntColumn get isDeleted => integer().withDefault(const Constant(0))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deletedBy => text().nullable()();
  TextColumn get createdBy => text().nullable()();
  TextColumn get updatedBy => text().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

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
  DateTimeColumn get updatedAt => dateTime().nullable()();
  IntColumn get isDeleted => integer().withDefault(const Constant(0))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deletedBy => text().nullable()();
  TextColumn get createdBy => text().nullable()();
  TextColumn get updatedBy => text().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Villas, Rooms, Incomes, Expenses])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

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
          if (from < 4) {
            await _addSyncColumns(migrator);
          }
        },
      );

  Future<void> _addSyncColumns(Migrator migrator) async {
    await _addColumnIfMissingSql(
        'villas', 'is_deleted', 'INTEGER NOT NULL DEFAULT 0');
    await _addColumnIfMissingSql(
        'villas', 'sync_status', "TEXT NOT NULL DEFAULT 'pending'");
    await _addColumnIfMissingSql('villas', 'deleted_at', 'INTEGER');
    await _addColumnIfMissingSql('villas', 'deleted_by', 'TEXT');
    await _addColumnIfMissingSql('villas', 'created_by', 'TEXT');
    await _addColumnIfMissingSql('villas', 'updated_by', 'TEXT');
    await _addColumnIfMissingSql('villas', 'last_synced_at', 'INTEGER');

    await _addColumnIfMissingSql('rooms', 'deleted_at', 'INTEGER');
    await _addColumnIfMissingSql('rooms', 'deleted_by', 'TEXT');
    await _addColumnIfMissingSql('rooms', 'created_by', 'TEXT');
    await _addColumnIfMissingSql('rooms', 'updated_by', 'TEXT');

    await _addColumnIfMissingSql(
        'incomes', 'is_deleted', 'INTEGER NOT NULL DEFAULT 0');
    await _addColumnIfMissingSql(
        'incomes', 'sync_status', "TEXT NOT NULL DEFAULT 'pending'");
    await _addColumnIfMissingSql('incomes', 'deleted_at', 'INTEGER');
    await _addColumnIfMissingSql('incomes', 'deleted_by', 'TEXT');
    await _addColumnIfMissingSql('incomes', 'created_by', 'TEXT');
    await _addColumnIfMissingSql('incomes', 'updated_by', 'TEXT');
    await _addColumnIfMissingSql('incomes', 'last_synced_at', 'INTEGER');

    await _addColumnIfMissingSql('expenses', 'updated_at', 'INTEGER');
    await _addColumnIfMissingSql(
        'expenses', 'is_deleted', 'INTEGER NOT NULL DEFAULT 0');
    await _addColumnIfMissingSql(
        'expenses', 'sync_status', "TEXT NOT NULL DEFAULT 'pending'");
    await _addColumnIfMissingSql('expenses', 'deleted_at', 'INTEGER');
    await _addColumnIfMissingSql('expenses', 'deleted_by', 'TEXT');
    await _addColumnIfMissingSql('expenses', 'created_by', 'TEXT');
    await _addColumnIfMissingSql('expenses', 'updated_by', 'TEXT');
    await _addColumnIfMissingSql('expenses', 'last_synced_at', 'INTEGER');
  }

  Future<void> _addColumnIfMissingSql(
    String tableName,
    String columnName,
    String definition,
  ) async {
    final columns = await customSelect('PRAGMA table_info($tableName)').get();
    if (columns.any((row) => row.data['name'] == columnName)) return;
    await customStatement(
        'ALTER TABLE $tableName ADD COLUMN $columnName $definition');
  }

  // Villa Queries
  Future<int> getRawVillaCount() async {
    final row =
        await customSelect('SELECT COUNT(*) AS count FROM villas').getSingle();
    return row.read<int>('count');
  }

  Future<int> getActiveVillaCount() async {
    final row = await customSelect(
      'SELECT COUNT(*) AS count FROM villas WHERE is_deleted = 0',
    ).getSingle();
    return row.read<int>('count');
  }

  Future<List<Villa>> getAllVillas() =>
      (select(villas)..where((tbl) => tbl.isDeleted.equals(0))).get();

  Stream<List<Villa>> watchAllVillas() =>
      (select(villas)..where((tbl) => tbl.isDeleted.equals(0))).watch();

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

  Future<void> deleteVilla(String id, {String? deletedBy}) {
    return transaction(() async {
      final childRooms =
          await (select(rooms)..where((tbl) => tbl.villaId.equals(id))).get();
      final roomIds = childRooms.map((room) => room.id).toSet();
      await softDeleteVilla(id, deletedBy: deletedBy);
      await softDeleteRoomsByVilla(id, deletedBy: deletedBy);
      await softDeleteIncomesForVillaOrRooms(
        villaId: id,
        roomIds: roomIds,
        deletedBy: deletedBy,
      );
      await softDeleteExpensesForVillaOrRooms(
        villaId: id,
        roomIds: roomIds,
        deletedBy: deletedBy,
      );
    });
  }

  Future<int> softDeleteVilla(String id, {String? deletedBy}) {
    final now = DateTime.now();
    return _softDeleteWhere(
      tableName: 'villas',
      whereClause: 'id = ?',
      whereArgs: [Variable<String>(id)],
      now: now,
      deletedBy: deletedBy,
    );
  }

  // Room Queries
  Future<int> getRawRoomCount() async {
    final row =
        await customSelect('SELECT COUNT(*) AS count FROM rooms').getSingle();
    return row.read<int>('count');
  }

  Future<int> getActiveRoomCount() async {
    final row = await customSelect(
      '''
      SELECT COUNT(*) AS count
      FROM rooms r
      WHERE r.is_deleted = 0
        AND EXISTS (
          SELECT 1
          FROM villas v
          WHERE v.id = r.villa_id
            AND v.is_deleted = 0
        )
      ''',
      readsFrom: {rooms, villas},
    ).getSingle();
    return row.read<int>('count');
  }

  Future<int> getOrphanRoomCount() async {
    final row = await customSelect(
      '''
      SELECT COUNT(*) AS count
      FROM rooms r
      WHERE r.is_deleted = 0
        AND NOT EXISTS (
          SELECT 1
          FROM villas v
          WHERE v.id = r.villa_id
            AND v.is_deleted = 0
        )
      ''',
      readsFrom: {rooms, villas},
    ).getSingle();
    return row.read<int>('count');
  }

  Future<int> getDeletedRoomCount() async {
    final row = await customSelect(
      'SELECT COUNT(*) AS count FROM rooms WHERE is_deleted = 1',
      readsFrom: {rooms},
    ).getSingle();
    return row.read<int>('count');
  }

  Future<int> getRawRoomCountForVilla(String villaId) async {
    final row = await customSelect(
      'SELECT COUNT(*) AS count FROM rooms WHERE villa_id = ?',
      variables: [Variable<String>(villaId)],
      readsFrom: {rooms},
    ).getSingle();
    return row.read<int>('count');
  }

  Future<int> getActiveRoomCountForVilla(String villaId) async {
    final row = await customSelect(
      '''
      SELECT COUNT(*) AS count
      FROM rooms
      WHERE villa_id = ?
        AND is_deleted = 0
      ''',
      variables: [Variable<String>(villaId)],
      readsFrom: {rooms},
    ).getSingle();
    return row.read<int>('count');
  }

  Future<List<Room>> getAllRooms() {
    final query = select(rooms).join([
      innerJoin(villas, villas.id.equalsExp(rooms.villaId)),
    ])
      ..where(rooms.isDeleted.equals(0) & villas.isDeleted.equals(0));
    return query.map((row) => row.readTable(rooms)).get();
  }

  Stream<List<Room>> watchAllRooms() {
    final query = select(rooms).join([
      innerJoin(villas, villas.id.equalsExp(rooms.villaId)),
    ])
      ..where(rooms.isDeleted.equals(0) & villas.isDeleted.equals(0));
    return query.map((row) => row.readTable(rooms)).watch();
  }

  Future<int> cleanupOrphanRecords({String? deletedBy}) {
    return transaction(() async {
      final now = DateTime.now();
      final orphanRoomIds = await customSelect(
        '''
        SELECT r.id
        FROM rooms r
        WHERE r.is_deleted = 0
          AND NOT EXISTS (
            SELECT 1
            FROM villas v
            WHERE v.id = r.villa_id
              AND v.is_deleted = 0
          )
        ''',
        readsFrom: {rooms, villas},
      ).map((row) => row.read<String>('id')).get();

      if (orphanRoomIds.isEmpty) return 0;

      final placeholders = orphanRoomIds.map((_) => '?').join(', ');
      final variables = [
        Variable<DateTime>(now),
        Variable<String>(deletedBy),
        Variable<DateTime>(now),
        Variable<String>(deletedBy),
        for (final roomId in orphanRoomIds) Variable<String>(roomId),
      ];

      await customUpdate(
        '''
        UPDATE rooms
        SET is_deleted = 1,
            sync_status = 'pending',
            deleted_at = ?,
            deleted_by = ?,
            updated_at = ?,
            updated_by = ?
        WHERE id IN ($placeholders)
        ''',
        variables: variables,
        updates: {rooms},
      );

      await customUpdate(
        '''
        UPDATE incomes
        SET is_deleted = 1,
            sync_status = 'pending',
            deleted_at = ?,
            deleted_by = ?,
            updated_at = ?,
            updated_by = ?
        WHERE is_deleted = 0
          AND room_id IN ($placeholders)
        ''',
        variables: variables,
        updates: {incomes},
      );

      await customUpdate(
        '''
        UPDATE expenses
        SET is_deleted = 1,
            sync_status = 'pending',
            deleted_at = ?,
            deleted_by = ?,
            updated_at = ?,
            updated_by = ?
        WHERE is_deleted = 0
          AND room_id IN ($placeholders)
        ''',
        variables: variables,
        updates: {expenses},
      );

      return orphanRoomIds.length;
    });
  }

  Future<int> cleanupDeletedAndOrphanRooms({String? deletedBy}) {
    return cleanupOrphanRecords(deletedBy: deletedBy);
  }

  Future<Room?> getRoomById(String id) =>
      (select(rooms)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<List<Room>> getRoomsByVillaId(String villaId) => (select(rooms)
        ..where(
          (tbl) =>
              tbl.villaId.equals(villaId) &
              tbl.isDeleted.equals(0) &
              existsQuery(
                selectOnly(villas)
                  ..addColumns([villas.id])
                  ..where(
                    villas.id.equals(villaId) & villas.isDeleted.equals(0),
                  ),
              ),
        ))
      .get();

  Stream<List<Room>> watchRoomsByVillaId(String villaId) => (select(rooms)
        ..where(
          (tbl) =>
              tbl.villaId.equals(villaId) &
              tbl.isDeleted.equals(0) &
              existsQuery(
                selectOnly(villas)
                  ..addColumns([villas.id])
                  ..where(
                    villas.id.equals(villaId) & villas.isDeleted.equals(0),
                  ),
              ),
        ))
      .watch();

  Stream<List<Room>> watchActiveRoomsByVilla(String villaId) {
    return (select(rooms)
          ..where(
            (tbl) => tbl.villaId.equals(villaId) & tbl.isDeleted.equals(0),
          ))
        .watch();
  }

  Future<int> insertRoom(RoomsCompanion room) => into(rooms).insert(room);

  Future<bool> updateRoom(RoomsCompanion room) => update(rooms).replace(room);

  Future<void> deleteRoom(String id, {String? deletedBy}) {
    return transaction(() async {
      await softDeleteRoom(id, deletedBy: deletedBy);
      await softDeleteIncomesForRoom(id, deletedBy: deletedBy);
      await softDeleteExpensesForRoom(id, deletedBy: deletedBy);
    });
  }

  Future<int> softDeleteRoom(String id, {String? deletedBy}) {
    final now = DateTime.now();
    return _softDeleteWhere(
      tableName: 'rooms',
      whereClause: 'id = ?',
      whereArgs: [Variable<String>(id)],
      now: now,
      deletedBy: deletedBy,
    );
  }

  Future<int> softDeleteRoomsByVilla(String villaId, {String? deletedBy}) {
    final now = DateTime.now();
    return _softDeleteWhere(
      tableName: 'rooms',
      whereClause: 'villa_id = ?',
      whereArgs: [Variable<String>(villaId)],
      now: now,
      deletedBy: deletedBy,
    );
  }

  // Income Queries
  Future<List<Income>> getAllIncomes() =>
      (select(incomes)..where((tbl) => tbl.isDeleted.equals(0))).get();

  Stream<List<Income>> watchAllIncomes() =>
      (select(incomes)..where((tbl) => tbl.isDeleted.equals(0))).watch();

  Future<List<Income>> getIncomesByVillaId(String villaId) => (select(incomes)
        ..where(
          (tbl) => tbl.villaId.equals(villaId) & tbl.isDeleted.equals(0),
        ))
      .get();

  Future<List<Income>> getIncomesByMonth(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);
    return (select(incomes)
          ..where((tbl) =>
              tbl.paymentDate.isBetweenValues(startOfMonth, endOfMonth) &
              tbl.isDeleted.equals(0)))
        .get();
  }

  Future<int> insertIncome(IncomesCompanion income) =>
      into(incomes).insert(income);

  Future<bool> updateIncome(IncomesCompanion income) =>
      update(incomes).replace(income);

  Future<int> deleteIncome(String id, {String? deletedBy}) {
    final now = DateTime.now();
    return _softDeleteWhere(
      tableName: 'incomes',
      whereClause: 'id = ?',
      whereArgs: [Variable<String>(id)],
      now: now,
      deletedBy: deletedBy,
    );
  }

  Future<int> softDeleteIncomesForRoom(String roomId, {String? deletedBy}) {
    final now = DateTime.now();
    return _softDeleteWhere(
      tableName: 'incomes',
      whereClause: 'room_id = ?',
      whereArgs: [Variable<String>(roomId)],
      now: now,
      deletedBy: deletedBy,
    );
  }

  Future<int> softDeleteIncomesForVillaOrRooms({
    required String villaId,
    required Set<String> roomIds,
    String? deletedBy,
  }) {
    final now = DateTime.now();
    final placeholders = roomIds.map((_) => '?').join(', ');
    return _softDeleteWhere(
      tableName: 'incomes',
      whereClause: roomIds.isEmpty
          ? 'villa_id = ?'
          : 'villa_id = ? OR room_id IN ($placeholders)',
      whereArgs: [
        Variable<String>(villaId),
        for (final roomId in roomIds) Variable<String>(roomId),
      ],
      now: now,
      deletedBy: deletedBy,
    );
  }

  // Expense Queries
  Future<List<Expense>> getAllExpenses() =>
      (select(expenses)..where((tbl) => tbl.isDeleted.equals(0))).get();

  Stream<List<Expense>> watchAllExpenses() =>
      (select(expenses)..where((tbl) => tbl.isDeleted.equals(0))).watch();

  Future<List<Expense>> getExpensesByVillaId(String villaId) =>
      (select(expenses)
            ..where(
              (tbl) => tbl.villaId.equals(villaId) & tbl.isDeleted.equals(0),
            ))
          .get();

  Future<List<Expense>> getExpensesByMonth(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);
    return (select(expenses)
          ..where((tbl) =>
              tbl.expenseDate.isBetweenValues(startOfMonth, endOfMonth) &
              tbl.isDeleted.equals(0)))
        .get();
  }

  Future<int> insertExpense(ExpensesCompanion expense) =>
      into(expenses).insert(expense);

  Future<bool> updateExpense(ExpensesCompanion expense) =>
      update(expenses).replace(expense);

  Future<int> deleteExpense(String id, {String? deletedBy}) {
    final now = DateTime.now();
    return _softDeleteWhere(
      tableName: 'expenses',
      whereClause: 'id = ?',
      whereArgs: [Variable<String>(id)],
      now: now,
      deletedBy: deletedBy,
    );
  }

  Future<int> softDeleteExpensesForRoom(String roomId, {String? deletedBy}) {
    final now = DateTime.now();
    return _softDeleteWhere(
      tableName: 'expenses',
      whereClause: 'room_id = ?',
      whereArgs: [Variable<String>(roomId)],
      now: now,
      deletedBy: deletedBy,
    );
  }

  Future<int> softDeleteExpensesForVillaOrRooms({
    required String villaId,
    required Set<String> roomIds,
    String? deletedBy,
  }) {
    final now = DateTime.now();
    final placeholders = roomIds.map((_) => '?').join(', ');
    return _softDeleteWhere(
      tableName: 'expenses',
      whereClause: roomIds.isEmpty
          ? 'villa_id = ?'
          : 'villa_id = ? OR room_id IN ($placeholders)',
      whereArgs: [
        Variable<String>(villaId),
        for (final roomId in roomIds) Variable<String>(roomId),
      ],
      now: now,
      deletedBy: deletedBy,
    );
  }

  Future<int> _softDeleteWhere({
    required String tableName,
    required String whereClause,
    required List<Variable> whereArgs,
    required DateTime now,
    required String? deletedBy,
  }) {
    late final Set<ResultSetImplementation<dynamic, dynamic>> updatedTables;
    switch (tableName) {
      case 'villas':
        updatedTables = {villas};
      case 'rooms':
        updatedTables = {rooms};
      case 'incomes':
        updatedTables = {incomes};
      case 'expenses':
        updatedTables = {expenses};
      default:
        throw ArgumentError('Unknown table: $tableName');
    }

    return customUpdate(
      '''
      UPDATE $tableName
      SET is_deleted = 1,
          sync_status = 'pending',
          deleted_at = ?,
          deleted_by = ?,
          updated_at = ?,
          updated_by = ?
      WHERE $whereClause
      ''',
      variables: [
        Variable<DateTime>(now),
        Variable<String>(deletedBy),
        Variable<DateTime>(now),
        Variable<String>(deletedBy),
        ...whereArgs,
      ],
      updates: updatedTables,
    );
  }

  // Dashboard Queries
  Future<double> getTotalIncomeForMonth(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);
    final result = await (select(incomes)
          ..where((tbl) =>
              tbl.paymentDate.isBetweenValues(startOfMonth, endOfMonth) &
              tbl.isDeleted.equals(0)))
        .map((r) => r.amount)
        .get();
    return result.fold<double>(0, (sum, amount) => sum + amount);
  }

  Future<double> getTotalExpenseForMonth(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);
    final result = await (select(expenses)
          ..where((tbl) =>
              tbl.expenseDate.isBetweenValues(startOfMonth, endOfMonth) &
              tbl.isDeleted.equals(0)))
        .map((r) => r.amount)
        .get();
    return result.fold<double>(0, (sum, amount) => sum + amount);
  }

  Future<Map<String, double>> getExpensesByCategory(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);
    final expenseList = await (select(expenses)
          ..where((tbl) =>
              tbl.expenseDate.isBetweenValues(startOfMonth, endOfMonth) &
              tbl.isDeleted.equals(0)))
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
              tbl.paymentDate.isBetweenValues(startOfMonth, endOfMonth) &
              tbl.isDeleted.equals(0)))
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

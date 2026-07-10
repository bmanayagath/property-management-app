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
  TextColumn get orgId => text().withDefault(const Constant('default_org'))();
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
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get mapAddress => text().nullable()();
  TextColumn get googleMapsUrl => text().nullable()();
  TextColumn get wazeUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Room Table
class Rooms extends Table {
  TextColumn get id => text()();
  TextColumn get orgId => text().withDefault(const Constant('default_org'))();
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
  TextColumn get depositType => text().withDefault(const Constant('None'))();
  RealColumn get depositAmount => real().withDefault(const Constant(0))();
  DateTimeColumn get depositDate => dateTime().nullable()();
  TextColumn get depositStatus => text().withDefault(const Constant('Held'))();
  TextColumn get depositNotes => text().withDefault(const Constant(''))();
  TextColumn get depositIncomeId => text().withDefault(const Constant(''))();
  TextColumn get depositRefundExpenseId =>
      text().withDefault(const Constant(''))();
  DateTimeColumn get moveInDate => dateTime().nullable()();
  DateTimeColumn get moveOutDate => dateTime().nullable()();
  TextColumn get lastTenantName => text().withDefault(const Constant(''))();
  TextColumn get lastTenantPhone => text().withDefault(const Constant(''))();
  RealColumn get refundAmount => real().withDefault(const Constant(0))();
  RealColumn get retainedAmount => real().withDefault(const Constant(0))();
  TextColumn get depositReason => text().withDefault(const Constant(''))();
  TextColumn get tenantHistoryJson =>
      text().withDefault(const Constant('[]'))();

  @override
  Set<Column> get primaryKey => {id};
}

// Income Table
class Incomes extends Table {
  TextColumn get id => text()();
  TextColumn get orgId => text().withDefault(const Constant('default_org'))();
  TextColumn get villaId => text().references(Villas, #id)();
  TextColumn get villaName => text().withDefault(const Constant(''))();
  TextColumn get roomId => text().withDefault(const Constant(''))();
  TextColumn get roomName => text().withDefault(const Constant(''))();
  TextColumn get tenantName => text().withDefault(const Constant(''))();
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
  TextColumn get orgId => text().withDefault(const Constant('default_org'))();
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

class AppLogs extends Table {
  TextColumn get id => text()();
  TextColumn get timestamp => text()();
  TextColumn get category => text()();
  TextColumn get level => text()();
  TextColumn get screenName => text().named('screen_name')();
  TextColumn get operation => text()();
  TextColumn get message => text()();
  TextColumn get details => text().withDefault(const Constant(''))();
  TextColumn get stackTrace =>
      text().named('stack_trace').withDefault(const Constant(''))();
  TextColumn get userId =>
      text().named('user_id').withDefault(const Constant(''))();
  TextColumn get userEmail =>
      text().named('user_email').withDefault(const Constant(''))();
  TextColumn get devicePlatform =>
      text().named('device_platform').withDefault(const Constant(''))();
  TextColumn get appVersion =>
      text().named('app_version').withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Villas, Rooms, Incomes, Expenses, AppLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 9;

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
          if (from < 5) {
            await _addVillaLocationColumns();
          }
          if (from < 6) {
            await migrator.createTable(appLogs);
          }
          if (from < 7) {
            await migrator.addColumn(rooms, rooms.depositType);
            await migrator.addColumn(rooms, rooms.depositAmount);
            await migrator.addColumn(rooms, rooms.depositDate);
            await migrator.addColumn(rooms, rooms.depositStatus);
            await migrator.addColumn(rooms, rooms.depositNotes);
            await migrator.addColumn(rooms, rooms.moveOutDate);
            await migrator.addColumn(rooms, rooms.lastTenantName);
            await migrator.addColumn(rooms, rooms.lastTenantPhone);
            await migrator.addColumn(rooms, rooms.refundAmount);
            await migrator.addColumn(rooms, rooms.retainedAmount);
            await migrator.addColumn(rooms, rooms.depositReason);
            await migrator.addColumn(rooms, rooms.tenantHistoryJson);
          }
          if (from < 8) {
            await migrator.addColumn(rooms, rooms.depositIncomeId);
            await migrator.addColumn(rooms, rooms.depositRefundExpenseId);
            await migrator.addColumn(rooms, rooms.moveInDate);
            await migrator.addColumn(incomes, incomes.tenantName);
          }
          if (from < 9) {
            await _addOrgColumns();
          }
        },
      );

  Future<void> _addOrgColumns() async {
    await _addColumnIfMissingSql(
        'villas', 'org_id', "TEXT NOT NULL DEFAULT 'default_org'");
    await _addColumnIfMissingSql(
        'rooms', 'org_id', "TEXT NOT NULL DEFAULT 'default_org'");
    await _addColumnIfMissingSql(
        'incomes', 'org_id', "TEXT NOT NULL DEFAULT 'default_org'");
    await _addColumnIfMissingSql(
        'expenses', 'org_id', "TEXT NOT NULL DEFAULT 'default_org'");
  }

  Future<void> _addVillaLocationColumns() async {
    await _addColumnIfMissingSql('villas', 'latitude', 'REAL');
    await _addColumnIfMissingSql('villas', 'longitude', 'REAL');
    await _addColumnIfMissingSql('villas', 'map_address', 'TEXT');
    await _addColumnIfMissingSql('villas', 'google_maps_url', 'TEXT');
    await _addColumnIfMissingSql('villas', 'waze_url', 'TEXT');
  }

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

    await _addColumnIfMissingSql(
        'rooms', 'is_deleted', 'INTEGER NOT NULL DEFAULT 0');
    await _addColumnIfMissingSql(
        'rooms', 'sync_status', "TEXT NOT NULL DEFAULT 'pending'");
    await _addColumnIfMissingSql('rooms', 'deleted_at', 'INTEGER');
    await _addColumnIfMissingSql('rooms', 'deleted_by', 'TEXT');
    await _addColumnIfMissingSql('rooms', 'created_by', 'TEXT');
    await _addColumnIfMissingSql('rooms', 'updated_by', 'TEXT');
    await _addColumnIfMissingSql('rooms', 'last_synced_at', 'INTEGER');

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

  Future<List<Villa>> getAllVillas({String orgId = 'default_org'}) =>
      (select(villas)
            ..where(
              (tbl) => tbl.isDeleted.equals(0) & tbl.orgId.equals(orgId),
            ))
          .get();

  Stream<List<Villa>> watchAllVillas({String orgId = 'default_org'}) =>
      (select(villas)
            ..where(
              (tbl) => tbl.isDeleted.equals(0) & tbl.orgId.equals(orgId),
            ))
          .watch();

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
    return _deleteVillaCascade(id, deletedBy);
  }

  Future<void> deleteVillaCascade(String villaId, String currentUserId) {
    return _deleteVillaCascade(villaId, currentUserId);
  }

  Future<void> _deleteVillaCascade(String villaId, String? currentUserId) {
    return transaction(() async {
      final villa = await getVillaById(villaId);
      if (villa == null) return;

      final now = DateTime.now();
      final childRooms = await (select(rooms)
            ..where((tbl) => tbl.villaId.equals(villaId)))
          .get();
      final roomIds = childRooms.map((room) => room.id).toSet();

      await _softDeleteWhere(
        tableName: 'villas',
        whereClause: 'id = ?',
        whereArgs: [Variable<String>(villaId)],
        now: now,
        deletedBy: currentUserId,
      );

      await _softDeleteWhere(
        tableName: 'rooms',
        whereClause: 'villa_id = ?',
        whereArgs: [Variable<String>(villaId)],
        now: now,
        deletedBy: currentUserId,
      );

      final placeholders = roomIds.map((_) => '?').join(', ');
      final linkedRecordWhereClause = roomIds.isEmpty
          ? 'villa_id = ?'
          : 'villa_id = ? OR room_id IN ($placeholders)';
      final linkedRecordWhereArgs = [
        Variable<String>(villaId),
        for (final roomId in roomIds) Variable<String>(roomId),
      ];

      await _softDeleteWhere(
        tableName: 'incomes',
        whereClause: linkedRecordWhereClause,
        whereArgs: linkedRecordWhereArgs,
        now: now,
        deletedBy: currentUserId,
      );

      await _softDeleteWhere(
        tableName: 'expenses',
        whereClause: linkedRecordWhereClause,
        whereArgs: linkedRecordWhereArgs,
        now: now,
        deletedBy: currentUserId,
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

  Future<List<Room>> getAllRooms({String orgId = 'default_org'}) {
    final query = select(rooms).join([
      innerJoin(villas, villas.id.equalsExp(rooms.villaId)),
    ])
      ..where(
        rooms.isDeleted.equals(0) &
            rooms.orgId.equals(orgId) &
            villas.isDeleted.equals(0) &
            villas.orgId.equals(orgId),
      );
    return query.map((row) => row.readTable(rooms)).get();
  }

  Stream<List<Room>> watchAllRooms({String orgId = 'default_org'}) {
    final query = select(rooms).join([
      innerJoin(villas, villas.id.equalsExp(rooms.villaId)),
    ])
      ..where(
        rooms.isDeleted.equals(0) &
            rooms.orgId.equals(orgId) &
            villas.isDeleted.equals(0) &
            villas.orgId.equals(orgId),
      );
    return query.map((row) => row.readTable(rooms)).watch();
  }

  Future<int> cleanupOrphanRecords({String? deletedBy}) {
    return transaction(() async {
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

      await cleanupOrphanRooms(deletedBy: deletedBy);
      await cleanupOrphanIncome(deletedBy: deletedBy);
      await cleanupOrphanExpenses(deletedBy: deletedBy);
      return orphanRoomIds.length;
    });
  }

  Future<int> cleanupOrphanRooms({String? deletedBy}) async {
    final now = DateTime.now();
    return customUpdate(
      '''
      UPDATE rooms
      SET is_deleted = 1,
          sync_status = 'pending',
          deleted_at = ?,
          deleted_by = ?,
          updated_at = ?,
          updated_by = ?
      WHERE is_deleted = 0
        AND NOT EXISTS (
          SELECT 1
          FROM villas v
          WHERE v.id = rooms.villa_id
            AND v.is_deleted = 0
        )
      ''',
      variables: [
        Variable<DateTime>(now),
        Variable<String>(deletedBy),
        Variable<DateTime>(now),
        Variable<String>(deletedBy),
      ],
      updates: {rooms},
    );
  }

  Future<int> cleanupOrphanIncome({String? deletedBy}) async {
    final now = DateTime.now();
    return customUpdate(
      '''
      UPDATE incomes
      SET is_deleted = 1,
          sync_status = 'pending',
          deleted_at = ?,
          deleted_by = ?,
          updated_at = ?,
          updated_by = ?
      WHERE is_deleted = 0
        AND (
          NOT EXISTS (
            SELECT 1
            FROM villas v
            WHERE v.id = incomes.villa_id
              AND v.is_deleted = 0
          )
          OR (
            room_id <> ''
            AND NOT EXISTS (
              SELECT 1
              FROM rooms r
              WHERE r.id = incomes.room_id
                AND r.is_deleted = 0
            )
          )
        )
      ''',
      variables: [
        Variable<DateTime>(now),
        Variable<String>(deletedBy),
        Variable<DateTime>(now),
        Variable<String>(deletedBy),
      ],
      updates: {incomes},
    );
  }

  Future<int> cleanupOrphanExpenses({String? deletedBy}) async {
    final now = DateTime.now();
    return customUpdate(
      '''
      UPDATE expenses
      SET is_deleted = 1,
          sync_status = 'pending',
          deleted_at = ?,
          deleted_by = ?,
          updated_at = ?,
          updated_by = ?
      WHERE is_deleted = 0
        AND (
          (
            villa_id IS NOT NULL
            AND villa_id <> ''
            AND NOT EXISTS (
              SELECT 1
              FROM villas v
              WHERE v.id = expenses.villa_id
                AND v.is_deleted = 0
            )
          )
          OR (
            room_id IS NOT NULL
            AND room_id <> ''
            AND NOT EXISTS (
              SELECT 1
              FROM rooms r
              WHERE r.id = expenses.room_id
                AND r.is_deleted = 0
            )
          )
        )
      ''',
      variables: [
        Variable<DateTime>(now),
        Variable<String>(deletedBy),
        Variable<DateTime>(now),
        Variable<String>(deletedBy),
      ],
      updates: {expenses},
    );
  }

  Future<int> cleanupDeletedAndOrphanRooms({String? deletedBy}) {
    return cleanupOrphanRecords(deletedBy: deletedBy);
  }

  Future<Room?> getRoomById(String id) =>
      (select(rooms)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<List<Room>> getRoomsByVillaId(
    String villaId, {
    String orgId = 'default_org',
  }) =>
      (select(rooms)
            ..where(
              (tbl) =>
                  tbl.villaId.equals(villaId) &
                  tbl.orgId.equals(orgId) &
                  tbl.isDeleted.equals(0) &
                  existsQuery(
                    selectOnly(villas)
                      ..addColumns([villas.id])
                      ..where(
                        villas.id.equals(villaId) &
                            villas.orgId.equals(orgId) &
                            villas.isDeleted.equals(0),
                      ),
                  ),
            ))
          .get();

  Stream<List<Room>> watchRoomsByVillaId(
    String villaId, {
    String orgId = 'default_org',
  }) =>
      (select(rooms)
            ..where(
              (tbl) =>
                  tbl.villaId.equals(villaId) &
                  tbl.orgId.equals(orgId) &
                  tbl.isDeleted.equals(0) &
                  existsQuery(
                    selectOnly(villas)
                      ..addColumns([villas.id])
                      ..where(
                        villas.id.equals(villaId) &
                            villas.orgId.equals(orgId) &
                            villas.isDeleted.equals(0),
                      ),
                  ),
            ))
          .watch();

  Stream<List<Room>> watchActiveRoomsByVilla(
    String villaId, {
    String orgId = 'default_org',
  }) {
    return (select(rooms)
          ..where(
            (tbl) =>
                tbl.villaId.equals(villaId) &
                tbl.orgId.equals(orgId) &
                tbl.isDeleted.equals(0),
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

  Future<void> deleteRoomCascade(String roomId, String currentUserId) {
    return deleteRoom(roomId, deletedBy: currentUserId);
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
  Future<List<Income>> getAllIncomes({String orgId = 'default_org'}) =>
      (select(incomes)
            ..where(
              (tbl) => tbl.isDeleted.equals(0) & tbl.orgId.equals(orgId),
            ))
          .get();

  Stream<List<Income>> watchAllIncomes({
    String orgId = 'default_org',
    bool includeDeleted = false,
  }) {
    final query = select(incomes)
      ..where((tbl) {
        final orgFilter = tbl.orgId.equals(orgId);
        if (includeDeleted) return orgFilter;
        return tbl.isDeleted.equals(0) & orgFilter;
      });
    return query.watch();
  }

  Future<List<Income>> getIncomesByVillaId(
    String villaId, {
    String orgId = 'default_org',
  }) =>
      (select(incomes)
            ..where(
              (tbl) =>
                  tbl.villaId.equals(villaId) &
                  tbl.orgId.equals(orgId) &
                  tbl.isDeleted.equals(0),
            ))
          .get();

  Future<List<Income>> getIncomesByMonth(
    DateTime month, {
    String orgId = 'default_org',
  }) async {
    final rows = await getAllIncomes(orgId: orgId);
    return rows.where((income) {
      if (!_isCountableIncomeType(income.incomeType)) return false;
      final date = _isRentIncomeType(income.incomeType)
          ? income.monthCovered
          : income.paymentDate;
      return _isSameMonth(date, month);
    }).toList();
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
  Future<List<Expense>> getAllExpenses({String orgId = 'default_org'}) =>
      (select(expenses)
            ..where(
              (tbl) => tbl.isDeleted.equals(0) & tbl.orgId.equals(orgId),
            ))
          .get();

  Stream<List<Expense>> watchAllExpenses({
    String orgId = 'default_org',
    bool includeDeleted = false,
  }) {
    final query = select(expenses)
      ..where((tbl) {
        final orgFilter = tbl.orgId.equals(orgId);
        if (includeDeleted) return orgFilter;
        return tbl.isDeleted.equals(0) & orgFilter;
      });
    return query.watch();
  }

  Future<List<Expense>> getExpensesByVillaId(
    String villaId, {
    String orgId = 'default_org',
  }) =>
      (select(expenses)
            ..where(
              (tbl) =>
                  tbl.villaId.equals(villaId) &
                  tbl.orgId.equals(orgId) &
                  tbl.isDeleted.equals(0),
            ))
          .get();

  Future<List<Expense>> getExpensesByMonth(
    DateTime month, {
    String orgId = 'default_org',
  }) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = _endOfMonth(month);
    return (select(expenses)
          ..where((tbl) =>
              tbl.expenseDate.isBetweenValues(startOfMonth, endOfMonth) &
              tbl.orgId.equals(orgId) &
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
  Future<double> getTotalIncomeForMonth(
    DateTime month, {
    String orgId = 'default_org',
  }) async {
    final result = await getIncomesByMonth(month, orgId: orgId);
    return result.fold<double>(0, (sum, income) => sum + income.amount);
  }

  Future<double> getTotalExpenseForMonth(
    DateTime month, {
    String orgId = 'default_org',
  }) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = _endOfMonth(month);
    final result = await (select(expenses)
          ..where((tbl) =>
              tbl.expenseDate.isBetweenValues(startOfMonth, endOfMonth) &
              tbl.orgId.equals(orgId) &
              tbl.isDeleted.equals(0)))
        .map((r) => r.amount)
        .get();
    return result.fold<double>(0, (sum, amount) => sum + amount);
  }

  Future<Map<String, double>> getExpensesByCategory(
    DateTime month, {
    String orgId = 'default_org',
  }) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = _endOfMonth(month);
    final expenseList = await (select(expenses)
          ..where((tbl) =>
              tbl.expenseDate.isBetweenValues(startOfMonth, endOfMonth) &
              tbl.orgId.equals(orgId) &
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

  Future<Map<String, double>> getIncomeByVillaSummary(
    DateTime month, {
    String orgId = 'default_org',
  }) async {
    final incomeList = await getIncomesByMonth(month, orgId: orgId);

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

  bool _isCountableIncomeType(String type) {
    final normalized = _normalizeIncomeType(type);
    return normalized == 'rent' ||
        normalized == 'maintenancecharge' ||
        normalized == 'penalty' ||
        normalized == 'other';
  }

  bool _isRentIncomeType(String type) {
    return _normalizeIncomeType(type) == 'rent';
  }

  bool _isSameMonth(DateTime date, DateTime month) {
    return date.year == month.year && date.month == month.month;
  }

  String _normalizeIncomeType(String type) {
    return type.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  DateTime _endOfMonth(DateTime month) {
    return DateTime(month.year, month.month + 1, 1)
        .subtract(const Duration(milliseconds: 1));
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

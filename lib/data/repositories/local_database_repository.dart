import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/app_notification.dart';
import '../../domain/models/app_user.dart';
import '../../domain/models/expense.dart' as domain;
import '../../domain/models/income.dart' as domain;
import '../../domain/models/room.dart' as domain;
import '../../domain/models/villa_model.dart';
import '../local/database.dart' as db;

class LocalDatabaseRepository {
  static const _notificationsKey = 'villabooks_notifications';
  static const _usersKey = 'villabooks_users';

  final db.AppDatabase database;

  const LocalDatabaseRepository(this.database);

  Future<List<PendingDeleteRecord>> getPendingDeleteRecords() async {
    final records = <PendingDeleteRecord>[];
    for (final collection in ['villas', 'rooms', 'incomes', 'expenses']) {
      final rows = await database.customSelect(
        '''
        SELECT id, deleted_at, deleted_by, updated_at
        FROM $collection
        WHERE is_deleted = 1 AND sync_status = 'pending'
        ''',
      ).get();
      records.addAll(
        rows.map(
          (row) => PendingDeleteRecord(
            collection: collection,
            id: row.read<String>('id'),
            deletedAt: row.readNullable<DateTime>('deleted_at'),
            deletedBy: row.readNullable<String>('deleted_by'),
            updatedAt: row.readNullable<DateTime>('updated_at'),
          ),
        ),
      );
    }
    return records;
  }

  Future<int> getPendingDeleteCount() async {
    final records = await getPendingDeleteRecords();
    return records.length;
  }

  Future<void> markSyncRecordSynced({
    required String collection,
    required String id,
  }) async {
    if (!{'villas', 'rooms', 'incomes', 'expenses'}.contains(collection)) {
      return;
    }

    await database.customUpdate(
      '''
      UPDATE $collection
      SET sync_status = 'synced',
          last_synced_at = ?
      WHERE id = ?
      ''',
      variables: [
        Variable<DateTime>(DateTime.now()),
        Variable<String>(id),
      ],
    );
  }

  Future<void> markRecordDeletedFromCloud({
    required String collection,
    required String id,
    DateTime? deletedAt,
    String? deletedBy,
  }) async {
    final now = DateTime.now();
    late final Set<ResultSetImplementation<dynamic, dynamic>> updatedTables;
    switch (collection) {
      case 'villas':
        updatedTables = {database.villas};
      case 'rooms':
        updatedTables = {database.rooms};
      case 'incomes':
        updatedTables = {database.incomes};
      case 'expenses':
        updatedTables = {database.expenses};
      default:
        updatedTables = const {};
    }
    await database.customUpdate(
      '''
      UPDATE $collection
      SET is_deleted = 1,
          sync_status = 'synced',
          deleted_at = ?,
          deleted_by = ?,
          updated_at = ?,
          last_synced_at = ?
      WHERE id = ?
      ''',
      variables: [
        Variable<DateTime>(deletedAt ?? now),
        Variable<String>(deletedBy),
        Variable<DateTime>(deletedAt ?? now),
        Variable<DateTime>(now),
        Variable<String>(id),
      ],
      updates: updatedTables,
    );
  }

  Future<void> upsertVilla(VillaModel villa) async {
    final existing = await database.getVillaById(villa.id);
    final now = DateTime.now();
    final createdAt = villa.createdAt;
    final updatedAt = villa.updatedAt ?? createdAt;
    if (_hasPendingLocalChange(
      syncStatus: existing?.syncStatus,
      localUpdatedAt: existing?.updatedAt,
      remoteUpdatedAt: updatedAt,
    )) {
      return;
    }

    final companion = db.VillasCompanion(
      id: Value(villa.id),
      orgId: Value(villa.orgId),
      villaName: Value(villa.villaName),
      villaNumber: Value(villa.villaNumber),
      location: Value(villa.location),
      notes: Value(villa.notes),
      tenantName: Value(existing?.tenantName ?? ''),
      tenantPhone: Value(existing?.tenantPhone ?? ''),
      monthlyRent: Value(existing?.monthlyRent ?? 0),
      contractStartDate: Value(existing?.contractStartDate ?? now),
      contractEndDate: Value(existing?.contractEndDate ?? now),
      paymentDueDay: Value(existing?.paymentDueDay ?? 1),
      status: Value(existing?.status ?? 'vacant'),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(villa.isDeleted ? 1 : 0),
      syncStatus: Value(villa.syncStatus == 'pending' ? 'pending' : 'synced'),
      deletedAt: Value(villa.deletedAt),
      deletedBy: Value(villa.deletedBy),
      createdBy: Value(villa.createdBy),
      updatedBy: Value(villa.updatedBy),
      lastSyncedAt: Value(DateTime.now()),
      latitude: Value(villa.latitude),
      longitude: Value(villa.longitude),
      mapAddress: Value(villa.mapAddress),
      googleMapsUrl: Value(villa.googleMapsUrl),
      wazeUrl: Value(villa.wazeUrl),
    );

    if (existing == null) {
      await database.insertVilla(companion);
    } else if (updatedAt.isAfter(existing.updatedAt) ||
        updatedAt.isAtSameMomentAs(existing.updatedAt)) {
      await database.updateVilla(companion);
    }
  }

  Future<void> upsertRoom(domain.Room room) async {
    final existing = await database.getRoomById(room.id);
    final remoteUpdatedAt = room.updatedAt ?? room.createdAt;

    if (_hasPendingLocalChange(
      syncStatus: existing?.syncStatus,
      localUpdatedAt: existing?.updatedAt,
      remoteUpdatedAt: remoteUpdatedAt,
    )) {
      return;
    }

    final companion = db.RoomsCompanion(
      id: Value(room.id),
      orgId: Value(room.orgId),
      villaId: Value(room.villaId),
      villaName: Value(room.villaName),
      roomName: Value(room.roomName),
      roomNumber: Value(room.roomNumber),
      tenantName: Value(room.tenantName.isEmpty ? null : room.tenantName),
      tenantPhone: Value(room.tenantPhone.isEmpty ? null : room.tenantPhone),
      monthlyRent: Value(room.monthlyRent),
      contractStartDate: Value(room.contractStartDate),
      contractEndDate: Value(room.contractEndDate),
      paymentDueDay: Value(room.paymentDueDay),
      status: Value(room.status),
      createdAt: Value(room.createdAt),
      updatedAt: Value(room.updatedAt),
      isDeleted: Value(room.isDeleted ? 1 : 0),
      syncStatus: Value(room.syncStatus == 'pending' ? 'pending' : 'synced'),
      deletedAt: Value(room.deletedAt),
      deletedBy: Value(room.deletedBy),
      createdBy: Value(room.createdBy),
      updatedBy: Value(room.updatedBy),
      lastSyncedAt: Value(DateTime.now()),
      depositType: Value(room.depositType),
      depositAmount: Value(room.depositAmount),
      depositDate: Value(room.depositDate),
      depositStatus: Value(room.depositStatus),
      depositNotes: Value(room.depositNotes),
      depositIncomeId: Value(room.depositIncomeId),
      depositRefundExpenseId: Value(room.depositRefundExpenseId),
      moveInDate: Value(room.moveInDate),
      moveOutDate: Value(room.moveOutDate),
      lastTenantName: Value(room.lastTenantName),
      lastTenantPhone: Value(room.lastTenantPhone),
      refundAmount: Value(room.refundAmount),
      retainedAmount: Value(room.retainedAmount),
      depositReason: Value(room.depositReason),
      tenantHistoryJson: Value(jsonEncode(
        room.tenantHistory.map((item) => item.toJson()).toList(),
      )),
    );

    if (existing == null) {
      await database.insertRoom(companion);
    } else {
      await database.updateRoom(companion);
    }
  }

  Future<void> upsertIncome(domain.Income income) async {
    final existing = await _getIncomeById(income.id);
    final remoteUpdatedAt = income.updatedAt ?? income.createdAt;
    if (_hasPendingLocalChange(
      syncStatus: existing?.syncStatus,
      localUpdatedAt: existing?.updatedAt,
      remoteUpdatedAt: remoteUpdatedAt,
    )) {
      return;
    }

    final companion = db.IncomesCompanion(
      id: Value(income.id),
      orgId: Value(income.orgId),
      villaId: Value(income.villaId),
      villaName: Value(income.villaName),
      roomId: Value(income.roomId),
      roomName: Value(income.roomName),
      tenantName: Value(income.tenantName),
      incomeType: Value(income.incomeType),
      amount: Value(income.amount),
      paymentDate: Value(income.paymentDate),
      paymentMethod: Value(income.paymentMethod),
      monthCovered: Value(income.monthCovered),
      notes: Value(income.notes),
      createdAt: Value(income.createdAt),
      updatedAt: Value(income.updatedAt),
      isDeleted: Value(income.isDeleted ? 1 : 0),
      syncStatus: Value(income.syncStatus == 'pending' ? 'pending' : 'synced'),
      deletedAt: Value(income.deletedAt),
      deletedBy: Value(income.deletedBy),
      createdBy: Value(income.createdBy),
      updatedBy: Value(income.updatedBy),
      lastSyncedAt: Value(DateTime.now()),
    );

    if (existing == null) {
      await database.insertIncome(companion);
    } else {
      await database.updateIncome(companion);
    }
  }

  Future<void> upsertExpense(domain.Expense expense) async {
    final existing = await _getExpenseById(expense.id);
    final remoteUpdatedAt = expense.updatedAt ?? expense.createdAt;
    if (_hasPendingLocalChange(
      syncStatus: existing?.syncStatus,
      localUpdatedAt: existing?.updatedAt,
      remoteUpdatedAt: remoteUpdatedAt,
    )) {
      return;
    }

    final companion = db.ExpensesCompanion(
      id: Value(expense.id),
      orgId: Value(expense.orgId),
      villaId: Value(expense.villaId),
      villaName: Value(expense.villaName),
      roomId: Value(expense.roomId),
      roomName: Value(expense.roomName),
      category: Value(expense.category),
      amount: Value(expense.amount),
      expenseDate: Value(expense.expenseDate),
      paidTo: Value(expense.paidTo),
      paymentMethod: Value(expense.paymentMethod),
      notes: Value(expense.notes),
      createdAt: Value(expense.createdAt),
      updatedAt: Value(expense.updatedAt),
      isDeleted: Value(expense.isDeleted ? 1 : 0),
      syncStatus: Value(expense.syncStatus == 'pending' ? 'pending' : 'synced'),
      deletedAt: Value(expense.deletedAt),
      deletedBy: Value(expense.deletedBy),
      createdBy: Value(expense.createdBy),
      updatedBy: Value(expense.updatedBy),
      lastSyncedAt: Value(DateTime.now()),
    );

    if (existing == null) {
      await database.insertExpense(companion);
    } else {
      await database.updateExpense(companion);
    }
  }

  Future<void> upsertNotification(AppNotification notification) async {
    final notifications = await _loadNotifications();
    final updated = [
      notification,
      for (final existing in notifications)
        if (existing.id != notification.id) existing,
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await _saveNotifications(updated);
  }

  Future<void> upsertUser(AppUser user) async {
    final users = await _loadUsers();
    final updated = [
      for (final existing in users)
        if (existing.id == user.id) user else existing,
      if (!users.any((existing) => existing.id == user.id)) user,
    ];
    await _saveUsers(updated);
  }

  Future<void> markRoomDeleted(String id) async {
    final existing = await database.getRoomById(id);
    if (existing == null) return;

    await database.updateRoom(
      existing
          .copyWith(
            isDeleted: 1,
            syncStatus: 'synced',
            lastSyncedAt: Value(DateTime.now()),
          )
          .toCompanion(true),
    );
  }

  Future<void> deleteVilla(String id, {String? deletedBy}) =>
      database.deleteVilla(id, deletedBy: deletedBy);
  Future<void> deleteRoom(String id, {String? deletedBy}) =>
      database.deleteRoom(id, deletedBy: deletedBy);
  Future<void> deleteVillaCascade(String villaId, String currentUserId) =>
      database.deleteVillaCascade(villaId, currentUserId);
  Future<void> deleteRoomCascade(String roomId, String currentUserId) =>
      database.deleteRoomCascade(roomId, currentUserId);
  Future<void> deleteIncome(String id, {String? deletedBy}) =>
      database.deleteIncome(id, deletedBy: deletedBy);
  Future<void> deleteExpense(String id, {String? deletedBy}) =>
      database.deleteExpense(id, deletedBy: deletedBy);

  Future<int> cleanupOrphanRecords({String? deletedBy}) {
    return database.cleanupOrphanRecords(deletedBy: deletedBy);
  }

  Future<int> cleanupOrphanRooms({String? deletedBy}) {
    return database.cleanupOrphanRooms(deletedBy: deletedBy);
  }

  Future<int> cleanupOrphanIncome({String? deletedBy}) {
    return database.cleanupOrphanIncome(deletedBy: deletedBy);
  }

  Future<int> cleanupOrphanExpenses({String? deletedBy}) {
    return database.cleanupOrphanExpenses(deletedBy: deletedBy);
  }

  Future<int> cleanupDeletedAndOrphanRooms({String? deletedBy}) {
    return database.cleanupDeletedAndOrphanRooms(deletedBy: deletedBy);
  }

  Future<db.Income?> _getIncomeById(String id) {
    return (database.select(database.incomes)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
  }

  Future<db.Expense?> _getExpenseById(String id) {
    return (database.select(database.expenses)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
  }

  bool _hasPendingLocalChange({
    required String? syncStatus,
    required DateTime? localUpdatedAt,
    required DateTime remoteUpdatedAt,
  }) {
    if (syncStatus != 'pending') return false;
    if (localUpdatedAt == null) return true;
    return !remoteUpdatedAt.isAfter(localUpdatedAt);
  }

  Future<List<AppNotification>> _loadNotifications() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_notificationsKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveNotifications(List<AppNotification> notifications) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      notifications.map((notification) => notification.toJson()).toList(),
    );
    await preferences.setString(_notificationsKey, encoded);
  }

  Future<List<AppUser>> _loadUsers() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_usersKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => AppUser.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveUsers(List<AppUser> users) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(users.map((user) => user.toJson()).toList());
    await preferences.setString(_usersKey, encoded);
  }
}

class PendingDeleteRecord {
  final String collection;
  final String id;
  final DateTime? deletedAt;
  final String? deletedBy;
  final DateTime? updatedAt;

  const PendingDeleteRecord({
    required this.collection,
    required this.id,
    required this.deletedAt,
    required this.deletedBy,
    required this.updatedAt,
  });
}

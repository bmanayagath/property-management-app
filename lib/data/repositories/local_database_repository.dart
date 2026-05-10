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

  Future<void> upsertVilla(VillaModel villa) async {
    final existing = await database.getVillaById(villa.id);
    final now = DateTime.now();
    final createdAt = villa.createdAt;
    final updatedAt = villa.updatedAt ?? createdAt;

    final companion = db.VillasCompanion(
      id: Value(villa.id),
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
      isDeleted: const Value(0),
      syncStatus: const Value('synced'),
      lastSyncedAt: Value(DateTime.now()),
    );

    if (existing == null) {
      await database.insertRoom(companion);
    } else {
      await database.updateRoom(companion);
    }
  }

  Future<void> upsertIncome(domain.Income income) async {
    final existing = await _getIncomeById(income.id);
    final companion = db.IncomesCompanion(
      id: Value(income.id),
      villaId: Value(income.villaId),
      villaName: Value(income.villaName),
      roomId: Value(income.roomId),
      roomName: Value(income.roomName),
      incomeType: Value(income.incomeType),
      amount: Value(income.amount),
      paymentDate: Value(income.paymentDate),
      paymentMethod: Value(income.paymentMethod),
      monthCovered: Value(income.monthCovered),
      notes: Value(income.notes),
      createdAt: Value(existing?.createdAt ?? DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    if (existing == null) {
      await database.insertIncome(companion);
    } else {
      await database.updateIncome(companion);
    }
  }

  Future<void> upsertExpense(domain.Expense expense) async {
    final existing = await _getExpenseById(expense.id);
    final companion = db.ExpensesCompanion(
      id: Value(expense.id),
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
      createdAt: Value(existing?.createdAt ?? DateTime.now()),
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

  Future<void> deleteVilla(String id) => database.deleteVilla(id);
  Future<void> deleteIncome(String id) => database.deleteIncome(id);
  Future<void> deleteExpense(String id) => database.deleteExpense(id);

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

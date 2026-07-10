import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/enums.dart';
import '../../data/local/database.dart' as db;
import '../../domain/models/expense.dart';
import '../../domain/models/expense_model.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/repositories/villa_repository.dart';
import 'active_org_provider.dart';
import 'auth_provider.dart';
import 'database_provider.dart';
import 'repository_provider.dart';
import 'sync_provider.dart';

final expenseListProvider = StreamProvider<List<Expense>>((ref) {
  final database = ref.watch(databaseProvider);
  final syncService = ref.watch(firebaseSyncServiceProvider);
  final orgId = ref.watch(activeOrgProvider);
  return _mergeExpenseStreams(
    localStream:
        database.watchAllExpenses(orgId: orgId, includeDeleted: true).map(
              (rows) => rows.map(_expenseFromRow).toList(),
            ),
    cloudStream: syncService.watchCloudExpenses(orgId: orgId),
    orgId: orgId,
  );
});

final expenseProvider =
    StateNotifierProvider<ExpenseNotifier, List<Expense>>((ref) {
  final expenseRepository = ref.watch(expenseRepositoryProvider);
  final villaRepository = ref.watch(villaRepositoryProvider);
  return ExpenseNotifier(
    expenseRepository: expenseRepository,
    villaRepository: villaRepository,
    ref: ref,
  );
});

class ExpenseNotifier extends StateNotifier<List<Expense>> {
  final ExpenseRepository _expenseRepository;
  final VillaRepository _villaRepository;
  final Ref _ref;

  ExpenseNotifier({
    required ExpenseRepository expenseRepository,
    required VillaRepository villaRepository,
    required Ref ref,
  })  : _expenseRepository = expenseRepository,
        _villaRepository = villaRepository,
        _ref = ref,
        super(const []) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    final expenseModels = await _expenseRepository.getAllExpenses();
    state = await Future.wait(expenseModels.map(_toExpense));
  }

  Future<void> addExpense(Expense expense) async {
    final id = expense.id.trim().isEmpty ? const Uuid().v4() : expense.id;
    final syncedExpense =
        expense.copyWith(id: id, orgId: _ref.read(activeOrgProvider));
    await _expenseRepository.addExpense(
      _toExpenseModel(syncedExpense),
    );
    await _queueExpenseSync(syncedExpense);
    await loadExpenses();
  }

  Future<void> updateExpense(Expense expense) async {
    final orgExpense = expense.copyWith(orgId: _ref.read(activeOrgProvider));
    await _expenseRepository.updateExpense(_toExpenseModel(orgExpense));
    await _queueExpenseSync(orgExpense);
    await loadExpenses();
  }

  Future<void> upsertExpense(Expense expense) async {
    final syncedExpense = expense.id.trim().isEmpty
        ? expense.copyWith(
            id: const Uuid().v4(),
            orgId: _ref.read(activeOrgProvider),
          )
        : expense.copyWith(orgId: _ref.read(activeOrgProvider));
    await _expenseRepository.upsertExpense(_toExpenseModel(syncedExpense));
    await _queueExpenseSync(syncedExpense);
    await loadExpenses();
  }

  Future<void> deleteExpense(String id) async {
    final currentUser = _ref.read(authProvider).currentUser;
    await _expenseRepository.deleteExpense(id, deletedBy: currentUser?.id);
    if (currentUser != null) {
      await _ref.read(firebaseSyncServiceProvider).queueDelete(
            collection: 'expenses',
            id: id,
            userId: currentUser.id,
          );
      await _ref.read(firebaseSyncServiceProvider).syncPendingDeletes();
      _ref.read(syncRefreshProvider.notifier).state++;
    }
    await loadExpenses();
  }

  double getTotalExpensesForMonth(DateTime month) {
    return state
        .where((expense) => _isSameMonth(expense.expenseDate, month))
        .fold<double>(0, (sum, expense) => sum + expense.amount);
  }

  List<Expense> getExpensesByVilla(String villaId) {
    return state.where((expense) => expense.villaId == villaId).toList();
  }

  List<Expense> getExpensesByCategory(String category) {
    return state.where((expense) => expense.category == category).toList();
  }

  Map<String, double> getTopExpenseCategories(DateTime month) {
    final totals = <String, double>{};

    for (final expense
        in state.where((expense) => _isSameMonth(expense.expenseDate, month))) {
      totals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    final sortedEntries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }

  Future<Expense> _toExpense(ExpenseModel model) async {
    final villa = model.villaId == null
        ? null
        : await _villaRepository.getVillaById(model.villaId!);

    return Expense(
      id: model.id,
      orgId: model.orgId,
      villaId: model.villaId,
      villaName: model.villaName.isNotEmpty
          ? model.villaName
          : villa?.villaName ?? 'General Expense',
      roomId: model.roomId,
      roomName: model.roomName,
      category: model.category.displayName,
      amount: model.amount,
      expenseDate: model.expenseDate,
      paidTo: model.paidTo,
      paymentMethod: _paymentMethodLabel(model.paymentMethod),
      notes: model.notes ?? '',
      createdAt: model.createdAt,
    );
  }

  ExpenseModel _toExpenseModel(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      orgId: expense.orgId,
      villaId: expense.villaId,
      villaName: expense.villaName,
      roomId: expense.roomId,
      roomName: expense.roomName,
      category: _expenseCategoryFromLabel(expense.category),
      amount: expense.amount,
      expenseDate: expense.expenseDate,
      paidTo: expense.paidTo,
      paymentMethod: _paymentMethodFromLabel(expense.paymentMethod),
      notes: expense.notes.trim().isEmpty ? null : expense.notes.trim(),
      createdAt: expense.createdAt,
    );
  }

  ExpenseCategory _expenseCategoryFromLabel(String label) {
    final normalized = _normalize(label);
    return ExpenseCategory.values.firstWhere(
      (category) => _normalize(category.displayName) == normalized,
      orElse: () => ExpenseCategory.other,
    );
  }

  PaymentMethod _paymentMethodFromLabel(String label) {
    switch (_normalize(label)) {
      case 'cash':
        return PaymentMethod.cash;
      case 'banktransfer':
      case 'transfer':
        return PaymentMethod.transfer;
      case 'card':
      case 'online':
        return PaymentMethod.online;
      case 'cheque':
      case 'check':
        return PaymentMethod.check;
      default:
        return PaymentMethod.other;
    }
  }

  String _paymentMethodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return ExpensePaymentMethods.cash;
      case PaymentMethod.transfer:
        return ExpensePaymentMethods.bankTransfer;
      case PaymentMethod.online:
        return ExpensePaymentMethods.card;
      case PaymentMethod.check:
        return ExpensePaymentMethods.cheque;
      case PaymentMethod.other:
        return ExpensePaymentMethods.other;
    }
  }

  static bool _isSameMonth(DateTime date, DateTime month) {
    return date.year == month.year && date.month == month.month;
  }

  static String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  Future<void> _queueExpenseSync(Expense expense) async {
    final currentUser = _ref.read(authProvider).currentUser;
    if (currentUser == null) return;

    await _ref.read(firebaseSyncServiceProvider).queueExpense(
          expense: expense,
          userId: currentUser.id,
        );
    _ref.read(syncRefreshProvider.notifier).state++;
  }
}

Stream<List<Expense>> _mergeExpenseStreams({
  required Stream<List<Expense>> localStream,
  required Stream<List<Expense>> cloudStream,
  required String orgId,
}) {
  late StreamController<List<Expense>> controller;
  StreamSubscription<List<Expense>>? localSubscription;
  StreamSubscription<List<Expense>>? cloudSubscription;
  var localExpenses = <Expense>[];
  var cloudExpenses = <Expense>[];

  void emitMerged() {
    final byId = <String, Expense>{};
    final locallyDeletedIds = <String>{};
    for (final expense in localExpenses) {
      if (expense.orgId != orgId) continue;
      if (expense.isDeleted) {
        locallyDeletedIds.add(expense.id);
        continue;
      }
      byId[expense.id] = _preferExpense(byId[expense.id], expense);
    }
    for (final expense in cloudExpenses) {
      if (expense.orgId != orgId) continue;
      if (expense.isDeleted) continue;
      if (locallyDeletedIds.contains(expense.id)) continue;
      byId[expense.id] = _preferExpense(byId[expense.id], expense);
    }

    final merged = byId.values.toList()
      ..sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
    controller.add(merged);
    debugPrint(
      '[ExpenseProvider] loaded local=${localExpenses.length}, cloud=${cloudExpenses.length}, merged=${merged.length}',
    );
  }

  controller = StreamController<List<Expense>>(
    onListen: () {
      localSubscription = localStream.listen(
        (expenses) {
          localExpenses = expenses;
          emitMerged();
        },
        onError: controller.addError,
      );

      cloudSubscription = cloudStream.listen(
        (expenses) {
          cloudExpenses = expenses;
          emitMerged();
        },
        onError: (error, stackTrace) {
          debugPrint('[ExpenseProvider] cloud expense stream failed: $error');
          emitMerged();
        },
      );
    },
    onCancel: () async {
      await localSubscription?.cancel();
      await cloudSubscription?.cancel();
    },
  );

  return controller.stream;
}

Expense _expenseFromRow(db.Expense row) {
  return Expense(
    id: row.id,
    orgId: row.orgId,
    villaId: row.villaId,
    villaName: row.villaName.trim().isEmpty
        ? row.villaId == null
            ? 'General Expense'
            : 'Villa ${row.villaId}'
        : row.villaName,
    roomId: row.roomId,
    roomName: row.roomName,
    category: _expenseCategoryLabel(row.category),
    amount: row.amount,
    expenseDate: row.expenseDate,
    paidTo: row.paidTo,
    paymentMethod: _paymentMethodLabelFromRaw(row.paymentMethod),
    notes: row.notes ?? '',
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    isDeleted: row.isDeleted == 1,
    syncStatus: row.syncStatus,
    deletedAt: row.deletedAt,
    deletedBy: row.deletedBy,
    createdBy: row.createdBy,
    updatedBy: row.updatedBy,
    lastSyncedAt: row.lastSyncedAt,
  );
}

String _expenseCategoryLabel(String value) {
  final normalized = _normalize(value);
  return ExpenseCategory.values
      .firstWhere(
        (category) =>
            category.name == value ||
            _normalize(category.displayName) == normalized,
        orElse: () => ExpenseCategory.other,
      )
      .displayName;
}

String _paymentMethodLabelFromRaw(String value) {
  switch (_normalize(value)) {
    case 'cash':
      return ExpensePaymentMethods.cash;
    case 'banktransfer':
    case 'transfer':
      return ExpensePaymentMethods.bankTransfer;
    case 'card':
    case 'online':
      return ExpensePaymentMethods.card;
    case 'cheque':
    case 'check':
      return ExpensePaymentMethods.cheque;
    default:
      return ExpensePaymentMethods.other;
  }
}

Expense _preferExpense(Expense? current, Expense incoming) {
  if (current == null) return incoming;
  if (current.syncStatus == 'pending' && incoming.syncStatus != 'pending') {
    return current;
  }
  if (incoming.syncStatus == 'pending' && current.syncStatus != 'pending') {
    return incoming;
  }

  final currentUpdatedAt = current.updatedAt ?? current.createdAt;
  final incomingUpdatedAt = incoming.updatedAt ?? incoming.createdAt;
  return incomingUpdatedAt.isAfter(currentUpdatedAt) ? incoming : current;
}

String _normalize(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/enums.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/expense_model.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/repositories/villa_repository.dart';
import 'auth_provider.dart';
import 'repository_provider.dart';
import 'sync_provider.dart';

final expenseListProvider = StreamProvider<List<Expense>>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  final syncService = ref.watch(firebaseSyncServiceProvider);
  return _mergeExpenseStreams(
    localStream: repository.watchAllExpenses().map(
          (models) => models.map(_expenseFromModel).toList(),
        ),
    cloudStream: syncService.watchCloudExpenses(),
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
    final syncedExpense = expense.copyWith(id: id);
    await _expenseRepository.addExpense(
      _toExpenseModel(syncedExpense),
    );
    await _queueExpenseSync(syncedExpense);
    await loadExpenses();
  }

  Future<void> updateExpense(Expense expense) async {
    await _expenseRepository.updateExpense(_toExpenseModel(expense));
    await _queueExpenseSync(expense);
    await loadExpenses();
  }

  Future<void> deleteExpense(String id) async {
    await _expenseRepository.deleteExpense(id);
    final currentUser = _ref.read(authProvider).currentUser;
    if (currentUser != null) {
      await _ref.read(firebaseSyncServiceProvider).queueDelete(
            collection: 'expenses',
            id: id,
            userId: currentUser.id,
          );
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
    );
  }

  ExpenseModel _toExpenseModel(Expense expense) {
    return ExpenseModel(
      id: expense.id,
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
      createdAt: DateTime.now(),
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

Expense _expenseFromModel(ExpenseModel model) {
  return Expense(
    id: model.id,
    villaId: model.villaId,
    villaName: model.villaName.isNotEmpty
        ? model.villaName
        : model.villaId == null
            ? 'General Expense'
            : 'Villa ${model.villaId}',
    roomId: model.roomId,
    roomName: model.roomName,
    category: model.category.displayName,
    amount: model.amount,
    expenseDate: model.expenseDate,
    paidTo: model.paidTo,
    paymentMethod: _paymentMethodLabel(model.paymentMethod),
    notes: model.notes ?? '',
  );
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

Stream<List<Expense>> _mergeExpenseStreams({
  required Stream<List<Expense>> localStream,
  required Stream<List<Expense>> cloudStream,
}) {
  late StreamController<List<Expense>> controller;
  StreamSubscription<List<Expense>>? localSubscription;
  StreamSubscription<List<Expense>>? cloudSubscription;
  var localExpenses = <Expense>[];
  var cloudExpenses = <Expense>[];

  void emitMerged() {
    final byId = <String, Expense>{};
    for (final expense in localExpenses) {
      byId[expense.id] = expense;
    }
    for (final expense in cloudExpenses) {
      byId[expense.id] = expense;
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

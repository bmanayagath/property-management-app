import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../domain/models/expense_model.dart';
import '../../domain/repositories/expense_repository.dart';
import '../local/database.dart';
import '../../core/constants/enums.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final AppDatabase database;
  final String orgId;

  ExpenseRepositoryImpl(this.database, {required this.orgId});

  @override
  Future<List<ExpenseModel>> getAllExpenses() async {
    final expenses = await database.getAllExpenses(orgId: orgId);
    return expenses.map((expense) => _mapToModel(expense)).toList();
  }

  @override
  Stream<List<ExpenseModel>> watchAllExpenses() {
    return database.watchAllExpenses(orgId: orgId).map(
          (expenses) => expenses.map(_mapToModel).toList(),
        );
  }

  @override
  Future<List<ExpenseModel>> getExpensesByVillaId(String villaId) async {
    final expenses = await database.getExpensesByVillaId(villaId, orgId: orgId);
    return expenses.map((expense) => _mapToModel(expense)).toList();
  }

  @override
  Future<List<ExpenseModel>> getExpensesByMonth(DateTime month) async {
    final expenses = await database.getExpensesByMonth(month, orgId: orgId);
    return expenses.map((expense) => _mapToModel(expense)).toList();
  }

  @override
  Future<String> addExpense(ExpenseModel expense) async {
    final id = expense.id.isEmpty ? const Uuid().v4() : expense.id;
    final now = DateTime.now();
    await database.insertExpense(
      ExpensesCompanion(
        id: Value(id),
        orgId: Value(orgId),
        villaId: Value(expense.villaId),
        villaName: Value(expense.villaName),
        roomId: Value(expense.roomId),
        roomName: Value(expense.roomName),
        category: Value(expense.category.name),
        amount: Value(expense.amount),
        expenseDate: Value(expense.expenseDate),
        paidTo: Value(expense.paidTo),
        paymentMethod: Value(expense.paymentMethod.name),
        notes: Value(expense.notes),
        createdAt: Value(now),
      ),
    );
    return id;
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    await database.updateExpense(
      ExpensesCompanion(
        id: Value(expense.id),
        orgId: Value(orgId),
        villaId: Value(expense.villaId),
        villaName: Value(expense.villaName),
        roomId: Value(expense.roomId),
        roomName: Value(expense.roomName),
        category: Value(expense.category.name),
        amount: Value(expense.amount),
        expenseDate: Value(expense.expenseDate),
        paidTo: Value(expense.paidTo),
        paymentMethod: Value(expense.paymentMethod.name),
        notes: Value(expense.notes),
      ),
    );
  }

  @override
  Future<void> upsertExpense(ExpenseModel expense) async {
    final now = DateTime.now();
    await database.into(database.expenses).insertOnConflictUpdate(
          ExpensesCompanion(
            id: Value(expense.id),
            orgId: Value(orgId),
            villaId: Value(expense.villaId),
            villaName: Value(expense.villaName),
            roomId: Value(expense.roomId),
            roomName: Value(expense.roomName),
            category: Value(expense.category.name),
            amount: Value(expense.amount),
            expenseDate: Value(expense.expenseDate),
            paidTo: Value(expense.paidTo),
            paymentMethod: Value(expense.paymentMethod.name),
            notes: Value(expense.notes),
            createdAt: Value(expense.createdAt),
            updatedAt: Value(now),
            isDeleted: const Value(0),
            syncStatus: const Value('pending'),
            deletedAt: const Value(null),
            deletedBy: const Value(null),
          ),
        );
  }

  @override
  Future<void> deleteExpense(String id, {String? deletedBy}) async {
    await database.deleteExpense(id, deletedBy: deletedBy);
  }

  @override
  Future<double> getTotalExpenseForMonth(DateTime month) {
    return database.getTotalExpenseForMonth(month, orgId: orgId);
  }

  @override
  Future<Map<String, double>> getExpensesByCategory(DateTime month) {
    return database.getExpensesByCategory(month, orgId: orgId);
  }

  ExpenseModel _mapToModel(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      orgId: expense.orgId,
      villaId: expense.villaId,
      villaName: expense.villaName,
      roomId: expense.roomId,
      roomName: expense.roomName,
      category: _parseExpenseCategory(expense.category),
      amount: expense.amount,
      expenseDate: expense.expenseDate,
      paidTo: expense.paidTo,
      paymentMethod: _parsePaymentMethod(expense.paymentMethod),
      notes: expense.notes,
      createdAt: expense.createdAt,
    );
  }

  ExpenseCategory _parseExpenseCategory(String category) {
    final normalized = _normalize(category);
    return ExpenseCategory.values.firstWhere(
      (e) => e.name == category || _normalize(e.displayName) == normalized,
      orElse: () => ExpenseCategory.other,
    );
  }

  PaymentMethod _parsePaymentMethod(String method) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name == method,
      orElse: () => PaymentMethod.other,
    );
  }

  String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}

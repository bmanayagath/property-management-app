import '../models/expense_model.dart';

abstract class ExpenseRepository {
  Future<List<ExpenseModel>> getAllExpenses();
  Stream<List<ExpenseModel>> watchAllExpenses();
  Future<List<ExpenseModel>> getExpensesByVillaId(String villaId);
  Future<List<ExpenseModel>> getExpensesByMonth(DateTime month);
  Future<String> addExpense(ExpenseModel expense);
  Future<void> updateExpense(ExpenseModel expense);
  Future<void> upsertExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id, {String? deletedBy});
  Future<double> getTotalExpenseForMonth(DateTime month);
  Future<Map<String, double>> getExpensesByCategory(DateTime month);
}

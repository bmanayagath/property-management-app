import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../domain/models/income_model.dart';
import '../../domain/repositories/income_repository.dart';
import '../local/database.dart';
import '../../core/constants/enums.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  final AppDatabase database;
  final String orgId;

  IncomeRepositoryImpl(this.database, {required this.orgId});

  @override
  Future<List<IncomeModel>> getAllIncomes() async {
    final incomes = await database.getAllIncomes(orgId: orgId);
    return incomes.map((income) => _mapToModel(income)).toList();
  }

  @override
  Future<List<IncomeModel>> getIncomesByVillaId(String villaId) async {
    final incomes = await database.getIncomesByVillaId(villaId, orgId: orgId);
    return incomes.map((income) => _mapToModel(income)).toList();
  }

  @override
  Future<List<IncomeModel>> getIncomesByMonth(DateTime month) async {
    final incomes = await database.getIncomesByMonth(month, orgId: orgId);
    return incomes.map((income) => _mapToModel(income)).toList();
  }

  @override
  Future<String> addIncome(IncomeModel income) async {
    final id = income.id.isEmpty ? const Uuid().v4() : income.id;
    final now = DateTime.now();
    await database.insertIncome(
      IncomesCompanion(
        id: Value(id),
        orgId: Value(orgId),
        villaId: Value(income.villaId),
        villaName: Value(income.villaName),
        roomId: Value(income.roomId),
        roomName: Value(income.roomName),
        incomeType: Value(income.incomeType.name),
        amount: Value(income.amount),
        paymentDate: Value(income.paymentDate),
        paymentMethod: Value(income.paymentMethod.name),
        monthCovered: Value(income.monthCovered),
        notes: Value(income.notes),
        createdAt: Value(now),
      ),
    );
    return id;
  }

  @override
  Future<void> updateIncome(IncomeModel income) async {
    await database.updateIncome(
      IncomesCompanion(
        id: Value(income.id),
        orgId: Value(orgId),
        villaId: Value(income.villaId),
        villaName: Value(income.villaName),
        roomId: Value(income.roomId),
        roomName: Value(income.roomName),
        incomeType: Value(income.incomeType.name),
        amount: Value(income.amount),
        paymentDate: Value(income.paymentDate),
        paymentMethod: Value(income.paymentMethod.name),
        monthCovered: Value(income.monthCovered),
        notes: Value(income.notes),
      ),
    );
  }

  @override
  Future<void> deleteIncome(String id, {String? deletedBy}) async {
    await database.deleteIncome(id, deletedBy: deletedBy);
  }

  @override
  Future<double> getTotalIncomeForMonth(DateTime month) {
    return database.getTotalIncomeForMonth(month, orgId: orgId);
  }

  @override
  Future<Map<String, double>> getIncomeByVillaSummary(DateTime month) {
    return database.getIncomeByVillaSummary(month, orgId: orgId);
  }

  IncomeModel _mapToModel(Income income) {
    return IncomeModel(
      id: income.id,
      orgId: income.orgId,
      villaId: income.villaId,
      villaName: income.villaName,
      roomId: income.roomId,
      roomName: income.roomName,
      incomeType: _parseIncomeType(income.incomeType),
      amount: income.amount,
      paymentDate: income.paymentDate,
      paymentMethod: _parsePaymentMethod(income.paymentMethod),
      monthCovered: income.monthCovered,
      notes: income.notes,
      createdAt: income.createdAt,
    );
  }

  IncomeType _parseIncomeType(String type) {
    return IncomeType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => IncomeType.other,
    );
  }

  PaymentMethod _parsePaymentMethod(String method) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name == method,
      orElse: () => PaymentMethod.other,
    );
  }
}

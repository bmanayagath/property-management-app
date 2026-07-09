import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../services/income_calculation_service.dart';
import '../../domain/models/income.dart';
import '../local/database.dart' as db;

class IncomeRepository {
  final db.AppDatabase database;
  final String orgId;
  static const _incomeCalculation = IncomeCalculationService();

  IncomeRepository(this.database, {required this.orgId});

  Future<List<Income>> getAllIncomes() async {
    final rows = await database.getAllIncomes(orgId: orgId);
    return rows.map(_mapRowToIncome).toList();
  }

  Stream<List<Income>> watchAllIncomes({bool includeDeleted = false}) {
    return database
        .watchAllIncomes(
          orgId: orgId,
          includeDeleted: includeDeleted,
        )
        .map(
          (rows) => rows.map(_mapRowToIncome).toList(),
        );
  }

  Future<void> addIncome(Income income) async {
    final now = DateTime.now();
    final id = income.id.trim().isEmpty ? const Uuid().v4() : income.id;

    await database.insertIncome(
      db.IncomesCompanion(
        id: Value(id),
        orgId: Value(orgId),
        villaId: Value(income.villaId),
        villaName: Value(income.villaName),
        roomId: Value(income.roomId),
        roomName: Value(income.roomName),
        tenantName: Value(income.tenantName),
        incomeType: Value(income.incomeType),
        amount: Value(income.amount),
        paymentDate: Value(income.paymentDate),
        paymentMethod: Value(income.paymentMethod),
        monthCovered: Value(_monthStart(income.monthCovered)),
        notes: Value(income.notes.trim().isEmpty ? null : income.notes.trim()),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> updateIncome(Income income) async {
    await database.updateIncome(
      db.IncomesCompanion(
        id: Value(income.id),
        orgId: Value(orgId),
        villaId: Value(income.villaId),
        villaName: Value(income.villaName),
        roomId: Value(income.roomId),
        roomName: Value(income.roomName),
        tenantName: Value(income.tenantName),
        incomeType: Value(income.incomeType),
        amount: Value(income.amount),
        paymentDate: Value(income.paymentDate),
        paymentMethod: Value(income.paymentMethod),
        monthCovered: Value(_monthStart(income.monthCovered)),
        notes: Value(income.notes.trim().isEmpty ? null : income.notes.trim()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteIncome(String id, {String? deletedBy}) {
    return database.deleteIncome(id, deletedBy: deletedBy);
  }

  Future<void> upsertIncome(Income income) async {
    final now = DateTime.now();
    await database.into(database.incomes).insertOnConflictUpdate(
          db.IncomesCompanion(
            id: Value(income.id),
            orgId: Value(orgId),
            villaId: Value(income.villaId),
            villaName: Value(income.villaName),
            roomId: Value(income.roomId),
            roomName: Value(income.roomName),
            tenantName: Value(income.tenantName),
            incomeType: Value(income.incomeType),
            amount: Value(income.amount),
            paymentDate: Value(income.paymentDate),
            paymentMethod: Value(income.paymentMethod),
            monthCovered: Value(_monthStart(income.monthCovered)),
            notes:
                Value(income.notes.trim().isEmpty ? null : income.notes.trim()),
            createdAt: Value(income.createdAt),
            updatedAt: Value(now),
            isDeleted: const Value(0),
            syncStatus: const Value('pending'),
            deletedAt: const Value(null),
            deletedBy: const Value(null),
          ),
        );
  }

  Future<List<Income>> getIncomesByVilla(String villaId) async {
    final rows = await database.getIncomesByVillaId(villaId, orgId: orgId);
    return rows.map(_mapRowToIncome).toList();
  }

  Future<double> getTotalIncomeForMonth(DateTime month) async {
    final incomes = await getIncomesForMonth(month);
    return _incomeCalculation.totalForMonth(incomes, month, orgId: orgId);
  }

  Future<List<Income>> getIncomesForMonth(DateTime month) async {
    final rows = await database.getAllIncomes(orgId: orgId);
    return _incomeCalculation.filterForMonthlyTotal(
      rows.map(_mapRowToIncome),
      month,
      orgId: orgId,
    );
  }

  Income _mapRowToIncome(db.Income row) {
    return Income(
      id: row.id,
      orgId: row.orgId,
      villaId: row.villaId,
      villaName:
          row.villaName.trim().isEmpty ? 'Villa ${row.villaId}' : row.villaName,
      roomId: row.roomId,
      roomName: row.roomName,
      tenantName: row.tenantName,
      incomeType: _incomeTypeLabel(row.incomeType),
      amount: row.amount,
      paymentDate: row.paymentDate,
      paymentMethod: _paymentMethodLabel(row.paymentMethod),
      monthCovered: _monthStart(row.monthCovered),
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

  String _incomeTypeLabel(String value) {
    switch (_normalize(value)) {
      case 'rent':
        return IncomeTypes.rent;
      case 'deposit':
        return IncomeTypes.deposit;
      case 'maintenancecharge':
        return IncomeTypes.maintenanceCharge;
      case 'penalty':
        return IncomeTypes.penalty;
      default:
        return IncomeTypes.other;
    }
  }

  String _paymentMethodLabel(String value) {
    switch (_normalize(value)) {
      case 'cash':
        return IncomePaymentMethods.cash;
      case 'banktransfer':
      case 'transfer':
        return IncomePaymentMethods.bankTransfer;
      case 'card':
      case 'online':
        return IncomePaymentMethods.card;
      case 'cheque':
      case 'check':
        return IncomePaymentMethods.cheque;
      default:
        return IncomePaymentMethods.other;
    }
  }

  static DateTime _monthStart(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}

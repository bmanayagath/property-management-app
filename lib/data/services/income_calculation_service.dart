import '../../domain/models/income.dart';

class IncomeCalculationService {
  const IncomeCalculationService();

  bool isValidIncomeType(String type) {
    switch (_normalize(type)) {
      case 'rent':
      case 'deposit':
      case 'maintenancecharge':
      case 'penalty':
      case 'other':
        return true;
      default:
        return false;
    }
  }

  bool isRentIncome(Income income) {
    return _normalize(income.incomeType) == 'rent';
  }

  bool isDepositIncome(Income income) {
    return _normalize(income.incomeType) == 'deposit';
  }

  bool isCountableIncomeType(String type) {
    return isValidIncomeType(type) && _normalize(type) != 'deposit';
  }

  bool matchesIncomeType(String type, String selectedType) {
    return _normalize(type) == _normalize(selectedType);
  }

  bool isInSelectedMonth(Income income, DateTime month) {
    final date =
        isRentIncome(income) ? income.monthCovered : income.paymentDate;
    return _isSameMonth(date, month);
  }

  bool shouldIncludeInTotal(
    Income income,
    DateTime month, {
    String? orgId,
  }) {
    if (income.isDeleted) return false;
    if (orgId != null && income.orgId != orgId) return false;
    if (!isCountableIncomeType(income.incomeType)) return false;
    return isInSelectedMonth(income, month);
  }

  List<Income> filterForMonthlyTotal(
    Iterable<Income> incomes,
    DateTime month, {
    String? orgId,
  }) {
    return incomes
        .where((income) => shouldIncludeInTotal(income, month, orgId: orgId))
        .toList();
  }

  double totalForMonth(
    Iterable<Income> incomes,
    DateTime month, {
    String? orgId,
  }) {
    return filterForMonthlyTotal(incomes, month, orgId: orgId)
        .fold<double>(0, (sum, income) => sum + income.amount);
  }

  bool _isSameMonth(DateTime date, DateTime month) {
    return date.year == month.year && date.month == month.month;
  }

  String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}

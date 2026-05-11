import '../../core/utils/currency_formatter.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/income.dart';
import '../../domain/models/room.dart';
import '../../domain/models/villa_model.dart';

class ValidationResult {
  final bool isValid;
  final String? message;
  final bool requiresConfirmation;

  const ValidationResult({
    required this.isValid,
    this.message,
    this.requiresConfirmation = false,
  });

  const ValidationResult.valid()
      : this(
          isValid: true,
        );

  const ValidationResult.invalid(String message)
      : this(
          isValid: false,
          message: message,
        );

  const ValidationResult.confirmation(String message)
      : this(
          isValid: true,
          message: message,
          requiresConfirmation: true,
        );
}

class BusinessValidationService {
  const BusinessValidationService();

  ValidationResult validateIncome({
    required Income income,
    required List<Income> existingIncomes,
    required List<VillaModel> villas,
    List<Room> rooms = const [],
    Income? originalIncome,
    DateTime? now,
  }) {
    final amountResult = _validatePositiveAmount(income.amount);
    if (!amountResult.isValid) return amountResult;

    if (income.incomeType.trim().isEmpty) {
      return const ValidationResult.invalid('Income type is required.');
    }
    if (income.paymentMethod.trim().isEmpty) {
      return const ValidationResult.invalid('Payment method is required.');
    }
    if (income.notes.length > 500) {
      return const ValidationResult.invalid(
        'Notes should not exceed 500 characters.',
      );
    }
    if (_isMoreThanMonthsInFuture(
        income.monthCovered, now ?? DateTime.now(), 3)) {
      return const ValidationResult.invalid(
        'Rent month covered cannot be more than 3 months in the future.',
      );
    }

    final selectedVilla =
        villas.where((villa) => villa.id == income.villaId).firstOrNull;
    if (_isRentIncome(income)) {
      if (income.villaId.trim().isEmpty || selectedVilla == null) {
        return const ValidationResult.invalid('Villa is required for rent.');
      }
      final selectedRoom =
          rooms.where((room) => room.id == income.roomId).firstOrNull;
      if (selectedRoom == null || selectedRoom.isDeleted) {
        return const ValidationResult.invalid(
            'Active room is required for rent.');
      }
      if (!selectedRoom.isOccupied) {
        return const ValidationResult.invalid(
          'Cannot add rent for a vacant room.',
        );
      }

      final duplicateRentResult = checkDuplicateRent(
        income: income,
        existingIncomes: existingIncomes,
        room: selectedRoom,
        originalIncome: originalIncome,
      );
      if (!duplicateRentResult.isValid) return duplicateRentResult;
    }

    if (_isDepositIncome(income)) {
      final hasExistingDeposit = existingIncomes.any(
        (existing) =>
            existing.id != originalIncome?.id &&
            existing.villaId == income.villaId &&
            _isDepositIncome(existing),
      );
      if (hasExistingDeposit) {
        return const ValidationResult.confirmation(
          'A deposit already exists for this villa. Do you still want to save?',
        );
      }
    }

    if (income.paymentDate.isAfter(_dateOnly(now ?? DateTime.now()))) {
      return const ValidationResult.confirmation(
        'Payment date is in the future. Do you still want to save?',
      );
    }

    return const ValidationResult.valid();
  }

  ValidationResult checkDuplicateRent({
    required Income income,
    required List<Income> existingIncomes,
    required Room room,
    Income? originalIncome,
  }) {
    final existingRentReceived = existingIncomes
        .where(
          (existing) =>
              existing.id != originalIncome?.id &&
              existing.roomId == room.id &&
              _isRentIncome(existing) &&
              !existing.isDeleted &&
              _isSameMonth(existing.monthCovered, income.monthCovered),
        )
        .fold<double>(0, (sum, existing) => sum + existing.amount);

    if (existingRentReceived >= room.monthlyRent) {
      return const ValidationResult.invalid(
        'Rent for this room and month is already fully recorded.',
      );
    }

    final remainingRent = room.monthlyRent - existingRentReceived;
    if (income.amount > remainingRent) {
      return ValidationResult.invalid(
        'Amount exceeds pending rent. Remaining rent is ${_money(remainingRent)}.',
      );
    }

    return const ValidationResult.valid();
  }

  ValidationResult validateExpense({
    required Expense expense,
    required List<Expense> existingExpenses,
    required List<VillaModel> villas,
    Expense? originalExpense,
    DateTime? now,
  }) {
    final amountResult = _validatePositiveAmount(expense.amount);
    if (!amountResult.isValid) return amountResult;

    if (expense.category.trim().isEmpty) {
      return const ValidationResult.invalid('Category is required.');
    }
    if (expense.paymentMethod.trim().isEmpty) {
      return const ValidationResult.invalid('Payment method is required.');
    }
    if (expense.paidTo.length > 100) {
      return const ValidationResult.invalid(
        'Paid To should not exceed 100 characters.',
      );
    }
    if (expense.notes.length > 500) {
      return const ValidationResult.invalid(
        'Notes should not exceed 500 characters.',
      );
    }
    if (expense.villaId != null &&
        !villas.any((villa) => villa.id == expense.villaId)) {
      return const ValidationResult.invalid('Selected villa does not exist.');
    }

    final duplicateResult = checkDuplicateExpense(
      expense: expense,
      existingExpenses: existingExpenses,
      originalExpense: originalExpense,
    );
    if (duplicateResult.requiresConfirmation) return duplicateResult;

    if (expense.expenseDate.isAfter(_dateOnly(now ?? DateTime.now()))) {
      return const ValidationResult.confirmation(
        'Expense date is in the future. Do you still want to save?',
      );
    }

    return const ValidationResult.valid();
  }

  ValidationResult checkDuplicateExpense({
    required Expense expense,
    required List<Expense> existingExpenses,
    Expense? originalExpense,
  }) {
    final hasDuplicate = existingExpenses.any(
      (existing) =>
          existing.id != originalExpense?.id &&
          existing.villaId == expense.villaId &&
          _normalize(existing.category) == _normalize(expense.category) &&
          existing.amount == expense.amount &&
          _isSameDay(existing.expenseDate, expense.expenseDate) &&
          _normalize(existing.paidTo) == _normalize(expense.paidTo),
    );

    if (!hasDuplicate) return const ValidationResult.valid();

    return const ValidationResult.confirmation(
      'Similar expense already exists. Do you still want to save?',
    );
  }

  ValidationResult validateVilla({
    required VillaModel villa,
    required List<VillaModel> existingVillas,
    VillaModel? originalVilla,
    DateTime? now,
  }) {
    if (villa.villaName.trim().isEmpty) {
      return const ValidationResult.invalid('Villa name is required.');
    }
    return const ValidationResult.valid();
  }

  ValidationResult validateVillaStatusChange({
    required VillaModel originalVilla,
    required VillaModel updatedVilla,
  }) {
    if (_isOccupiedVilla(originalVilla) && _isVacantVilla(updatedVilla)) {
      return const ValidationResult.confirmation(
        'Changing this villa to vacant will stop pending rent calculations. Clear tenant details?',
      );
    }

    return const ValidationResult.valid();
  }

  ValidationResult checkVillaCanBeDeleted({
    required String villaId,
    required List<Income> incomes,
    required List<Expense> expenses,
  }) {
    final hasLinkedTransactions =
        incomes.any((income) => income.villaId == villaId) ||
            expenses.any((expense) => expense.villaId == villaId);

    if (hasLinkedTransactions) {
      return const ValidationResult.invalid(
        'This villa has linked transactions. Archive it instead.',
      );
    }

    return const ValidationResult.valid();
  }

  ValidationResult _validatePositiveAmount(double amount) {
    if (amount <= 0) {
      return const ValidationResult.invalid('Amount must be greater than 0.');
    }
    return const ValidationResult.valid();
  }

  bool _isRentIncome(Income income) {
    return income.incomeType.toLowerCase() == IncomeTypes.rent.toLowerCase();
  }

  bool _isDepositIncome(Income income) {
    return income.incomeType.toLowerCase() == IncomeTypes.deposit.toLowerCase();
  }

  bool _isOccupiedVilla(VillaModel villa) {
    return villa.status.name.toLowerCase() == 'occupied';
  }

  bool _isVacantVilla(VillaModel villa) {
    return villa.status.name.toLowerCase() == 'vacant';
  }

  bool _isSameMonth(DateTime left, DateTime right) {
    return left.year == right.year && left.month == right.month;
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  bool _isMoreThanMonthsInFuture(DateTime date, DateTime now, int months) {
    final maxAllowed = DateTime(now.year, now.month + months, 1);
    final normalizedDate = DateTime(date.year, date.month, 1);
    return normalizedDate.isAfter(maxAllowed);
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  static String _money(double value) => CurrencyFormatter.formatQAR(value);
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}

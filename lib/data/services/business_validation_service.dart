import '../../core/utils/currency_formatter.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/income.dart';
import '../../domain/models/room.dart';
import '../../domain/models/villa_model.dart';

class ValidationResult {
  final bool isValid;
  final String? message;
  final bool requiresConfirmation;
  final String? confirmationTitle;

  const ValidationResult({
    required this.isValid,
    this.message,
    this.requiresConfirmation = false,
    this.confirmationTitle,
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

  const ValidationResult.confirmation(
    String message, {
    String? confirmationTitle,
  }) : this(
          isValid: true,
          message: message,
          requiresConfirmation: true,
          confirmationTitle: confirmationTitle,
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
    final today = _dateOnly(now ?? DateTime.now());
    final amountResult = _validatePositiveAmount(income.amount);
    if (!amountResult.isValid) return amountResult;

    final selectedVilla =
        villas.where((villa) => villa.id == income.villaId).firstOrNull;
    if (income.villaId.trim().isEmpty || selectedVilla == null) {
      return const ValidationResult.invalid('Please select a villa.');
    }
    if (income.incomeType.trim().isEmpty) {
      return const ValidationResult.invalid('Please select an income type.');
    }
    if (income.paymentMethod.trim().isEmpty) {
      return const ValidationResult.invalid('Please select a payment method.');
    }
    if (income.notes.length > 500) {
      return const ValidationResult.invalid(
        'Notes should not exceed 500 characters.',
      );
    }
    if (income.paymentDate.isAfter(today.add(const Duration(days: 30)))) {
      return const ValidationResult.invalid(
        'Payment date is too far in the future.',
      );
    }
    if (_isMoreThanMonthsInFuture(
      income.monthCovered,
      today,
      3,
    )) {
      return const ValidationResult.invalid(
        'Month covered cannot be more than 3 months in the future.',
      );
    }

    final selectedRoom =
        rooms.where((room) => room.id == income.roomId).firstOrNull;
    if (_isRentIncome(income)) {
      if (selectedRoom == null || selectedRoom.isDeleted) {
        return const ValidationResult.invalid(
          'Please select an active room for rent.',
        );
      }
      if (!selectedRoom.isOccupied) {
        return const ValidationResult.invalid(
          'Cannot record rent for a vacant room.',
        );
      }

      final duplicateRentResult = checkDuplicateRent(
        income: income,
        existingIncomes: existingIncomes,
        room: selectedRoom,
        originalIncome: originalIncome,
      );
      if (!duplicateRentResult.isValid) return duplicateRentResult;
    } else if (selectedRoom != null &&
        !selectedRoom.isDeleted &&
        selectedRoom.isVacant) {
      return const ValidationResult.confirmation(
        'This room is vacant. Do you still want to record this income?',
        confirmationTitle: 'Vacant room income',
      );
    }

    if (_isDepositIncome(income)) {
      final hasExistingDeposit = existingIncomes.any(
        (existing) =>
            existing.id != originalIncome?.id &&
            !existing.isDeleted &&
            existing.roomId == income.roomId &&
            _isDepositIncome(existing),
      );
      if (hasExistingDeposit) {
        return const ValidationResult.confirmation(
          'A deposit already exists for this room. Do you still want to save?',
          confirmationTitle: 'Duplicate deposit',
        );
      }
    }

    if (income.paymentDate.isAfter(today)) {
      return const ValidationResult.confirmation(
        'Payment date is in the future. Do you still want to save?',
        confirmationTitle: 'Future payment date',
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
    return validateRentDuplicate(
      income: income,
      existingIncomes: existingIncomes,
      room: room,
      originalIncome: originalIncome,
    );
  }

  ValidationResult validateRentDuplicate({
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
        'Rent for this room is already fully recorded for this month.',
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
    List<Room> rooms = const [],
    Expense? originalExpense,
    DateTime? now,
    double? highExpenseLimit,
  }) {
    final today = _dateOnly(now ?? DateTime.now());
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
    final villaId = expense.villaId?.trim() ?? '';
    final roomId = expense.roomId?.trim() ?? '';
    final selectedVilla = villaId.isEmpty
        ? null
        : villas.where((v) => v.id == villaId).firstOrNull;
    final selectedRoom =
        roomId.isEmpty ? null : rooms.where((r) => r.id == roomId).firstOrNull;
    final isOwnerRent = _isOwnerRentExpense(expense);

    if (isOwnerRent) {
      if (villaId.isEmpty || selectedVilla == null) {
        return const ValidationResult.invalid(
          'Please select a villa for owner rent.',
        );
      }
      if (roomId.isNotEmpty) {
        return const ValidationResult.invalid(
          'Owner Rent should be linked to a villa, not a room.',
        );
      }
    }

    if (roomId.isNotEmpty) {
      if (villaId.isEmpty || selectedVilla == null) {
        return const ValidationResult.invalid(
          'Please select a villa for this room expense.',
        );
      }
      if (selectedRoom == null || selectedRoom.isDeleted) {
        return const ValidationResult.invalid(
          'Please select an active room for this expense.',
        );
      }
    } else if (villaId.isNotEmpty && selectedVilla == null) {
      return const ValidationResult.invalid(
        'Please select an active villa for this expense.',
      );
    }

    final duplicateResult = validateDuplicateExpense(
      expense: expense,
      existingExpenses: existingExpenses,
      originalExpense: originalExpense,
    );
    if (duplicateResult.requiresConfirmation) return duplicateResult;

    if (expense.expenseDate.isAfter(today.add(const Duration(days: 30)))) {
      return const ValidationResult.invalid(
        'Expense date is too far in the future.',
      );
    }
    if (expense.expenseDate.isAfter(today)) {
      return const ValidationResult.confirmation(
        'Expense date is in the future. Do you still want to save?',
        confirmationTitle: 'Future expense date',
      );
    }

    if (highExpenseLimit != null &&
        highExpenseLimit > 0 &&
        expense.amount > highExpenseLimit) {
      return const ValidationResult.confirmation(
        'This is a high expense. Do you want to continue?',
        confirmationTitle: 'High expense',
      );
    }

    return const ValidationResult.valid();
  }

  ValidationResult checkDuplicateExpense({
    required Expense expense,
    required List<Expense> existingExpenses,
    Expense? originalExpense,
  }) {
    return validateDuplicateExpense(
      expense: expense,
      existingExpenses: existingExpenses,
      originalExpense: originalExpense,
    );
  }

  ValidationResult validateDuplicateExpense({
    required Expense expense,
    required List<Expense> existingExpenses,
    Expense? originalExpense,
  }) {
    if (_isOwnerRentExpense(expense)) {
      final hasOwnerRentForMonth = existingExpenses.any(
        (existing) =>
            existing.id != originalExpense?.id &&
            !existing.isDeleted &&
            _isOwnerRentExpense(existing) &&
            existing.villaId == expense.villaId &&
            _isSameMonth(existing.expenseDate, expense.expenseDate),
      );

      if (hasOwnerRentForMonth) {
        return const ValidationResult.confirmation(
          'Owner rent for this villa already exists for this month. Do you still want to save?',
          confirmationTitle: 'Duplicate owner rent',
        );
      }
    }

    final hasDuplicate = existingExpenses.any(
      (existing) =>
          existing.id != originalExpense?.id &&
          !existing.isDeleted &&
          existing.villaId == expense.villaId &&
          existing.roomId == expense.roomId &&
          _normalize(existing.category) == _normalize(expense.category) &&
          existing.amount == expense.amount &&
          _isSameDay(existing.expenseDate, expense.expenseDate) &&
          _normalize(existing.paidTo) == _normalize(expense.paidTo),
    );

    if (!hasDuplicate) return const ValidationResult.valid();

    return const ValidationResult.confirmation(
      'Similar expense already exists. Do you still want to save?',
      confirmationTitle: 'Duplicate expense',
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

  bool _isOwnerRentExpense(Expense expense) {
    return _normalize(expense.category) ==
        _normalize(ExpenseCategories.ownerRent);
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

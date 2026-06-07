import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_permissions.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/room_helpers.dart';
import '../../data/services/business_validation_service.dart';
import '../../domain/models/app_notification.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/room.dart';
import '../../domain/models/villa_model.dart';
import '../providers/active_data_helpers.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/villa_provider.dart';
import '../providers/room_provider.dart';
import '../widgets/premium_widgets.dart';

class AddEditExpenseScreen extends ConsumerStatefulWidget {
  final Expense? expense;

  const AddEditExpenseScreen({
    Key? key,
    this.expense,
  }) : super(key: key);

  @override
  ConsumerState<AddEditExpenseScreen> createState() =>
      _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends ConsumerState<AddEditExpenseScreen> {
  static const String _generalExpenseId = '__general_expense__';
  static const double _defaultHighExpenseLimit = 10000;
  static const _validationService = BusinessValidationService();

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _paidToController = TextEditingController();
  final _notesController = TextEditingController();

  late String _selectedVillaId;
  String? _selectedRoomId;
  late String _selectedCategory;
  late String _selectedPaymentMethod;
  late DateTime _selectedDate;

  bool get _isEditing => widget.expense != null;

  bool get _isOwnerRent => _selectedCategory == ExpenseCategories.ownerRent;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    _selectedVillaId = expense?.villaId ?? _generalExpenseId;
    _selectedRoomId = expense?.roomId;
    _selectedCategory = expense?.category ?? ExpenseCategories.maintenance;
    _selectedPaymentMethod =
        expense?.paymentMethod ?? ExpensePaymentMethods.cash;
    _selectedDate = expense?.expenseDate ?? DateTime.now();
    _amountController.text =
        expense == null ? '' : expense.amount.toStringAsFixed(0);
    _paidToController.text = expense?.paidTo ?? '';
    _notesController.text = expense?.notes ?? '';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _paidToController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final villasAsync = ref.watch(villaListProvider);
    final roomsAsync = ref.watch(roomListProvider);

    return PremiumScaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Expense' : 'Add Expense'),
        elevation: 0,
      ),
      body: villasAsync.when(
        data: (villas) => roomsAsync.when(
          data: (rooms) {
            final activeVillas = activeVillasOnly(villas);
            final activeRooms = activeRoomsForVillas(
              rooms: rooms,
              villas: activeVillas,
            );
            final roomsForSelectedVilla = activeRooms
                .where((room) => room.villaId == _selectedVillaId)
                .toList()
              ..sort(compareRoomsNaturally);
            final selectedVillaIsValid =
                _selectedVillaId == _generalExpenseId ||
                    activeVillas.any((villa) => villa.id == _selectedVillaId);
            final selectedRoomIsValid =
                roomsForSelectedVilla.any((room) => room.id == _selectedRoomId);
            _clearInvalidSelectedRoom(
              selectedRoomIsValid,
              shouldClear: !_isOwnerRent &&
                  _selectedVillaId != _generalExpenseId &&
                  _selectedVillaId.isNotEmpty,
            );

            return Form(
              key: _formKey,
              child: ListView(
                padding: PremiumTokens.pagePadding,
                children: [
                  _FormPanel(
                    children: [
                      _SectionTitle(
                        title: 'Expense Details',
                        icon: Icons.receipt_long_rounded,
                      ),
                      const SizedBox(height: 18),
                      DropdownButtonFormField<String>(
                        initialValue:
                            selectedVillaIsValid ? _selectedVillaId : null,
                        decoration: _decoration(
                          _isOwnerRent ? 'Villa' : 'Expense Scope',
                        ),
                        items: [
                          DropdownMenuItem(
                            value: _generalExpenseId,
                            child: Text(_isOwnerRent
                                ? 'Select Villa'
                                : 'General Expense'),
                          ),
                          ...activeVillas.map(
                            (villa) => DropdownMenuItem(
                              value: villa.id,
                              child: Text(_villaLabel(villa)),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedVillaId = value;
                            _selectedRoomId = null; // Reset room selection
                          });
                        },
                        validator: (value) {
                          if (_isOwnerRent &&
                              (value == null || value == _generalExpenseId)) {
                            return 'Villa is required for Owner Rent';
                          }
                          return null;
                        },
                      ),
                      // Room Selection (if villa is selected, not general)
                      if (!_isOwnerRent &&
                          _selectedVillaId != _generalExpenseId &&
                          _selectedVillaId.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Builder(
                          builder: (context) {
                            return DropdownButtonFormField<String?>(
                              initialValue:
                                  selectedRoomIsValid ? _selectedRoomId : null,
                              decoration: _decoration('Room (Optional)'),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('Villa-level expense'),
                                ),
                                ...roomsForSelectedVilla.map(
                                  (room) => DropdownMenuItem(
                                    value: room.id,
                                    child: Text(getRoomDropdownLabel(room)),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedRoomId = value);
                              },
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: _decoration('Category'),
                        items: ExpenseCategories.values
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList(),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Category is required'
                            : null,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedCategory = value;
                            if (_selectedCategory ==
                                ExpenseCategories.ownerRent) {
                              _selectedRoomId = null;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: _decoration('Amount', prefixText: 'QAR '),
                        validator: (value) {
                          final amount = double.tryParse(value?.trim() ?? '');
                          if (amount == null) return 'Amount is required';
                          if (amount <= 0)
                            return 'Amount must be greater than 0';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: _decoration('Expense Date'),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(DateFormat('dd MMM yyyy')
                                    .format(_selectedDate)),
                              ),
                              const Icon(
                                Icons.calendar_month_rounded,
                                color: AppColors.expense,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _paidToController,
                        decoration: _decoration(
                          _isOwnerRent ? 'Paid To / Owner Name' : 'Paid To',
                        ),
                        validator: (value) => (value?.length ?? 0) > 100
                            ? 'Paid To should not exceed 100 characters'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedPaymentMethod,
                        decoration: _decoration('Payment Method'),
                        items: ExpensePaymentMethods.values
                            .map(
                              (method) => DropdownMenuItem(
                                value: method,
                                child: Text(method),
                              ),
                            )
                            .toList(),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Payment method is required'
                            : null,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _selectedPaymentMethod = value);
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _notesController,
                        minLines: 3,
                        maxLines: 5,
                        decoration: _decoration('Notes'),
                        validator: (value) => (value?.length ?? 0) > 500
                            ? 'Notes should not exceed 500 characters'
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  ModuleActionButton.expense(
                    onPressed: () => _save(activeVillas),
                    icon: Icons.check_rounded,
                    label: _isEditing ? 'Update Expense' : 'Save Expense',
                    fullWidth: true,
                  ),
                ],
              ),
            );
          },
          error: (error, _) => Center(child: Text(error.toString())),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Center(child: Text(error.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  InputDecoration _decoration(String label, {String? prefixText}) {
    return InputDecoration(
      labelText: label,
      prefixText: prefixText,
      filled: true,
      fillColor: const Color(0xFFFFFBFA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.expenseBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.expenseBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.expense, width: 1.5),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save(List<VillaModel> villas) async {
    if (!_formKey.currentState!.validate()) return;

    final selectedVilla = _selectedVillaId == _generalExpenseId
        ? null
        : villas.where((villa) => villa.id == _selectedVillaId).firstOrNull;
    final allRooms = ref.read(allRoomsProvider).valueOrNull ?? const <Room>[];
    final selectedRoom = _selectedRoomId == null
        ? null
        : allRooms
            .where((room) => room.id == _selectedRoomId && !room.isDeleted)
            .firstOrNull;
    final List<Expense> existingExpenses =
        ref.read(expenseListProvider).valueOrNull ?? ref.read(expenseProvider);

    final expense = Expense(
      id: widget.expense?.id ?? const Uuid().v4(),
      villaId: selectedVilla?.id,
      villaName:
          selectedVilla == null ? 'General Expense' : selectedVilla.villaName,
      roomId: _isOwnerRent ? null : _selectedRoomId,
      roomName: _isOwnerRent ? null : selectedRoom?.displayName ?? '',
      category: _selectedCategory,
      amount: double.parse(_amountController.text.trim()),
      expenseDate: _selectedDate,
      paidTo: _paidToController.text.trim(),
      paymentMethod: _selectedPaymentMethod,
      notes: _notesController.text.trim(),
      createdAt: widget.expense?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final validation = _validationService.validateExpense(
      expense: expense,
      existingExpenses: existingExpenses,
      villas: villas,
      rooms: allRooms,
      originalExpense: widget.expense,
      highExpenseLimit: _defaultHighExpenseLimit,
    );
    if (!await _handleValidation(validation)) return;

    final notifier = ref.read(expenseProvider.notifier);
    if (_isEditing) {
      await notifier.updateExpense(expense);
    } else {
      await notifier.addExpense(expense);
      await _createExpenseAddedNotification(expense);
    }
    ref.invalidate(expenseListProvider);
    ref.invalidate(dashboardSummaryProvider);

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _createExpenseAddedNotification(Expense expense) async {
    final authState = ref.read(authProvider);
    final currentUser = authState.currentUser;
    if (currentUser == null) return;
    if (!authState.hasPermission(AppPermissions.manageExpenses)) return;

    final targetUserIds = authState.users
        .where((user) => user.id != currentUser.id)
        .map((user) => user.id)
        .toList();

    debugPrint('[Notifications] current user id=${currentUser.id}');
    debugPrint('[Notifications] target user ids=$targetUserIds');

    if (targetUserIds.isEmpty) return;

    final notification = AppNotification(
      id: const Uuid().v4(),
      title: 'New expense added',
      body:
          '${CurrencyFormatter.formatQAR(expense.amount)} ${expense.category.toLowerCase()} expense added for ${expense.villaName} by ${currentUser.username}',
      type: NotificationTypes.expenseAdded,
      createdByUserId: currentUser.id,
      createdByUsername: currentUser.username,
      targetUserIds: targetUserIds,
      targetRole: null,
      createdAt: DateTime.now(),
      isReadMap: {
        for (final userId in targetUserIds) userId: false,
      },
    );

    await ref
        .read(notificationControllerProvider)
        .createNotification(notification);
  }

  static String _villaLabel(VillaModel villa) {
    return villa.villaName.trim().isEmpty ? 'Villa' : villa.villaName.trim();
  }

  void _clearInvalidSelectedRoom(
    bool selectedRoomIsValid, {
    required bool shouldClear,
  }) {
    if (!shouldClear || _selectedRoomId == null || selectedRoomIsValid) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _selectedRoomId == null) return;
      setState(() => _selectedRoomId = null);
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<bool> _handleValidation(ValidationResult result) async {
    if (!result.isValid) {
      _showMessage(result.message ?? 'Please check the expense details.');
      return false;
    }
    if (!result.requiresConfirmation) return true;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(result.confirmationTitle ?? 'Please confirm'),
            content: Text(result.message ?? 'Do you want to continue?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Continue'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _FormPanel extends StatelessWidget {
  final List<Widget> children;

  const _FormPanel({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.expenseBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.expenseDark.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 38,
          width: 38,
          decoration: const BoxDecoration(
            color: AppColors.expenseSurface,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.expense),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF060B26),
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}

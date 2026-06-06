import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_permissions.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/room_helpers.dart';
import '../../../data/services/business_validation_service.dart';
import '../../../domain/models/app_notification.dart';
import '../../../domain/models/income.dart';
import '../../../domain/models/room.dart';
import '../../../domain/models/villa_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/active_data_helpers.dart';
import '../../providers/income_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/villa_provider.dart';
import '../../providers/room_provider.dart';
import '../../widgets/premium_widgets.dart';

class AddEditIncomeScreen extends ConsumerStatefulWidget {
  final Income? income;

  const AddEditIncomeScreen({
    Key? key,
    this.income,
  }) : super(key: key);

  @override
  ConsumerState<AddEditIncomeScreen> createState() =>
      _AddEditIncomeScreenState();
}

class _AddEditIncomeScreenState extends ConsumerState<AddEditIncomeScreen> {
  static const _validationService = BusinessValidationService();

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedVillaId;
  String? _selectedRoomId;
  late String _selectedIncomeType;
  late String _selectedPaymentMethod;
  late DateTime _paymentDate;
  late DateTime _monthCovered;
  String? _lastRentAutofillKey;

  bool get _isEditing => widget.income != null;

  bool get _isRentIncome => _selectedIncomeType == IncomeTypes.rent;

  @override
  void initState() {
    super.initState();
    final income = widget.income;
    _selectedVillaId = income?.villaId;
    _selectedRoomId = income?.roomId;
    _selectedIncomeType = income?.incomeType ?? IncomeTypes.rent;
    _selectedPaymentMethod = income?.paymentMethod ?? IncomePaymentMethods.cash;
    _paymentDate = income?.paymentDate ?? DateTime.now();
    _monthCovered = income?.monthCovered ??
        DateTime(DateTime.now().year, DateTime.now().month, 1);
    _amountController.text =
        income == null ? '' : income.amount.toStringAsFixed(0);
    _notesController.text = income?.notes ?? '';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final villasAsync = ref.watch(villaListProvider);
    final roomsAsync = ref.watch(roomListProvider);
    final controllerState = ref.watch(incomeControllerProvider);

    return PremiumScaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Income' : 'Add Income'),
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
            final selectableRooms = roomsForSelectedVilla;
            final selectedVillaIsValid =
                activeVillas.any((villa) => villa.id == _selectedVillaId);
            final selectedRoom = roomsForSelectedVilla
                .where((room) => room.id == _selectedRoomId)
                .firstOrNull;
            final selectedRoomIsValid =
                selectableRooms.any((room) => room.id == _selectedRoomId);
            _clearInvalidSelectedRoom(selectedRoomIsValid);
            final rentSummary = _rentSummaryFor(selectedRoom);
            _autoPopulateRentAmount(
              selectedRoom: selectedRoom,
              rentSummary: rentSummary,
            );
            final saveBlocked = _isRentSaveBlocked(
              selectedRoom: selectedRoom,
              rentSummary: rentSummary,
            );

            return Form(
              key: _formKey,
              child: ListView(
                padding: PremiumTokens.pagePadding,
                children: [
                  _FormPanel(
                    children: [
                      const _SectionTitle(
                        title: 'Income Details',
                        icon: Icons.payments_rounded,
                      ),
                      const SizedBox(height: 18),
                      DropdownButtonFormField<String>(
                        initialValue:
                            selectedVillaIsValid ? _selectedVillaId : null,
                        decoration: _decoration('Villa'),
                        items: activeVillas
                            .map(
                              (villa) => DropdownMenuItem(
                                value: villa.id,
                                child: Text(_villaLabel(villa)),
                              ),
                            )
                            .toList(),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Villa is required'
                            : null,
                        onChanged: (value) {
                          setState(() {
                            _selectedVillaId = value;
                            _selectedRoomId = null; // Reset room selection
                            _lastRentAutofillKey = null;
                          });
                        },
                      ),
                      if (activeVillas.isEmpty) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Income can only be added for villas with rooms.',
                          style: TextStyle(
                            color: Color(0xFFF04438),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      // Room Selection
                      if (selectedVillaIsValid) ...[
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          initialValue:
                              selectedRoomIsValid ? _selectedRoomId : null,
                          decoration: _decoration('Room'),
                          items: selectableRooms
                              .map(
                                (room) => DropdownMenuItem(
                                  value: room.id,
                                  child: Text(getRoomDropdownLabel(room)),
                                ),
                              )
                              .toList(),
                          validator: (value) {
                            if (_selectedIncomeType == IncomeTypes.rent &&
                                (value == null || value.isEmpty)) {
                              return 'Room is required for rent';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _selectedRoomId = value;
                              _lastRentAutofillKey = null;
                            });
                          },
                        ),
                      ],
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedIncomeType,
                        decoration: _decoration('Income Type'),
                        items: IncomeTypes.values
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Income type is required'
                            : null,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedIncomeType = value;
                            _lastRentAutofillKey = null;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: _decoration(
                          'Amount',
                          prefixText: 'QAR ',
                          helperText: _isRentIncome
                              ? 'Auto-filled from pending rent. You can enter a lower partial payment.'
                              : null,
                        ),
                        validator: (value) {
                          final amount = double.tryParse(value?.trim() ?? '');
                          if (amount == null) return 'Amount is required';
                          if (amount <= 0)
                            return 'Amount must be greater than 0';
                          if (_isRentIncome &&
                              rentSummary != null &&
                              amount > rentSummary.remainingRent) {
                            return 'Amount exceeds pending rent. Remaining rent is ${CurrencyFormatter.formatQAR(rentSummary.remainingRent)}.';
                          }
                          return null;
                        },
                      ),
                      if (_isRentIncome) ...[
                        const SizedBox(height: 10),
                        _RentInformation(
                          room: selectedRoom,
                          summary: rentSummary,
                        ),
                      ],
                      const SizedBox(height: 14),
                      _DateField(
                        label: 'Payment Date',
                        value: _paymentDate,
                        formatter: DateFormat('dd MMM yyyy'),
                        onTap: () => _pickDate(
                          initialDate: _paymentDate,
                          onPicked: (date) =>
                              setState(() => _paymentDate = date),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedPaymentMethod,
                        decoration: _decoration('Payment Method'),
                        items: IncomePaymentMethods.values
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
                      _DateField(
                        label: 'Month Covered',
                        value: _monthCovered,
                        formatter: DateFormat('MMMM yyyy'),
                        onTap: () => _pickDate(
                          initialDate: _monthCovered,
                          onPicked: (date) => setState(() {
                            _monthCovered = DateTime(date.year, date.month, 1);
                            _lastRentAutofillKey = null;
                          }),
                        ),
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
                  FilledButton.icon(
                    onPressed: controllerState.isLoading || saveBlocked
                        ? null
                        : () => _save(activeVillas),
                    icon: controllerState.isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(_isEditing ? 'Update Income' : 'Save Income'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF12B76A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
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

  InputDecoration _decoration(
    String label, {
    String? prefixText,
    String? helperText,
  }) {
    return InputDecoration(
      labelText: label,
      prefixText: prefixText,
      helperText: helperText,
      filled: true,
      fillColor: const Color(0xFFFBFFFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFCDEFD8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFCDEFD8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF12B76A), width: 1.5),
      ),
    );
  }

  RentPaymentSummary? _rentSummaryFor(Room? selectedRoom) {
    if (!_isRentIncome || selectedRoom == null) return null;
    return ref
        .watch(
          rentPaymentSummaryProvider(
            RentPaymentSummaryRequest(
              roomId: selectedRoom.id,
              monthlyRent: selectedRoom.monthlyRent,
              month: _monthCovered,
              excludedIncomeId: widget.income?.id,
            ),
          ),
        )
        .valueOrNull;
  }

  void _autoPopulateRentAmount({
    required Room? selectedRoom,
    required RentPaymentSummary? rentSummary,
  }) {
    if (_isEditing ||
        !_isRentIncome ||
        selectedRoom == null ||
        selectedRoom.isVacant ||
        rentSummary == null ||
        rentSummary.isFullyPaid) {
      return;
    }

    final key = [
      selectedRoom.id,
      _monthCovered.year,
      _monthCovered.month,
      rentSummary.paidAmount,
      rentSummary.remainingRent,
    ].join(':');
    if (_lastRentAutofillKey == key) return;
    _lastRentAutofillKey = key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _amountController.text = _formatAmountInput(rentSummary.remainingRent);
      _amountController.selection = TextSelection.collapsed(
        offset: _amountController.text.length,
      );
    });
  }

  bool _isRentSaveBlocked({
    required Room? selectedRoom,
    required RentPaymentSummary? rentSummary,
  }) {
    if (!_isRentIncome) return false;
    if (selectedRoom == null) return false;
    if (selectedRoom.isVacant) return true;
    return rentSummary?.isFullyPaid == true;
  }

  String _formatAmountInput(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2);
  }

  Future<void> _pickDate({
    required DateTime initialDate,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      onPicked(picked);
    }
  }

  Future<void> _save(List<VillaModel> villas) async {
    if (!_formKey.currentState!.validate()) return;

    final selectedVilla =
        villas.where((villa) => villa.id == _selectedVillaId).firstOrNull;
    if (selectedVilla == null) return;
    final allRooms = ref.read(roomListProvider).valueOrNull ?? const <Room>[];
    final existingIncomes =
        ref.read(incomeListProvider).valueOrNull ?? const <Income>[];

    // For rent income, room is required
    if (_selectedIncomeType == IncomeTypes.rent && _selectedRoomId == null) {
      _showMessage('Room is required for rent income.');
      return;
    }

    if (_selectedIncomeType == IncomeTypes.rent) {
      final selectedRoom = allRooms
          .where((room) => !room.isDeleted && room.id == _selectedRoomId)
          .firstOrNull;
      if (selectedRoom != null && selectedRoom.isVacant) {
        _showMessage('Cannot record rent for a vacant room.');
        return;
      }
      if (selectedRoom != null) {
        final paidAmount = _validationService.rentAlreadyRecordedForRoomMonth(
          roomId: selectedRoom.id,
          month: _monthCovered,
          existingIncomes: existingIncomes,
          originalIncome: widget.income,
        );
        final remainingRent =
            (selectedRoom.monthlyRent - paidAmount).clamp(0.0, double.infinity);
        if (remainingRent <= 0) {
          _showMessage(
            'Rent is already fully recorded for this room and month.',
          );
          return;
        }
        final enteredAmount =
            double.tryParse(_amountController.text.trim()) ?? 0;
        if (enteredAmount > remainingRent) {
          _showMessage(
            'Amount exceeds pending rent. Remaining rent is ${CurrencyFormatter.formatQAR(remainingRent.toDouble())}.',
          );
          return;
        }
      }
    }

    String roomName = '';
    if (_selectedRoomId != null) {
      final rooms = ref.read(roomListProvider).valueOrNull;
      var selectedRoomName = _selectedRoomId!;
      if (rooms != null) {
        for (final room in rooms.where((room) => !room.isDeleted)) {
          if (room.id == _selectedRoomId) {
            selectedRoomName = room.displayName;
            break;
          }
        }
      }
      roomName = selectedRoomName;
    }

    final income = Income(
      id: widget.income?.id ?? const Uuid().v4(),
      villaId: selectedVilla.id,
      villaName: selectedVilla.villaName,
      roomId: _selectedRoomId ?? '',
      roomName: roomName,
      incomeType: _selectedIncomeType,
      amount: double.parse(_amountController.text.trim()),
      paymentDate: _paymentDate,
      paymentMethod: _selectedPaymentMethod,
      monthCovered: DateTime(_monthCovered.year, _monthCovered.month, 1),
      notes: _notesController.text.trim(),
      createdAt: widget.income?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final validation = _validationService.validateIncome(
      income: income,
      existingIncomes: existingIncomes,
      villas: villas,
      rooms: allRooms,
      originalIncome: widget.income,
    );
    if (!await _handleValidation(validation)) return;

    final controller = ref.read(incomeControllerProvider.notifier);
    if (_isEditing) {
      await controller.updateIncome(income);
    } else {
      await controller.addIncome(income);
      await _createIncomeAddedNotification(income);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _createIncomeAddedNotification(Income income) async {
    final authState = ref.read(authProvider);
    final currentUser = authState.currentUser;
    if (currentUser == null) return;
    if (!authState.hasPermission(AppPermissions.manageIncome)) return;

    final targetUserIds = authState.users
        .where((user) => user.id != currentUser.id)
        .map((user) => user.id)
        .toList();

    debugPrint('[Notifications] current user id=${currentUser.id}');
    debugPrint('[Notifications] target user ids=$targetUserIds');

    if (targetUserIds.isEmpty) return;

    final notification = AppNotification(
      id: const Uuid().v4(),
      title: 'New income added',
      body:
          '${CurrencyFormatter.formatQAR(income.amount)} ${income.incomeType.toLowerCase()} added for ${income.villaName} by ${currentUser.username}',
      type: NotificationTypes.incomeAdded,
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<bool> _handleValidation(ValidationResult result) async {
    if (!result.isValid) {
      _showMessage(result.message ?? 'Please check the income details.');
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

  static String _villaLabel(VillaModel villa) {
    return villa.villaName.trim().isEmpty ? 'Villa' : villa.villaName.trim();
  }

  void _clearInvalidSelectedRoom(bool selectedRoomIsValid) {
    if (_selectedRoomId == null || selectedRoomIsValid) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _selectedRoomId == null) return;
      setState(() => _selectedRoomId = null);
    });
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final DateFormat formatter;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.formatter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFFBFFFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFCDEFD8)),
          ),
        ),
        child: Row(
          children: [
            Expanded(child: Text(formatter.format(value))),
            const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF12B76A),
            ),
          ],
        ),
      ),
    );
  }
}

class _RentInformation extends StatelessWidget {
  final Room? room;
  final RentPaymentSummary? summary;

  const _RentInformation({
    required this.room,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    if (room == null) {
      return const _RentMessage(
        icon: Icons.meeting_room_outlined,
        message: 'Select an occupied room to calculate rent.',
      );
    }
    if (room!.isVacant) {
      return const _RentMessage(
        icon: Icons.warning_amber_rounded,
        message: 'Cannot record rent for a vacant room.',
        isWarning: true,
      );
    }
    final rentSummary = summary;
    if (rentSummary == null) {
      return const _RentMessage(
        icon: Icons.hourglass_empty_rounded,
        message: 'Loading rent information...',
      );
    }
    if (rentSummary.remainingRent <= 0) {
      return const _RentMessage(
        icon: Icons.check_circle_outline_rounded,
        message: 'Rent is already fully recorded for this room and month.',
        isWarning: true,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE4F8EA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCDEFD8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RentInfoLine(
            label: 'Monthly Rent',
            value: CurrencyFormatter.formatQAR(rentSummary.monthlyRent),
          ),
          const SizedBox(height: 6),
          _RentInfoLine(
            label: 'Already Paid',
            value: CurrencyFormatter.formatQAR(rentSummary.paidAmount),
          ),
          const SizedBox(height: 6),
          _RentInfoLine(
            label: 'Remaining Rent',
            value: CurrencyFormatter.formatQAR(rentSummary.remainingRent),
            isEmphasized: true,
          ),
        ],
      ),
    );
  }
}

class _RentInfoLine extends StatelessWidget {
  final String label;
  final String value;
  final bool isEmphasized;

  const _RentInfoLine({
    required this.label,
    required this.value,
    this.isEmphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$label:',
            style: TextStyle(
              color: const Color(0xFF38664D),
              fontSize: 12,
              fontWeight: isEmphasized ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isEmphasized
                ? const Color(0xFF067647)
                : const Color(0xFF143D27),
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _RentMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool isWarning;

  const _RentMessage({
    required this.icon,
    required this.message,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isWarning ? const Color(0xFFF04438) : const Color(0xFF12B76A);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.26)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
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
        border: Border.all(color: const Color(0xFFCDEFD8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF067647).withValues(alpha: 0.08),
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
            color: Color(0xFFE4F8EA),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF12B76A)),
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

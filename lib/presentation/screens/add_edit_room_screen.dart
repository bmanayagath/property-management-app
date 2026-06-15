import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../domain/models/room.dart';
import '../../domain/models/villa_model.dart';
import '../providers/dashboard_provider.dart';
import '../providers/room_provider.dart';
import '../providers/villa_provider.dart';
import '../widgets/app_text_field.dart';
import '../widgets/premium_widgets.dart';
import '../widgets/app_date_picker_field.dart';
import '../widgets/app_dropdown.dart';

class AddEditRoomScreen extends ConsumerStatefulWidget {
  final Room? room;
  final String villaId;

  const AddEditRoomScreen({
    Key? key,
    this.room,
    required this.villaId,
  }) : super(key: key);

  @override
  ConsumerState<AddEditRoomScreen> createState() => _AddEditRoomScreenState();
}

class _AddEditRoomScreenState extends ConsumerState<AddEditRoomScreen> {
  late TextEditingController _roomNameController;
  late TextEditingController _tenantNameController;
  late TextEditingController _tenantPhoneController;
  late TextEditingController _monthlyRentController;
  late TextEditingController _paymentDueDayController;
  late TextEditingController _depositAmountController;
  late TextEditingController _depositNotesController;
  late DateTime _contractStartDate;
  late DateTime _contractEndDate;
  late int _paymentDueDay;
  late String _status;
  late String _depositType;
  late String _depositStatus;
  DateTime? _depositDate;
  late VillaModel? _selectedVilla;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.room != null) {
      _roomNameController = TextEditingController(text: widget.room!.roomName);
      _tenantNameController =
          TextEditingController(text: widget.room!.tenantName);
      _tenantPhoneController =
          TextEditingController(text: widget.room!.tenantPhone);
      _monthlyRentController =
          TextEditingController(text: widget.room!.monthlyRent.toString());
      _paymentDueDayController =
          TextEditingController(text: widget.room!.paymentDueDay.toString());
      _contractStartDate = widget.room!.contractStartDate ?? DateTime.now();
      _contractEndDate = widget.room!.contractEndDate ??
          DateTime.now().add(const Duration(days: 365));
      _paymentDueDay = widget.room!.paymentDueDay;
      _status = widget.room!.status;
      _depositType = widget.room!.depositType;
      _depositStatus = widget.room!.depositStatus;
      _depositDate = widget.room!.depositDate;
      _depositAmountController = TextEditingController(
        text: widget.room!.depositAmount == 0
            ? ''
            : widget.room!.depositAmount.toString(),
      );
      _depositNotesController =
          TextEditingController(text: widget.room!.depositNotes);
      _selectedVilla = null;
    } else {
      _roomNameController = TextEditingController();
      _tenantNameController = TextEditingController();
      _tenantPhoneController = TextEditingController();
      _monthlyRentController = TextEditingController();
      _paymentDueDayController = TextEditingController(text: '1');
      _contractStartDate = DateTime.now();
      _contractEndDate = DateTime.now().add(const Duration(days: 365));
      _paymentDueDay = 1;
      _status = RoomStatuses.vacant;
      _depositType = DepositTypes.none;
      _depositStatus = DepositStatuses.held;
      _depositDate = null;
      _depositAmountController = TextEditingController();
      _depositNotesController = TextEditingController();
      _selectedVilla = null;
    }
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    _tenantNameController.dispose();
    _tenantPhoneController.dispose();
    _monthlyRentController.dispose();
    _paymentDueDayController.dispose();
    _depositAmountController.dispose();
    _depositNotesController.dispose();
    super.dispose();
  }

  bool get _isTenantRequired => _status == RoomStatuses.occupied;

  void _saveRoom() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedVilla == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a villa')),
      );
      return;
    }

    final duplicateRoomName = await _findDuplicateRoomName();
    if (duplicateRoomName != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Room name "$duplicateRoomName" is already used in this villa.',
          ),
        ),
      );
      return;
    }

    final depositAmount = _depositType == DepositTypes.none
        ? 0.0
        : double.parse(_depositAmountController.text);
    final room = (widget.room ?? Room.empty()).copyWith(
      id: widget.room?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      villaId: _selectedVilla!.id,
      villaName: _selectedVilla!.villaName,
      roomName: _roomNameController.text.trim(),
      roomNumber: '',
      tenantName: _tenantNameController.text.trim(),
      tenantPhone: _tenantPhoneController.text.trim(),
      monthlyRent: double.parse(_monthlyRentController.text),
      contractStartDate: _isTenantRequired ? _contractStartDate : null,
      contractEndDate: _isTenantRequired ? _contractEndDate : null,
      paymentDueDay: _paymentDueDay,
      status: _status,
      createdAt: widget.room?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      depositType: _depositType,
      depositAmount: depositAmount,
      depositDate: _depositType == DepositTypes.none
          ? null
          : _depositDate ?? DateTime.now(),
      clearDepositDate: _depositType == DepositTypes.none,
      depositStatus: _depositStatus,
      depositNotes: _depositNotesController.text.trim(),
    );

    try {
      if (widget.room == null) {
        await ref.read(addRoomProvider(room).future);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room added successfully!')),
        );
      } else {
        await ref.read(updateRoomProvider(room).future);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room updated successfully!')),
        );
      }
      ref.invalidate(allRoomsProvider);
      ref.invalidate(villasProvider);
      ref.invalidate(dashboardSummaryProvider);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<String?> _findDuplicateRoomName() async {
    final selectedVilla = _selectedVilla;
    if (selectedVilla == null) return null;

    final rooms = await ref.read(roomsByVillaProvider(selectedVilla.id).future);
    final normalized = _roomNameController.text.trim().toLowerCase();
    for (final room in rooms) {
      if (room.id == widget.room?.id) continue;
      if (room.roomName.trim().toLowerCase() == normalized) {
        return room.roomName.trim();
      }
    }
    return null;
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: AppStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ...List.generate(
            children.length,
            (index) => Column(
              children: [
                children[index],
                if (index < children.length - 1) const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.room != null;
    final villas = ref.watch(villasProvider);

    return PremiumScaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Room' : 'Add New Room'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: PremiumTokens.pagePadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Villa Selection
                _buildSectionHeader('Villa Selection', Icons.home_outlined),
                villas.when(
                  data: (villaList) {
                    // Set selected villa on first load
                    if (_selectedVilla == null && villaList.isNotEmpty) {
                      final targetVillaId =
                          widget.room?.villaId ?? widget.villaId;
                      for (final villa in villaList) {
                        if (villa.id == targetVillaId) {
                          _selectedVilla = villa;
                          break;
                        }
                      }
                      _selectedVilla ??= villaList.first;
                    }

                    return _buildFormCard(
                      children: [
                        DropdownButtonFormField<VillaModel>(
                          initialValue: _selectedVilla,
                          hint: const Text('Select Villa'),
                          decoration: InputDecoration(
                            labelText: 'Villa *',
                            prefixIcon: const Icon(Icons.home_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: villaList.map((villa) {
                            return DropdownMenuItem(
                              value: villa,
                              child: Text(villa.villaName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedVilla = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Villa is required';
                            }
                            return null;
                          },
                        ),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                ),
                const SizedBox(height: 24),

                // Status Selection
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.08),
                        AppColors.primary.withValues(alpha: 0.02),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: AppDropdown<String>(
                    label: 'Room Status',
                    value: _status,
                    items: RoomStatuses.values,
                    itemLabel: (status) => status,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _status = value);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Room Details Section
                _buildSectionHeader(
                    'Room Details', Icons.meeting_room_outlined),
                _buildFormCard(
                  children: [
                    AppTextField(
                      controller: _roomNameController,
                      label: 'Room Name *',
                      hint: 'e.g., Main Room',
                      prefixIcon: Icons.label_outlined,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Room name is required';
                        }
                        return null;
                      },
                    ),
                    AppTextField(
                      controller: _monthlyRentController,
                      label: 'Monthly Rent (QAR) *',
                      hint: '0.00',
                      prefixIcon: Icons.attach_money_outlined,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Monthly rent is required';
                        }
                        try {
                          final rent = double.parse(value!);
                          if (rent <= 0) {
                            return 'Monthly rent must be greater than 0';
                          }
                        } catch (e) {
                          return 'Invalid amount';
                        }
                        return null;
                      },
                    ),
                    AppTextField(
                      controller: _paymentDueDayController,
                      label: 'Payment Due Day (1-31) *',
                      hint: '1',
                      prefixIcon: Icons.calendar_today,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          try {
                            final day = int.parse(value);
                            if (day >= 1 && day <= 31) {
                              setState(() => _paymentDueDay = day);
                            }
                          } catch (e) {
                            // Invalid input
                          }
                        }
                      },
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Payment due day is required';
                        }
                        try {
                          final day = int.parse(value!);
                          if (day < 1 || day > 31) {
                            return 'Due day must be between 1 and 31';
                          }
                        } catch (e) {
                          return 'Invalid due day';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Tenant Information Section (Conditional)
                if (_isTenantRequired) ...[
                  _buildSectionHeader(
                      'Tenant Information', Icons.person_outlined),
                  _buildFormCard(
                    children: [
                      AppTextField(
                        controller: _tenantNameController,
                        label: 'Tenant Name *',
                        hint: 'e.g., Ahmed',
                        prefixIcon: Icons.person_outlined,
                        validator: (value) {
                          if (_isTenantRequired && (value?.isEmpty ?? true)) {
                            return 'Tenant name is required for occupied rooms';
                          }
                          return null;
                        },
                      ),
                      AppTextField(
                        controller: _tenantPhoneController,
                        label: 'Tenant Phone *',
                        hint: '+974 1234 5678',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (_isTenantRequired && (value?.isEmpty ?? true)) {
                            return 'Tenant phone is required for occupied rooms';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Contract Dates Section
                  _buildSectionHeader(
                      'Contract Details', Icons.description_outlined),
                  _buildFormCard(
                    children: [
                      AppDatePickerField(
                        label: 'Contract Start Date',
                        value: _contractStartDate,
                        onChanged: (newDate) {
                          setState(() => _contractStartDate = newDate);
                        },
                      ),
                      AppDatePickerField(
                        label: 'Contract End Date',
                        value: _contractEndDate,
                        onChanged: (newDate) {
                          setState(() => _contractEndDate = newDate);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                _buildSectionHeader(
                    'Tenant Deposit', Icons.account_balance_wallet_outlined),
                _buildFormCard(
                  children: [
                    AppDropdown<String>(
                      label: 'Deposit Type',
                      value: _depositType,
                      items: DepositTypes.values,
                      itemLabel: (value) => value,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _depositType = value;
                          if (value == DepositTypes.none) {
                            _depositAmountController.clear();
                            _depositDate = null;
                          }
                        });
                      },
                    ),
                    if (_depositType != DepositTypes.none) ...[
                      AppTextField(
                        controller: _depositAmountController,
                        label: 'Deposit Amount (QAR) *',
                        hint: '0.00',
                        prefixIcon: Icons.payments_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (_depositType == DepositTypes.none) return null;
                          final amount = double.tryParse(value ?? '');
                          if (amount == null || amount <= 0) {
                            return 'Enter a deposit amount greater than 0';
                          }
                          return null;
                        },
                      ),
                      AppDatePickerField(
                        label: 'Deposit Date',
                        value: _depositDate ?? DateTime.now(),
                        onChanged: (date) =>
                            setState(() => _depositDate = date),
                      ),
                      AppDropdown<String>(
                        label: 'Deposit Status',
                        value: _depositStatus,
                        items: DepositStatuses.values,
                        itemLabel: (value) => value,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _depositStatus = value);
                          }
                        },
                      ),
                    ],
                    AppTextField(
                      controller: _depositNotesController,
                      label: 'Notes (optional)',
                      hint: 'Deposit notes',
                      prefixIcon: Icons.notes_outlined,
                      maxLines: 3,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _saveRoom,
                    icon: Icon(isEditing ? Icons.save : Icons.add),
                    label: Text(isEditing ? 'Update Room' : 'Add Room'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

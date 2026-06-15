import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/models/room.dart';
import '../providers/room_provider.dart';
import '../widgets/premium_widgets.dart';

class RoomDetailScreen extends ConsumerStatefulWidget {
  final Room room;
  final bool canManage;

  const RoomDetailScreen({
    super.key,
    required this.room,
    required this.canManage,
  });

  @override
  ConsumerState<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends ConsumerState<RoomDetailScreen> {
  late Room _room;

  @override
  void initState() {
    super.initState();
    _room = widget.room;
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      appBar: AppBar(title: Text(_room.displayName)),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _section('Current Tenant', [
            _row('Status', _room.status),
            _row(
                'Tenant', _room.tenantName.isEmpty ? 'None' : _room.tenantName),
            _row('Phone',
                _room.tenantPhone.isEmpty ? 'None' : _room.tenantPhone),
          ]),
          const SizedBox(height: 16),
          _section('Tenant Deposit', [
            _row('Type', _room.depositType),
            _row('Amount', CurrencyFormatter.format(_room.depositAmount)),
            _row('Status', _room.depositStatus),
            if (_room.depositDate != null)
              _row(
                'Date',
                DateFormat('dd MMM yyyy').format(_room.depositDate!),
              ),
            if (_room.depositNotes.trim().isNotEmpty)
              _row('Notes', _room.depositNotes),
          ]),
          if (_room.isOccupied && widget.canManage) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _vacateRoom,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Vacate Room'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'Tenant History',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          if (_room.tenantHistory.isEmpty)
            const Text('No previous tenants.')
          else
            ..._room.tenantHistory.reversed.map(_historyCard),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyCard(TenantHistory history) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              history.tenantName,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            _row(
              'Move out',
              DateFormat('dd MMM yyyy').format(history.moveOutDate),
            ),
            _row(
              'Deposit',
              '${history.depositType} - '
                  '${CurrencyFormatter.format(history.depositAmount)}',
            ),
            _row('Status', history.depositStatus),
            if (history.refundAmount > 0)
              _row(
                'Refunded',
                CurrencyFormatter.format(history.refundAmount),
              ),
            if (history.retainedAmount > 0)
              _row(
                'Retained',
                CurrencyFormatter.format(history.retainedAmount),
              ),
            if (history.notes.trim().isNotEmpty) _row('Notes', history.notes),
          ],
        ),
      ),
    );
  }

  Future<void> _vacateRoom() async {
    final result = await showDialog<_VacateResult>(
      context: context,
      builder: (_) => _VacateRoomDialog(depositAmount: _room.depositAmount),
    );
    if (result == null) return;

    final now = DateTime.now();
    final history = TenantHistory(
      roomId: _room.id,
      villaId: _room.villaId,
      tenantName: _room.tenantName,
      tenantPhone: _room.tenantPhone,
      moveInDate: _room.contractStartDate,
      moveOutDate: now,
      depositType: _room.depositType,
      depositAmount: _room.depositAmount,
      depositStatus: result.status,
      refundAmount: result.refundAmount,
      retainedAmount: result.retainedAmount,
      notes: [_room.depositNotes, result.reason]
          .where((value) => value.trim().isNotEmpty)
          .join(' - '),
    );
    final updated = _room.copyWith(
      status: RoomStatuses.vacant,
      tenantName: '',
      tenantPhone: '',
      clearContractStartDate: true,
      clearContractEndDate: true,
      moveOutDate: now,
      lastTenantName: _room.tenantName,
      lastTenantPhone: _room.tenantPhone,
      depositType: result.noDeposit ? DepositTypes.none : _room.depositType,
      depositAmount: result.noDeposit ? 0 : _room.depositAmount,
      clearDepositDate: result.noDeposit,
      depositStatus: result.status,
      refundAmount: result.refundAmount,
      retainedAmount: result.retainedAmount,
      depositReason: result.reason,
      tenantHistory: [..._room.tenantHistory, history],
      updatedAt: now,
    );

    await ref.read(updateRoomProvider(updated).future);
    if (!mounted) return;
    setState(() => _room = updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Room vacated successfully.')),
    );
  }
}

class _VacateRoomDialog extends StatefulWidget {
  final double depositAmount;

  const _VacateRoomDialog({required this.depositAmount});

  @override
  State<_VacateRoomDialog> createState() => _VacateRoomDialogState();
}

class _VacateRoomDialogState extends State<_VacateRoomDialog> {
  static const _actions = [
    'Fully Refunded',
    'Partially Refunded',
    'Forfeited',
    'Keep Held',
    'No Deposit',
  ];

  final _refundController = TextEditingController();
  final _reasonController = TextEditingController();
  late String _action;
  String? _error;

  @override
  void initState() {
    super.initState();
    _action = widget.depositAmount > 0 ? 'Fully Refunded' : 'No Deposit';
  }

  @override
  void dispose() {
    _refundController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Vacate Room'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vacating this room will mark it as vacant and clear current '
              'tenant details. Income, expenses, and history will be preserved.',
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              initialValue: _action,
              decoration: const InputDecoration(labelText: 'Deposit Action'),
              items: _actions
                  .map(
                    (action) => DropdownMenuItem(
                      value: action,
                      child: Text(action),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() {
                _action = value ?? _action;
                _error = null;
              }),
            ),
            if (_action == 'Partially Refunded') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _refundController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Refund Amount *'),
              ),
            ],
            if (_action == 'Partially Refunded' || _action == 'Forfeited') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _reasonController,
                decoration:
                    const InputDecoration(labelText: 'Reason (optional)'),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: AppColors.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _confirm,
          child: const Text('Confirm Vacate'),
        ),
      ],
    );
  }

  void _confirm() {
    var status = DepositStatuses.held;
    var refund = 0.0;
    var retained = 0.0;
    var noDeposit = false;

    switch (_action) {
      case 'Fully Refunded':
        status = DepositStatuses.refunded;
        refund = widget.depositAmount;
      case 'Partially Refunded':
        refund = double.tryParse(_refundController.text) ?? -1;
        if (refund <= 0 || refund >= widget.depositAmount) {
          setState(() {
            _error = 'Refund must be greater than 0 and less than the deposit.';
          });
          return;
        }
        status = DepositStatuses.partiallyRefunded;
        retained = widget.depositAmount - refund;
      case 'Forfeited':
        status = DepositStatuses.forfeited;
        retained = widget.depositAmount;
      case 'Keep Held':
        status = DepositStatuses.held;
      case 'No Deposit':
        status = DepositStatuses.held;
        noDeposit = true;
    }

    Navigator.pop(
      context,
      _VacateResult(
        status: status,
        refundAmount: refund,
        retainedAmount: retained,
        reason: _reasonController.text.trim(),
        noDeposit: noDeposit,
      ),
    );
  }
}

class _VacateResult {
  final String status;
  final double refundAmount;
  final double retainedAmount;
  final String reason;
  final bool noDeposit;

  const _VacateResult({
    required this.status,
    required this.refundAmount,
    required this.retainedAmount,
    required this.reason,
    required this.noDeposit,
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/services/tenant_contact_service.dart';
import '../../domain/models/income.dart';
import '../../domain/models/room.dart';
import '../providers/income_provider.dart';
import '../providers/room_provider.dart';
import '../widgets/premium_widgets.dart';
import 'add_edit_room_screen.dart';

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
  final _contactService = TenantContactService();
  late Room _room;

  @override
  void initState() {
    super.initState();
    _room = widget.room;
  }

  @override
  Widget build(BuildContext context) {
    final currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    final rentSummary = ref.watch(
      rentPaymentSummaryProvider(
        RentPaymentSummaryRequest(
          roomId: _room.id,
          monthlyRent: _room.monthlyRent,
          month: currentMonth,
        ),
      ),
    );
    final incomes =
        ref.watch(incomeListProvider).valueOrNull ?? const <Income>[];
    final lastRentPayment = incomes
        .where(
          (income) =>
              income.roomId == _room.id &&
              income.incomeType.toLowerCase() == IncomeTypes.rent.toLowerCase(),
        )
        .fold<DateTime?>(
          null,
          (latest, income) =>
              latest == null || income.paymentDate.isAfter(latest)
                  ? income.paymentDate
                  : latest,
        );

    return PremiumScaffold(
      appBar: AppBar(title: Text(_room.displayName)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          _tenantCard(),
          const SizedBox(height: 12),
          rentSummary.when(
            data: (summary) => _rentCard(summary, lastRentPayment),
            loading: () => const _SectionLoading(title: 'Rent Information'),
            error: (_, __) => _rentCard(
              RentPaymentSummary(
                monthlyRent: _room.monthlyRent,
                paidAmount: 0,
                remainingRent: _room.monthlyRent,
              ),
              lastRentPayment,
            ),
          ),
          const SizedBox(height: 12),
          _depositCard(),
          if (_room.isOccupied && widget.canManage) ...[
            const SizedBox(height: 12),
            _actionsCard(),
          ],
          const SizedBox(height: 24),
          _historySection(),
        ],
      ),
    );
  }

  Widget _tenantCard() {
    final hasPhone = _room.tenantPhone.trim().isNotEmpty;
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _room.displayName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              _statusChip(
                _room.isOccupied ? 'Occupied' : 'Vacant',
                _room.isOccupied ? AppColors.success : AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_room.isOccupied) ...[
            const Text(
              'TENANT',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _room.tenantName.trim().isEmpty
                  ? 'Tenant name not provided'
                  : _room.tenantName,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 3),
            Text(
              hasPhone ? _room.tenantPhone : 'Phone number not provided',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _quickAction(
                    icon: Icons.call_outlined,
                    label: 'Call',
                    onPressed: hasPhone ? () => _callTenant() : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _quickAction(
                    icon: Icons.chat_outlined,
                    label: 'WhatsApp',
                    onPressed: hasPhone ? () => _whatsappTenant() : null,
                  ),
                ),
                if (widget.canManage) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _quickAction(
                      icon: Icons.edit_outlined,
                      label: 'Edit Room',
                      onPressed: _editRoom,
                    ),
                  ),
                ],
              ],
            ),
          ] else ...[
            const Text(
              'Ready for occupancy',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.canManage) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: _quickAction(
                  icon: Icons.edit_outlined,
                  label: 'Edit Room',
                  onPressed: _editRoom,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _rentCard(RentPaymentSummary summary, DateTime? lastPayment) {
    final collected = _room.isOccupied ? summary.paidAmount : 0.0;
    final pending = _room.isOccupied ? summary.remainingRent : 0.0;
    final isCollected = pending <= 0 && _room.monthlyRent > 0;
    return _sectionCard(
      title: 'Rent Information',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _metric(
                    'Monthly Rent', _room.monthlyRent, AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: _metric('Collected', collected, AppColors.success)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _metric('Pending', pending, AppColors.warningDark)),
              const SizedBox(width: 10),
              Expanded(
                child: _dateMetric(
                  lastPayment == null
                      ? 'No payment yet'
                      : DateFormat('dd MMM yyyy').format(lastPayment),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: _statusChip(
              _room.isVacant
                  ? 'Vacant'
                  : isCollected
                      ? 'Collected'
                      : 'Pending',
              _room.isVacant
                  ? AppColors.error
                  : isCollected
                      ? AppColors.success
                      : AppColors.warningDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _depositCard() {
    final hasDeposit =
        _room.depositType != DepositTypes.none && _room.depositAmount > 0;
    return _sectionCard(
      title: 'Deposit Information',
      child: hasDeposit
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: _money(_room.depositAmount, size: 34)),
                    _statusChip(
                      _room.depositStatus,
                      _depositStatusColor(_room.depositStatus),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  '${_room.depositType} deposit',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_room.depositDate != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Collected on',
                    style:
                        TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd MMM yyyy').format(_room.depositDate!),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
                if (_room.depositNotes.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    _room.depositNotes,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ],
            )
          : const Text(
              'No tenant deposit recorded.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
    );
  }

  Widget _actionsCard() {
    final hasHeldDeposit =
        _room.depositAmount > 0 && _room.depositStatus == DepositStatuses.held;
    return _sectionCard(
      title: 'Room Actions',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasHeldDeposit) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Deposit Held',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  _money(_room.depositAmount, size: 24),
                  const SizedBox(height: 6),
                  const Text(
                    'Refund will be processed during vacating.',
                    style:
                        TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _vacateRoom,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Vacate Tenant'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _historySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tenant History',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 10),
        if (_room.tenantHistory.isEmpty)
          _sectionCard(
            child: const Text(
              'No previous tenant records.\n\nHistory will appear after the first tenant vacates.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          )
        else ...[
          if (_room.isOccupied) _currentTenantHistoryCard(),
          ..._room.tenantHistory.reversed.map(_historyCard),
        ],
      ],
    );
  }

  Widget _historyCard(TenantHistory history) {
    final start = history.moveInDate == null
        ? 'Unknown'
        : DateFormat('MMM yyyy').format(history.moveInDate!);
    final end = DateFormat('MMM yyyy').format(history.moveOutDate);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _sectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              history.tenantName,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              '$start -> $end',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                    child: _historyMetric('Deposit', history.depositAmount)),
                _statusChip(
                  history.depositStatus,
                  _depositStatusColor(history.depositStatus),
                ),
              ],
            ),
            if (history.refundAmount > 0 || history.retainedAmount > 0) ...[
              const SizedBox(height: 12),
              Text(
                'Refunded ${CurrencyFormatter.format(history.refundAmount)}  |  '
                'Retained ${CurrencyFormatter.format(history.retainedAmount)}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
            if (history.notes.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(history.notes,
                  style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _currentTenantHistoryCard() {
    final startDate = _room.moveInDate ?? _room.contractStartDate;
    final start = startDate == null
        ? 'Unknown'
        : DateFormat('MMM yyyy').format(startDate);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _sectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _room.tenantName,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              '$start -> Present',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _historyMetric('Deposit', _room.depositAmount)),
                _statusChip(
                  _room.depositStatus,
                  _depositStatusColor(_room.depositStatus),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({String? title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: FittedBox(child: Text(label)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _metric(String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          const SizedBox(height: 5),
          _money(amount, size: 17),
        ],
      ),
    );
  }

  Widget _dateMetric(String value) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Last Payment',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyMetric(String label, double amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 2),
        _money(amount, size: 17),
      ],
    );
  }

  Widget _money(double amount, {required double size}) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: CurrencyFormatter.formatAmount(amount),
            style: TextStyle(fontSize: size, fontWeight: FontWeight.w800),
          ),
          TextSpan(
            text: ' QAR',
            style: TextStyle(
              fontSize: size * 0.45,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }

  Color _depositStatusColor(String status) {
    switch (status) {
      case DepositStatuses.refunded:
        return AppColors.success;
      case DepositStatuses.partiallyRefunded:
        return AppColors.warningDark;
      case DepositStatuses.forfeited:
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  Future<void> _callTenant() async {
    if (!await _contactService.callTenant(_room.tenantPhone) && mounted) {
      _showMessage('Unable to open the phone app.');
    }
  }

  Future<void> _whatsappTenant() async {
    if (!await _contactService.whatsappTenant(phone: _room.tenantPhone) &&
        mounted) {
      _showMessage('Unable to open WhatsApp.');
    }
  }

  Future<void> _editRoom() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditRoomScreen(room: _room, villaId: _room.villaId),
      ),
    );
    ref.invalidate(roomByIdProvider(_room.id));
    final refreshed = await ref.read(roomByIdProvider(_room.id).future);
    if (mounted && refreshed != null) {
      setState(() => _room = refreshed);
    }
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
      moveInDate: _room.moveInDate ?? _room.contractStartDate,
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
      clearMoveInDate: true,
      moveOutDate: now,
      lastTenantName: _room.tenantName,
      lastTenantPhone: _room.tenantPhone,
      depositType: result.noDeposit ? DepositTypes.none : _room.depositType,
      depositAmount: result.noDeposit ? 0 : _room.depositAmount,
      clearDepositDate: result.noDeposit,
      depositStatus: result.status,
      clearDepositIncomeId: true,
      clearDepositRefundExpenseId: true,
      refundAmount: result.refundAmount,
      retainedAmount: result.retainedAmount,
      depositReason: result.reason,
      tenantHistory: [..._room.tenantHistory, history],
      updatedAt: now,
    );

    await ref.read(updateRoomProvider(updated).future);
    if (!mounted) return;
    setState(() => _room = updated);
    _showMessage('Tenant vacated successfully.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SectionLoading extends StatelessWidget {
  final String title;

  const _SectionLoading({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const Spacer(),
          const Center(child: CircularProgressIndicator()),
          const Spacer(),
        ],
      ),
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

  double get _partialRefund => double.tryParse(_refundController.text) ?? 0;
  double get _retained =>
      (widget.depositAmount - _partialRefund).clamp(0, widget.depositAmount);

  @override
  void initState() {
    super.initState();
    _action = widget.depositAmount > 0 ? 'Fully Refunded' : 'No Deposit';
    _refundController.addListener(_refreshAmounts);
  }

  @override
  void dispose() {
    _refundController.removeListener(_refreshAmounts);
    _refundController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _refreshAmounts() => setState(() => _error = null);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Vacate Tenant'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Deposit Held',
                      style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(
                    '${CurrencyFormatter.formatAmount(widget.depositAmount)} QAR',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _action,
              decoration: const InputDecoration(labelText: 'Refund Action'),
              items: _actions
                  .map((action) =>
                      DropdownMenuItem(value: action, child: Text(action)))
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
              const SizedBox(height: 10),
              Text(
                'Retained: ${CurrencyFormatter.formatAmount(_retained)} QAR',
                style: const TextStyle(fontWeight: FontWeight.w700),
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
            const SizedBox(height: 14),
            const Text(
              'The room will become vacant. Tenant history and all financial records will be preserved.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: AppColors.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(onPressed: _confirm, child: const Text('Confirm Vacate')),
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
        refund = _partialRefund;
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
        status = DepositStatuses.none;
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

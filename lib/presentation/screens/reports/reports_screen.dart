import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_permissions.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/services/profit_calculation_service.dart';
import '../../../data/services/report_export_service.dart';
import '../../../domain/models/expense.dart';
import '../../../domain/models/income.dart';
import '../../../domain/models/report_models.dart';
import '../../../domain/models/room.dart';
import '../../../domain/models/room_profit_summary.dart';
import '../../../domain/models/villa_model.dart';
import '../../providers/expense_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/income_provider.dart';
import '../../providers/room_provider.dart';
import '../../providers/villa_provider.dart';
import '../villa_detail_screen.dart';
import '../common/access_denied_screen.dart';
import '../../widgets/premium_widgets.dart';
import '../../widgets/reports/expense_report_view.dart';
import '../../widgets/reports/income_report_view.dart';
import '../../widgets/reports/pending_rent_report_view.dart';
import '../../widgets/reports/room_wise_profit_report.dart';
import '../../widgets/reports/villa_wise_profit_report.dart';
import '../../widgets/reports/yearly_summary_report.dart';
import '../../widgets/currency_amount_text.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final ReportExportService _exportService = ReportExportService();
  final ProfitCalculationService _profitService =
      const ProfitCalculationService();
  final DateFormat _monthFormat = DateFormat('MMMM yyyy');
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  late DateTime _selectedMonth;
  late int _selectedYear;
  ReportType _selectedReportType = ReportType.monthlySummary;
  _ReportPeriod _selectedPeriod = _ReportPeriod.thisMonth;
  String? _selectedVillaId;
  String? _selectedRoomId;
  String _selectedStatus = 'All';
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _selectedMonth = ref.read(selectedMonthProvider);
    _selectedYear = _selectedMonth.year;
  }

  @override
  Widget build(BuildContext context) {
    final villasAsync = ref.watch(villasProvider);
    final roomsAsync = ref.watch(allRoomsProvider);
    final incomesAsync = ref.watch(incomeListProvider);
    final expenses = ref.watch(expenseProvider);
    final authState = ref.watch(authProvider);
    final canViewReports = authState.hasPermission(AppPermissions.viewReports);
    final canExportReports =
        authState.hasPermission(AppPermissions.exportReports);

    if (!canViewReports) {
      return const AccessDeniedScreen();
    }

    return PremiumScaffold(
      body: villasAsync.when(
        data: (villas) => roomsAsync.when(
          data: (rooms) => incomesAsync.when(
            data: (incomes) {
              final reportData =
                  _buildReportData(villas, rooms, incomes, expenses);

              return ListView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 142),
                children: [
                  _ReportsHeader(
                    title: 'Reports',
                    subtitle: 'Property Financial Overview',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (canExportReports) ...[
                          _CircleIconButton(
                            icon: Icons.picture_as_pdf_rounded,
                            tooltip: 'Export PDF',
                            onPressed: _isExporting
                                ? null
                                : () => _export(
                                      villasAsync.valueOrNull ?? const [],
                                      roomsAsync.valueOrNull ?? const [],
                                      incomesAsync.valueOrNull ?? const [],
                                      expenses,
                                      ExportFormat.pdf,
                                    ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        _CircleIconButton(
                          icon: Icons.tune_rounded,
                          tooltip: 'Filters',
                          onPressed: () => _showFiltersSheet(
                            villas: villas,
                            rooms: rooms,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _PeriodPills(
                    selectedPeriod: _selectedPeriod,
                    onSelected: (period) =>
                        _selectPeriod(period, villas, rooms),
                  ),
                  const SizedBox(height: 16),
                  _buildSelectedReport(reportData),
                ],
              );
            },
            error: (error, _) => Center(child: Text(error.toString())),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Center(child: Text(error.toString())),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Center(child: Text(error.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  _ReportData _buildReportData(
    List<VillaModel> villas,
    List<Room> rooms,
    List<Income> incomes,
    List<Expense> expenses,
  ) {
    final filteredRooms = _filteredRooms(rooms);
    final activeVillaIds = villas.map((villa) => villa.id).toSet();
    final activeRooms = filteredRooms
        .where(
            (room) => !room.isDeleted && activeVillaIds.contains(room.villaId))
        .toList();
    final activeRoomIds = activeRooms.map((room) => room.id).toSet();
    final activeIncomes = incomes.where((income) {
      if (income.isDeleted) return false;
      if (_isDepositIncome(income)) return false;
      if (!activeVillaIds.contains(income.villaId)) return false;
      if (income.roomId.trim().isEmpty) return true;
      return activeRoomIds.contains(income.roomId);
    }).toList();
    final activeExpenses = expenses.where((expense) {
      if (expense.isDeleted) return false;
      if (_isDepositRefundExpense(expense)) return false;
      final villaId = expense.villaId;
      if (villaId == null || villaId.trim().isEmpty) return true;
      if (!activeVillaIds.contains(villaId)) return false;
      final roomId = expense.roomId;
      if (roomId == null || roomId.trim().isEmpty) return true;
      return activeRoomIds.contains(roomId);
    }).toList();
    final roomSummaries = _profitService.calculateRoomProfitSummaries(
      rooms: activeRooms,
      incomes: activeIncomes,
      expenses: activeExpenses,
      month: _selectedMonth,
      status: _selectedStatus,
    );
    final roomTotals = _profitService.calculateRoomProfitTotals(roomSummaries);
    final monthlyIncomes = activeIncomes
        .where((income) =>
            _isSameMonth(income.paymentDate, _selectedMonth) &&
            _matchesIncomeFilters(income))
        .toList();
    final monthlyExpenses = activeExpenses
        .where((expense) =>
            _isSameMonth(expense.expenseDate, _selectedMonth) &&
            _matchesExpenseFilters(expense))
        .toList();
    final totalIncome =
        monthlyIncomes.fold<double>(0, (sum, income) => sum + income.amount);
    final totalExpenses =
        monthlyExpenses.fold<double>(0, (sum, expense) => sum + expense.amount);

    final monthlySummary = MonthlySummaryReportData(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      netProfit: totalIncome - totalExpenses,
      totalRoomRent: activeRooms.fold<double>(
        0,
        (sum, room) => sum + room.monthlyRent,
      ),
      expectedRent: roomTotals.expectedRent,
      pendingRent: roomTotals.pendingRent,
      vacancyLoss: roomTotals.vacancyLoss,
      rentCollectionPercentage: roomTotals.rentCollectionPercentage,
    );

    final scopedVillas = _selectedVillaId == null
        ? villas
        : villas.where((villa) => villa.id == _selectedVillaId).toList();
    final villaProfitItems = scopedVillas.map((villa) {
      final villaIncomes =
          monthlyIncomes.where((income) => income.villaId == villa.id).toList();
      final villaExpenses = monthlyExpenses
          .where((expense) => expense.villaId == villa.id)
          .toList();
      final villaIncome =
          villaIncomes.fold<double>(0, (sum, income) => sum + income.amount);
      final villaExpense =
          villaExpenses.fold<double>(0, (sum, expense) => sum + expense.amount);
      final villaRoomSummaries =
          roomSummaries.where((item) => item.villaId == villa.id).toList();
      final villaExpectedRent = villaRoomSummaries.fold<double>(
        0,
        (sum, item) => sum + item.expectedRent,
      );
      final villaPendingRent = villaRoomSummaries.fold<double>(
        0,
        (sum, item) => sum + item.pendingRent,
      );
      final villaVacancyLoss = villaRoomSummaries.fold<double>(
        0,
        (sum, item) => sum + item.vacancyLoss,
      );
      final occupiedRooms =
          villaRoomSummaries.where((item) => item.isOccupied).length;
      final vacantRooms =
          villaRoomSummaries.where((item) => item.isVacant).length;

      return VillaProfitReportItem(
        villaId: villa.id,
        villaName: villa.villaName,
        totalRooms: villaRoomSummaries.length,
        occupiedRooms: occupiedRooms,
        vacantRooms: vacantRooms,
        expectedRent: villaExpectedRent,
        receivedIncome: villaIncome,
        totalExpense: villaExpense,
        netProfit: villaIncome - villaExpense,
        pendingAmount: villaPendingRent,
        vacancyLoss: villaVacancyLoss,
      );
    }).toList();

    final pendingRentItems = roomSummaries
        .where((item) => item.isOccupied)
        .map(
          (item) => PendingRentReportItem(
            villaName: '${item.villaName} > ${item.displayRoomName}',
            tenantName: item.tenantName,
            expectedRent: item.expectedRent,
            receivedRent: item.rentReceived,
            pendingRent: item.pendingRent,
            dueDay: item.paymentDueDay,
          ),
        )
        .where((item) => item.pendingRent > 0)
        .toList();
    final roomProfitItems = roomSummaries.map(_toRoomReportItem).toList();
    final vacancyItems =
        roomProfitItems.where((item) => item.isVacant).toList();

    final yearlyItems = List.generate(12, (index) {
      final month = DateTime(_selectedYear, index + 1, 1);
      final income = activeIncomes
          .where((item) =>
              _isSameMonth(item.paymentDate, month) &&
              _matchesIncomeFilters(item))
          .fold<double>(0, (sum, item) => sum + item.amount);
      final expense = activeExpenses
          .where((item) =>
              _isSameMonth(item.expenseDate, month) &&
              _matchesExpenseFilters(item))
          .fold<double>(0, (sum, item) => sum + item.amount);

      return YearlySummaryReportItem(
        month: month,
        income: income,
        expense: expense,
        profit: income - expense,
      );
    });

    return _ReportData(
      monthlySummary: monthlySummary,
      villaProfitItems: villaProfitItems,
      roomProfitItems: roomProfitItems,
      vacancyItems: vacancyItems,
      monthlyIncomes: monthlyIncomes,
      monthlyExpenses: monthlyExpenses,
      pendingRentItems: pendingRentItems,
      yearlyItems: yearlyItems,
      depositRooms: activeRooms
          .where((room) => room.depositType != DepositTypes.none)
          .toList(),
    );
  }

  Widget _buildSelectedReport(_ReportData data) {
    switch (_selectedReportType) {
      case ReportType.monthlySummary:
        return _DashboardReportView(
          data: data,
          money: _money,
          dateFormat: _dateFormat,
          periodLabel: _monthFormat.format(_selectedMonth),
          onVillaTap: (item) => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => VillaDetailScreen(villaId: item.villaId),
            ),
          ),
        );
      case ReportType.villaWiseProfit:
        return VillaWiseProfitReport(items: data.villaProfitItems);
      case ReportType.roomWiseProfit:
        return RoomWiseProfitReport(items: data.roomProfitItems);
      case ReportType.incomeReport:
        return IncomeReportView(incomes: data.monthlyIncomes);
      case ReportType.expenseReport:
        return ExpenseReportView(expenses: data.monthlyExpenses);
      case ReportType.pendingRentReport:
        return PendingRentReportView(items: data.pendingRentItems);
      case ReportType.vacancyReport:
        return RoomWiseProfitReport(items: data.vacancyItems);
      case ReportType.yearlySummary:
        return YearlySummaryReport(items: data.yearlyItems);
      case ReportType.depositReport:
        return _DepositReportView(rooms: data.depositRooms);
    }
  }

  void _selectPeriod(
    _ReportPeriod period,
    List<VillaModel> villas,
    List<Room> rooms,
  ) {
    final now = DateTime.now();
    setState(() {
      _selectedPeriod = period;
      switch (period) {
        case _ReportPeriod.today:
        case _ReportPeriod.thisMonth:
          _selectedMonth = DateTime(now.year, now.month, 1);
          _selectedYear = now.year;
          _selectedReportType = ReportType.monthlySummary;
          break;
        case _ReportPeriod.last3Months:
          _selectedMonth = DateTime(now.year, now.month - 2, 1);
          _selectedYear = _selectedMonth.year;
          _selectedReportType = ReportType.monthlySummary;
          break;
        case _ReportPeriod.thisYear:
          _selectedYear = now.year;
          _selectedMonth = DateTime(now.year, now.month, 1);
          _selectedReportType = ReportType.yearlySummary;
          break;
        case _ReportPeriod.custom:
          break;
      }
    });
    ref.read(selectedMonthProvider.notifier).state = _selectedMonth;

    if (period == _ReportPeriod.custom) {
      _showFiltersSheet(villas: villas, rooms: rooms);
    }
  }

  void _showFiltersSheet({
    required List<VillaModel> villas,
    required List<Room> rooms,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 14,
              right: 14,
              bottom: MediaQuery.viewInsetsOf(context).bottom + 14,
            ),
            child: Material(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(28),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _Filters(
                  selectedMonth: _selectedMonth,
                  selectedYear: _selectedYear,
                  selectedReportType: _selectedReportType,
                  villas: villas,
                  rooms: rooms,
                  selectedVillaId: _selectedVillaId,
                  selectedRoomId: _selectedRoomId,
                  selectedStatus: _selectedStatus,
                  onPreviousMonth: () => _changeMonth(-1),
                  onNextMonth: () => _changeMonth(1),
                  onYearChanged: (year) {
                    if (year == null) return;
                    setState(() => _selectedYear = year);
                  },
                  onReportTypeChanged: (type) {
                    if (type == null) return;
                    setState(() => _selectedReportType = type);
                    Navigator.of(context).pop();
                  },
                  onVillaChanged: (villaId) {
                    setState(() {
                      _selectedVillaId = villaId;
                      _selectedRoomId = null;
                    });
                  },
                  onRoomChanged: (roomId) {
                    setState(() => _selectedRoomId = roomId);
                  },
                  onStatusChanged: (status) {
                    if (status == null) return;
                    setState(() => _selectedStatus = status);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _export(
    List<VillaModel> villas,
    List<Room> rooms,
    List<Income> incomes,
    List<Expense> expenses,
    ExportFormat format,
  ) async {
    setState(() => _isExporting = true);
    try {
      final data = _buildReportData(villas, rooms, incomes, expenses);
      final exportData = _buildExportData(data);
      final title =
          '${_selectedReportType.label} - ${_selectedReportType == ReportType.yearlySummary ? _selectedYear : _monthFormat.format(_selectedMonth)}';

      if (format == ExportFormat.csv) {
        await _exportService.exportCsv(
          title: title,
          headers: exportData.headers,
          rows: exportData.rows,
        );
      } else {
        await _exportService.exportPdf(
          title: title,
          summaryLines: exportData.summaryLines,
          headers: exportData.headers,
          rows: exportData.rows,
          period: _selectedReportType == ReportType.yearlySummary
              ? _selectedYear.toString()
              : _monthFormat.format(_selectedMonth),
          villaProfitItems: _selectedReportType == ReportType.villaWiseProfit
              ? data.villaProfitItems
              : null,
          roomProfitItems: _selectedReportType == ReportType.roomWiseProfit
              ? data.roomProfitItems
              : null,
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  _ExportData _buildExportData(_ReportData data) {
    switch (_selectedReportType) {
      case ReportType.monthlySummary:
        return _ExportData(
          headers: const ['Metric', 'Value'],
          rows: [
            ['Total Income', _money(data.monthlySummary.totalIncome)],
            ['Total Expenses', _money(data.monthlySummary.totalExpenses)],
            ['Net Profit', _money(data.monthlySummary.netProfit)],
            ['Total Room Rent', _money(data.monthlySummary.totalRoomRent)],
            ['Expected Rent', _money(data.monthlySummary.expectedRent)],
            ['Pending Rent', _money(data.monthlySummary.pendingRent)],
            ['Vacancy Loss', _money(data.monthlySummary.vacancyLoss)],
            [
              'Rent Collection',
              '${data.monthlySummary.rentCollectionPercentage.toStringAsFixed(1)}%',
            ],
          ],
          summaryLines: [
            'Period: ${_monthFormat.format(_selectedMonth)}',
          ],
        );
      case ReportType.villaWiseProfit:
        return _ExportData(
          headers: const [
            'Villa',
            'Expected Rent',
            'Received Income',
            'Total Expense',
            'Net Profit',
            'Pending',
            'Vacancy Loss',
          ],
          rows: data.villaProfitItems
              .map(
                (item) => [
                  item.villaName,
                  _money(item.expectedRent),
                  _money(item.receivedIncome),
                  _money(item.totalExpense),
                  _money(item.netProfit),
                  _money(item.pendingAmount),
                  _money(item.vacancyLoss),
                ],
              )
              .toList(),
          summaryLines: ['Period: ${_monthFormat.format(_selectedMonth)}'],
        );
      case ReportType.roomWiseProfit:
        return _roomWiseExportData(data.roomProfitItems);
      case ReportType.incomeReport:
        return _ExportData(
          headers: const ['Date', 'Villa', 'Type', 'Payment Method', 'Amount'],
          rows: data.monthlyIncomes
              .map(
                (income) => [
                  _dateFormat.format(income.paymentDate),
                  income.villaName,
                  income.incomeType,
                  income.paymentMethod,
                  _money(income.amount),
                ],
              )
              .toList(),
          summaryLines: ['Period: ${_monthFormat.format(_selectedMonth)}'],
        );
      case ReportType.expenseReport:
        return _ExportData(
          headers: const [
            'Date',
            'Villa / General',
            'Category',
            'Paid To',
            'Amount'
          ],
          rows: data.monthlyExpenses
              .map(
                (expense) => [
                  _dateFormat.format(expense.expenseDate),
                  expense.villaName,
                  expense.category,
                  expense.paidTo,
                  _money(expense.amount),
                ],
              )
              .toList(),
          summaryLines: ['Period: ${_monthFormat.format(_selectedMonth)}'],
        );
      case ReportType.pendingRentReport:
        return _ExportData(
          headers: const [
            'Villa / Room',
            'Tenant',
            'Expected Rent',
            'Received Rent',
            'Pending Rent',
            'Due Day',
          ],
          rows: data.pendingRentItems
              .map(
                (item) => [
                  item.villaName,
                  item.tenantName,
                  _money(item.expectedRent),
                  _money(item.receivedRent),
                  _money(item.pendingRent),
                  item.dueDay.toString(),
                ],
              )
              .toList(),
          summaryLines: ['Period: ${_monthFormat.format(_selectedMonth)}'],
        );
      case ReportType.vacancyReport:
        return _roomWiseExportData(data.vacancyItems);
      case ReportType.yearlySummary:
        return _ExportData(
          headers: const ['Month', 'Income', 'Expense', 'Profit'],
          rows: data.yearlyItems
              .map(
                (item) => [
                  DateFormat('MMMM').format(item.month),
                  _money(item.income),
                  _money(item.expense),
                  _money(item.profit),
                ],
              )
              .toList(),
          summaryLines: ['Year: $_selectedYear'],
        );
      case ReportType.depositReport:
        return _ExportData(
          headers: const [
            'Villa',
            'Room',
            'Tenant',
            'Deposit Type',
            'Amount',
            'Status',
            'Refund Amount',
            'Retained Amount',
          ],
          rows: data.depositRooms
              .map(
                (room) => [
                  room.villaName,
                  room.displayName,
                  room.tenantName.isEmpty
                      ? room.lastTenantName
                      : room.tenantName,
                  room.depositType,
                  _money(room.depositAmount),
                  room.depositStatus,
                  _money(room.refundAmount),
                  _money(room.retainedAmount),
                ],
              )
              .toList(),
          summaryLines: const ['Deposits are tracking records, not income.'],
        );
    }
  }

  _ExportData _roomWiseExportData(List<RoomWiseProfitReportItem> items) {
    return _ExportData(
      headers: const [
        'Villa',
        'Room',
        'Tenant',
        'Status',
        'Expected Rent',
        'Rent Received',
        'Other Income',
        'Expenses',
        'Pending Rent',
        'Vacancy Loss',
        'Actual Profit',
        'Expected Profit',
      ],
      rows: items
          .map(
            (item) => [
              item.villaName,
              item.displayRoomName,
              item.tenantName,
              item.status,
              _money(item.expectedRent),
              _money(item.rentReceived),
              _money(item.otherIncome),
              _money(item.totalExpenses),
              _money(item.pendingRent),
              _money(item.vacancyLoss),
              _money(item.actualProfit),
              _money(item.expectedProfit),
            ],
          )
          .toList(),
      summaryLines: ['Period: ${_monthFormat.format(_selectedMonth)}'],
    );
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + offset,
        1,
      );
      _selectedYear = _selectedMonth.year;
    });
    ref.read(selectedMonthProvider.notifier).state = _selectedMonth;
  }

  bool _isSameMonth(DateTime date, DateTime month) {
    return date.year == month.year && date.month == month.month;
  }

  String _money(double value) => CurrencyFormatter.formatQAR(value);

  bool _isDepositIncome(Income income) {
    return income.incomeType.toLowerCase() == IncomeTypes.deposit.toLowerCase();
  }

  bool _isDepositRefundExpense(Expense expense) {
    return expense.category.toLowerCase() ==
        ExpenseCategories.depositRefund.toLowerCase();
  }

  List<Room> _filteredRooms(List<Room> rooms) {
    return rooms.where((room) {
      if (room.isDeleted) return false;
      if (_selectedVillaId != null && room.villaId != _selectedVillaId) {
        return false;
      }
      if (_selectedRoomId != null && room.id != _selectedRoomId) {
        return false;
      }
      if (_selectedStatus != 'All' && room.status != _selectedStatus) {
        return false;
      }
      return true;
    }).toList();
  }

  bool _matchesIncomeFilters(Income income) {
    if (_selectedVillaId != null && income.villaId != _selectedVillaId) {
      return false;
    }
    if (_selectedRoomId != null && income.roomId != _selectedRoomId) {
      return false;
    }
    if (_selectedStatus == 'All') return true;
    return true;
  }

  bool _matchesExpenseFilters(Expense expense) {
    if (_selectedVillaId != null && expense.villaId != _selectedVillaId) {
      return false;
    }
    if (_selectedRoomId != null && expense.roomId != _selectedRoomId) {
      return false;
    }
    return true;
  }

  RoomWiseProfitReportItem _toRoomReportItem(RoomProfitSummary summary) {
    return RoomWiseProfitReportItem(
      villaId: summary.villaId,
      villaName: summary.villaName,
      roomId: summary.roomId,
      roomName: summary.roomName,
      tenantName: summary.tenantName,
      status: summary.status,
      expectedRent: summary.expectedRent,
      rentReceived: summary.rentReceived,
      otherIncome: summary.otherIncome,
      totalExpenses: summary.totalExpenses,
      pendingRent: summary.pendingRent,
      vacancyLoss: summary.vacancyLoss,
      actualProfit: summary.actualProfit,
      expectedProfit: summary.expectedProfit,
      rentCollectionPercentage: summary.rentCollectionPercentage,
    );
  }
}

enum ExportFormat { pdf, csv }

enum _ReportPeriod {
  today('Today'),
  thisMonth('This Month'),
  last3Months('Last 3 Months'),
  thisYear('This Year'),
  custom('Custom');

  final String label;

  const _ReportPeriod(this.label);
}

class _ReportsHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget trailing;

  const _ReportsHeader({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1.02,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        trailing,
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _CircleIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: _ReportSurface.shadow,
            ),
            child: Icon(icon, color: const Color(0xFF1F2937), size: 21),
          ),
        ),
      ),
    );
  }
}

class _PeriodPills extends StatelessWidget {
  final _ReportPeriod selectedPeriod;
  final ValueChanged<_ReportPeriod> onSelected;

  const _PeriodPills({
    required this.selectedPeriod,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final period in _ReportPeriod.values) ...[
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: selectedPeriod == period
                    ? const Color(0xFFEAF2FF)
                    : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selectedPeriod == period
                      ? const Color(0xFFBFD8FF)
                      : const Color(0xFFE7EAF0),
                ),
                boxShadow:
                    selectedPeriod == period ? _ReportSurface.shadow : null,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => onSelected(period),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    period.label,
                    style: TextStyle(
                      color: selectedPeriod == period
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF4B5563),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DashboardReportView extends StatelessWidget {
  final _ReportData data;
  final String Function(double value) money;
  final DateFormat dateFormat;
  final String periodLabel;
  final ValueChanged<VillaProfitReportItem> onVillaTap;

  const _DashboardReportView({
    required this.data,
    required this.money,
    required this.dateFormat,
    required this.periodLabel,
    required this.onVillaTap,
  });

  @override
  Widget build(BuildContext context) {
    final sortedVillas = [...data.villaProfitItems]
      ..sort((a, b) => b.netProfit.compareTo(a.netProfit));
    final transactions = _recentTransactions();
    final occupiedRooms =
        data.roomProfitItems.where((item) => item.isOccupied).length;
    final vacantRooms =
        data.roomProfitItems.where((item) => item.isVacant).length;
    final totalRooms = occupiedRooms + vacantRooms;
    final occupancyRate = totalRooms == 0 ? 0.0 : occupiedRooms / totalRooms;
    final hasData = data.monthlySummary.totalIncome != 0 ||
        data.monthlySummary.totalExpenses != 0 ||
        data.monthlySummary.expectedRent != 0 ||
        sortedVillas.isNotEmpty ||
        transactions.isNotEmpty;

    if (!hasData) {
      return const _EmptyReportsState();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: Column(
        key: ValueKey(periodLabel),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PeriodLabel(label: periodLabel),
          const SizedBox(height: 12),
          _SummaryGrid(summary: data.monthlySummary, money: money),
          const SizedBox(height: 16),
          _FinancialPerformanceCard(summary: data.monthlySummary),
          const SizedBox(height: 16),
          _OccupancyCard(
            occupiedRooms: occupiedRooms,
            vacantRooms: vacantRooms,
            occupancyRate: occupancyRate,
          ),
          const SizedBox(height: 22),
          _PropertyPerformanceSection(
            items: sortedVillas,
            money: money,
            onTap: onVillaTap,
          ),
          const SizedBox(height: 22),
          _RecentTransactionsSection(
            transactions: transactions,
            money: money,
            dateFormat: dateFormat,
          ),
        ],
      ),
    );
  }

  List<_ReportTransaction> _recentTransactions() {
    final transactions = <_ReportTransaction>[
      ...data.monthlyIncomes.map(
        (income) => _ReportTransaction(
          date: income.paymentDate,
          description: income.incomeType,
          type: 'Income',
          amount: income.amount,
          isIncome: true,
        ),
      ),
      ...data.monthlyExpenses.map(
        (expense) => _ReportTransaction(
          date: expense.expenseDate,
          description: expense.category,
          type: 'Expense',
          amount: expense.amount,
          isIncome: false,
        ),
      ),
    ]..sort((a, b) => b.date.compareTo(a.date));
    return transactions.take(6).toList();
  }
}

class _ReportSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  static List<BoxShadow> get shadow => [
        BoxShadow(
          color: const Color(0xFF64748B).withValues(alpha: 0.07),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];

  const _ReportSurface({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE9ECEF)),
        boxShadow: shadow,
      ),
      child: child,
    );
  }
}

class _PeriodLabel extends StatelessWidget {
  final String label;

  const _PeriodLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 13,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final MonthlySummaryReportData summary;
  final String Function(double value) money;

  const _SummaryGrid({
    required this.summary,
    required this.money,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _SummaryMetricCard(
              width: itemWidth,
              label: 'Total Income',
              value: summary.totalIncome,
              accent: _valueColor(summary.totalIncome, const Color(0xFF059669)),
              icon: Icons.trending_up_rounded,
            ),
            _SummaryMetricCard(
              width: itemWidth,
              label: 'Total Expenses',
              value: summary.totalExpenses,
              accent:
                  _valueColor(summary.totalExpenses, const Color(0xFFE5484D)),
              icon: Icons.trending_down_rounded,
            ),
            _SummaryMetricCard(
              width: itemWidth,
              label: 'Net Profit',
              value: summary.netProfit,
              accent: summary.netProfit == 0
                  ? const Color(0xFF6B7280)
                  : summary.netProfit > 0
                      ? const Color(0xFF059669)
                      : const Color(0xFFE5484D),
              icon: Icons.account_balance_wallet_rounded,
            ),
            _SummaryMetricCard(
              width: itemWidth,
              label: 'Pending Rent',
              value: summary.pendingRent,
              accent: _valueColor(summary.pendingRent, const Color(0xFFD97706)),
              icon: Icons.schedule_rounded,
            ),
          ],
        );
      },
    );
  }

  Color _valueColor(double value, Color color) {
    return value == 0 ? const Color(0xFF6B7280) : color;
  }
}

class _SummaryMetricCard extends StatelessWidget {
  final double width;
  final String label;
  final double value;
  final Color accent;
  final IconData icon;

  const _SummaryMetricCard({
    required this.width,
    required this.label,
    required this.value,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: _ReportSurface(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accent, size: 19),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: CurrencyAmountText(
                  amount: value,
                  amountColor: accent,
                  amountFontSize: 22,
                  currencyFontSize: 11,
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinancialPerformanceCard extends StatelessWidget {
  final MonthlySummaryReportData summary;

  const _FinancialPerformanceCard({
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final collectionProgress =
        (summary.rentCollectionPercentage / 100).clamp(0.0, 1.0);

    return _ReportSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Financial Performance'),
          const SizedBox(height: 16),
          _PerformanceRow(
            label: 'Expected Rent',
            value: summary.expectedRent,
            valueColor: const Color(0xFF0F2A4A),
          ),
          _PerformanceRow(
            label: 'Collected Rent',
            value: summary.totalIncome,
            valueColor: const Color(0xFF059669),
          ),
          _PerformanceRow(
            label: 'Pending Rent',
            value: summary.pendingRent,
            valueColor: const Color(0xFFF59E0B),
          ),
          _PerformanceRow(
            label: 'Vacancy Loss',
            value: summary.vacancyLoss,
            valueColor: const Color(0xFFE5484D),
            isLast: true,
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Rent Collection',
                  style: TextStyle(
                    color: Color(0xFF374151),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${summary.rentCollectionPercentage.toStringAsFixed(0)}% collected',
                style: const TextStyle(
                  color: Color(0xFF059669),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _AnimatedProgress(
            value: collectionProgress,
            color: const Color(0xFF059669),
          ),
        ],
      ),
    );
  }
}

class _PerformanceRow extends StatelessWidget {
  final String label;
  final double value;
  final Color valueColor;
  final bool isLast;

  const _PerformanceRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          CurrencyAmountText(
            amount: value,
            amountColor: valueColor,
            amountFontSize: 15,
            currencyFontSize: 9,
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

class _OccupancyCard extends StatelessWidget {
  final int occupiedRooms;
  final int vacantRooms;
  final double occupancyRate;

  const _OccupancyCard({
    required this.occupiedRooms,
    required this.vacantRooms,
    required this.occupancyRate,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (occupancyRate * 100).round();
    return _ReportSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Occupancy Overview'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _TinyStat(
                      label: 'Occupied Rooms', value: '$occupiedRooms')),
              Expanded(
                  child:
                      _TinyStat(label: 'Vacant Rooms', value: '$vacantRooms')),
              Expanded(
                  child: _TinyStat(label: 'Occupancy %', value: '$percent%')),
            ],
          ),
          const SizedBox(height: 16),
          _AnimatedProgress(
              value: occupancyRate, color: const Color(0xFF10B981), height: 12),
          const SizedBox(height: 10),
          Text(
            '$percent% Occupied',
            style: const TextStyle(
              color: Color(0xFF059669),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TinyStat extends StatelessWidget {
  final String label;
  final String value;

  const _TinyStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PropertyPerformanceSection extends StatelessWidget {
  final List<VillaProfitReportItem> items;
  final String Function(double value) money;
  final ValueChanged<VillaProfitReportItem> onTap;

  const _PropertyPerformanceSection({
    required this.items,
    required this.money,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _ReportSurface(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Property Performance'),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Text(
                'No properties found.',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            )
          else
            for (final item in items)
              _VillaPerformanceRow(
                item: item,
                money: money,
                onTap: () => onTap(item),
              ),
        ],
      ),
    );
  }
}

class _VillaPerformanceRow extends StatelessWidget {
  final VillaProfitReportItem item;
  final String Function(double value) money;
  final VoidCallback onTap;

  const _VillaPerformanceRow({
    required this.item,
    required this.money,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final profitColor =
        item.netProfit < 0 ? const Color(0xFFE5484D) : const Color(0xFF059669);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  item.villaName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _MoneyColumn(label: 'Income', value: item.receivedIncome),
              const SizedBox(width: 8),
              _MoneyColumn(label: 'Expenses', value: item.totalExpense),
              const SizedBox(width: 8),
              _MoneyColumn(
                label: 'Net Profit',
                value: item.netProfit,
                color: profitColor,
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoneyColumn extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MoneyColumn({
    required this.label,
    required this.value,
    this.color = const Color(0xFF111827),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CurrencyAmountText(
            amount: value,
            amountColor: color,
            amountFontSize: 12,
            currencyFontSize: 8,
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentTransactionsSection extends StatelessWidget {
  final List<_ReportTransaction> transactions;
  final String Function(double value) money;
  final DateFormat dateFormat;

  const _RecentTransactionsSection({
    required this.transactions,
    required this.money,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    return _ReportSurface(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Recent Transactions'),
          const SizedBox(height: 8),
          if (transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Text(
                'No transactions found.',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            )
          else
            for (var index = 0; index < transactions.length; index++)
              _TransactionRow(
                transaction: transactions[index],
                money: money,
                dateFormat: dateFormat,
                showDivider: index != transactions.length - 1,
              ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final _ReportTransaction transaction;
  final String Function(double value) money;
  final DateFormat dateFormat;
  final bool showDivider;

  const _TransactionRow({
    required this.transaction,
    required this.money,
    required this.dateFormat,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    final amountColor = transaction.isIncome
        ? const Color(0xFF059669)
        : const Color(0xFFE5484D);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 72,
                child: Text(
                  dateFormat.format(transaction.date),
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  transaction.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                transaction.type,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 96,
                child: CurrencyAmountText(
                  amount: transaction.amount,
                  amountColor: amountColor,
                  amountFontSize: 14,
                  currencyFontSize: 9,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: Color(0xFFE9ECEF)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF111827),
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _AnimatedProgress extends StatelessWidget {
  final double value;
  final Color color;
  final double height;

  const _AnimatedProgress({
    required this.value,
    required this.color,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: clamped),
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
        builder: (context, animatedValue, child) {
          return LinearProgressIndicator(
            value: animatedValue,
            minHeight: height,
            backgroundColor: const Color(0xFFE9ECEF),
            valueColor: AlwaysStoppedAnimation(color),
          );
        },
      ),
    );
  }
}

class _EmptyReportsState extends StatelessWidget {
  const _EmptyReportsState();

  @override
  Widget build(BuildContext context) {
    return _ReportSurface(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.insert_chart_outlined_rounded,
              color: Color(0xFF2563EB),
              size: 38,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No report data available',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add records to generate financial reports.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportTransaction {
  final DateTime date;
  final String description;
  final String type;
  final double amount;
  final bool isIncome;

  const _ReportTransaction({
    required this.date,
    required this.description,
    required this.type,
    required this.amount,
    required this.isIncome,
  });
}

class _Filters extends StatelessWidget {
  final DateTime selectedMonth;
  final int selectedYear;
  final ReportType selectedReportType;
  final List<VillaModel> villas;
  final List<Room> rooms;
  final String? selectedVillaId;
  final String? selectedRoomId;
  final String selectedStatus;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<int?> onYearChanged;
  final ValueChanged<ReportType?> onReportTypeChanged;
  final ValueChanged<String?> onVillaChanged;
  final ValueChanged<String?> onRoomChanged;
  final ValueChanged<String?> onStatusChanged;

  const _Filters({
    required this.selectedMonth,
    required this.selectedYear,
    required this.selectedReportType,
    required this.villas,
    required this.rooms,
    required this.selectedVillaId,
    required this.selectedRoomId,
    required this.selectedStatus,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onYearChanged,
    required this.onReportTypeChanged,
    required this.onVillaChanged,
    required this.onRoomChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final years = List.generate(8, (index) => now.year - 5 + index);
    final activeRooms = rooms.where((room) => !room.isDeleted).toList();
    final filteredRooms = selectedVillaId == null
        ? activeRooms
        : activeRooms.where((room) => room.villaId == selectedVillaId).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EAF0)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 820;
          final monthControl = Row(
            children: [
              IconButton(
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    DateFormat('MMMM yyyy').format(selectedMonth),
                    style: const TextStyle(
                      color: Color(0xFF060B26),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          );
          final yearControl = DropdownButtonFormField<int>(
            initialValue: selectedYear,
            decoration: _inputDecoration('Year'),
            items: years
                .map(
                  (year) => DropdownMenuItem(
                    value: year,
                    child: Text(year.toString()),
                  ),
                )
                .toList(),
            onChanged: onYearChanged,
          );
          final typeControl = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ReportType.values
                .map(
                  (type) => ChoiceChip(
                    label: Text(type.label),
                    selected: selectedReportType == type,
                    onSelected: (_) => onReportTypeChanged(type),
                    selectedColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.14),
                    labelStyle: TextStyle(
                      color: selectedReportType == type
                          ? Theme.of(context).colorScheme.primary
                          : const Color(0xFF646B7A),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
                .toList(),
          );
          final villaControl = DropdownButtonFormField<String?>(
            initialValue: selectedVillaId,
            decoration: _inputDecoration('Villa'),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All Villas'),
              ),
              ...villas.map(
                (villa) => DropdownMenuItem<String?>(
                  value: villa.id,
                  child: Text(villa.villaName),
                ),
              ),
            ],
            onChanged: onVillaChanged,
          );
          final roomControl = DropdownButtonFormField<String?>(
            initialValue: selectedRoomId,
            decoration: _inputDecoration('Room'),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All Rooms'),
              ),
              ...filteredRooms.map(
                (room) => DropdownMenuItem<String?>(
                  value: room.id,
                  child: Text(room.displayName),
                ),
              ),
            ],
            onChanged: onRoomChanged,
          );
          final statusControl = DropdownButtonFormField<String>(
            initialValue: selectedStatus,
            decoration: _inputDecoration('Status'),
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All')),
              DropdownMenuItem(value: 'Occupied', child: Text('Occupied')),
              DropdownMenuItem(value: 'Vacant', child: Text('Vacant')),
            ],
            onChanged: onStatusChanged,
          );

          if (isWide) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(flex: 2, child: monthControl),
                    const SizedBox(width: 12),
                    Expanded(child: yearControl),
                    const SizedBox(width: 12),
                    Expanded(child: villaControl),
                    const SizedBox(width: 12),
                    Expanded(child: roomControl),
                    const SizedBox(width: 12),
                    Expanded(child: statusControl),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: typeControl,
                ),
              ],
            );
          }

          return Column(
            children: [
              monthControl,
              const SizedBox(height: 12),
              yearControl,
              const SizedBox(height: 12),
              villaControl,
              const SizedBox(height: 12),
              roomControl,
              const SizedBox(height: 12),
              statusControl,
              const SizedBox(height: 12),
              typeControl,
            ],
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFFCFCFD),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE8EAF0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE8EAF0)),
      ),
    );
  }
}

class _ReportData {
  final MonthlySummaryReportData monthlySummary;
  final List<VillaProfitReportItem> villaProfitItems;
  final List<RoomWiseProfitReportItem> roomProfitItems;
  final List<RoomWiseProfitReportItem> vacancyItems;
  final List<Income> monthlyIncomes;
  final List<Expense> monthlyExpenses;
  final List<PendingRentReportItem> pendingRentItems;
  final List<YearlySummaryReportItem> yearlyItems;
  final List<Room> depositRooms;

  const _ReportData({
    required this.monthlySummary,
    required this.villaProfitItems,
    required this.roomProfitItems,
    required this.vacancyItems,
    required this.monthlyIncomes,
    required this.monthlyExpenses,
    required this.pendingRentItems,
    required this.yearlyItems,
    required this.depositRooms,
  });
}

class _DepositReportView extends StatelessWidget {
  final List<Room> rooms;

  const _DepositReportView({required this.rooms});

  @override
  Widget build(BuildContext context) {
    if (rooms.isEmpty) {
      return const _ReportSurface(
        padding: EdgeInsets.all(24),
        child: Text('No deposits found.'),
      );
    }
    return _ReportSurface(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Villa')),
            DataColumn(label: Text('Room')),
            DataColumn(label: Text('Tenant')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Refund')),
            DataColumn(label: Text('Retained')),
          ],
          rows: rooms
              .map(
                (room) => DataRow(
                  cells: [
                    DataCell(Text(room.villaName)),
                    DataCell(Text(room.displayName)),
                    DataCell(Text(
                      room.tenantName.isEmpty
                          ? room.lastTenantName
                          : room.tenantName,
                    )),
                    DataCell(Text(room.depositType)),
                    DataCell(
                        Text(CurrencyFormatter.format(room.depositAmount))),
                    DataCell(Text(room.depositStatus)),
                    DataCell(Text(CurrencyFormatter.format(room.refundAmount))),
                    DataCell(
                        Text(CurrencyFormatter.format(room.retainedAmount))),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _ExportData {
  final List<String> headers;
  final List<List<String>> rows;
  final List<String> summaryLines;

  const _ExportData({
    required this.headers,
    required this.rows,
    required this.summaryLines,
  });
}

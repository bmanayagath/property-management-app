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
import '../common/access_denied_screen.dart';
import '../../widgets/reports/expense_report_view.dart';
import '../../widgets/reports/income_report_view.dart';
import '../../widgets/reports/monthly_summary_report.dart';
import '../../widgets/reports/pending_rent_report_view.dart';
import '../../widgets/reports/room_wise_profit_report.dart';
import '../../widgets/reports/villa_wise_profit_report.dart';
import '../../widgets/reports/yearly_summary_report.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFD),
      appBar: AppBar(
        title: const Text('Reports'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Wrap(
              spacing: 8,
              children: [
                if (canExportReports) ...[
                  OutlinedButton.icon(
                    onPressed: _isExporting
                        ? null
                        : () => _export(
                              villasAsync.valueOrNull ?? const [],
                              roomsAsync.valueOrNull ?? const [],
                              incomesAsync.valueOrNull ?? const [],
                              expenses,
                              ExportFormat.pdf,
                            ),
                    icon: const Icon(Icons.picture_as_pdf_rounded),
                    label: const Text('Export PDF'),
                  ),
                  FilledButton.icon(
                    onPressed: _isExporting
                        ? null
                        : () => _export(
                              villasAsync.valueOrNull ?? const [],
                              roomsAsync.valueOrNull ?? const [],
                              incomesAsync.valueOrNull ?? const [],
                              expenses,
                              ExportFormat.csv,
                            ),
                    icon: const Icon(Icons.table_chart_rounded),
                    label: const Text('Export CSV'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF5549DE),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      body: villasAsync.when(
        data: (villas) => roomsAsync.when(
          data: (rooms) => incomesAsync.when(
            data: (incomes) {
              final reportData =
                  _buildReportData(villas, rooms, incomes, expenses);

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 116),
                children: [
                  _Filters(
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
                  const SizedBox(height: 16),
                  _ReportHeader(
                    title: _selectedReportType.label,
                    subtitle: _selectedReportType == ReportType.yearlySummary
                        ? '$_selectedYear'
                        : _monthFormat.format(_selectedMonth),
                  ),
                  const SizedBox(height: 14),
                  _buildReportView(reportData),
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
      if (!activeVillaIds.contains(income.villaId)) return false;
      if (income.roomId.trim().isEmpty) return true;
      return activeRoomIds.contains(income.roomId);
    }).toList();
    final activeExpenses = expenses.where((expense) {
      if (expense.isDeleted) return false;
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
    );
  }

  Widget _buildReportView(_ReportData data) {
    switch (_selectedReportType) {
      case ReportType.monthlySummary:
        return MonthlySummaryReport(data: data.monthlySummary);
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
    }
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

  List<Room> _filteredRooms(List<Room> rooms) {
    return rooms.where((room) {
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
    final filteredRooms = selectedVillaId == null
        ? rooms
        : rooms.where((room) => room.villaId == selectedVillaId).toList();

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

class _ReportHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ReportHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF060B26),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF646B7A),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
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

  const _ReportData({
    required this.monthlySummary,
    required this.villaProfitItems,
    required this.roomProfitItems,
    required this.vacancyItems,
    required this.monthlyIncomes,
    required this.monthlyExpenses,
    required this.pendingRentItems,
    required this.yearlyItems,
  });
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

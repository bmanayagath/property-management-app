import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_permissions.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/room.dart';
import '../../domain/models/villa_model.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/income_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/room_provider.dart';
import '../providers/villa_provider.dart';
import '../widgets/premium_widgets.dart';
import 'add_edit_expense_screen.dart';
import 'add_edit_villa_screen.dart';
import 'income/add_edit_income_screen.dart';
import 'notifications/notifications_screen.dart';
import 'villa_detail_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    final selectedMonth = summary.selectedMonth;
    final dashboard = summary.metrics;
    final authState = ref.watch(authProvider);
    final canManageIncome =
        authState.hasPermission(AppPermissions.manageIncome);
    final canManageExpenses =
        authState.hasPermission(AppPermissions.manageExpenses);
    final canManageVillas =
        authState.hasPermission(AppPermissions.manageVillas);

    return PremiumScaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(villaListProvider);
          ref.invalidate(roomListProvider);
          ref.invalidate(incomeListProvider);
          ref.invalidate(expenseListProvider);
          ref.invalidate(dashboardSummaryProvider);
        },
        child: ListView(
          padding: PremiumTokens.pagePadding,
          children: [
            const _DashboardHeader(),
            const SizedBox(height: 18),
            _MonthFilter(
              selectedMonth: selectedMonth,
              onTap: () => _showMonthFilter(context, ref, selectedMonth),
            ),
            const SizedBox(height: 14),
            _MetricGrid(
              totalRooms: dashboard.totalRooms,
              occupiedRooms: dashboard.occupiedRooms,
              vacantRooms: dashboard.vacantRooms,
              totalIncome: summary.totalIncome,
              actualNetProfit: summary.totalIncome - summary.totalExpense,
              pendingRent: dashboard.pendingRent,
              pendingRooms: dashboard.pendingRooms,
              vacancyLoss: dashboard.vacancyLoss,
            ),
            const SizedBox(height: 12),
            _QuickActions(
              onAddIncome: canManageIncome
                  ? () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddEditIncomeScreen(),
                        ),
                      )
                  : null,
              onAddExpense: canManageExpenses
                  ? () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddEditExpenseScreen(),
                        ),
                      )
                  : null,
              onAddVilla: canManageVillas
                  ? () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddEditVillaScreen(),
                        ),
                      )
                  : null,
            ),
            const SizedBox(height: 16),
            _RentCollectionCard(
              expectedRent: dashboard.expectedRent,
              collected: dashboard.rentReceived,
              pending: dashboard.pendingRent,
              progress: dashboard.rentCollectionProgress,
            ),
            const SizedBox(height: 22),
            _VillaSummary(
              villas: summary.villas,
              rooms: summary.rooms,
              expenses: summary.expenses,
              rentReceivedByRoom: summary.rentReceivedByRoom,
              selectedMonth: summary.selectedMonth,
              onViewAll: () => ref.read(selectedTabProvider.notifier).state = 1,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMonthFilter(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedMonth,
  ) async {
    final action = await showModalBottomSheet<_MonthFilterAction>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _MonthFilterSheet(),
    );

    if (action == null || !context.mounted) return;

    final now = DateTime.now();
    switch (action) {
      case _MonthFilterAction.thisMonth:
        ref.read(selectedMonthProvider.notifier).state = DateTime(
          now.year,
          now.month,
          1,
        );
        return;
      case _MonthFilterAction.lastMonth:
        ref.read(selectedMonthProvider.notifier).state = DateTime(
          now.year,
          now.month - 1,
          1,
        );
        return;
      case _MonthFilterAction.selectMonth:
        await _selectMonth(context, ref, selectedMonth);
        return;
      case _MonthFilterAction.selectYear:
        await _selectYear(context, ref, selectedMonth);
        return;
    }
  }

  Future<void> _selectMonth(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedMonth,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100, 12, 31),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked == null) return;

    ref.read(selectedMonthProvider.notifier).state = DateTime(
      picked.year,
      picked.month,
      1,
    );
  }

  Future<void> _selectYear(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedMonth,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100, 12, 31),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked == null) return;

    ref.read(selectedMonthProvider.notifier).state = DateTime(
      picked.year,
      selectedMonth.month,
      1,
    );
  }

  static String money(double value) => CurrencyFormatter.formatQAR(value);
}

double _calculatePendingRent({
  required double expectedRent,
  required double rentReceived,
}) {
  return math.max(expectedRent - rentReceived, 0).toDouble();
}

class _DashboardHeader extends ConsumerWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount =
        ref.watch(unreadNotificationCountProvider).valueOrNull ?? 0;

    return Container(
      height: 178,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE4E1DA)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667085).withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFFCF5),
                  Color(0xFFF1F4F5),
                  Color(0xFFE8EEF1),
                ],
              ),
            ),
          ),
          const Positioned.fill(
            child: CustomPaint(painter: _QatarSkylinePainter()),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x26FFFFFF), Color(0xB8FFFFFF)],
              ),
            ),
          ),
          const Positioned(
            left: 22,
            top: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VillaBooks',
                  style: TextStyle(
                    color: Color(0xFF172B3A),
                    fontSize: 31,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: -0.8,
                  ),
                ),
                SizedBox(height: 9),
                Text(
                  'Dashboard',
                  style: TextStyle(
                    color: Color(0xFF60717D),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            top: 20,
            child: Material(
              color: Colors.white.withValues(alpha: 0.82),
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: 'Notifications',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.notifications_none_rounded,
                      color: Color(0xFF172B3A),
                      size: 27,
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: -5,
                        top: -6,
                        child: Container(
                          height: 21,
                          constraints: const BoxConstraints(minWidth: 21),
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF04438),
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QatarSkylinePainter extends CustomPainter {
  const _QatarSkylinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final skyline = Paint()
      ..color = const Color(0xFF526C7B).withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    final sand = Paint()
      ..color = const Color(0xFFB69A72).withValues(alpha: 0.09)
      ..style = PaintingStyle.fill;
    final baseline = size.height * 0.88;

    canvas.drawRect(
      Rect.fromLTWH(0, baseline, size.width, size.height - baseline),
      sand,
    );

    final museum = Path()
      ..moveTo(size.width * 0.03, baseline)
      ..lineTo(size.width * 0.08, baseline - 22)
      ..lineTo(size.width * 0.15, baseline - 31)
      ..lineTo(size.width * 0.19, baseline - 16)
      ..lineTo(size.width * 0.25, baseline - 25)
      ..lineTo(size.width * 0.31, baseline)
      ..close();
    canvas.drawPath(museum, sand);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.15, baseline - 25),
        width: size.width * 0.18,
        height: 17,
      ),
      sand,
    );

    final buildings = <Rect>[
      Rect.fromLTWH(size.width * 0.37, baseline - 47, 18, 47),
      Rect.fromLTWH(size.width * 0.43, baseline - 68, 23, 68),
      Rect.fromLTWH(size.width * 0.51, baseline - 38, 17, 38),
      Rect.fromLTWH(size.width * 0.57, baseline - 82, 25, 82),
      Rect.fromLTWH(size.width * 0.66, baseline - 54, 20, 54),
      Rect.fromLTWH(size.width * 0.74, baseline - 72, 28, 72),
      Rect.fromLTWH(size.width * 0.84, baseline - 44, 20, 44),
      Rect.fromLTWH(size.width * 0.91, baseline - 59, 24, 59),
    ];
    for (final building in buildings) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(building, const Radius.circular(3)),
        skyline,
      );
    }

    final tower = Path()
      ..moveTo(size.width * 0.76, baseline - 72)
      ..lineTo(size.width * 0.78, baseline - 105)
      ..lineTo(size.width * 0.80, baseline - 72)
      ..close();
    canvas.drawPath(tower, skyline);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MonthFilter extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onTap;

  const _MonthFilter({
    required this.selectedMonth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final month = DateFormat('MMMM yyyy').format(selectedMonth);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE8EAF0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667085).withValues(alpha: 0.10),
                blurRadius: 20,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: Color(0xFF5549DE),
                size: 24,
              ),
              const SizedBox(width: 9),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    month,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Color(0xFF060B26),
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF5549DE),
                size: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _MonthFilterAction {
  thisMonth,
  lastMonth,
  selectMonth,
  selectYear,
}

class _MonthFilterSheet extends StatelessWidget {
  const _MonthFilterSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Choose period',
                style: TextStyle(
                  color: Color(0xFF060B26),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _MonthOptionTile(
              icon: Icons.today_rounded,
              label: 'This Month',
              onTap: () => Navigator.pop(
                context,
                _MonthFilterAction.thisMonth,
              ),
            ),
            _MonthOptionTile(
              icon: Icons.history_rounded,
              label: 'Last Month',
              onTap: () => Navigator.pop(
                context,
                _MonthFilterAction.lastMonth,
              ),
            ),
            _MonthOptionTile(
              icon: Icons.calendar_month_rounded,
              label: 'Select Month',
              onTap: () => Navigator.pop(
                context,
                _MonthFilterAction.selectMonth,
              ),
            ),
            _MonthOptionTile(
              icon: Icons.event_note_rounded,
              label: 'Select Year',
              onTap: () => Navigator.pop(
                context,
                _MonthFilterAction.selectYear,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MonthOptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F0FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF5549DE), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF060B26),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF89909E),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  final int totalRooms;
  final int occupiedRooms;
  final int vacantRooms;
  final double totalIncome;
  final double actualNetProfit;
  final double pendingRent;
  final int pendingRooms;
  final double vacancyLoss;

  const _MetricGrid({
    required this.totalRooms,
    required this.occupiedRooms,
    required this.vacantRooms,
    required this.totalIncome,
    required this.actualNetProfit,
    required this.pendingRent,
    required this.pendingRooms,
    required this.vacancyLoss,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Total Income',
                value: DashboardScreen.money(totalIncome),
                color: const Color(0xFF2EA043),
                background: const Color(0xFFF1FCF3),
                border: const Color(0xFFC8EFD0),
                icon: Icons.insert_chart_outlined_rounded,
                iconBackground: const Color(0xFFDDF6E2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Actual Net Profit',
                value: DashboardScreen.money(actualNetProfit),
                color: const Color(0xFF2563EB),
                background: const Color(0xFFF4F8FF),
                border: const Color(0xFFD2E2FF),
                icon: Icons.account_balance_wallet_outlined,
                iconBackground: const Color(0xFFE2EAFF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Pending Rent',
                value: DashboardScreen.money(pendingRent),
                trend: '$pendingRooms Rooms',
                color: const Color(0xFFF59E0B),
                background: const Color(0xFFFFFAF0),
                border: const Color(0xFFF8E4BC),
                icon: Icons.access_time_rounded,
                iconBackground: const Color(0xFFFFF0D6),
                showTrendArrow: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Vacancy Loss',
                value: DashboardScreen.money(vacancyLoss),
                trend: 'Vacant Rooms: $vacantRooms',
                color: const Color(0xFFEA580C),
                background: const Color(0xFFFFF7ED),
                border: const Color(0xFFFED7AA),
                icon: Icons.home_work_outlined,
                iconBackground: const Color(0xFFFFEDD5),
                showTrendArrow: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Total Rooms',
                value: totalRooms.toString(),
                color: const Color(0xFF5549DE),
                background: const Color(0xFFF4F0FF),
                border: const Color(0xFFE1D6FF),
                icon: Icons.meeting_room_outlined,
                iconBackground: const Color(0xFFEDE9FF),
                showTrendArrow: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Occupied Rooms',
                value: occupiedRooms.toString(),
                color: const Color(0xFF2EA043),
                background: const Color(0xFFF1FCF3),
                border: const Color(0xFFC8EFD0),
                icon: Icons.check_circle_outline_rounded,
                iconBackground: const Color(0xFFDDF6E2),
                showTrendArrow: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _MetricCard(
          title: 'Vacant Rooms',
          value: vacantRooms.toString(),
          color: const Color(0xFFEA580C),
          background: const Color(0xFFFFF7ED),
          border: const Color(0xFFFED7AA),
          icon: Icons.sensor_door_outlined,
          iconBackground: const Color(0xFFFFEDD5),
          showTrendArrow: false,
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? trend;
  final Color color;
  final Color background;
  final Color border;
  final IconData icon;
  final Color iconBackground;
  final bool showTrendArrow;

  const _MetricCard({
    required this.title,
    required this.value,
    this.trend,
    required this.color,
    required this.background,
    required this.border,
    required this.icon,
    required this.iconBackground,
    this.showTrendArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: 104,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      color: iconBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF596070),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Color(0xFF060B26),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (trend != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (showTrendArrow)
                      Icon(
                        Icons.arrow_upward_rounded,
                        color: color,
                        size: 13,
                      ),
                    Flexible(
                      child: Text(
                        trend!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: showTrendArrow
                              ? const Color(0xFF6C7180)
                              : const Color(0xFF6C7180),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else
                const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback? onAddIncome;
  final VoidCallback? onAddExpense;
  final VoidCallback? onAddVilla;

  const _QuickActions({
    required this.onAddIncome,
    required this.onAddExpense,
    required this.onAddVilla,
  });

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      _ActionCard(
        label: 'Income',
        icon: Icons.credit_card_rounded,
        color: AppColors.income,
        onTap: onAddIncome,
      ),
      _ActionCard(
        label: 'Expense',
        icon: Icons.receipt_long_rounded,
        color: AppColors.expense,
        onTap: onAddExpense,
      ),
      _ActionCard(
        label: 'Villa',
        icon: Icons.home_rounded,
        color: const Color(0xFF5549DE),
        onTap: onAddVilla,
      ),
    ];

    return _RaisedPanel(
      padding: const EdgeInsets.fromLTRB(14, 15, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: Color(0xFF060B26),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              const columns = 3;
              const spacing = 12.0;
              final width =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: actions
                    .map((action) => SizedBox(width: width, child: action))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 112,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE8EAF0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.045),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: enabled ? 0.11 : 0.05),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: enabled ? color : const Color(0xFFADB2BD),
                  size: 24,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: enabled
                      ? const Color(0xFF060B26)
                      : const Color(0xFF89909E),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RentCollectionCard extends StatelessWidget {
  final double expectedRent;
  final double collected;
  final double pending;
  final double progress;

  const _RentCollectionCard({
    required this.expectedRent,
    required this.collected,
    required this.pending,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final hasRentDue = expectedRent > 0;
    final safeProgress = progress.clamp(0.0, 1.0);
    final percent = (safeProgress * 100).round();

    return _RaisedPanel(
      padding: const EdgeInsets.fromLTRB(14, 15, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rent Collection Status',
            style: TextStyle(
              color: Color(0xFF060B26),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          if (!hasRentDue)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  'No rent due for selected period',
                  style: TextStyle(
                    color: Color(0xFF656B7B),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: _CollectionAmount(
                    label: 'Total Expected Rent',
                    value: DashboardScreen.money(expectedRent),
                    color: const Color(0xFF0F2747),
                  ),
                ),
                const _CollectionDivider(),
                Expanded(
                  child: _CollectionAmount(
                    label: 'Current Collected',
                    value: DashboardScreen.money(collected),
                    color: const Color(0xFF2EA043),
                  ),
                ),
                const _CollectionDivider(),
                Expanded(
                  child: _CollectionAmount(
                    label: 'Current Pending',
                    value: DashboardScreen.money(pending),
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text(
                  'Collection Progress',
                  style: TextStyle(
                    color: Color(0xFF656B7B),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    color: Color(0xFF172B3A),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: safeProgress,
                minHeight: 10,
                backgroundColor: const Color(0xFFF1E2C8),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF2EA043)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CollectionDivider extends StatelessWidget {
  const _CollectionDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: const Color(0xFFE1E4EA),
    );
  }
}

class _CollectionAmount extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _CollectionAmount({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF656B7B),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _VillaSummary extends StatelessWidget {
  final List<VillaModel> villas;
  final List<Room> rooms;
  final List<Expense> expenses;
  final Map<String, double> rentReceivedByRoom;
  final DateTime selectedMonth;
  final VoidCallback onViewAll;

  const _VillaSummary({
    required this.villas,
    required this.rooms,
    required this.expenses,
    required this.rentReceivedByRoom,
    required this.selectedMonth,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final visibleVillas = villas.take(3).toList();

    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Villa Summary',
                style: TextStyle(
                  color: Color(0xFF3B4152),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              child: const Text(
                'View All',
                style: TextStyle(
                  color: Color(0xFF5549DE),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _RaisedPanel(
          padding: EdgeInsets.zero,
          child: visibleVillas.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No villas added yet',
                      style: TextStyle(
                        color: Color(0xFF656B7B),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              : Column(
                  children: List.generate(visibleVillas.length, (index) {
                    final villa = visibleVillas[index];
                    final summary = _VillaRoomSummary.fromData(
                      rooms.where((room) => room.villaId == villa.id),
                      rentReceivedByRoom,
                      expenses.where((expense) => expense.villaId == villa.id),
                      selectedMonth,
                    );

                    return Column(
                      children: [
                        _VillaRow(
                          villa: villa,
                          summary: summary,
                        ),
                        if (index != visibleVillas.length - 1)
                          const Divider(height: 1, color: Color(0xFFE5E7EF)),
                      ],
                    );
                  }),
                ),
        ),
      ],
    );
  }
}

class _VillaRow extends StatelessWidget {
  final VillaModel villa;
  final _VillaRoomSummary summary;

  const _VillaRow({
    required this.villa,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VillaDetailScreen(villaId: villa.id),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 9, 10, 9),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final showThumbnail = constraints.maxWidth >= 430;

            return Row(
              children: [
                if (showThumbnail) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 68,
                      width: 68,
                      child: CustomPaint(
                        painter: _VillaThumbnailPainter(
                          seed: villa.id.hashCode,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          villa.villaName.isEmpty ? 'Villa' : villa.villaName,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Color(0xFF060B26),
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (villa.location.trim().isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Color(0xFF89909E),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                villa.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF656B7B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            'Occupancy',
                            style: TextStyle(
                              color: Color(0xFF3B4152),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${summary.occupiedRooms} / ${summary.totalRooms} Rooms',
                            style: const TextStyle(
                              color: Color(0xFF060B26),
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 5,
                        children: [
                          _RoomCountChip(
                            label: '${summary.occupiedRooms} Occupied',
                            color: const Color(0xFF2EA043),
                          ),
                          _RoomCountChip(
                            label: '${summary.vacantRooms} Vacant',
                            color: const Color(0xFFEA580C),
                          ),
                          _RoomCountChip(
                            label: '${summary.totalRooms} Total',
                            color: const Color(0xFF2563EB),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _SolidOccupancyLine(
                        hasOccupiedRooms: summary.occupiedRooms > 0,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: _VillaAmount(
                              label: 'Total Room Rent',
                              value: DashboardScreen.money(
                                summary.totalRoomRent,
                              ),
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                          _SmallDivider(),
                          Expanded(
                            flex: 4,
                            child: _VillaAmount(
                              label: 'Expected Rent',
                              value: DashboardScreen.money(
                                summary.expectedRent,
                              ),
                              color: const Color(0xFF0F2747),
                            ),
                          ),
                          _SmallDivider(),
                          Expanded(
                            flex: 4,
                            child: _VillaAmount(
                              label: 'Collected',
                              value: DashboardScreen.money(
                                summary.rentReceived,
                              ),
                              color: summary.rentReceived > 0
                                  ? const Color(0xFF2EA043)
                                  : const Color(0xFF596070),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: _VillaAmount(
                              label: 'Pending',
                              value: DashboardScreen.money(
                                summary.pendingRent,
                              ),
                              color: summary.pendingRent > 0
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF596070),
                            ),
                          ),
                          _SmallDivider(),
                          Expanded(
                            flex: 4,
                            child: _VillaAmount(
                              label: 'Vacancy Loss',
                              value: DashboardScreen.money(
                                summary.vacancyLoss,
                              ),
                              color: summary.vacancyLoss > 0
                                  ? const Color(0xFFF04438)
                                  : const Color(0xFF596070),
                            ),
                          ),
                          const Expanded(flex: 4, child: SizedBox()),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.meeting_room_outlined,
                      color: Color(0xFF5549DE),
                      size: 18,
                    ),
                    SizedBox(height: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF89909E),
                      size: 26,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _VillaAmount extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _VillaAmount({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF89909E),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _SolidOccupancyLine extends StatelessWidget {
  final bool hasOccupiedRooms;

  const _SolidOccupancyLine({
    required this.hasOccupiedRooms,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      width: double.infinity,
      decoration: BoxDecoration(
        color: hasOccupiedRooms
            ? const Color(0xFF2EA043)
            : const Color(0xFFE4E4E6),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _VillaRoomSummary {
  final int totalRooms;
  final int occupiedRooms;
  final int vacantRooms;
  final double totalRoomRent;
  final double expectedRent;
  final double rentReceived;
  final double pendingRent;
  final double vacancyLoss;
  final double totalExpenses;
  final double actualNetProfit;
  final double expectedNetProfit;

  const _VillaRoomSummary({
    required this.totalRooms,
    required this.occupiedRooms,
    required this.vacantRooms,
    required this.totalRoomRent,
    required this.expectedRent,
    required this.rentReceived,
    required this.pendingRent,
    required this.vacancyLoss,
    required this.totalExpenses,
    required this.actualNetProfit,
    required this.expectedNetProfit,
  });

  static _VillaRoomSummary fromData(
    Iterable<Room> rooms,
    Map<String, double> rentReceivedByRoom,
    Iterable<Expense> expenses,
    DateTime selectedMonth,
  ) {
    var totalRooms = 0;
    var occupiedRooms = 0;
    var vacantRooms = 0;
    var totalRoomRent = 0.0;
    var expectedRent = 0.0;
    var rentReceived = 0.0;
    var pendingRent = 0.0;
    var vacancyLoss = 0.0;
    final totalExpenses = expenses
        .where(
          (expense) =>
              expense.expenseDate.year == selectedMonth.year &&
              expense.expenseDate.month == selectedMonth.month,
        )
        .fold<double>(0, (sum, expense) => sum + expense.amount);

    for (final room in rooms.where((room) => !room.isDeleted)) {
      totalRooms++;
      totalRoomRent += room.monthlyRent;
      final received = rentReceivedByRoom[room.id] ?? 0;
      rentReceived += received;
      if (room.isOccupied) {
        occupiedRooms++;
        expectedRent += room.monthlyRent;
        pendingRent += _calculatePendingRent(
          expectedRent: room.monthlyRent,
          rentReceived: received,
        );
      } else if (room.isVacant) {
        vacantRooms++;
        vacancyLoss += room.monthlyRent;
      }
    }

    return _VillaRoomSummary(
      totalRooms: totalRooms,
      occupiedRooms: occupiedRooms,
      vacantRooms: vacantRooms,
      totalRoomRent: totalRoomRent,
      expectedRent: expectedRent,
      rentReceived: rentReceived,
      pendingRent: pendingRent,
      vacancyLoss: vacancyLoss,
      totalExpenses: totalExpenses,
      actualNetProfit: rentReceived - totalExpenses,
      expectedNetProfit: expectedRent - totalExpenses,
    );
  }
}

class _RoomCountChip extends StatelessWidget {
  final String label;
  final Color color;

  const _RoomCountChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SmallDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: const Color(0xFFD8DCE5),
    );
  }
}

class _RaisedPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _RaisedPanel({
    required this.child,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EAF0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667085).withValues(alpha: 0.09),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _VillaThumbnailPainter extends CustomPainter {
  final int seed;

  const _VillaThumbnailPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final sky = Rect.fromLTWH(0, 0, size.width, size.height);
    paint.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFAED2FF),
        Color(0xFFEAF3FF),
        Color(0xFFD7C3A0),
      ],
    ).createShader(sky);
    canvas.drawRect(sky, paint);
    paint.shader = null;

    final sunX = seed.isEven ? size.width * 0.78 : size.width * 0.2;
    paint.color = const Color(0xFFFFE6A3);
    canvas.drawCircle(Offset(sunX, size.height * 0.18), 8, paint);

    paint.color = const Color(0xFFC9A775);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.18, size.height * 0.34, size.width * 0.64,
          size.height * 0.42),
      paint,
    );
    paint.color = const Color(0xFFEAD8B8);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.23, size.height * 0.27, size.width * 0.54,
          size.height * 0.45),
      paint,
    );
    paint.color = const Color(0xFFB08756);
    canvas.drawRect(
      Rect.fromLTWH(
          size.width * 0.19, size.height * 0.26, size.width * 0.62, 5),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
          size.width * 0.16, size.height * 0.51, size.width * 0.68, 5),
      paint,
    );

    paint.color = const Color(0xFF92B6D9);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.31, size.height * 0.37, 12, 12),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.58, size.height * 0.37, 12, 12),
      paint,
    );
    paint.color = const Color(0xFF7C5A35);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.46, size.height * 0.56, 12, 20),
      paint,
    );

    paint.color = const Color(0xFF2C8A4A);
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.77, size.width, 5), paint);
    for (final x in [7.0, size.width - 10]) {
      paint.color = const Color(0xFF8B5E36);
      canvas.drawRect(Rect.fromLTWH(x, size.height * 0.42, 3, 28), paint);
      paint.color = const Color(0xFF287A3C);
      canvas.drawOval(Rect.fromLTWH(x - 8, size.height * 0.31, 19, 18), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _VillaThumbnailPainter oldDelegate) {
    return oldDelegate.seed != seed;
  }
}

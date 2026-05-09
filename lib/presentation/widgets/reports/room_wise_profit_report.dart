import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/models/report_models.dart';

class RoomWiseProfitReport extends StatelessWidget {
  final List<RoomWiseProfitReportItem> items;

  const RoomWiseProfitReport({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyRoomReport();
    }

    final totalExpectedRent =
        items.fold<double>(0, (sum, item) => sum + item.expectedRent);
    final totalRentReceived =
        items.fold<double>(0, (sum, item) => sum + item.rentReceived);
    final totalExpenses =
        items.fold<double>(0, (sum, item) => sum + item.totalExpenses);
    final totalPendingRent =
        items.fold<double>(0, (sum, item) => sum + item.pendingRent);
    final totalVacancyLoss =
        items.fold<double>(0, (sum, item) => sum + item.vacancyLoss);
    final actualProfit =
        items.fold<double>(0, (sum, item) => sum + item.actualProfit);
    final expectedProfit =
        items.fold<double>(0, (sum, item) => sum + item.expectedProfit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryBand(
          expectedRent: totalExpectedRent,
          rentReceived: totalRentReceived,
          expenses: totalExpenses,
          pendingRent: totalPendingRent,
          vacancyLoss: totalVacancyLoss,
          actualProfit: actualProfit,
          expectedProfit: expectedProfit,
        ),
        const SizedBox(height: 14),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _RoomProfitTile(item: item),
          ),
        ),
      ],
    );
  }
}

class _SummaryBand extends StatelessWidget {
  final double expectedRent;
  final double rentReceived;
  final double expenses;
  final double pendingRent;
  final double vacancyLoss;
  final double actualProfit;
  final double expectedProfit;

  const _SummaryBand({
    required this.expectedRent,
    required this.rentReceived,
    required this.expenses,
    required this.pendingRent,
    required this.vacancyLoss,
    required this.actualProfit,
    required this.expectedProfit,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 760;
        final cards = [
          _MetricCard(
            label: 'Expected Rent',
            value: CurrencyFormatter.format(expectedRent),
            icon: Icons.home_work_outlined,
            color: AppColors.primary,
          ),
          _MetricCard(
            label: 'Rent Received',
            value: CurrencyFormatter.format(rentReceived),
            icon: Icons.trending_up_rounded,
            color: AppColors.success,
          ),
          _MetricCard(
            label: 'Expenses',
            value: CurrencyFormatter.format(expenses),
            icon: Icons.receipt_long_outlined,
            color: AppColors.error,
          ),
          _MetricCard(
            label: 'Pending',
            value: CurrencyFormatter.format(pendingRent),
            icon: Icons.schedule_rounded,
            color: AppColors.warning,
          ),
          _MetricCard(
            label: 'Vacancy Loss',
            value: CurrencyFormatter.format(vacancyLoss),
            icon: Icons.sensor_door_outlined,
            color: Colors.deepPurple,
          ),
          _MetricCard(
            label: 'Actual Profit',
            value: CurrencyFormatter.format(actualProfit),
            icon: Icons.account_balance_wallet_outlined,
            color: AppColors.profit,
          ),
          _MetricCard(
            label: 'Expected Profit',
            value: CurrencyFormatter.format(expectedProfit),
            icon: Icons.insights_rounded,
            color: AppColors.primary,
          ),
        ];

        return GridView.count(
          crossAxisCount: isWide ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: isWide ? 3.4 : 2.4,
          children: cards,
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF646B7A),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF060B26),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomProfitTile extends StatelessWidget {
  final RoomWiseProfitReportItem item;

  const _RoomProfitTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final statusColor = item.isOccupied ? AppColors.success : AppColors.warning;
    final progress = (item.rentCollectionPercentage / 100).clamp(0.0, 1.0);

    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE8EAF0)),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE8EAF0)),
      ),
      backgroundColor: Colors.white,
      collapsedBackgroundColor: Colors.white,
      title: Row(
        children: [
          Expanded(
            child: Text(
              '${item.villaName} > ${item.displayRoomName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF060B26),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.status,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InlineRow(
              icon: Icons.person_outline,
              label: 'Tenant',
              value:
                  item.tenantName.trim().isEmpty ? 'Vacant' : item.tenantName,
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: const Color(0xFFE8EAF0),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
          ],
        ),
      ),
      children: [
        const SizedBox(height: 10),
        _DetailGrid(
          values: [
            _DetailValue('Expected Rent', item.expectedRent, AppColors.primary),
            _DetailValue('Rent Received', item.rentReceived, AppColors.success),
            _DetailValue('Other Income', item.otherIncome, AppColors.success),
            _DetailValue('Expenses', item.totalExpenses, AppColors.error),
            _DetailValue('Pending', item.pendingRent, AppColors.warning),
            _DetailValue('Vacancy Loss', item.vacancyLoss, Colors.deepPurple),
            _DetailValue('Actual Profit', item.actualProfit, AppColors.profit),
            _DetailValue(
              'Expected Profit',
              item.expectedProfit,
              AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }
}

class _InlineRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InlineRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF646B7A)),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Color(0xFF646B7A),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF060B26),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailGrid extends StatelessWidget {
  final List<_DetailValue> values;

  const _DetailGrid({required this.values});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          crossAxisCount: constraints.maxWidth > 640 ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: constraints.maxWidth > 640 ? 3.0 : 2.4,
          children: values
              .map(
                (value) => Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: value.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        value.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF646B7A),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.format(value.amount),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: value.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _DetailValue {
  final String label;
  final double amount;
  final Color color;

  const _DetailValue(this.label, this.amount, this.color);
}

class _EmptyRoomReport extends StatelessWidget {
  const _EmptyRoomReport();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EAF0)),
      ),
      child: const Column(
        children: [
          Icon(Icons.meeting_room_outlined, size: 42, color: Color(0xFF646B7A)),
          SizedBox(height: 12),
          Text(
            'No room data found',
            style: TextStyle(
              color: Color(0xFF060B26),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Try changing the month, villa, room, or status filters.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF646B7A),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

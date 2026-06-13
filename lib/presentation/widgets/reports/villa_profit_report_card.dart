import 'package:flutter/material.dart';

import '../../../domain/models/report_models.dart';
import '../currency_amount_text.dart';

class VillaProfitReportCard extends StatelessWidget {
  final VillaProfitReportItem item;

  const VillaProfitReportCard({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profitColor =
        item.netProfit >= 0 ? const Color(0xFF2563EB) : const Color(0xFFF04438);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EAF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF0FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.home_rounded, color: Color(0xFF2563EB)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.villaName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF060B26),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _CountChip(label: '${item.totalRooms} rooms'),
                        _CountChip(
                          label: '${item.occupiedRooms} occupied',
                          color: const Color(0xFF12B76A),
                        ),
                        _CountChip(
                          label: '${item.vacantRooms} vacant',
                          color: const Color(0xFFF59E0B),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              CurrencyAmountText(
                amount: item.netProfit,
                amountColor: profitColor,
                amountFontSize: 16,
                currencyFontSize: 9,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Metric(label: 'Expected Rent', value: item.expectedRent),
              _Metric(
                label: 'Received',
                value: item.receivedIncome,
                color: const Color(0xFF12B76A),
              ),
              _Metric(
                label: 'Expenses',
                value: item.totalExpense,
                color: const Color(0xFFF04438),
              ),
              _Metric(
                label: 'Pending',
                value: item.pendingAmount,
                color: const Color(0xFFF59E0B),
              ),
              _Metric(
                label: 'Vacancy Loss',
                value: item.vacancyLoss,
                color: const Color(0xFFEA580C),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final Color color;

  const _CountChip({
    required this.label,
    this.color = const Color(0xFF2563EB),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _Metric({
    required this.label,
    required this.value,
    this.color = const Color(0xFF060B26),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF646B7A),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: CurrencyAmountText(
              amount: value,
              amountColor: color,
              amountFontSize: 13,
              currencyFontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}

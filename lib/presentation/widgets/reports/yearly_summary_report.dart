import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/report_models.dart';
import '../currency_amount_text.dart';

class YearlySummaryReport extends StatelessWidget {
  final List<YearlySummaryReportItem> items;

  const YearlySummaryReport({
    Key? key,
    required this.items,
  }) : super(key: key);

  static final DateFormat _monthFormat = DateFormat('MMM');

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EAF0)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Month')),
            DataColumn(label: Text('Income')),
            DataColumn(label: Text('Expense')),
            DataColumn(label: Text('Profit')),
          ],
          rows: items.map((item) {
            final profitColor = item.profit >= 0
                ? const Color(0xFF2563EB)
                : const Color(0xFFF04438);

            return DataRow(
              cells: [
                DataCell(Text(_monthFormat.format(item.month))),
                DataCell(
                  CurrencyAmountText(
                    amount: item.income,
                    amountColor: const Color(0xFF12B76A),
                    amountFontSize: 14,
                    currencyFontSize: 9,
                  ),
                ),
                DataCell(
                  CurrencyAmountText(
                    amount: item.expense,
                    amountColor: const Color(0xFFF04438),
                    amountFontSize: 14,
                    currencyFontSize: 9,
                  ),
                ),
                DataCell(
                  CurrencyAmountText(
                    amount: item.profit,
                    amountColor: profitColor,
                    amountFontSize: 14,
                    currencyFontSize: 9,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/income.dart';
import '../currency_amount_text.dart';

class IncomeReportView extends StatelessWidget {
  final List<Income> incomes;

  const IncomeReportView({
    Key? key,
    required this.incomes,
  }) : super(key: key);

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    if (incomes.isEmpty) {
      return const _EmptyReport(message: 'No income records found.');
    }

    return _ReportTable(
      columns: const ['Date', 'Villa', 'Type', 'Payment', 'Amount'],
      rows: incomes.map((income) {
        return _ReportRow(
          values: [
            _dateFormat.format(income.paymentDate),
            income.villaName,
            income.incomeType,
            income.paymentMethod,
          ],
          amount: income.amount,
        );
      }).toList(),
      amountColor: const Color(0xFF12B76A),
    );
  }
}

class _ReportTable extends StatelessWidget {
  final List<String> columns;
  final List<_ReportRow> rows;
  final Color amountColor;

  const _ReportTable({
    required this.columns,
    required this.rows,
    required this.amountColor,
  });

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
          columns: columns
              .map(
                (column) => DataColumn(
                  label: Text(
                    column,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              )
              .toList(),
          rows: rows.map((row) {
            return DataRow(
              cells: [
                ...row.values.map(
                  (value) => DataCell(
                    Text(
                      value,
                      style: const TextStyle(
                        color: Color(0xFF060B26),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  CurrencyAmountText(
                    amount: row.amount,
                    amountColor: amountColor,
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

class _ReportRow {
  final List<String> values;
  final double amount;

  const _ReportRow({required this.values, required this.amount});
}

class _EmptyReport extends StatelessWidget {
  final String message;

  const _EmptyReport({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EAF0)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF646B7A),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

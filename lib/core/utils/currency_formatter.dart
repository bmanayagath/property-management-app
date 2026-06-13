import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static const String qatariRiyal = 'QAR';
  static const String symbol = qatariRiyal;
  static final NumberFormat _wholeFormatter = NumberFormat('#,##0');
  static final NumberFormat _decimalFormatter = NumberFormat('#,##0.00');

  static String formatAmount(num amount, {bool showDecimals = false}) {
    final formatter = showDecimals ? _decimalFormatter : _wholeFormatter;
    return formatter.format(amount);
  }

  static String formatQAR(num amount, {bool showDecimals = false}) {
    return '${formatAmount(amount, showDecimals: showDecimals)} $qatariRiyal';
  }

  static String format(double amount) => formatQAR(amount);

  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M $qatariRiyal';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K $qatariRiyal';
    }
    return formatQAR(amount);
  }

  static String simpleFormat(double amount) => formatQAR(amount);
}

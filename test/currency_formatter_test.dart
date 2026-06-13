import 'package:flutter_test/flutter_test.dart';
import 'package:villabooks/core/utils/currency_formatter.dart';

void main() {
  test('formats QAR after the amount', () {
    expect(CurrencyFormatter.formatQAR(22000), '22,000 QAR');
    expect(
      CurrencyFormatter.formatQAR(22000.5, showDecimals: true),
      '22,000.50 QAR',
    );
  });

  test('formats compact QAR after the amount', () {
    expect(CurrencyFormatter.formatCompact(22000), '22.0K QAR');
    expect(CurrencyFormatter.formatCompact(2200000), '2.2M QAR');
  });
}

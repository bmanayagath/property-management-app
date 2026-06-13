import 'package:flutter/material.dart';

import '../../core/utils/currency_formatter.dart';

enum CurrencyAmountLayout { inline, stacked }

class CurrencyAmountText extends StatelessWidget {
  final num amount;
  final String currency;
  final Color? amountColor;
  final Color? currencyColor;
  final CurrencyAmountLayout layout;
  final double amountFontSize;
  final double currencyFontSize;
  final bool showDecimals;
  final TextAlign textAlign;

  const CurrencyAmountText({
    super.key,
    required this.amount,
    this.currency = CurrencyFormatter.qatariRiyal,
    this.amountColor,
    this.currencyColor,
    this.layout = CurrencyAmountLayout.inline,
    this.amountFontSize = 22,
    this.currencyFontSize = 12,
    this.showDecimals = false,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedAmountColor =
        amountColor ?? Theme.of(context).colorScheme.onSurface;
    final resolvedCurrencyColor = currencyColor ??
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    final amountStyle = TextStyle(
      color: resolvedAmountColor,
      fontSize: amountFontSize,
      fontWeight: FontWeight.w900,
      height: 1.1,
    );
    final currencyStyle = TextStyle(
      color: resolvedCurrencyColor,
      fontSize: currencyFontSize,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.4,
      height: 1.1,
    );
    final formattedAmount = CurrencyFormatter.formatAmount(
      amount,
      showDecimals: showDecimals,
    );

    if (layout == CurrencyAmountLayout.stacked) {
      final alignment = switch (textAlign) {
        TextAlign.center => CrossAxisAlignment.center,
        TextAlign.end || TextAlign.right => CrossAxisAlignment.end,
        _ => CrossAxisAlignment.start,
      };

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: alignment,
        children: [
          Text(formattedAmount, textAlign: textAlign, style: amountStyle),
          const SizedBox(height: 2),
          Text(currency, textAlign: textAlign, style: currencyStyle),
        ],
      );
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: formattedAmount, style: amountStyle),
          TextSpan(text: ' $currency', style: currencyStyle),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
    );
  }
}

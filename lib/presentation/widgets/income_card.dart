import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/models/income.dart';
import 'currency_amount_text.dart';

class IncomeCard extends StatelessWidget {
  final Income income;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const IncomeCard({
    Key? key,
    required this.income,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFCDEFD8)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF067647).withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFE4F8EA),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.payments_rounded,
                color: Color(0xFF12B76A),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    income.incomeType,
                    style: const TextStyle(
                      color: Color(0xFF060B26),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        income.villaName,
                        style: const TextStyle(
                          color: Color(0xFF646B7A),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        ' • ',
                        style: const TextStyle(
                          color: Color(0xFF646B7A),
                          fontSize: 11,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _dateFormat.format(income.paymentDate),
                          style: const TextStyle(
                            color: Color(0xFF646B7A),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CurrencyAmountText(
                  amount: income.amount,
                  amountColor: const Color(0xFF12B76A),
                  amountFontSize: 14,
                  currencyFontSize: 9,
                ),
              ],
            ),
            if (onDelete != null || onEdit != null) ...[
              const SizedBox(width: 8),
              _IncomeActionMenu(
                onView: onTap,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IncomeActionMenu extends StatelessWidget {
  final VoidCallback onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _IncomeActionMenu({
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'More',
      icon: const Icon(Icons.more_horiz_rounded),
      onSelected: (value) {
        switch (value) {
          case 'view':
            onView();
            break;
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: Text('View Details'),
        ),
        if (onEdit != null)
          const PopupMenuItem(
            value: 'edit',
            child: Text('Edit Income'),
          ),
        if (onDelete != null)
          const PopupMenuItem(
            value: 'delete',
            child: Text(
              'Delete Income',
              style: TextStyle(color: Color(0xFFF04438)),
            ),
          ),
      ],
    );
  }
}

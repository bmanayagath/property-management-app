import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/models/expense.dart';
import 'currency_amount_text.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ExpenseCard({
    Key? key,
    required this.expense,
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
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1D6CF)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB42318).withValues(alpha: 0.06),
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
                color: Color(0xFFFFE6E0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: Color(0xFFF04438),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.category,
                    style: const TextStyle(
                      color: Color(0xFF060B26),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    expense.locationLabel,
                    style: const TextStyle(
                      color: Color(0xFF646B7A),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _dateFormat.format(expense.expenseDate),
                    style: const TextStyle(
                      color: Color(0xFF646B7A),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 116,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: CurrencyAmountText(
                      amount: expense.amount,
                      amountColor: const Color(0xFFF04438),
                      amountFontSize: 14,
                      currencyFontSize: 9,
                      textAlign: TextAlign.end,
                    ),
                  ),
                  if (onDelete != null || onEdit != null)
                    _ExpenseActionMenu(
                      onView: onTap,
                      onEdit: onEdit,
                      onDelete: onDelete,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseActionMenu extends StatelessWidget {
  final VoidCallback onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ExpenseActionMenu({
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'More',
      icon: const Icon(Icons.more_horiz_rounded),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 44),
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
            child: Text('Edit Expense'),
          ),
        if (onDelete != null)
          const PopupMenuItem(
            value: 'delete',
            child: Text(
              'Delete Expense',
              style: TextStyle(color: Color(0xFFF04438)),
            ),
          ),
      ],
    );
  }
}

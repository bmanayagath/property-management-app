import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_permissions.dart';
import '../../domain/models/expense.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_card.dart';
import '../widgets/currency_amount_text.dart';
import '../widgets/destructive_action_dialog.dart';
import '../widgets/premium_widgets.dart';
import 'add_edit_expense_screen.dart';
import 'expense_detail_screen.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final expensesAsync = ref.watch(expenseListProvider);
    final authState = ref.watch(authProvider);
    final canManageExpenses =
        authState.hasPermission(AppPermissions.manageExpenses);

    return PremiumScaffold(
      body: expensesAsync.when(
        data: (expenses) {
          final monthlyExpenses = expenses
              .where(
                  (expense) => _isSameMonth(expense.expenseDate, selectedMonth))
              .toList();
          final total = monthlyExpenses.fold<double>(
            0,
            (sum, expense) => sum + expense.amount,
          );
          final filteredExpenses = monthlyExpenses.where((expense) {
            final matchesCategory = _selectedCategory == 'All' ||
                _sameCategory(expense.category, _selectedCategory);
            final query = _searchQuery.toLowerCase().trim();
            final matchesSearch = query.isEmpty ||
                expense.category.toLowerCase().contains(query) ||
                expense.villaName.toLowerCase().contains(query) ||
                (expense.roomName ?? '').toLowerCase().contains(query) ||
                expense.paidTo.toLowerCase().contains(query) ||
                expense.paymentMethod.toLowerCase().contains(query) ||
                expense.notes.toLowerCase().contains(query);

            return matchesCategory && matchesSearch;
          }).toList()
            ..sort((a, b) => b.expenseDate.compareTo(a.expenseDate));

          return ListView(
            padding: PremiumTokens.pagePadding,
            children: [
              PremiumPageHeader(
                title: 'Expenses',
                subtitle: 'Track upkeep, payments, and property costs',
                actions: [
                  if (canManageExpenses)
                    ModuleActionButton.expense(
                      onPressed: _openAddExpense,
                      icon: Icons.add_rounded,
                      label: 'Add Expense',
                    ),
                ],
              ),
              const SizedBox(height: 18),
              _MonthSelector(
                month: selectedMonth,
                onPrevious: () => _changeMonth(selectedMonth, -1),
                onNext: () => _changeMonth(selectedMonth, 1),
              ),
              const SizedBox(height: 14),
              _SummaryCard(total: total, month: selectedMonth),
              const SizedBox(height: 16),
              PremiumSearchBar(
                onChanged: (value) => setState(() => _searchQuery = value),
                hintText: 'Search expenses...',
                value: _searchQuery,
                onClear: () => setState(() => _searchQuery = ''),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE8EAF0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE8EAF0)),
                  ),
                ),
                items: [
                  const DropdownMenuItem(
                      value: 'All', child: Text('All Categories')),
                  ...ExpenseCategories.values.map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedCategory = value);
                },
              ),
              const SizedBox(height: 18),
              if (filteredExpenses.isEmpty)
                _EmptyExpenses(
                  onAddExpense: canManageExpenses ? _openAddExpense : null,
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredExpenses.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 88,
                      ),
                      itemBuilder: (context, index) {
                        final expense = filteredExpenses[index];

                        return ExpenseCard(
                          expense: expense,
                          onTap: () => _openDetail(expense),
                          onEdit: canManageExpenses
                              ? () => _openEditExpense(expense)
                              : null,
                          onDelete: canManageExpenses
                              ? () => _confirmDelete(expense)
                              : null,
                        );
                      },
                    );
                  },
                ),
            ],
          );
        },
        error: (error, _) => Center(child: Text(error.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: canManageExpenses
          ? Padding(
              padding: const EdgeInsets.only(bottom: 88),
              child: ModuleActionFab.expense(
                heroTag: 'add-expense-fab',
                onPressed: _openAddExpense,
              ),
            )
          : null,
    );
  }

  void _changeMonth(DateTime selectedMonth, int offset) {
    ref.read(selectedMonthProvider.notifier).state = DateTime(
      selectedMonth.year,
      selectedMonth.month + offset,
      1,
    );
  }

  void _openAddExpense() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditExpenseScreen(),
      ),
    );
  }

  void _openEditExpense(Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditExpenseScreen(expense: expense),
      ),
    );
  }

  void _openDetail(Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseDetailScreen(expenseId: expense.id),
      ),
    );
  }

  Future<void> _confirmDelete(Expense expense) async {
    final confirmed = await showDestructiveActionDialog(
      context: context,
      title: 'Delete Expense?',
      message: 'This expense entry will be removed from active records.',
      confirmLabel: 'Delete',
    );
    if (!confirmed) return;

    await ref.read(expenseProvider.notifier).deleteExpense(expense.id);
    ref.invalidate(expenseListProvider);
    ref.invalidate(dashboardSummaryProvider);
  }

  bool _isSameMonth(DateTime date, DateTime month) {
    return date.year == month.year && date.month == month.month;
  }

  bool _sameCategory(String left, String right) {
    return _normalize(left) == _normalize(right);
  }

  String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}

class _MonthSelector extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthSelector({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Center(
            child: Text(
              DateFormat('MMMM yyyy').format(month),
              style: const TextStyle(
                color: Color(0xFF060B26),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double total;
  final DateTime month;

  const _SummaryCard({
    required this.total,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.expenseSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.expenseBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.expenseDark.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: const BoxDecoration(
              color: AppColors.expenseSurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.trending_down_rounded,
              color: AppColors.expense,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Expenses',
                  style: TextStyle(
                    color: AppColors.expense,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                CurrencyAmountText(
                  amount: total,
                  amountFontSize: 25,
                  currencyFontSize: 12,
                ),
                const SizedBox(height: 3),
                Text(
                  DateFormat('MMMM yyyy').format(month),
                  style: const TextStyle(
                    color: Color(0xFF646B7A),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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

class _EmptyExpenses extends StatelessWidget {
  final VoidCallback? onAddExpense;

  const _EmptyExpenses({
    this.onAddExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EAF0)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            color: AppColors.expense,
            size: 46,
          ),
          const SizedBox(height: 12),
          const Text(
            'No expenses found',
            style: TextStyle(
              color: Color(0xFF060B26),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add an expense or adjust your filters.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF646B7A),
              fontSize: 13,
            ),
          ),
          if (onAddExpense != null) ...[
            const SizedBox(height: 16),
            ModuleActionButton.expense(
              onPressed: onAddExpense,
              icon: Icons.add_rounded,
              label: 'Add Expense',
            ),
          ],
        ],
      ),
    );
  }
}

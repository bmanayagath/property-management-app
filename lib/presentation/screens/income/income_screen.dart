import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_permissions.dart';
import '../../../core/utils/room_helpers.dart';
import '../../../domain/models/income.dart';
import '../../providers/active_org_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/income_provider.dart';
import '../../widgets/income_card.dart';
import '../../widgets/currency_amount_text.dart';
import '../../widgets/destructive_action_dialog.dart';
import '../../widgets/premium_widgets.dart';
import 'add_edit_income_screen.dart';
import 'income_detail_screen.dart';

class IncomeScreen extends ConsumerStatefulWidget {
  const IncomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends ConsumerState<IncomeScreen> {
  String _searchQuery = '';
  String _selectedType = 'All';

  @override
  Widget build(BuildContext context) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final incomeAsync = ref.watch(incomeListProvider);
    final authState = ref.watch(authProvider);
    final activeOrgId = ref.watch(activeOrgProvider);
    final canManageIncome =
        authState.hasPermission(AppPermissions.manageIncome);

    return PremiumScaffold(
      body: incomeAsync.when(
        data: (incomes) {
          final monthlyIncomes = incomeCalculationService.filterForMonthlyTotal(
            incomes,
            selectedMonth,
            orgId: activeOrgId,
          );
          final filteredIncomes = monthlyIncomes.where((income) {
            final matchesType = _selectedType == 'All' ||
                incomeCalculationService.matchesIncomeType(
                  income.incomeType,
                  _selectedType,
                );
            final query = _searchQuery.toLowerCase().trim();
            final matchesSearch = query.isEmpty ||
                income.incomeType.toLowerCase().contains(query) ||
                income.villaName.toLowerCase().contains(query) ||
                income.roomName.toLowerCase().contains(query) ||
                income.paymentMethod.toLowerCase().contains(query) ||
                income.notes.toLowerCase().contains(query);

            return matchesType && matchesSearch;
          }).toList()
            ..sort(_compareIncomeEntries);

          final total = incomeCalculationService.totalForMonth(
            incomes,
            selectedMonth,
            orgId: activeOrgId,
          );

          return ListView(
            padding: PremiumTokens.pagePadding,
            children: [
              PremiumPageHeader(
                title: 'Income',
                subtitle: 'Track rent and other received payments',
                actions: [
                  if (canManageIncome)
                    ModuleActionButton.income(
                      onPressed: _openAddIncome,
                      icon: Icons.add_rounded,
                      label: 'Add Income',
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
                hintText: 'Search income...',
                value: _searchQuery,
                onClear: () => setState(() => _searchQuery = ''),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Income Type',
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
                      value: 'All', child: Text('All Income')),
                  ...IncomeTypes.values
                      .where(incomeCalculationService.isCountableIncomeType)
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ),
                      ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedType = value);
                },
              ),
              const SizedBox(height: 18),
              if (filteredIncomes.isEmpty)
                _EmptyIncome(
                  onAddIncome: canManageIncome ? _openAddIncome : null,
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredIncomes.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 76,
                      ),
                      itemBuilder: (context, index) {
                        final income = filteredIncomes[index];

                        return IncomeCard(
                          income: income,
                          onTap: () => _openDetail(income),
                          onEdit: canManageIncome
                              ? () => _openEditIncome(income)
                              : null,
                          onDelete: canManageIncome
                              ? () => _confirmDelete(income)
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
      floatingActionButton: canManageIncome
          ? Padding(
              padding: const EdgeInsets.only(bottom: 88),
              child: ModuleActionFab.income(
                heroTag: 'add-income-fab',
                onPressed: _openAddIncome,
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

  void _openAddIncome() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditIncomeScreen(),
      ),
    );
  }

  void _openEditIncome(Income income) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditIncomeScreen(income: income),
      ),
    );
  }

  void _openDetail(Income income) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IncomeDetailScreen(incomeId: income.id),
      ),
    );
  }

  Future<void> _confirmDelete(Income income) async {
    final confirmed = await showDestructiveActionDialog(
      context: context,
      title: 'Delete Income?',
      message: 'This income entry will be removed from active records.',
      confirmLabel: 'Delete',
    );
    if (!confirmed) return;

    await ref.read(incomeControllerProvider.notifier).deleteIncome(income.id);
  }

  int _compareIncomeEntries(Income left, Income right) {
    final villaCompare = compareNaturalText(
      _displayVillaName(left),
      _displayVillaName(right),
    );
    if (villaCompare != 0) return villaCompare;

    final leftRoom = left.roomName.trim();
    final rightRoom = right.roomName.trim();
    final leftHasRoom = leftRoom.isNotEmpty;
    final rightHasRoom = rightRoom.isNotEmpty;
    if (leftHasRoom != rightHasRoom) return leftHasRoom ? -1 : 1;
    if (leftHasRoom && rightHasRoom) {
      final roomCompare = compareNaturalText(leftRoom, rightRoom);
      if (roomCompare != 0) return roomCompare;
    }

    return right.paymentDate.compareTo(left.paymentDate);
  }

  String _displayVillaName(Income income) {
    final villaName = income.villaName.trim();
    return villaName.isEmpty ? 'General Income' : villaName;
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
        color: AppColors.incomeSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.incomeBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.incomeDark.withValues(alpha: 0.08),
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
              color: AppColors.incomeSurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: AppColors.income,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Income',
                  style: TextStyle(
                    color: AppColors.incomeDark,
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

class _EmptyIncome extends StatelessWidget {
  final VoidCallback? onAddIncome;

  const _EmptyIncome({
    this.onAddIncome,
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
            Icons.payments_outlined,
            color: AppColors.income,
            size: 46,
          ),
          const SizedBox(height: 12),
          const Text(
            'No income found',
            style: TextStyle(
              color: Color(0xFF060B26),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add an income record or adjust your filters.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF646B7A),
              fontSize: 13,
            ),
          ),
          if (onAddIncome != null) ...[
            const SizedBox(height: 16),
            ModuleActionButton.income(
              onPressed: onAddIncome,
              icon: Icons.add_rounded,
              label: 'Add Income',
            ),
          ],
        ],
      ),
    );
  }
}

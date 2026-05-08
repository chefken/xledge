import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xledge/models/expense_model.dart';
import 'package:xledge/providers/void_provider.dart';
import 'package:xledge/screens/add_expense_sheet.dart';
import 'package:xledge/utils/void_colors.dart';
import 'package:xledge/utils/void_text_styles.dart';
import 'package:xledge/widgets/transaction_tile.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  static const _months = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  static const _short = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<VoidProvider>(
      builder: (context, provider, _) {
        final grouped = _group(provider.expenses);
        final dates   = grouped.keys.toList();

        return Scaffold(
          backgroundColor: VoidColors.background,
          floatingActionButton: _MiniPurpleFab(
            onTap: () => _addSheet(context),
          ),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(24, 64, 24, 20),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                       Text('Expenses',
                          style: VoidTextStyles.headlineLarge),
                      _FilterChip(
                        label:
                            '${_months[provider.selectedMonth]} ${provider.selectedYear}',
                        onTap: () => _filterSheet(context, provider),
                      ),
                    ],
                  ),
                ),
              ),
              grouped.isEmpty
                  ? SliverFillRemaining(child: _Empty())
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) {
                            final date  = dates[i];
                            final items = grouped[date]!;
                            final net   = items.fold(
                              0.0,
                              (s, e) => s +
                                  (e.isAllowance ? e.amount : -e.amount),
                            );
                            return _DateSection(
                              date:  date,
                              net:   net,
                              items: items,
                              onDelete: (id) =>
                                  provider.deleteExpense(id),
                              onEdit: (e) => _editSheet(context, e),
                            );
                          },
                          childCount: dates.length,
                        ),
                      ),
                    ),
              const SliverToBoxAdapter(child: SizedBox(height: 130)),
            ],
          ),
        );
      },
    );
  }

  void _addSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddExpenseSheet(),
    );
  }

  void _editSheet(BuildContext context, Expense e) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddExpenseSheet(existingExpense: e),
    );
  }

  void _filterSheet(BuildContext context, VoidProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FilterSheet(provider: provider),
    );
  }

  Map<String, List<Expense>> _group(List<Expense> expenses) {
    final map = <String, List<Expense>>{};
    for (final e in expenses) {
      final key = '${_short[e.date.month]} ${e.date.year}';
      map.putIfAbsent(key, () => []).add(e);
    }
    return map;
  }
}

class _DateSection extends StatelessWidget {
  final String date;
  final double net;
  final List<Expense> items;
  final ValueChanged<String> onDelete;
  final ValueChanged<Expense> onEdit;

  const _DateSection({
    required this.date,
    required this.net,
    required this.items,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(date,
                style: VoidTextStyles.labelLarge.copyWith(
                  color: VoidColors.textHint,
                  letterSpacing: 0.3,
                )),
            Text(
  '${net >= 0 ? '+' : '-'}₹${net.abs().toStringAsFixed(0)}',
  style: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: net >= 0
        ? VoidColors.primary
        : VoidColors.textPrimary,
  ),
),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((e) => TransactionTile(
              expense:   e,
              onDismiss: () => onDelete(e.id),
              onEdit:    () => onEdit(e),
            )),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: VoidColors.primaryLight,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: VoidColors.primary,
                )),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more_rounded,
                color: VoidColors.primary, size: 16),
          ],
        ),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final VoidProvider provider;
  const _FilterSheet({required this.provider});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  late int _month;
  late int _year;

  @override
  void initState() {
    super.initState();
    _month = widget.provider.selectedMonth;
    _year  = widget.provider.selectedYear;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      decoration: const BoxDecoration(
        color: VoidColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: VoidColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Filter by Month', style: VoidTextStyles.titleLarge),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Year', style: VoidTextStyles.bodyMedium),
              Row(
                children: [
                  _ChipBtn(
                    label: '<',
                    onTap: () => setState(() => _year--),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('$_year',
                        style: VoidTextStyles.titleMedium),
                  ),
                  _ChipBtn(
                    label: '>',
                    onTap: () => setState(() => _year++),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: List.generate(12, (i) {
              final m      = i + 1;
              final active = _month == m;
              return GestureDetector(
                onTap: () => setState(() => _month = m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color:  active ? VoidColors.primary : VoidColors.outlineVariant,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    _monthNames[i].substring(0, 3),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: active
                          ? Colors.white
                          : VoidColors.textSecondary,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 28),
          GestureDetector(
  onTap: () {
    widget.provider.setMonth(_year, _month);
    Navigator.pop(context);
  },
  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 17),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFA78BFA), Color(0xFF6C3CE1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(100),
      boxShadow: [
        BoxShadow(
          color: VoidColors.primary.withOpacity(0.26),
          blurRadius: 16,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    alignment: Alignment.center,
    child: const Text(
      'Apply',
      style: TextStyle(
        fontFamily: 'BricolageGrotesque',
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: -0.1,
      ),
    ),
  ),
),
        ],
      ),
    );
  }
}

class _ChipBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ChipBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: VoidColors.outlineVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: VoidColors.textSecondary,
            )),
      ),
    );
  }
}

class _MiniPurpleFab extends StatelessWidget {
  final VoidCallback onTap;
  const _MiniPurpleFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52, height: 52,
        margin: const EdgeInsets.only(bottom: 98),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [VoidColors.gradientStart, VoidColors.gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: VoidColors.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded,
            color: Colors.white, size: 24),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: VoidColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.receipt_long_rounded,
                color: VoidColors.primary, size: 28),
          ),
          const SizedBox(height: 14),
          Text('No expenses', style: VoidTextStyles.titleMedium),
          const SizedBox(height: 6),
          Text('Tap + to add your first record',
              style: VoidTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
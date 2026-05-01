import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xledge/models/expense_model.dart';
import 'package:xledge/providers/void_provider.dart';
import 'package:xledge/screens/add_expense_sheet.dart';
import 'package:xledge/utils/void_colors.dart';
import 'package:xledge/utils/void_spacing.dart';
import 'package:xledge/utils/void_text_styles.dart';
import 'package:xledge/widgets/transaction_tile.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VoidColors.background,
      body: Consumer<VoidProvider>(
        builder: (context, provider, _) {
          final grouped = _groupByDate(provider.expenses);
          final dates   = grouped.keys.toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      VoidSpacing.screenH, 16, VoidSpacing.screenH, 16),
                  child: Text('Expenses',
                      style: VoidTextStyles.headlineMedium),
                ),
              ),
              if (grouped.isEmpty)
                SliverFillRemaining(child: _EmptyExpenses())
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: VoidSpacing.screenH),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final date  = dates[i];
                        final items = grouped[date]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 16, bottom: 4),
                              child: Text(date,
                                  style: VoidTextStyles.labelSmall.copyWith(
                                    color: VoidColors.textHint,
                                    letterSpacing: 0.8,
                                  )),
                            ),
                            ...items.map((e) => TransactionTile(
                                  expense: e,
                                  onDismiss: () =>
                                      provider.deleteExpense(e.id),
                                )),
                          ],
                        );
                      },
                      childCount: dates.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const AddExpenseSheet(),
        ),
        backgroundColor: VoidColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Map<String, List<Expense>> _groupByDate(List<Expense> expenses) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final map    = <String, List<Expense>>{};
    for (final e in expenses) {
      final key =
          '${e.date.day.toString().padLeft(2, '0')} ${months[e.date.month]} ${e.date.year}';
      map.putIfAbsent(key, () => []).add(e);
    }
    return map;
  }
}

class _EmptyExpenses extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72, height: 72,
          decoration: const BoxDecoration(
              color: VoidColors.primaryLight, shape: BoxShape.circle),
          child: const Icon(Icons.receipt_long_rounded,
              color: VoidColors.primary, size: 32),
        ),
        const SizedBox(height: 16),
        const Text('No expenses yet', style: VoidTextStyles.titleMedium),
        const SizedBox(height: 6),
        const Text('Tap + to log your first expense',
            style: VoidTextStyles.bodyMedium),
      ],
    );
  }
}
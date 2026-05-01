import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xledge/providers/void_provider.dart';
import 'package:xledge/utils/void_colors.dart';
import 'package:xledge/utils/void_spacing.dart';
import 'package:xledge/utils/void_text_styles.dart';
import 'package:xledge/widgets/transaction_tile.dart';
import 'package:xledge/widgets/category_scroll_row.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String? _filterCategory;

  @override
  Widget build(BuildContext context) {
    return Consumer<VoidProvider>(
      builder: (context, provider, _) {
        final filtered = _filterCategory == null
            ? provider.expenses
            : provider.expenses
                .where((e) => e.category == _filterCategory)
                .toList();

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    VoidSpacing.screenH, 16, VoidSpacing.screenH, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Expenses', style: VoidTextStyles.headlineMedium),
                    Text(
                      '${filtered.length} records',
                      style: VoidTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: VoidSpacing.md)),
            SliverToBoxAdapter(
              child: CategoryScrollRow(
                onSelected: (cat) =>
                    setState(() => _filterCategory = cat),
              ),
            ),
            const SliverToBoxAdapter(
                child: SizedBox(height: VoidSpacing.md)),
            filtered.isEmpty
                ? SliverFillRemaining(child: _EmptyExpenses())
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: VoidSpacing.screenH),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => TransactionTile(
                          expense: filtered[i],
                          onDismiss: () =>
                              provider.deleteExpense(filtered[i].id),
                        ),
                        childCount: filtered.length,
                      ),
                    ),
                  ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }
}

class _EmptyExpenses extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: VoidColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.receipt_long_rounded,
              color: VoidColors.primary, size: 32),
        ),
        const SizedBox(height: 16),
        const Text('No expenses yet',
            style: VoidTextStyles.titleMedium),
        const SizedBox(height: 6),
        const Text('Tap + to log your first expense',
            style: VoidTextStyles.bodyMedium),
      ],
    );
  }
}
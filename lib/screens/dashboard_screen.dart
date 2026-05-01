import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xledge/providers/void_provider.dart';
import 'package:xledge/utils/void_colors.dart';
import 'package:xledge/utils/void_spacing.dart';
import 'package:xledge/utils/void_text_styles.dart';
import 'package:xledge/widgets/balance_hero_card.dart';
import 'package:xledge/widgets/transaction_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VoidProvider>(
      builder: (context, provider, _) {
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // THE LOGO
                            Image.asset(
                              'assets/images/xl.png',
                              height: 32,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 10),
                            Text('XLedge',
                                style: VoidTextStyles.headlineMedium),
                          ],
                        ),
                        Text(_monthYear(provider.selectedMonth,
                                provider.selectedYear),
                            style: VoidTextStyles.bodyMedium),
                      ],
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: VoidColors.primaryLight,
                      child: const Text('K',
                          style: TextStyle(
                            color: VoidColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          )),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    VoidSpacing.screenH, 20, VoidSpacing.screenH, 0),
                child: BalanceHeroCard(
                  totalSpend:    provider.analysis?.totalSpend ?? 0,
                  totalTheyOwe:  provider.totalTheyOwe,
                  totalIOwe:     provider.totalIOwe,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    VoidSpacing.screenH, VoidSpacing.sectionGap,
                    VoidSpacing.screenH, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent', style: VoidTextStyles.titleLarge),
                    if (provider.expenses.isNotEmpty)
                      Text('${provider.expenses.length} total',
                          style: VoidTextStyles.bodyMedium),
                  ],
                ),
              ),
            ),
            provider.expenses.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: VoidColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.receipt_long_rounded,
                                color: VoidColors.primary, size: 28),
                          ),
                          const SizedBox(height: 12),
                          const Text('No transactions yet',
                              style: VoidTextStyles.titleMedium),
                          const SizedBox(height: 4),
                          const Text('Tap + to add your first',
                              style: VoidTextStyles.bodyMedium),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: VoidSpacing.screenH),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => TransactionTile(
                          expense: provider.expenses[i],
                          onDismiss: () =>
                              provider.deleteExpense(provider.expenses[i].id),
                        ),
                        childCount: provider.expenses.length > 5
                            ? 5
                            : provider.expenses.length,
                      ),
                    ),
                  ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

  String _monthYear(int month, int year) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[month]} $year';
  }
}
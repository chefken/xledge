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
        final recent = provider.expenses.take(5).toList();

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    VoidSpacing.screenH, 16, VoidSpacing.screenH, 0),
                child: Row(
                  children: [
                    Image.asset('assets/xl.png', width: 32, height: 32),
                    const SizedBox(width: 10),
                    const Text('XLedge',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: VoidColors.textPrimary,
                          letterSpacing: -0.5,
                        )),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: VoidColors.primaryLight,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        _monthYear(provider.selectedMonth,
                            provider.selectedYear),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: VoidColors.primary,
                        ),
                      ),
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
                  totalAllowance: provider.totalAllowance,
                  netBalance:    provider.netBalance,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    VoidSpacing.screenH, 28, VoidSpacing.screenH, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Transactions',
                        style: VoidTextStyles.titleLarge),
                    if (provider.expenses.length > 5)
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          foregroundColor: VoidColors.primary,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('See all',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                  ],
                ),
              ),
            ),
            recent.isEmpty
                ? SliverToBoxAdapter(child: _EmptyDashboard())
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: VoidSpacing.screenH),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => TransactionTile(
                          expense: recent[i],
                          onDismiss: () =>
                              provider.deleteExpense(recent[i].id),
                        ),
                        childCount: recent.length,
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
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[month]} $year';
  }
}

class _EmptyDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            width: 72, height: 72,
            decoration: const BoxDecoration(
              color: VoidColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_rounded,
                color: VoidColors.primary, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('No transactions yet',
              style: VoidTextStyles.titleMedium),
          const SizedBox(height: 4),
          const Text('Tap + to log your first record',
              style: VoidTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
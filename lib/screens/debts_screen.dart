import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:xledge/utils/void_theme.dart';
import 'package:xledge/providers/void_provider.dart';
import 'package:xledge/screens/add_debt_sheet.dart';

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VOID // DEBTS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: VoidColors.accent),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const AddDebtSheet(),
            ),
          ),
        ],
      ),
      body: Consumer<VoidProvider>(
        builder: (context, provider, _) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _SummaryTile(
                        label: 'I OWE',
                        amount: provider.totalIOwe,
                        color: VoidColors.danger,
                      ),
                      const SizedBox(width: 12),
                      _SummaryTile(
                        label: 'THEY OWE',
                        amount: provider.totalTheyOwe,
                        color: VoidColors.success,
                      ),
                    ],
                  ),
                ),
              ),
              if (provider.iOweDebts.isNotEmpty) ...[
                _SectionHeader(
                  label: 'I OWE',
                  color: VoidColors.danger,
                  count: provider.iOweDebts.length,
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _DebtTile(
                      debt: provider.iOweDebts[i],
                      provider: provider,
                    ),
                    childCount: provider.iOweDebts.length,
                  ),
                ),
              ],
              if (provider.theyOweDebts.isNotEmpty) ...[
                _SectionHeader(
                  label: 'THEY OWE',
                  color: VoidColors.success,
                  count: provider.theyOweDebts.length,
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _DebtTile(
                      debt: provider.theyOweDebts[i],
                      provider: provider,
                    ),
                    childCount: provider.theyOweDebts.length,
                  ),
                ),
              ],
              if (provider.activeDebts.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'ALL DEBTS CLEARED',
                      style: TextStyle(
                        color: VoidColors.textMuted,
                        letterSpacing: 3,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _SummaryTile({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 9,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: color,
                fontSize: 20,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;
  final int count;

  const _SectionHeader({
    required this.label,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
        child: Row(
          children: [
            Container(width: 2, height: 12, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '[$count]',
              style: const TextStyle(
                color: VoidColors.textMuted,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DebtTile extends StatelessWidget {
  final debt;
  final VoidProvider provider;

  const _DebtTile({required this.debt, required this.provider});

  @override
  Widget build(BuildContext context) {
    final color = debt.isIOwe ? VoidColors.danger : VoidColors.success;
    return Dismissible(
      key: Key(debt.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: VoidColors.danger.withOpacity(0.15),
        child: const Icon(Icons.delete_outline, color: VoidColors.danger),
      ),
      onDismissed: (_) => provider.deleteDebt(debt.id),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: VoidColors.card,
          border: Border.all(color: VoidColors.border),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(
          children: [
            Container(width: 3, height: 40, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    debt.contactName.toUpperCase(),
                    style: const TextStyle(
                      color: VoidColors.textPrimary,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    debt.description.toUpperCase(),
                    style: const TextStyle(
                      color: VoidColors.textSecondary,
                      fontSize: 9,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${debt.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => provider.settleDebt(debt.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      border: Border.all(color: VoidColors.success),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Text(
                      'SETTLE',
                      style: TextStyle(
                        color: VoidColors.success,
                        fontSize: 8,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
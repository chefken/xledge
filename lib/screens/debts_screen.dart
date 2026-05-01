import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xledge/models/debt_model.dart';
import 'package:xledge/providers/void_provider.dart';
import 'package:xledge/utils/void_colors.dart';
import 'package:xledge/utils/void_spacing.dart';
import 'package:xledge/utils/void_text_styles.dart';

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({super.key});

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
                child: Text('Debts', style: VoidTextStyles.headlineMedium),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    VoidSpacing.screenH, 16, VoidSpacing.screenH, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        label: 'They Owe Me',
                        amount: provider.totalTheyOwe,
                        color: VoidColors.success,
                        bgColor: VoidColors.successLight,
                        icon: Icons.arrow_downward_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        label: 'I Owe',
                        amount: provider.totalIOwe,
                        color: VoidColors.danger,
                        bgColor: VoidColors.dangerLight,
                        icon: Icons.arrow_upward_rounded,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (provider.theyOweDebts.isNotEmpty) ...[
              _SectionLabel(label: 'They Owe Me', color: VoidColors.success),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: VoidSpacing.screenH),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _DebtCard(
                      debt: provider.theyOweDebts[i],
                      provider: provider,
                    ),
                    childCount: provider.theyOweDebts.length,
                  ),
                ),
              ),
            ],
            if (provider.iOweDebts.isNotEmpty) ...[
              _SectionLabel(label: 'I Owe', color: VoidColors.danger),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: VoidSpacing.screenH),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _DebtCard(
                      debt: provider.iOweDebts[i],
                      provider: provider,
                    ),
                    childCount: provider.iOweDebts.length,
                  ),
                ),
              ),
            ],
            if (provider.activeDebts.isEmpty)
              SliverFillRemaining(child: _EmptyDebts()),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            VoidSpacing.screenH, 20, VoidSpacing.screenH, 8),
        child: Row(
          children: [
            Container(width: 3, height: 14, color: color,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text(label,
                style: VoidTextStyles.labelLarge
                    .copyWith(color: color, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final Color bgColor;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text('₹${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: -0.5,
              )),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: VoidColors.textSecondary,
              )),
        ],
      ),
    );
  }
}

class _DebtCard extends StatelessWidget {
  final Debt debt;
  final VoidProvider provider;

  const _DebtCard({required this.debt, required this.provider});

  @override
  Widget build(BuildContext context) {
    final color = debt.isIOwe ? VoidColors.danger : VoidColors.success;
    return Dismissible(
      key: Key(debt.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: VoidColors.dangerLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: VoidColors.danger),
      ),
      onDismissed: (_) => provider.deleteDebt(debt.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: VoidColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: VoidColors.outline, width: 1.5),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(0.1),
              child: Text(
                debt.contactName[0].toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(debt.contactName,
                      style: VoidTextStyles.titleMedium),
                  const SizedBox(height: 3),
                  Text(debt.description,
                      style: VoidTextStyles.bodyMedium),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${debt.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: color,
                      letterSpacing: -0.3,
                    )),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => provider.settleDebt(debt.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: VoidColors.successLight,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                          color: VoidColors.success.withOpacity(0.4)),
                    ),
                    child: const Text('Settle',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: VoidColors.success,
                        )),
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

class _EmptyDebts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: VoidColors.successLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.handshake_outlined,
              color: VoidColors.success, size: 32),
        ),
        const SizedBox(height: 16),
        const Text('All clear', style: VoidTextStyles.titleMedium),
        const SizedBox(height: 6),
        const Text('No outstanding debts', style: VoidTextStyles.bodyMedium),
      ],
    );
  }
}
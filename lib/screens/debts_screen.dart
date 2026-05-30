import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:xledge/models/debt_model.dart';
import 'package:xledge/providers/void_provider.dart';
import 'package:xledge/screens/add_debt_sheet.dart';
import 'package:xledge/utils/theme_ext.dart';
import 'package:xledge/utils/void_colors.dart';
import 'package:xledge/utils/void_text_styles.dart';

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VoidProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: context.xBg,
          floatingActionButton: _MiniPurpleFab(
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const AddDebtSheet(),
            ),
          ),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      24, 64, 24, 20),
                  child: Text('Debts',
                      style: VoidTextStyles.headlineLarge),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          label:  'YOU OWE',
                          amount: provider.totalIOwe,
                          count:  provider.iOweDebts.length,
                          isPrimary: false,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _SummaryCard(
                          label:  'OWES YOU',
                          amount: provider.totalTheyOwe,
                          count:  provider.theyOweDebts.length,
                          isPrimary: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (provider.iOweDebts.isNotEmpty) ...[
                _Label('You Owe', context),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _DebtTile(
                        debt:     provider.iOweDebts[i],
                        provider: provider,
                        isIOwe:   true,
                      ),
                      childCount: provider.iOweDebts.length,
                    ),
                  ),
                ),
              ],
              if (provider.theyOweDebts.isNotEmpty) ...[
                _Label('Owes You', context),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _DebtTile(
                        debt:     provider.theyOweDebts[i],
                        provider: provider,
                        isIOwe:   false,
                      ),
                      childCount:
                          provider.theyOweDebts.length,
                    ),
                  ),
                ),
              ],
              if (provider.activeDebts.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(Icons.handshake_rounded,
                            color: VoidColors.primaryLight,
                            size: 44),
                        const SizedBox(height: 14),
                        Text('All clear',
                            style: GoogleFonts
                                .bricolageGrotesque(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: context.xTxPri,
                            )),
                        const SizedBox(height: 6),
                        Text('No outstanding debts',
                            style: GoogleFonts
                                .bricolageGrotesque(
                              fontSize: 13,
                              color: context.xTxSec,
                            )),
                      ],
                    ),
                  ),
                ),
              const SliverToBoxAdapter(
                  child: SizedBox(height: 130)),
            ],
          ),
        );
      },
    );
  }

  SliverToBoxAdapter _Label(
      String text, BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 10),
        child: Text(text,
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.xTxHint,
              letterSpacing: 0.3,
            )),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final int count;
  final bool isPrimary;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.count,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPrimary
            ? VoidColors.primaryLight
            : context.xCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPrimary
              ? VoidColors.primary.withOpacity(0.15)
              : context.xBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: context.xShadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isPrimary
                    ? VoidColors.primary
                    : context.xTxHint,
                letterSpacing: 1.2,
              )),
          const SizedBox(height: 10),
          Text(
            '₹${amount.toInt()}',
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isPrimary
                  ? VoidColors.primary
                  : context.xTxPri,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text('$count pending',
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 11,
                color: context.xTxHint,
              )),
        ],
      ),
    );
  }
}

class _DebtTile extends StatelessWidget {
  final Debt debt;
  final VoidProvider provider;
  final bool isIOwe;

  const _DebtTile({
    required this.debt,
    required this.provider,
    required this.isIOwe,
  });

  @override
  Widget build(BuildContext context) {
    const m = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.xCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: context.xShadow,
              blurRadius: 16,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: isIOwe
                    ? context.xFill
                    : VoidColors.primaryLight,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                debt.contactName[0].toUpperCase(),
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isIOwe
                      ? context.xTxPri
                      : VoidColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(debt.contactName,
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: context.xTxPri,
                        letterSpacing: -0.1,
                      )),
                  const SizedBox(height: 3),
                  Text(
                    '${debt.description}  ·  '
                    '${debt.createdAt.day} ${m[debt.createdAt.month]}',
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 11,
                      color: context.xTxHint,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${debt.amount.toInt()}',
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isIOwe
                        ? context.xTxPri
                        : VoidColors.primary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => provider.settleDebt(debt.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: VoidColors.primaryLight,
                      borderRadius:
                          BorderRadius.circular(100),
                    ),
                    child: Text('Settle',
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: VoidColors.primary,
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
            colors: [VoidColors.gradStart, VoidColors.gradEnd],
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
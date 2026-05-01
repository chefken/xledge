import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xledge/providers/void_provider.dart';
import 'package:xledge/services/auth_service.dart';
import 'package:xledge/services/pdf_service.dart';
import 'package:xledge/utils/category_utils.dart';
import 'package:xledge/utils/void_colors.dart';
import 'package:xledge/utils/void_spacing.dart';
import 'package:xledge/utils/void_text_styles.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  bool _authenticated = false;
  bool _loading       = true;
  int  _touchedIndex  = -1;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    setState(() => _loading = true);
    final result = await AuthService.authenticate(
      reason: 'Verify your identity to view Activity Report',
    );
    if (mounted) setState(() { _authenticated = result; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: VoidColors.background,
        body: Center(
          child: CircularProgressIndicator(color: VoidColors.primary),
        ),
      );
    }

    if (!_authenticated) {
      return Scaffold(
        backgroundColor: VoidColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: const BoxDecoration(
                    color: VoidColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.fingerprint,
                      color: VoidColors.primary, size: 40),
                ),
                const SizedBox(height: 20),
                const Text('Authentication Required',
                    style: VoidTextStyles.titleLarge,
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                const Text(
                  'This section is protected.\nVerify your identity to continue.',
                  style: VoidTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _authenticate,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Authenticate'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Consumer<VoidProvider>(
      builder: (context, provider, _) {
        final analysis = provider.analysis;
        final hasData  = analysis?.hasData ?? false;

        return Scaffold(
          backgroundColor: VoidColors.background,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      VoidSpacing.screenH, 16, VoidSpacing.screenH, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Activity', style: VoidTextStyles.headlineMedium),
                      IconButton(
                        onPressed: hasData
                            ? () => _generatePdf(context, provider)
                            : null,
                        icon: const Icon(Icons.picture_as_pdf_rounded),
                        color: VoidColors.primary,
                        tooltip: 'Export PDF',
                        style: IconButton.styleFrom(
                          backgroundColor: VoidColors.primaryLight,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
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
                  child: _MonthSummaryCard(provider: provider),
                ),
              ),
              if (hasData) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        VoidSpacing.screenH, 28, VoidSpacing.screenH, 12),
                    child: Text('Spending Breakdown',
                        style: VoidTextStyles.titleLarge),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: VoidSpacing.screenH),
                    child: _PieChartSection(
                      analysis: analysis!,
                      touchedIndex: _touchedIndex,
                      onTouch: (i) => setState(() => _touchedIndex = i),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        VoidSpacing.screenH, 20, VoidSpacing.screenH, 12),
                    child: Text('Category Details',
                        style: VoidTextStyles.titleLarge),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: VoidSpacing.screenH),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final c = analysis.categoryBreakdown[i];
                        return _CategoryBar(categoryTotal: c);
                      },
                      childCount: analysis.categoryBreakdown.length,
                    ),
                  ),
                ),
                if (analysis.primaryLeak != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          VoidSpacing.screenH, 20,
                          VoidSpacing.screenH, 0),
                      child: _LeakCard(analysis: analysis),
                    ),
                  ),
              ] else
                SliverFillRemaining(child: _EmptyActivity()),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }

  Future<void> _generatePdf(
      BuildContext context, VoidProvider provider) async {
    final analysis = provider.analysis;
    if (analysis == null) return;
    await PdfService.generateMonthlyReport(
      month:          provider.selectedMonth,
      year:           provider.selectedYear,
      expenses:       provider.getAllExpensesForMonth(
                          provider.selectedYear, provider.selectedMonth),
      analysis:       analysis,
      totalAllowance: provider.totalAllowance,
    );
  }
}

class _MonthSummaryCard extends StatelessWidget {
  final VoidProvider provider;
  const _MonthSummaryCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final net      = provider.netBalance;
    final positive = net >= 0;

    return Container(
      padding: const EdgeInsets.all(VoidSpacing.cardInner),
      decoration: BoxDecoration(
        color: VoidColors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: VoidColors.outline, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: 'Total Spent',
                  value: '₹${(provider.analysis?.totalSpend ?? 0).toStringAsFixed(2)}',
                  color: VoidColors.danger,
                  bg: VoidColors.dangerLight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  label: 'Allowance',
                  value: '₹${provider.totalAllowance.toStringAsFixed(2)}',
                  color: VoidColors.success,
                  bg: VoidColors.successLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: positive
                  ? VoidColors.successLight
                  : VoidColors.dangerLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  positive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color:
                      positive ? VoidColors.success : VoidColors.danger,
                ),
                const SizedBox(width: 8),
                Text(
                  'Net Balance: ${positive ? '+' : ''}₹${net.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color:
                        positive ? VoidColors.success : VoidColors.danger,
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

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color bg;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                fontSize: 11,
                color: VoidColors.textSecondary,
                fontWeight: FontWeight.w500,
              )),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: -0.5,
              )),
        ],
      ),
    );
  }
}

class _PieChartSection extends StatelessWidget {
  final dynamic analysis;
  final int touchedIndex;
  final ValueChanged<int> onTouch;

  const _PieChartSection({
    required this.analysis,
    required this.touchedIndex,
    required this.onTouch,
  });

  @override
  Widget build(BuildContext context) {
    final sections = <PieChartSectionData>[];
    for (int i = 0; i < analysis.categoryBreakdown.length; i++) {
      final c      = analysis.categoryBreakdown[i];
      final meta   = categoryMeta(c.category);
      final touched = i == touchedIndex;
      sections.add(PieChartSectionData(
        value:     c.percentage,
        color:     meta.color,
        radius:    touched ? 70 : 56,
        title:     touched ? '${c.percentage.toStringAsFixed(1)}%' : '',
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ));
    }

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VoidColors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: VoidColors.outline, width: 1.5),
      ),
      child: PieChart(
        PieChartData(
          sections:           sections,
          centerSpaceRadius:  48,
          sectionsSpace:      2,
          pieTouchData: PieTouchData(
            touchCallback: (event, response) {
              if (!event.isInterestedForInteractions ||
                  response == null ||
                  response.touchedSection == null) {
                onTouch(-1);
                return;
              }
              onTouch(response.touchedSection!.touchedSectionIndex);
            },
          ),
        ),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final dynamic categoryTotal;
  const _CategoryBar({required this.categoryTotal});

  @override
  Widget build(BuildContext context) {
    final meta = categoryMeta(categoryTotal.category);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                        color: meta.lightColor, shape: BoxShape.circle),
                    child: Icon(meta.icon, color: meta.color, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Text(categoryTotal.category,
                      style: VoidTextStyles.titleMedium),
                ],
              ),
              Text(
                '₹${categoryTotal.total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: meta.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value:            categoryTotal.percentage / 100,
              minHeight:        6,
              backgroundColor:  meta.lightColor,
              valueColor:       AlwaysStoppedAnimation(meta.color),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${categoryTotal.percentage.toStringAsFixed(1)}% of total',
            style: VoidTextStyles.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _LeakCard extends StatelessWidget {
  final dynamic analysis;
  const _LeakCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final meta = categoryMeta(analysis.primaryLeak!);
    return Container(
      padding: const EdgeInsets.all(VoidSpacing.cardInner),
      decoration: BoxDecoration(
        color: meta.lightColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: meta.color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
                color: meta.color.withOpacity(0.15),
                shape: BoxShape.circle),
            child: Icon(meta.icon, color: meta.color, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Primary Spending Leak',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: VoidColors.textSecondary,
                    )),
                const SizedBox(height: 2),
                Text(analysis.primaryLeak!,
                    style: VoidTextStyles.titleMedium),
                Text(
                  '₹${analysis.primaryLeakAmount!.toStringAsFixed(2)} · '
                  '${analysis.primaryLeakPercentage!.toStringAsFixed(1)}% of spend',
                  style: TextStyle(
                    fontSize: 12,
                    color: meta.color,
                    fontWeight: FontWeight.w600,
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

class _EmptyActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72, height: 72,
          decoration: const BoxDecoration(
              color: VoidColors.primaryLight, shape: BoxShape.circle),
          child: const Icon(Icons.bar_chart_rounded,
              color: VoidColors.primary, size: 32),
        ),
        const SizedBox(height: 16),
        const Text('No data this month', style: VoidTextStyles.titleMedium),
        const SizedBox(height: 6),
        const Text('Add expenses to see your breakdown',
            style: VoidTextStyles.bodyMedium),
      ],
    );
  }
}
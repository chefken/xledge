import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xledge/models/expense_model.dart';
import 'package:xledge/providers/void_provider.dart';
import 'package:xledge/services/pdf_service.dart';
import 'package:xledge/utils/category_utils.dart';
import 'package:xledge/utils/void_colors.dart';
import 'package:xledge/utils/void_text_styles.dart';
import 'package:xledge/widgets/void_card.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    return Consumer<VoidProvider>(
      builder: (context, provider, _) {
        final analysis = provider.analysis;
        final hasData  = analysis?.hasData ?? false;
        final now      = DateTime.now();

        final yearlyData = List.generate(now.month, (i) {
          final m = i + 1;
          return provider
              .getAllExpensesForMonth(now.year, m)
              .where((e) => !e.isAllowance)
              .fold(0.0, (s, e) => s + e.amount);
        });

        return Scaffold(
          backgroundColor: VoidColors.background,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 64, 24, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Activity',
                          style: VoidTextStyles.headlineLarge),
                      GestureDetector(
                        onTap: hasData
                            ? () => _exportPdf(context, provider)
                            : null,
                        child: Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: hasData
                                ? VoidColors.primaryLight
                                : VoidColors.outlineVariant,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(
                            Icons.picture_as_pdf_rounded,
                            color: hasData
                                ? VoidColors.primary
                                : VoidColors.textHint,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _SummaryCard(provider: provider),
                ),
              ),
              if (yearlyData.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                    child: const Text('This Year',
                        style: VoidTextStyles.titleLarge),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: VoidCard(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: _YearlyGraph(data: yearlyData),
                    ),
                  ),
                ),
              ],
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                  child: const Text('Daily Heatmap',
                      style: VoidTextStyles.titleLarge),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: VoidCard(
                    child: _Heatmap(provider: provider),
                  ),
                ),
              ),
              if (hasData) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                    child: const Text('Breakdown',
                        style: VoidTextStyles.titleLarge),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: VoidCard(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        height: 200,
                        child: _DonutChart(
                          analysis:  analysis!,
                          touched:   _touched,
                          onTouch:   (i) => setState(() => _touched = i),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                    child: const Text('Categories',
                        style: VoidTextStyles.titleLarge),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _CatBar(
                          cat: analysis!.categoryBreakdown[i]),
                      childCount: analysis!.categoryBreakdown.length,
                    ),
                  ),
                ),
                if (analysis!.primaryLeak != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                      child: _InsightCard(
                        text: 'Your biggest spend is on '
                            '${analysis.primaryLeak}. It accounts for '
                            '${analysis.primaryLeakPercentage!.toStringAsFixed(0)}% of this month.',
                      ),
                    ),
                  ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 130)),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportPdf(
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

class _SummaryCard extends StatelessWidget {
  final VoidProvider provider;
  const _SummaryCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final net = provider.netBalance;
    final pos = net >= 0;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9B7EF8), Color(0xFF6C3CE1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: VoidColors.primary.withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${months[provider.selectedMonth]} ${provider.selectedYear}',
            style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w500,
              color: Colors.white60, letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SumItem(
                  label: 'Spent',
                  value: '₹${(provider.analysis?.totalSpend ?? 0).toStringAsFixed(0)}',
                ),
              ),
              Expanded(
                child: _SumItem(
                  label: 'Received',
                  value: '₹${provider.totalAllowance.toStringAsFixed(0)}',
                ),
              ),
              Expanded(
                child: _SumItem(
                  label: 'Net',
                  value: '${pos ? '+' : ''}₹${net.abs().toStringAsFixed(0)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SumItem extends StatelessWidget {
  final String label;
  final String value;
  const _SumItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 11, color: Colors.white54,
              fontWeight: FontWeight.w400,
            )),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: Colors.white, letterSpacing: -0.5,
            )),
      ],
    );
  }
}

class _YearlyGraph extends StatelessWidget {
  final List<double> data;
  const _YearlyGraph({required this.data});

  @override
  Widget build(BuildContext context) {
    const labels = ['J','F','M','A','M','J','J','A','S','O','N','D'];
    final max    = data.isEmpty ? 1.0 : data.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 160,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: max * 1.25,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: max > 0 ? max / 3 : 1,
            getDrawingHorizontalLine: (_) => FlLine(
              color: VoidColors.outline,
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= labels.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(labels[i],
                        style: VoidTextStyles.labelSmall),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: data
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              isCurved: true,
              curveSmoothness: 0.35,
              color: VoidColors.primary,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (_, __, ___, ____) =>
                    FlDotCirclePainter(
                  radius: 3,
                  color: VoidColors.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    VoidColors.primary.withOpacity(0.15),
                    VoidColors.primary.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      ),
    );
  }
}

class _Heatmap extends StatelessWidget {
  final VoidProvider provider;
  const _Heatmap({required this.provider});

  @override
  Widget build(BuildContext context) {
    final now       = DateTime.now();
    final daysInMonth =
        DateUtils.getDaysInMonth(now.year, now.month);
    final firstDay =
        DateTime(now.year, now.month, 1).weekday % 7;

    final dailyAmounts = <int, double>{};
    final expenses = provider.getAllExpensesForMonth(now.year, now.month)
        .where((e) => !e.isAllowance);
    for (final e in expenses) {
      dailyAmounts[e.date.day] =
          (dailyAmounts[e.date.day] ?? 0) + e.amount;
    }

    final maxAmt = dailyAmounts.values.isEmpty
        ? 1.0
        : dailyAmounts.values.reduce((a, b) => a > b ? a : b);

    const headers = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: headers
              .map((h) => SizedBox(
                    width: 30,
                    child: Text(h,
                        style: VoidTextStyles.labelSmall,
                        textAlign: TextAlign.center),
                  ))
              .toList(),
        ),
        const SizedBox(height: 6),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: firstDay + daysInMonth,
          itemBuilder: (_, i) {
            if (i < firstDay) return const SizedBox.shrink();
            final day  = i - firstDay + 1;
            final amt  = dailyAmounts[day] ?? 0;
            final intensity = amt > 0 ? (amt / maxAmt).clamp(0.1, 1.0) : 0.0;

            return Container(
              decoration: BoxDecoration(
                color: intensity > 0
                    ? VoidColors.primary.withOpacity(intensity * 0.75)
                    : VoidColors.outlineVariant,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text('$day',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: intensity > 0.5
                        ? Colors.white
                        : VoidColors.textHint,
                  )),
            );
          },
        ),
      ],
    );
  }
}

class _DonutChart extends StatelessWidget {
  final dynamic analysis;
  final int touched;
  final ValueChanged<int> onTouch;

  const _DonutChart({
    required this.analysis,
    required this.touched,
    required this.onTouch,
  });

  @override
  Widget build(BuildContext context) {
    final sections = <PieChartSectionData>[];
    final purples = [
      const Color(0xFF7C5CFC),
      const Color(0xFF9B7EF8),
      const Color(0xFFB49BFB),
      const Color(0xFFCDBCFC),
      const Color(0xFFD8CFFF),
      const Color(0xFF5B3FD4),
      const Color(0xFF3D2B9E),
      const Color(0xFF6C3CE1),
    ];

    for (int i = 0; i < analysis.categoryBreakdown.length; i++) {
      final c       = analysis.categoryBreakdown[i];
      final isTouched = i == touched;
      sections.add(PieChartSectionData(
        value:  c.percentage,
        color:  purples[i % purples.length],
        radius: isTouched ? 64 : 50,
        title:  isTouched
            ? '${c.percentage.toStringAsFixed(0)}%'
            : '',
        titleStyle: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ));
    }

    return PieChart(
      PieChartData(
        sections:          sections,
        centerSpaceRadius: 50,
        sectionsSpace:     2,
        pieTouchData: PieTouchData(
          touchCallback: (e, r) {
            if (!e.isInterestedForInteractions ||
                r?.touchedSection == null) {
              onTouch(-1);
              return;
            }
            onTouch(r!.touchedSection!.touchedSectionIndex);
          },
        ),
      ),
      duration: const Duration(milliseconds: 300),
    );
  }
}

class _CatBar extends StatelessWidget {
  final dynamic cat;
  const _CatBar({required this.cat});

  @override
  Widget build(BuildContext context) {
    final meta = categoryMeta(cat.category);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: VoidColors.iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(meta.icon, color: VoidColors.iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(cat.category, style: VoidTextStyles.titleMedium),
                    Text('₹${cat.total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: VoidColors.primary,
                          letterSpacing: -0.2,
                        )),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: cat.percentage / 100,
                    minHeight: 4,
                    backgroundColor: VoidColors.outlineVariant,
                    valueColor: const AlwaysStoppedAnimation(
                        VoidColors.primary),
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

class _InsightCard extends StatelessWidget {
  final String text;
  const _InsightCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VoidColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline_rounded,
              color: VoidColors.primary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                  fontSize: 13,
                  color: VoidColors.primary,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                )),
          ),
        ],
      ),
    );
  }
}
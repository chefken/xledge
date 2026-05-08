import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        final analysis  = provider.analysis;
        final hasData   = analysis?.hasData ?? false;
        final now       = DateTime.now();
        final yearData  = List.generate(now.month, (i) {
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
                       Text('Activity',
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
                            Icons.ios_share_rounded,
                            color: hasData
                                ? VoidColors.primary
                                : VoidColors.textHint,
                            size: 17,
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
                  child: _MonthCard(provider: provider),
                ),
              ),
              if (yearData.isNotEmpty) ...[
                _SectionTitle('This Year'),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: VoidCard(
  padding: const EdgeInsets.all(20),
  child: _MonthlyBarGraph(data: yearData),
),
                  ),
                ),
              ],
              
              if (hasData) ...[
                _SectionTitle('Spending Mix'),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: VoidCard(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: _MonoDonut(
                              analysis: analysis!,
                              touched:  _touched,
                              onTouch:  (i) =>
                                  setState(() => _touched = i),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: analysis!.categoryBreakdown
                                  .take(4)
                                  .map((c) => _LegendRow(cat: c))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _SectionTitle('By Category'),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _CatInterpretRow(
                        cat: analysis!.categoryBreakdown[i],
                        isTop: i == 0,
                      ),
                      childCount:
                          analysis!.categoryBreakdown.length,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: _ReflectionCard(
                        provider: provider, analysis: analysis!),
                  ),
                ),
              ],
              if (!hasData)
                SliverFillRemaining(child: _EmptyActivity()),
              const SliverToBoxAdapter(child: SizedBox(height: 130)),
            ],
          ),
        );
      },
    );
  }

  List<String> _generateInsights(VoidProvider provider, DateTime now) {
    final expenses = provider.getAllExpensesForMonth(now.year, now.month)
        .where((e) => !e.isAllowance)
        .toList();

    if (expenses.isEmpty) return [];

    final insights = <String>[];

    final lowDays = <int>{};
    for (final e in expenses) {
      lowDays.add(e.date.day);
    }
    final totalDays = DateUtils.getDaysInMonth(now.year, now.month);
    final quietDays = totalDays - lowDays.length;
    if (quietDays > 0) {
      insights.add(
          'You had $quietDays quiet days with no spending this month.');
    }

    final weekendSpend = expenses
        .where((e) =>
            e.date.weekday == DateTime.saturday ||
            e.date.weekday == DateTime.sunday)
        .fold(0.0, (s, e) => s + e.amount);

    final weekdaySpend = expenses
        .where((e) =>
            e.date.weekday != DateTime.saturday &&
            e.date.weekday != DateTime.sunday)
        .fold(0.0, (s, e) => s + e.amount);

    if (weekendSpend > weekdaySpend * 0.4) {
      insights.add(
          'Weekends accounted for a notable portion of your spending.');
    }

    final analysis = provider.analysis;
    if (analysis != null && analysis.primaryLeak != null) {
      insights.add(
          '${analysis.primaryLeak} is your primary spending category at '
          '${analysis.primaryLeakPercentage!.toStringAsFixed(0)}% of total.');
    }

    final net = provider.netBalance;
    if (net > 0) {
      insights.add(
          'You are ₹${net.toStringAsFixed(0)} in the green this month.');
    } else if (net < 0) {
      insights.add(
          'You overspent by ₹${net.abs().toStringAsFixed(0)} this month.');
    }

    return insights;
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

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
        child: Text(text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: VoidColors.textPrimary,
              letterSpacing: -0.2,
            )),
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  final VoidProvider provider;
  const _MonthCard({required this.provider});

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
          colors: [Color(0xFF9B7EF8), Color(0xFF5B3FD4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: VoidColors.primary.withOpacity(0.2),
            blurRadius: 28,
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
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Colors.white54,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MonthStat(
                  label: 'Spent',
                  value: '₹${(provider.analysis?.totalSpend ?? 0).toStringAsFixed(0)}',
                ),
              ),
              Expanded(
                child: _MonthStat(
                  label: 'Received',
                  value: '₹${provider.totalAllowance.toStringAsFixed(0)}',
                ),
              ),
              Expanded(
                child: _MonthStat(
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

class _MonthStat extends StatelessWidget {
  final String label;
  final String value;
  const _MonthStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white38,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.3,
            )),
        const SizedBox(height: 5),
        Text(value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.6,
            )),
      ],
    );
  }
}

class _MonthlyBarGraph extends StatefulWidget {
  final List<double> data;
  const _MonthlyBarGraph({required this.data});

  @override
  State<_MonthlyBarGraph> createState() => _MonthlyBarGraphState();
}

class _MonthlyBarGraphState extends State<_MonthlyBarGraph>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _anim;
  int _tapped = -1;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    const labels = ['J','F','M','A','M','J','J','A','S','O','N','D'];
    final max = widget.data.isEmpty
        ? 1.0
        : widget.data.reduce((a, b) => a > b ? a : b);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return SizedBox(
          height: 160,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(widget.data.length, (i) {
              final val        = widget.data[i];
              final ratio      = max > 0 ? val / max : 0.0;
              final animRatio  = ratio * _anim.value;
              final isTapped   = _tapped == i;
              final intensity  = ratio.clamp(0.15, 1.0);

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() =>
                      _tapped = isTapped ? -1 : i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isTapped)
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: VoidColors.primary,
                              borderRadius:
                                  BorderRadius.circular(6),
                            ),
                            child: Text(
                              '₹${val.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontFamily: 'BricolageGrotesque',
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 3),
                        child: AnimatedContainer(
                          duration:
                              const Duration(milliseconds: 200),
                          height: (animRatio * 120).clamp(4.0, 120.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                VoidColors.primary.withOpacity(
                                    0.3 + intensity * 0.7),
                                VoidColors.primaryDark.withOpacity(
                                    0.4 + intensity * 0.6),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: isTapped
                                ? Border.all(
                                    color: VoidColors.primary,
                                    width: 1.5,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        labels[i],
                        style: const TextStyle(
                          fontFamily: 'BricolageGrotesque',
                          fontSize: 10,
                          color: VoidColors.textHint,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class _InsightTile extends StatelessWidget {
  final String text;
  const _InsightTile({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VoidColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: VoidColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: VoidColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lightbulb_outline_rounded,
                color: VoidColors.primary, size: 15),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                  fontSize: 13,
                  color: VoidColors.textPrimary,
                  fontWeight: FontWeight.w400,
                  height: 1.45,
                  letterSpacing: -0.1,
                )),
          ),
        ],
      ),
    );
  }
}

class _MonoDonut extends StatelessWidget {
  final dynamic analysis;
  final int touched;
  final ValueChanged<int> onTouch;

  const _MonoDonut({
    required this.analysis,
    required this.touched,
    required this.onTouch,
  });

  @override
  Widget build(BuildContext context) {
    final shades = [
      VoidColors.primary,
      const Color(0xFF9B7EF8),
      const Color(0xFFB9A5FC),
      const Color(0xFFD0C4FD),
      const Color(0xFFE8E2FE),
      const Color(0xFF5B3FD4),
    ];

    final sections = <PieChartSectionData>[];
    for (int i = 0; i < analysis.categoryBreakdown.length; i++) {
      final c       = analysis.categoryBreakdown[i];
      final isTouched = i == touched;
      sections.add(PieChartSectionData(
        value:     c.percentage,
        color:     shades[i % shades.length],
        radius:    isTouched ? 52 : 42,
        title:     '',
        showTitle: false,
      ));
    }

    return PieChart(
      PieChartData(
        sections:          sections,
        centerSpaceRadius: 32,
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

class _LegendRow extends StatelessWidget {
  final dynamic cat;
  const _LegendRow({required this.cat});

  @override
  Widget build(BuildContext context) {
    const shades = [
      VoidColors.primary,
      Color(0xFF9B7EF8),
      Color(0xFFB9A5FC),
      Color(0xFFD0C4FD),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: shades[0],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              cat.category,
              style: const TextStyle(
                fontSize: 12,
                color: VoidColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${cat.percentage.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: VoidColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CatInterpretRow extends StatelessWidget {
  final dynamic cat;
  final bool isTop;

  const _CatInterpretRow({required this.cat, required this.isTop});

  @override
  Widget build(BuildContext context) {
    final meta = categoryMeta(cat.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isTop ? VoidColors.primaryLight : VoidColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isTop
            ? null
            : const [
                BoxShadow(
                  color: VoidColors.shadow,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: isTop
                  ? VoidColors.primary.withOpacity(0.12)
                  : VoidColors.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              meta.icon,
              size: 17,
              color: isTop ? VoidColors.primary : VoidColors.iconColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cat.category,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isTop
                          ? VoidColors.primary
                          : VoidColors.textPrimary,
                      letterSpacing: -0.1,
                    )),
                const SizedBox(height: 3),
                Text(
                  isTop
                      ? 'Highest spend · ${cat.percentage.toStringAsFixed(0)}% of total'
                      : '${cat.percentage.toStringAsFixed(0)}% of total spending',
                  style: TextStyle(
                    fontSize: 11,
                    color: isTop
                        ? VoidColors.primary.withOpacity(0.7)
                        : VoidColors.textHint,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${cat.total.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isTop
                  ? VoidColors.primary
                  : VoidColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReflectionCard extends StatelessWidget {
  final VoidProvider provider;
  final dynamic analysis;
  const _ReflectionCard({
    required this.provider,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final month = months[provider.selectedMonth];
    final leak  = analysis.primaryLeak ?? 'various categories';
    final net   = provider.netBalance;
    final netStr = net >= 0
        ? 'You stayed in the green by ₹${net.toStringAsFixed(0)}.'
        : 'You overspent by ₹${net.abs().toStringAsFixed(0)} this month.';

    final reflection =
        'In $month, most of your spending went towards $leak. '
        '$netStr Consider reviewing your $leak expenses going into next month.';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: VoidColors.outlineVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Monthly Reflection',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: VoidColors.textHint,
                letterSpacing: 0.3,
              )),
          const SizedBox(height: 10),
          Text(reflection,
              style: const TextStyle(
                fontSize: 14,
                color: VoidColors.textPrimary,
                fontWeight: FontWeight.w400,
                height: 1.55,
                letterSpacing: -0.1,
              )),
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
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: VoidColors.primaryLight,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.bar_chart_rounded,
              color: VoidColors.primary, size: 26),
        ),
        const SizedBox(height: 14),
        Text('No data yet', style: VoidTextStyles.titleMedium),
        const SizedBox(height: 6),
        Text('Add expenses to see your monthly report',
            style: VoidTextStyles.bodyMedium,
            textAlign: TextAlign.center),
      ],
    );
  }
}
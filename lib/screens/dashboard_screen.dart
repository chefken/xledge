import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:xledge/providers/void_provider.dart';
import 'package:xledge/screens/add_expense_sheet.dart';
import 'package:xledge/utils/void_colors.dart';
import 'package:xledge/utils/void_text_styles.dart';
import 'package:xledge/widgets/transaction_tile.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:xledge/models/expense_model.dart';
import 'package:xledge/services/user_prefs_service.dart';
import 'package:xledge/utils/theme_ext.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onSeeAll;
  const DashboardScreen({super.key, this.onSeeAll});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}


class _DashboardScreenState extends State<DashboardScreen> {
  final _pageCtrl = PageController(viewportFraction: 0.91);
  int _heroPage   = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _openCalendar(BuildContext context, VoidProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CalendarSheet(provider: provider),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VoidProvider>(
      builder: (context, provider, _) {
        final analysis = provider.analysis;
        final recent   = provider.expenses.take(5).toList();

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _Header(
                onCalendar: () => _openCalendar(context, provider),
              ),
            ),
            SliverToBoxAdapter(
              child: _HeroCarousel(
                ctrl:       _pageCtrl,
                page:       _heroPage,
                onPage:     (i) => setState(() => _heroPage = i),
                totalSpend: analysis?.totalSpend ?? 0,
                totalAllow: provider.totalAllowance,
                totalDebt:  provider.totalIOwe,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent', style: VoidTextStyles.titleLarge),
                    GestureDetector(
                      onTap: widget.onSeeAll,
                      child: Text('See all',
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: VoidColors.primary,
                          )),
                    ),
                  ],
                ),
              ),
            ),
            recent.isEmpty
                ? SliverToBoxAdapter(child: _EmptyState())
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => TransactionTile(
                          expense:   recent[i],
                          onDismiss: () =>
                              provider.deleteExpense(recent[i].id),
                          onEdit: () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => AddExpenseSheet(
                                existingExpense: recent[i]),
                          ),
                        ),
                        childCount: recent.length,
                      ),
                    ),
                  ),
            const SliverToBoxAdapter(child: SizedBox(height: 140)),
          ],
        );
      },
    );
  }
}

class _Header extends StatefulWidget {
  final VoidCallback onCalendar;
  const _Header({required this.onCalendar});

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  String _name = UserPrefsService.username;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() => _name = UserPrefsService.username);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txPri  = isDark ? VoidColors.darkTextPrimary   : VoidColors.textPrimary;
    final txSec  = isDark ? VoidColors.darkTextSecondary : VoidColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello,',
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: txSec,
                    letterSpacing: 0.1,
                    height: 1.2,
                  )),
              const SizedBox(height: 2),
              Text(_name,
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 38,
                    fontWeight: FontWeight.w600,
                    color: txPri,
                    letterSpacing: -1.5,
                    height: 1.0,
                  )),
            ],
          ),
          _CalendarButton(onTap: widget.onCalendar),
        ],
      ),
    );
  }
}

class _CalendarButton extends StatefulWidget {
  final VoidCallback onTap;
  const _CalendarButton({required this.onTap});

  @override
  State<_CalendarButton> createState() => _CalendarButtonState();
}

class _CalendarButtonState extends State<_CalendarButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      value: 1,
    );
    _scale = Tween(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
Widget build(BuildContext context) {
  return GestureDetector(
    onTapDown:   (_) => _ctrl.reverse(),
    onTapUp:     (_) { _ctrl.forward(); widget.onTap(); },
    onTapCancel: ()  => _ctrl.forward(),
    child: ScaleTransition(
      scale: _scale,
      child: Container(
        width: 46, height: 46,
        decoration: BoxDecoration(
          color: context.xCard,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: context.xShadow,
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.calendar_month_outlined,
          color: context.xTxSec,
          size: 20,
        ),
      ),
    ),
  );
}
}

class _HeroCarousel extends StatelessWidget {
  final PageController ctrl;
  final int page;
  final ValueChanged<int> onPage;
  final double totalSpend;
  final double totalAllow;
  final double totalDebt;

  const _HeroCarousel({
    required this.ctrl,
    required this.page,
    required this.onPage,
    required this.totalSpend,
    required this.totalAllow,
    required this.totalDebt,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _CardData(
        tag: 'THIS MONTH',
        label: 'Total Spent',
        amount: totalSpend,
        colors: [
          const Color(0xFF1A1830),
          const Color(0xFF2D2A52),
          const Color(0xFF3D3870),
        ],
      ),
      _CardData(
        tag: 'THIS MONTH',
        label: 'Total Allowance',
        amount: totalAllow,
        colors: [
          const Color(0xFF1C1A34),
          const Color(0xFF2E2B54),
          const Color(0xFF3E3A72),
        ],
      ),
      _CardData(
        tag: 'THIS MONTH',
        label: 'You Owe',
        amount: totalDebt,
        colors: [
          const Color(0xFF181628),
          const Color(0xFF282546),
          const Color(0xFF363264),
        ],
      ),
    ];

    return Column(
      children: [
        SizedBox(
          height: 172,
          child: PageView.builder(
            controller: ctrl,
            onPageChanged: onPage,
            physics: const BouncingScrollPhysics(),
            itemCount: cards.length,
            itemBuilder: (_, i) => AnimatedBuilder(
              animation: ctrl,
              builder: (_, child) {
                double p = 0;
                try { p = ctrl.page ?? i.toDouble(); } catch (_) {}
                final d       = (p - i).abs().clamp(0.0, 1.0);
                final scale   = 1.0 - d * 0.04;
                final opacity = 1.0 - d * 0.3;
                return Transform.scale(
                  scale: scale,
                  child: Opacity(opacity: opacity, child: child),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _HeroCard(data: cards[i]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            cards.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width:  page == i ? 22 : 5,
              height: 5,
              decoration: BoxDecoration(
                color: page == i
                    ? VoidColors.primary
                    : VoidColors.outline,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CardData {
  final String tag;
  final String label;
  final double amount;
  final List<Color> colors;
  const _CardData({
    required this.tag,
    required this.label,
    required this.amount,
    required this.colors,
  });
}

class _HeroCard extends StatelessWidget {
  final _CardData data;
  const _HeroCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: data.colors,
          stops: const [0.0, 0.55, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D2A52).withOpacity(0.22),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.tag,
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Colors.white38,
                letterSpacing: 1.8,
              )),
          const Spacer(),
          Text(
            '₹${data.amount.toStringAsFixed(0)}',
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 38,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: -1.6,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(data.label,
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 13,
                    color: Colors.white54,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.1,
                  )),
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white54, size: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: VoidColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.receipt_long_outlined,
                color: VoidColors.primary, size: 26),
          ),
          const SizedBox(height: 16),
          Text('Nothing yet', style: VoidTextStyles.titleMedium),
          const SizedBox(height: 6),
          Text('Your activity will appear here',
              style: VoidTextStyles.bodyMedium,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _CalendarSheet extends StatefulWidget {
  final VoidProvider provider;
  const _CalendarSheet({required this.provider});

  @override
  State<_CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<_CalendarSheet> {
  DateTime _focused  = DateTime.now();
  DateTime _selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final allExpenses = widget.provider.getAllExpensesForMonth(
        _focused.year, _focused.month);

    final events = <DateTime, List<Expense>>{};
    for (final e in allExpenses) {
      final key = DateTime(e.date.year, e.date.month, e.date.day);
      events.putIfAbsent(key, () => []).add(e);
    }

    final dayExpenses = allExpenses.where((e) =>
        e.date.year  == _selected.year &&
        e.date.month == _selected.month &&
        e.date.day   == _selected.day).toList();

    final daySpend = dayExpenses
        .where((e) => !e.isAllowance)
        .fold(0.0, (s, e) => s + e.amount);

    final dayRecv = dayExpenses
        .where((e) => e.isAllowance)
        .fold(0.0, (s, e) => s + e.amount);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: VoidColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: VoidColors.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Calendar', style: VoidTextStyles.headlineMedium),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      color: VoidColors.outlineVariant,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: VoidColors.textSecondary, size: 18),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: VoidColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: VoidColors.shadowMd,
                            blurRadius: 20,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TableCalendar<Expense>(
                        firstDay:  DateTime(2020),
                        lastDay:   DateTime(2030),
                        focusedDay: _focused,
                        selectedDayPredicate: (d) =>
                            isSameDay(d, _selected),
                        eventLoader: (day) {
                          final key = DateTime(
                              day.year, day.month, day.day);
                          return events[key] ?? [];
                        },
                        onDaySelected: (sel, foc) {
                          setState(() {
                            _selected = sel;
                            _focused  = foc;
                          });
                        },
                        onPageChanged: (foc) {
                          setState(() => _focused = foc);
                          widget.provider.setMonth(
                              foc.year, foc.month);
                        },
                        calendarFormat: CalendarFormat.month,
                        availableCalendarFormats: const {
                          CalendarFormat.month: 'Month',
                        },
                        startingDayOfWeek: StartingDayOfWeek.sunday,
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          leftChevronIcon: Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: VoidColors.outlineVariant,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                                Icons.chevron_left_rounded,
                                color: VoidColors.textSecondary,
                                size: 18),
                          ),
                          rightChevronIcon: Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: VoidColors.outlineVariant,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                                Icons.chevron_right_rounded,
                                color: VoidColors.textSecondary,
                                size: 18),
                          ),
                          titleTextStyle:
                              GoogleFonts.bricolageGrotesque(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: VoidColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                          headerPadding: const EdgeInsets.fromLTRB(
                              16, 18, 16, 6),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle:
                              GoogleFonts.bricolageGrotesque(
                            fontSize: 11,
                            color: VoidColors.textHint,
                          ),
                          weekendStyle:
                              GoogleFonts.bricolageGrotesque(
                            fontSize: 11,
                            color: VoidColors.textHint,
                          ),
                        ),
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: false,
                          defaultTextStyle:
                              GoogleFonts.bricolageGrotesque(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: VoidColors.textPrimary,
                          ),
                          weekendTextStyle:
                              GoogleFonts.bricolageGrotesque(
                            fontSize: 13,
                            color: VoidColors.textPrimary,
                          ),
                          todayTextStyle:
                              GoogleFonts.bricolageGrotesque(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: VoidColors.primary,
                          ),
                          selectedTextStyle:
                              GoogleFonts.bricolageGrotesque(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: VoidColors.primary,
                          ),
                          todayDecoration: BoxDecoration(
                            color: VoidColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: const BoxDecoration(
  color: VoidColors.primaryLight,
  shape: BoxShape.circle,
),
                          
                          markersMaxCount: 1,
                  
                          cellMargin: const EdgeInsets.all(4),
                        ),
                        calendarBuilders: CalendarBuilders(
  markerBuilder: (context, day, events) {
    if (events.isEmpty) return const SizedBox.shrink();
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: VoidColors.primary,
        shape: BoxShape.circle,
      ),
    );
  },
),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: VoidColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: VoidColors.shadowMd,
                            blurRadius: 16,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _fmtDay(_selected),
                                  style: GoogleFonts.bricolageGrotesque(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: VoidColors.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                Text(
                                  '${dayExpenses.length} transaction${dayExpenses.length == 1 ? '' : 's'}',
                                  style: VoidTextStyles.labelSmall,
                                ),
                              ],
                            ),
                          ),
                          _MiniChip(
  label: 'Spent',
  value: daySpend > 0
      ? '₹${daySpend.toStringAsFixed(0)}'
      : '₹0',
  color: VoidColors.textPrimary,
  bg: const Color(0xFFF4F4F6),
),
const SizedBox(width: 8),
                          _MiniChip(
                            label: 'Allowance',
                            value: dayRecv > 0
                                ? '+₹${dayRecv.toStringAsFixed(0)}'
                                : '₹0',
                            color: dayRecv > 0
                                ? VoidColors.primary
                                : VoidColors.textHint,
                            bg: dayRecv > 0
                                ? VoidColors.primaryLight
                                : VoidColors.outlineVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (dayExpenses.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'TRANSACTIONS',
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: VoidColors.textHint,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: dayExpenses.map((e) => TransactionTile(
                          expense: e,
                          onDismiss: () =>
                              widget.provider.deleteExpense(e.id),
                        )).toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDay(DateTime d) {
    const m = ['','Jan','Feb','Mar','Apr','May','Jun',
                'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month]} ${d.year}';
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color bg;

  const _MiniChip({
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 9,
                color: VoidColors.textHint,
              )),
          const SizedBox(height: 2),
          Text(value,
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: -0.3,
              )),
        ],
      ),
    );
  }
}
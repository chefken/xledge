import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:xledge/models/expense_model.dart';
import 'package:xledge/providers/void_provider.dart';
import 'package:xledge/utils/void_colors.dart';
import 'package:xledge/utils/void_text_styles.dart';
import 'package:xledge/widgets/transaction_tile.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  DateTime _focused  = DateTime.now();
  DateTime _selected = DateTime.now();

  late final AnimationController _headerCtrl;
  late final Animation<double>   _headerFade;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _headerFade = CurvedAnimation(
        parent: _headerCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VoidProvider>(
      builder: (context, provider, _) {
        final allExpenses = provider.getAllExpensesForMonth(
            _focused.year, _focused.month);

        final dayExpenses = allExpenses.where((e) =>
            e.date.year  == _selected.year &&
            e.date.month == _selected.month &&
            e.date.day   == _selected.day).toList();

        final daySpend = dayExpenses
            .where((e) => !e.isAllowance)
            .fold(0.0, (s, e) => s + e.amount);

        final dayIncome = dayExpenses
            .where((e) => e.isAllowance)
            .fold(0.0, (s, e) => s + e.amount);

        final events = <DateTime, List<Expense>>{};
        for (final e in allExpenses) {
          final key = DateTime(e.date.year, e.date.month, e.date.day);
          events.putIfAbsent(key, () => []).add(e);
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _headerFade,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 64, 24, 8),
                  child: Text('Calendar',
                      style: VoidTextStyles.headlineLarge),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _CalendarCard(
                  focused:   _focused,
                  selected:  _selected,
                  events:    events,
                  onDaySelected: (sel, foc) {
                    setState(() {
                      _selected = sel;
                      _focused  = foc;
                    });
                  },
                  onPageChanged: (foc) {
                    setState(() => _focused = foc);
                    provider.setMonth(foc.year, foc.month);
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 0.04),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: _DaySummary(
                  key:    ValueKey(_selected),
                  date:   _selected,
                  spend:  daySpend,
                  income: dayIncome,
                ),
              ),
            ),
            if (dayExpenses.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
                  child: Text(
                    _dayLabel(_selected),
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: VoidColors.textHint,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => TransactionTile(
                      expense: dayExpenses[i],
                      onDismiss: () =>
                          provider.deleteExpense(dayExpenses[i].id),
                    ),
                    childCount: dayExpenses.length,
                  ),
                ),
              ),
            ] else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 32, horizontal: 24),
                  child: Center(
                    child: Text(
                      'No activity on this day',
                      style: VoidTextStyles.bodyMedium,
                    ),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 140)),
          ],
        );
      },
    );
  }

  String _dayLabel(DateTime d) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date  = DateTime(d.year, d.month, d.day);
    final diff  = today.difference(date).inDays;
    if (diff == 0) return 'TODAY';
    if (diff == 1) return 'YESTERDAY';
    const m = ['','JAN','FEB','MAR','APR','MAY','JUN',
                'JUL','AUG','SEP','OCT','NOV','DEC'];
    return '${d.day} ${m[d.month]} ${d.year}';
  }
}

class _CalendarCard extends StatelessWidget {
  final DateTime focused;
  final DateTime selected;
  final Map<DateTime, List<Expense>> events;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;

  const _CalendarCard({
    required this.focused,
    required this.selected,
    required this.events,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: VoidColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: VoidColors.shadowMd,
            blurRadius: 24,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TableCalendar<Expense>(
        firstDay:     DateTime(2020),
        lastDay:      DateTime(2030),
        focusedDay:   focused,
        selectedDayPredicate: (d) => isSameDay(d, selected),
        eventLoader: (day) {
          final key = DateTime(day.year, day.month, day.day);
          return events[key] ?? [];
        },
        onDaySelected:  onDaySelected,
        onPageChanged:  onPageChanged,
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {
          CalendarFormat.month: 'Month',
        },
        startingDayOfWeek: StartingDayOfWeek.sunday,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: VoidColors.outlineVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.chevron_left_rounded,
                color: VoidColors.textSecondary, size: 18),
          ),
          rightChevronIcon: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: VoidColors.outlineVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.chevron_right_rounded,
                color: VoidColors.textSecondary, size: 18),
          ),
          titleTextStyle: GoogleFonts.bricolageGrotesque(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: VoidColors.textPrimary,
            letterSpacing: -0.2,
          ),
          headerPadding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: GoogleFonts.bricolageGrotesque(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: VoidColors.textHint,
          ),
          weekendStyle: GoogleFonts.bricolageGrotesque(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: VoidColors.textHint,
          ),
        ),
        calendarStyle: const CalendarStyle(
          outsideDaysVisible: false,
          cellMargin: EdgeInsets.all(4),
          markersMaxCount: 0,
        ),
        calendarBuilders: CalendarBuilders<Expense>(
          defaultBuilder: (context, day, focusedDay) => _DayCell(
            day:      day,
            selected: false,
            today:    false,
            hasEvent: events.containsKey(
                DateTime(day.year, day.month, day.day)),
          ),
          todayBuilder: (context, day, focusedDay) => _DayCell(
            day:      day,
            selected: false,
            today:    true,
            hasEvent: events.containsKey(
                DateTime(day.year, day.month, day.day)),
          ),
          selectedBuilder: (context, day, focusedDay) => _DayCell(
            day:      day,
            selected: true,
            today:    false,
            hasEvent: events.containsKey(
                DateTime(day.year, day.month, day.day)),
          ),
          outsideBuilder: (context, day, focusedDay) =>
              const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime day;
  final bool selected;
  final bool today;
  final bool hasEvent;

  const _DayCell({
    required this.day,
    required this.selected,
    required this.today,
    required this.hasEvent,
  });

  @override
  Widget build(BuildContext context) {
    final highlight = selected || today;

    return Center(
      child: SizedBox(
        width: 36,
        height: 36,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: highlight
                    ? VoidColors.primaryLight
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${day.day}',
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 13,
                    fontWeight: highlight
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: highlight
                        ? VoidColors.primary
                        : VoidColors.textPrimary,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  width: 4,
                  height: 4,
                  child: hasEvent
                      ? DecoratedBox(
                          decoration: BoxDecoration(
                            color: VoidColors.primary.withOpacity(
                                highlight ? 0.8 : 0.4),
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DaySummary extends StatelessWidget {
  final DateTime date;
  final double spend;
  final double income;

  const _DaySummary({
    super.key,
    required this.date,
    required this.spend,
    required this.income,
  });

  @override
  Widget build(BuildContext context) {
    const m = ['','Jan','Feb','Mar','Apr','May','Jun',
                'Jul','Aug','Sep','Oct','Nov','Dec'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${date.day} ${m[date.month]}',
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: VoidColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${date.year}',
                    style: VoidTextStyles.labelSmall,
                  ),
                ],
              ),
            ),
            _StatChip(
              label: 'Spent',
              value: '₹${spend.toInt()}',
              color: VoidColors.textPrimary,
              bg:    VoidColors.outlineVariant,
              isGradient: false,
            ),
            const SizedBox(width: 10),
            _StatChip(
              label: 'Income',
              value: '₹${income.toInt()}',
              color: income > 0
                  ? Colors.white
                  : VoidColors.textHint,
              bg: VoidColors.outlineVariant,
              isGradient: income > 0,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color bg;
  final bool isGradient;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
    this.isGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isGradient ? null : bg,
        gradient: isGradient
            ? const LinearGradient(
                colors: [Color(0xFFA78BFA), Color(0xFF5B3FD4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 10,
              color: isGradient
                  ? Colors.white70
                  : VoidColors.textHint,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}
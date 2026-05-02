import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xledge/providers/void_provider.dart';
import 'package:xledge/screens/add_expense_sheet.dart';
import 'package:xledge/utils/void_colors.dart';
import 'package:xledge/utils/void_text_styles.dart';
import 'package:xledge/widgets/transaction_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _pageCtrl = PageController(viewportFraction: 0.92);
  int _heroPage   = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
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
                onCalendarTap: () => _showCalendar(context, provider),
              ),
            ),
            SliverToBoxAdapter(
              child: _HeroCarousel(
                ctrl:        _pageCtrl,
                page:        _heroPage,
                onPage:      (i) => setState(() => _heroPage = i),
                totalSpend:  analysis?.totalSpend ?? 0,
                totalAllow:  provider.totalAllowance,
                totalDebt:   provider.totalIOwe,
                onArrowTap:  () {},
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recent',
                        style: VoidTextStyles.titleLarge),
                    GestureDetector(
                      onTap: () {},
                      child: const Text('See all',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: VoidColors.primary,
                          )),
                    ),
                  ],
                ),
              ),
            ),
            recent.isEmpty
                ? SliverToBoxAdapter(child: _EmptyRecent())
                : SliverPadding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24),
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
            const SliverToBoxAdapter(child: SizedBox(height: 130)),
          ],
        );
      },
    );
  }

  void _showCalendar(BuildContext context, VoidProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CalendarSheet(provider: provider),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onCalendarTap;
  const _Header({required this.onCalendarTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hello,',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: VoidColors.textSecondary,
                    letterSpacing: -0.1,
                  )),
              const SizedBox(height: 1),
              const Text('Chef',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: VoidColors.textPrimary,
                    letterSpacing: -0.8,
                    height: 1.1,
                  )),
            ],
          ),
          _CalendarBtn(onTap: onCalendarTap),
        ],
      ),
    );
  }
}

class _CalendarBtn extends StatefulWidget {
  final VoidCallback onTap;
  const _CalendarBtn({required this.onTap});

  @override
  State<_CalendarBtn> createState() => _CalendarBtnState();
}

class _CalendarBtnState extends State<_CalendarBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120), value: 1);
    _scale = Tween(begin: 0.88, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp:   (_) { _ctrl.forward(); widget.onTap(); },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: VoidColors.surface,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: VoidColors.shadowMd,
                blurRadius: 16,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.calendar_month_rounded,
            color: VoidColors.textSecondary,
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
  final VoidCallback onArrowTap;

  const _HeroCarousel({
    required this.ctrl,
    required this.page,
    required this.onPage,
    required this.totalSpend,
    required this.totalAllow,
    required this.totalDebt,
    required this.onArrowTap,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _CardData(
        tag: 'THIS MONTH',
        label: 'Total Spent',
        amount: totalSpend,
        colors: [const Color(0xFFA78BFA), const Color(0xFF7C5CFC)],
      ),
      _CardData(
        tag: 'THIS MONTH',
        label: 'Received',
        amount: totalAllow,
        colors: [const Color(0xFF6EE7B7), const Color(0xFF059669)],
      ),
      _CardData(
        tag: 'OUTSTANDING',
        label: 'You Owe',
        amount: totalDebt,
        colors: [const Color(0xFFFCA5A5), const Color(0xFFDC2626)],
      ),
    ];

    return Column(
      children: [
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: ctrl,
            onPageChanged: onPage,
            physics: const BouncingScrollPhysics(),
            itemCount: cards.length,
            itemBuilder: (_, i) {
              return AnimatedBuilder(
                animation: ctrl,
                builder: (_, child) {
                  double p = 0;
                  try { p = ctrl.page ?? i.toDouble(); } catch (_) {}
                  final d     = (p - i).abs().clamp(0.0, 1.0);
                  final scale = 1.0 - d * 0.04;
                  final opacity = 1.0 - d * 0.3;
                  return Transform.scale(
                    scale: scale,
                    child: Opacity(opacity: opacity, child: child),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _HeroCard(
                    data: cards[i],
                    onArrow: onArrowTap,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            cards.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width:  page == i ? 22 : 6,
              height: 6,
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
  final VoidCallback onArrow;

  const _HeroCard({required this.data, required this.onArrow});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: data.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: data.colors.last.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.tag,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
                letterSpacing: 1.4,
              )),
          const Spacer(),
          Text(
            '₹${data.amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -1.2,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(data.label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  )),
              GestureDetector(
                onTap: onArrow,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyRecent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: VoidColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.receipt_long_rounded,
                color: VoidColors.primary, size: 28),
          ),
          const SizedBox(height: 14),
          const Text('No transactions yet',
              style: VoidTextStyles.titleMedium),
          const SizedBox(height: 6),
          const Text('Your activity will appear here',
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
  DateTime  _focus    = DateTime.now();
  DateTime? _selected;

  static const _months = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  static const _short = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  static const _days = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  @override
  Widget build(BuildContext context) {
    final dim  = DateUtils.getDaysInMonth(_focus.year, _focus.month);
    final first = DateTime(_focus.year, _focus.month, 1).weekday % 7;

    return Container(
      height: MediaQuery.of(context).size.height * 0.70,
      decoration: const BoxDecoration(
        color: VoidColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_months[_focus.month]} ${_focus.year}',
                    style: VoidTextStyles.titleLarge),
                Row(
                  children: [
                    _ChevronBtn(
                      icon: Icons.chevron_left_rounded,
                      onTap: () => setState(() => _focus =
                          DateTime(_focus.year, _focus.month - 1)),
                    ),
                    const SizedBox(width: 8),
                    _ChevronBtn(
                      icon: Icons.chevron_right_rounded,
                      onTap: () => setState(() => _focus =
                          DateTime(_focus.year, _focus.month + 1)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _days
                  .map((d) => SizedBox(
                        width: 36,
                        child: Text(d,
                            style: VoidTextStyles.labelSmall,
                            textAlign: TextAlign.center),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                ),
                itemCount: first + dim,
                itemBuilder: (_, i) {
                  if (i < first) return const SizedBox.shrink();
                  final day  = i - first + 1;
                  final date = DateTime(_focus.year, _focus.month, day);
                  final isSel =
                      _selected != null && DateUtils.isSameDay(_selected!, date);
                  final isToday = DateUtils.isSameDay(date, DateTime.now());

                  final expenses = widget.provider
                      .getAllExpensesForMonth(_focus.year, _focus.month)
                      .where((e) => e.date.day == day)
                      .toList();

                  final hasSpend = expenses.any((e) => !e.isAllowance);
                  final hasAllow = expenses.any((e) => e.isAllowance);

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selected = date);
                      _showDayDetail(context, date, expenses);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isSel
                            ? VoidColors.primary
                            : isToday
                                ? VoidColors.primaryLight
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text('$day',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isToday || isSel
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: isSel
                                    ? Colors.white
                                    : isToday
                                        ? VoidColors.primary
                                        : VoidColors.textPrimary,
                              )),
                          if ((hasSpend || hasAllow) && !isSel)
                            Positioned(
                              bottom: 4,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (hasSpend)
                                    Container(
                                      width: 4, height: 4,
                                      decoration: const BoxDecoration(
                                        color: VoidColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  if (hasSpend && hasAllow)
                                    const SizedBox(width: 2),
                                  if (hasAllow)
                                    Container(
                                      width: 4, height: 4,
                                      decoration: BoxDecoration(
                                        color: VoidColors.primary
                                            .withOpacity(0.4),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDayDetail(BuildContext context, DateTime date, List expenses) {
    final spent = expenses
        .where((e) => !e.isAllowance)
        .fold(0.0, (s, e) => s + e.amount);
    final received = expenses
        .where((e) => e.isAllowance)
        .fold(0.0, (s, e) => s + e.amount);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: VoidColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${date.day} ${_short[date.month]}',
              style: VoidTextStyles.headlineMedium,
            ),
            const SizedBox(height: 20),
            _DayRow('Spent',    spent > 0    ? '-₹${spent.toStringAsFixed(0)}' : '₹0',    VoidColors.danger),
            _DayRow('Received', received > 0 ? '+₹${received.toStringAsFixed(0)}' : '₹0', VoidColors.success),
            _DayRow('Debt',     '₹0',  VoidColors.textSecondary),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _DayRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: VoidTextStyles.bodyMedium),
          Text(value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              )),
        ],
      ),
    );
  }
}

class _ChevronBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ChevronBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: VoidColors.outlineVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: VoidColors.textSecondary, size: 20),
      ),
    );
  }
}
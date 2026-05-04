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
              child: _PremiumHeader(
                onCalendar: () => _showCal(context, provider),
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
                padding: const EdgeInsets.fromLTRB(24, 36, 24, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recent',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: VoidColors.textPrimary,
                          letterSpacing: -0.2,
                        )),
                    GestureDetector(
                      onTap: () {},
                      child: const Text('See all',
                          style: TextStyle(
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

  void _showCal(BuildContext context, VoidProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PremiumCalendar(provider: provider),
    );
  }
}

class _PremiumHeader extends StatelessWidget {
  final VoidCallback onCalendar;
  const _PremiumHeader({required this.onCalendar});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 68, 24, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hello,',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: VoidColors.textSecondary,
                  letterSpacing: 0.2,
                  height: 1.3,
                ),
              ),
              const Text(
                'Chef',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: VoidColors.textPrimary,
                  letterSpacing: -1.0,
                  height: 1.1,
                ),
              ),
            ],
          ),
          _CalendarButton(onTap: onCalendar),
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
        duration: const Duration(milliseconds: 130),
        value: 1);
    _scale = Tween(begin: 0.88, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => _ctrl.reverse(),
      onTapUp:     (_) { _ctrl.forward(); widget.onTap(); },
      onTapCancel: ()  => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: VoidColors.surface,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: VoidColors.shadowMd,
                blurRadius: 18,
                offset: Offset(0, 4),
              ),
              BoxShadow(
                color: VoidColors.shadow,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: const Icon(
            Icons.calendar_month_outlined,
            color: VoidColors.textSecondary,
            size: 18,
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
        gradients: [const Color(0xFFA78BFA), const Color(0xFF6C3CE1)],
      ),
      _CardData(
        tag: 'THIS MONTH',
        label: 'Allowance',
        amount: totalAllow,
        gradients: [const Color(0xFFB49BFB), const Color(0xFF7C5CFC)],
      ),
      _CardData(
        tag: 'OUTSTANDING',
        label: 'You Owe',
        amount: totalDebt,
        gradients: [const Color(0xFF9B8AFB), const Color(0xFF4C35C8)],
      ),
    ];

    return Column(
      children: [
        SizedBox(
          height: 168,
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
                final scale   = 1.0 - d * 0.035;
                final opacity = 1.0 - d * 0.25;
                return Transform.scale(
                  scale: scale,
                  child: Opacity(opacity: opacity, child: child),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
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
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width:  page == i ? 20 : 5,
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
  final List<Color> gradients;
  const _CardData({
    required this.tag,
    required this.label,
    required this.amount,
    required this.gradients,
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
          colors: data.gradients,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: data.gradients.last.withOpacity(0.28),
            blurRadius: 22,
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
                fontWeight: FontWeight.w500,
                color: Colors.white54,
                letterSpacing: 1.5,
              )),
          const Spacer(),
          Text(
            '₹${data.amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -1.4,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(data.label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white60,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.1,
                  )),
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 14),
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
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: VoidColors.primaryLight,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.receipt_long_outlined,
                color: VoidColors.primary, size: 26),
          ),
          const SizedBox(height: 14),
          const Text('Nothing yet',
              style: VoidTextStyles.titleMedium),
          const SizedBox(height: 5),
          const Text('Your activity will show here',
              style: VoidTextStyles.bodyMedium,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _PremiumCalendar extends StatefulWidget {
  final VoidProvider provider;
  const _PremiumCalendar({required this.provider});

  @override
  State<_PremiumCalendar> createState() => _PremiumCalendarState();
}

class _PremiumCalendarState extends State<_PremiumCalendar>
    with TickerProviderStateMixin {
  DateTime  _focus    = DateTime.now();
  DateTime? _selected;

  late AnimationController _slideCtrl;
  late Animation<Offset>   _slideAnim;
  late Animation<double>   _fadeAnim;
  int _slideDir = 1;

  static const _monthNames = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  static const _shortMonths = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  static const _dayHeaders = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..forward();
    _buildAnims(1);
  }

  void _buildAnims(int dir) {
    _slideAnim = Tween<Offset>(
      begin: Offset(dir * 0.06, 0),
      end:   Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideCtrl,
      curve:  Curves.easeOutCubic,
    ));
    _fadeAnim = CurvedAnimation(
        parent: _slideCtrl, curve: Curves.easeOut);
  }

  void _changeMonth(int dir) {
    _slideDir = dir;
    _slideCtrl.reset();
    _buildAnims(dir);
    setState(() {
      _focus = DateTime(_focus.year, _focus.month + dir);
    });
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dim   = DateUtils.getDaysInMonth(_focus.year, _focus.month);
    final first = DateTime(_focus.year, _focus.month, 1).weekday % 7;

    return Container(
      height: MediaQuery.of(context).size.height * 0.68,
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
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim, child: child),
                  child: Text(
                    '${_monthNames[_focus.month]} ${_focus.year}',
                    key: ValueKey('${_focus.month}-${_focus.year}'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: VoidColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                Row(
                  children: [
                    _MonthBtn(
                      icon: Icons.chevron_left_rounded,
                      onTap: () => _changeMonth(-1),
                    ),
                    const SizedBox(width: 8),
                    _MonthBtn(
                      icon: Icons.chevron_right_rounded,
                      onTap: () => _changeMonth(1),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _dayHeaders
                  .map((d) => SizedBox(
                        width: 34,
                        child: Text(d,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: VoidColors.textHint,
                            ),
                            textAlign: TextAlign.center),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
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
                      final isSel = _selected != null &&
                          DateUtils.isSameDay(_selected!, date);
                      final isToday =
                          DateUtils.isSameDay(date, DateTime.now());

                      final exps = widget.provider
                          .getAllExpensesForMonth(_focus.year, _focus.month)
                          .where((e) => e.date.day == day)
                          .toList();

                      final hasActivity = exps.isNotEmpty;
                      final spendAmt = exps
                          .where((e) => !e.isAllowance)
                          .fold(0.0, (s, e) => s + e.amount);
                      final maxDay = 2000.0;
                      final intensity = spendAmt > 0
                          ? (spendAmt / maxDay).clamp(0.12, 0.7)
                          : 0.0;

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selected = date);
                          _showDayDetail(context, date, exps);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isSel
                                ? VoidColors.primary
                                : isToday
                                    ? VoidColors.primaryLight
                                    : hasActivity
                                        ? VoidColors.primary
                                            .withOpacity(intensity)
                                        : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSel || isToday
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isSel
                                  ? Colors.white
                                  : isToday
                                      ? VoidColors.primary
                                      : intensity > 0.45
                                          ? Colors.white
                                          : VoidColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDayDetail(BuildContext context, DateTime date, List exps) {
    final spent = exps
        .where((e) => !e.isAllowance)
        .fold(0.0, (s, e) => s + e.amount);
    final recv = exps
        .where((e) => e.isAllowance)
        .fold(0.0, (s, e) => s + e.amount);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 36),
        decoration: const BoxDecoration(
          color: VoidColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: VoidColors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              '${date.day} ${_shortMonths[date.month]}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: VoidColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _DayStatCard(
                    label: 'Spent',
                    value: spent > 0
                        ? '-₹${spent.toStringAsFixed(0)}'
                        : '₹0',
                    color: spent > 0
                        ? VoidColors.textPrimary
                        : VoidColors.textHint,
                    bg: VoidColors.outlineVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DayStatCard(
                    label: 'Received',
                    value: recv > 0
                        ? '+₹${recv.toStringAsFixed(0)}'
                        : '₹0',
                    color: recv > 0
                        ? VoidColors.primary
                        : VoidColors.textHint,
                    bg: recv > 0
                        ? VoidColors.primaryLight
                        : VoidColors.outlineVariant,
                  ),
                ),
              ],
            ),
            if (exps.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('Transactions',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: VoidColors.textHint,
                    letterSpacing: 0.3,
                  )),
              const SizedBox(height: 8),
              ...exps.take(3).map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: VoidColors.outlineVariant,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.receipt_outlined,
                              size: 14,
                              color: VoidColors.iconColor),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(e.title,
                              style: VoidTextStyles.bodyMedium
                                  .copyWith(
                                      color: VoidColors.textPrimary)),
                        ),
                        Text(
                          '${e.isAllowance ? '+' : '-'}₹${e.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: e.isAllowance
                                ? VoidColors.primary
                                : VoidColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DayStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color bg;

  const _DayStatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                color: VoidColors.textHint,
                fontWeight: FontWeight.w400,
              )),
          const SizedBox(height: 6),
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

class _MonthBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MonthBtn({required this.icon, required this.onTap});

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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xledge/screens/activity_screen.dart';
import 'package:xledge/screens/add_debt_sheet.dart';
import 'package:xledge/screens/add_expense_sheet.dart';
import 'package:xledge/screens/dashboard_screen.dart';
import 'package:xledge/screens/debts_screen.dart';
import 'package:xledge/screens/expenses_screen.dart';
import 'package:xledge/utils/void_colors.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen>
    with TickerProviderStateMixin {
  int _tab = 0;

  late final AnimationController _fabCtrl;
  late final Animation<double>   _fabAnim;

  @override
  void initState() {
    super.initState();
    _fabCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
      value: 1,
    );
    _fabAnim = CurvedAnimation(
      parent: _fabCtrl,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _fabCtrl.dispose();
    super.dispose();
  }

  void _setTab(int i) {
    if (i == _tab) return;
    HapticFeedback.selectionClick();
    final wasHome = _tab == 0;
    final isHome  = i == 0;
    setState(() => _tab = i);
    if (isHome && !wasHome) {
      _fabCtrl.forward();
    } else if (!isHome && wasHome) {
      _fabCtrl.reverse();
    }
  }

  void _onFabTap() {
    _openSheet(_tab == 3
        ? const AddDebtSheet()
        : const AddExpenseSheet());
  }

  void _openSheet(Widget w) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => w,
    );
  }

  Widget _screen() {
    switch (_tab) {
      case 0:  return const DashboardScreen();
      case 1:  return const ExpensesScreen();
      case 3:  return const DebtsScreen();
      case 4:  return const ActivityScreen();
      default: return const DashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VoidColors.background,
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        switchInCurve:  Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.015),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: anim,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        ),
        child: KeyedSubtree(key: ValueKey(_tab), child: _screen()),
      ),
      bottomNavigationBar: _PremiumNav(
        current: _tab,
        fabAnim: _fabAnim,
        onTap:   _setTab,
        onFab:   _onFabTap,
      ),
    );
  }
}

class _PremiumNav extends StatelessWidget {
  final int current;
  final Animation<double> fabAnim;
  final ValueChanged<int> onTap;
  final VoidCallback onFab;

  const _PremiumNav({
    required this.current,
    required this.fabAnim,
    required this.onTap,
    required this.onFab,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
        child: SizedBox(
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: VoidColors.surface,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: const [
                    BoxShadow(
                      color: VoidColors.shadowLg,
                      blurRadius: 40,
                      offset: Offset(0, 10),
                    ),
                    BoxShadow(
                      color: VoidColors.shadow,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _NavItem(icon: Icons.home_rounded,
                        active: current == 0, onTap: () => onTap(0)),
                    _NavItem(icon: Icons.receipt_long_rounded,
                        active: current == 1, onTap: () => onTap(1)),
                    const Spacer(),
                    _NavItem(icon: Icons.handshake_rounded,
                        active: current == 3, onTap: () => onTap(3)),
                    _NavItem(icon: Icons.bar_chart_rounded,
                        active: current == 4, onTap: () => onTap(4)),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: fabAnim,
                builder: (_, child) => Transform.translate(
                  offset: Offset(0, (1 - fabAnim.value) * 12),
                  child: Transform.scale(
                    scale: 0.7 + fabAnim.value * 0.3,
                    child: Opacity(opacity: fabAnim.value, child: child),
                  ),
                ),
                child: _FabButton(onTap: onFab),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 64,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: active
                    ? VoidColors.primaryLight
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(13),
              ),
              child: AnimatedScale(
                scale: active ? 1.0 : 0.9,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                child: Icon(
                  icon,
                  size: 21,
                  color: active
                      ? VoidColors.primary
                      : VoidColors.textHint,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FabButton extends StatefulWidget {
  final VoidCallback onTap;
  const _FabButton({required this.onTap});

  @override
  State<_FabButton> createState() => _FabButtonState();
}

class _FabButtonState extends State<_FabButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      value: 1,
    );
    _scale = Tween(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) { _press.reverse(); HapticFeedback.lightImpact(); },
      onTapUp:     (_) { _press.forward(); widget.onTap(); },
      onTapCancel: ()  => _press.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [VoidColors.gradientStart, VoidColors.gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: VoidColors.primary.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.add_rounded,
            color: VoidColors.onPrimary,
            size: 26,
          ),
        ),
      ),
    );
  }
}
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
      duration: const Duration(milliseconds: 350),
      value: 1,
    );
    _fabAnim = CurvedAnimation(
        parent: _fabCtrl, curve: Curves.easeOutCubic);
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
    if (_tab == 1) {
      _showSheet(const AddExpenseSheet());
    } else if (_tab == 3) {
      _showSheet(const AddDebtSheet());
    } else if (_tab == 0) {
      _showSheet(const AddExpenseSheet());
    }
  }

  void _showSheet(Widget sheet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => sheet,
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
        duration: const Duration(milliseconds: 300),
        switchInCurve:  Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.02),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey(_tab),
          child: _screen(),
        ),
      ),
      bottomNavigationBar: _FloatingNav(
        current: _tab,
        fabAnim: _fabAnim,
        onTap:   _setTab,
        onFab:   _onFabTap,
      ),
    );
  }
}

class _FloatingNav extends StatelessWidget {
  final int current;
  final Animation<double> fabAnim;
  final ValueChanged<int> onTap;
  final VoidCallback onFab;

  const _FloatingNav({
    required this.current,
    required this.fabAnim,
    required this.onTap,
    required this.onFab,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
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
                      offset: Offset(0, 8),
                    ),
                    BoxShadow(
                      color: VoidColors.shadow,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      active: current == 0,
                      onTap: () => onTap(0),
                    ),
                    _NavItem(
                      icon: Icons.receipt_long_rounded,
                      active: current == 1,
                      onTap: () => onTap(1),
                    ),
                    AnimatedBuilder(
                      animation: fabAnim,
                      builder: (_, __) => SizedBox(
                        width: 56 * fabAnim.value,
                      ),
                    ),
                    _NavItem(
                      icon: Icons.handshake_rounded,
                      active: current == 3,
                      onTap: () => onTap(3),
                    ),
                    _NavItem(
                      icon: Icons.bar_chart_rounded,
                      active: current == 4,
                      onTap: () => onTap(4),
                    ),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: fabAnim,
                builder: (_, child) => Transform.scale(
                  scale: fabAnim.value,
                  child: Opacity(opacity: fabAnim.value, child: child),
                ),
                child: Positioned(
                  top: -16,
                  child: _FabButton(onTap: onFab),
                ),
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        height: 64,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: active ? 40 : 36,
            height: active ? 40 : 36,
            decoration: BoxDecoration(
              color: active
                  ? VoidColors.primaryLight
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: active ? 22 : 20,
              color: active
                  ? VoidColors.primary
                  : VoidColors.textHint,
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
        duration: const Duration(milliseconds: 120),
        value: 1);
    _scale = Tween(begin: 0.9, end: 1.0)
        .animate(CurvedAnimation(parent: _press, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _press.reverse();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        _press.forward();
        widget.onTap();
      },
      onTapCancel: () => _press.forward(),
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
                color: VoidColors.primary.withOpacity(0.38),
                blurRadius: 20,
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
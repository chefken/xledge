import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xledge/screens/activity_screen.dart';
import 'package:xledge/screens/add_debt_sheet.dart';
import 'package:xledge/screens/add_expense_sheet.dart';
import 'package:xledge/screens/dashboard_screen.dart';
import 'package:xledge/screens/debts_screen.dart';
import 'package:xledge/screens/expenses_screen.dart';
import 'package:xledge/utils/theme_ext.dart';
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
      duration: const Duration(milliseconds: 480),
      value: 1.0,
    );
    _fabAnim = CurvedAnimation(
      parent: _fabCtrl,
      curve:        Curves.easeInOutCubic,
      reverseCurve: Curves.easeInOutCubic,
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _tab == 3
          ? const AddDebtSheet()
          : const AddExpenseSheet(),
    );
  }

  Widget _screen() {
    switch (_tab) {
      case 0:  return DashboardScreen(onSeeAll: () => _setTab(1));
      case 1:  return const ExpensesScreen();
      case 3:  return const DebtsScreen();
      case 4:  return const ActivityScreen();
      default: return DashboardScreen(onSeeAll: () => _setTab(1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.xBg,
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve:  Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.012),
              end:   Offset.zero,
            ).animate(CurvedAnimation(
              parent: anim, curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        ),
        child: KeyedSubtree(
            key: ValueKey(_tab), child: _screen()),
      ),
      bottomNavigationBar: _PremiumNav(
        current:  _tab,
        fabAnim:  _fabAnim,
        onTap:    _setTab,
        onFab:    _onFabTap,
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
    final navBg = context.xSurface;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: SizedBox(
          height: 72,
          child: AnimatedBuilder(
            animation: fabAnim,
            builder: (_, __) {
              final t = fabAnim.value;
              return Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: navBg,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: context.isDark
                              ? Colors.black.withOpacity(0.4)
                              : VoidColors.shadowPurple
                                  .withOpacity(0.12),
                          blurRadius: 40,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: context.isDark
                              ? Colors.black.withOpacity(0.2)
                              : VoidColors.shadowLg,
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _NavIcon(
                          icon:   Icons.home_rounded,
                          active: current == 0,
                          onTap:  () => onTap(0),
                        ),
                        _NavIcon(
                          icon:   Icons.receipt_long_rounded,
                          active: current == 1,
                          onTap:  () => onTap(1),
                        ),
                        SizedBox(width: 72 * t),
                        _NavIcon(
                          icon:   Icons.handshake_rounded,
                          active: current == 3,
                          onTap:  () => onTap(3),
                        ),
                        _NavIcon(
                          icon:   Icons.bar_chart_rounded,
                          active: current == 4,
                          onTap:  () => onTap(4),
                        ),
                      ],
                    ),
                  ),
                  if (t > 0.01)
                    Positioned(
                      top: -10,
                      child: Transform.scale(
                        scale: 0.4 + (t * 0.6),
                        child: Opacity(
                          opacity: t.clamp(0.0, 1.0),
                          child: _PurpleFab(onTap: onFab),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _NavIcon({
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
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: active
                    ? VoidColors.primaryLight
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: AnimatedScale(
                scale: active ? 1.0 : 0.88,
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                child: Icon(
                  icon, size: 22,
                  color: active
                      ? VoidColors.primary
                      : context.xTxHint,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PurpleFab extends StatefulWidget {
  final VoidCallback onTap;
  const _PurpleFab({required this.onTap});

  @override
  State<_PurpleFab> createState() => _PurpleFabState();
}

class _PurpleFabState extends State<_PurpleFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      value: 1,
    );
    _scale = Tween(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() { _press.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) { _press.reverse(); HapticFeedback.lightImpact(); },
      onTapUp:     (_) { _press.forward(); widget.onTap(); },
      onTapCancel: ()  => _press.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 58, height: 58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFA78BFA), Color(0xFF5B3FD4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: VoidColors.primary.withOpacity(0.45),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
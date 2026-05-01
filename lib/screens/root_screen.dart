import 'package:flutter/material.dart';
import 'package:xledge/screens/activity_screen.dart';
import 'package:xledge/screens/add_debt_sheet.dart';
import 'package:xledge/screens/add_expense_sheet.dart';
import 'package:xledge/screens/dashboard_screen.dart';
import 'package:xledge/screens/debts_screen.dart';
import 'package:xledge/screens/expenses_screen.dart';
import 'package:xledge/utils/void_colors.dart';
import 'package:xledge/utils/void_text_styles.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _tab = 0;

  static const _labels = ['Home', 'Expenses', 'Debts', 'Activity'];
  static const _icons  = [
    Icons.home_rounded,
    Icons.receipt_long_rounded,
    Icons.handshake_rounded,
    Icons.bar_chart_rounded,
  ];

  Widget _screen() {
    switch (_tab) {
      case 0: return const DashboardScreen();
      case 1: return const ExpensesScreen();
      case 2: return const DebtsScreen();
      case 3: return const ActivityScreen();
      default: return const DashboardScreen();
    }
  }

  void _showFab() {
    if (_tab == 3) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        if (_tab == 2) return const AddDebtSheet();
        return const AddExpenseSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _screen()),
      floatingActionButton: _tab != 3
          ? FloatingActionButton(
              onPressed: _showFab,
              backgroundColor: VoidColors.primary,
              child: const Icon(Icons.add_rounded, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomNav(
        current: _tab,
        labels:  _labels,
        icons:   _icons,
        onTap:   (i) => setState(() => _tab = i),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int current;
  final List<String> labels;
  final List<IconData> icons;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.current,
    required this.labels,
    required this.icons,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: VoidColors.background,
        border:
            Border(top: BorderSide(color: VoidColors.outline, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                  icon: icons[0], label: labels[0],
                  index: 0, current: current, onTap: onTap),
              _NavItem(
                  icon: icons[1], label: labels[1],
                  index: 1, current: current, onTap: onTap),
              const SizedBox(width: 56),
              _NavItem(
                  icon: icons[2], label: labels[2],
                  index: 2, current: current, onTap: onTap),
              _NavItem(
                  icon: icons[3], label: labels[3],
                  index: 3, current: current, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = current == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? VoidColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: active
                    ? VoidColors.primary
                    : VoidColors.textSecondary,
                size: 22),
            if (active) ...[
              const SizedBox(width: 6),
              Text(label,
                  style: VoidTextStyles.labelLarge
                      .copyWith(color: VoidColors.primary)),
            ],
          ],
        ),
      ),
    );
  }
}
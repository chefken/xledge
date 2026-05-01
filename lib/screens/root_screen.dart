import 'package:flutter/material.dart';
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

  static const _screens = [
    DashboardScreen(),
    ExpensesScreen(),
    DebtsScreen(),
  ];

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _tab == 2
          ? const AddDebtSheet()
          : const AddExpenseSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _screens[_tab]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        icon: const Icon(Icons.add_rounded),
        label: Text(_tab == 2 ? 'Add Debt' : 'Add Expense'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _XLedgeNavBar(
        current: _tab,
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }
}

class _XLedgeNavBar extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;

  const _XLedgeNavBar({required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: VoidColors.background,
        border: Border(top: BorderSide(color: VoidColors.outline, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.dashboard_rounded,
                  label: 'Home', index: 0, current: current, onTap: onTap),
              _NavItem(icon: Icons.receipt_long_rounded,
                  label: 'Expenses', index: 1, current: current, onTap: onTap),
              const SizedBox(width: 64),
              _NavItem(icon: Icons.handshake_rounded,
                  label: 'Debts', index: 2, current: current, onTap: onTap),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? VoidColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
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
            ]
          ],
        ),
      ),
    );
  }
}
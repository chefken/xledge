import 'package:flutter/material.dart';
import 'package:xledge/utils/void_colors.dart';
import 'package:xledge/utils/void_spacing.dart';
import 'package:xledge/utils/void_text_styles.dart';

class BalanceHeroCard extends StatefulWidget {
  final double totalSpend;
  final double totalTheyOwe;
  final double totalIOwe;

  const BalanceHeroCard({
    super.key,
    required this.totalSpend,
    required this.totalTheyOwe,
    required this.totalIOwe,
  });

  @override
  State<BalanceHeroCard> createState() => _BalanceHeroCardState();
}

class _BalanceHeroCardState extends State<BalanceHeroCard>
    with SingleTickerProviderStateMixin {
  bool _visible = true;
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 260));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _visible = !_visible);
    _visible ? _ctrl.forward() : _ctrl.reverse();
  }

  String _fmt(double v) => _visible ? '₹${v.toStringAsFixed(2)}' : '₹ ••••••';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(VoidSpacing.cardInner),
      decoration: BoxDecoration(
        color: VoidColors.background,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: VoidColors.outline, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Monthly Spend',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: VoidColors.textSecondary,
                  )),
              GestureDetector(
                onTap: _toggle,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _visible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    key: ValueKey(_visible),
                    color: VoidColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FadeTransition(
            opacity: _fade,
            child: Text(_fmt(widget.totalSpend),
                style: VoidTextStyles.displayLarge),
          ),
          const SizedBox(height: VoidSpacing.lg),
          const Divider(color: VoidColors.outline, height: 1),
          const SizedBox(height: VoidSpacing.md),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'They Owe Me',
                  value: _fmt(widget.totalTheyOwe),
                  icon: Icons.arrow_downward_rounded,
                  iconColor: VoidColors.success,
                  bgColor: VoidColors.successLight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  label: 'I Owe',
                  value: _fmt(widget.totalIOwe),
                  icon: Icons.arrow_upward_rounded,
                  iconColor: VoidColors.danger,
                  bgColor: VoidColors.dangerLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: VoidColors.textSecondary,
                    )),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: VoidColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
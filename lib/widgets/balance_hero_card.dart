import 'package:flutter/material.dart';
import 'package:xledge/services/auth_service.dart';
import 'package:xledge/utils/void_colors.dart';
import 'package:xledge/utils/void_spacing.dart';
import 'package:xledge/utils/void_text_styles.dart';

class BalanceHeroCard extends StatefulWidget {
  final double totalSpend;
  final double totalAllowance;
  final double netBalance;

  const BalanceHeroCard({
    super.key,
    required this.totalSpend,
    required this.totalAllowance,
    required this.netBalance,
  });

  @override
  State<BalanceHeroCard> createState() => _BalanceHeroCardState();
}

class _BalanceHeroCardState extends State<BalanceHeroCard> {
  bool _visible = false;
  bool _loading = false;

  Future<void> _toggleVisibility() async {
    if (_visible) {
      setState(() => _visible = false);
      return;
    }
    setState(() => _loading = true);
    final auth = await AuthService.authenticate(
      reason: 'Verify identity to view your balance',
    );
    if (mounted) setState(() { _loading = false; _visible = auth; });
  }

  String _fmt(double v, {bool signed = false}) {
    if (!_visible) return '₹ ••••••';
    final prefix = signed && v >= 0 ? '+' : '';
    return '$prefix₹${v.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final netPositive = widget.netBalance >= 0;

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
              const Text(
                'Spent this month',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: VoidColors.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: _loading ? null : _toggleVisibility,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: VoidColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: _loading
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: VoidColors.primary,
                          ),
                        )
                      : Icon(
                          _visible
                              ? Icons.fingerprint
                              : Icons.fingerprint,
                          color: _visible
                              ? VoidColors.primary
                              : VoidColors.textSecondary,
                          size: 20,
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _fmt(widget.totalSpend),
            style: VoidTextStyles.displayLarge.copyWith(
              color: VoidColors.danger,
            ),
          ),
          const SizedBox(height: VoidSpacing.lg),
          const Divider(color: VoidColors.outline, height: 1),
          const SizedBox(height: VoidSpacing.md),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Allowance',
                  value: _fmt(widget.totalAllowance),
                  icon: Icons.arrow_downward_rounded,
                  iconColor: VoidColors.success,
                  bgColor: VoidColors.successLight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  label: 'Net Balance',
                  value: _fmt(widget.netBalance, signed: true),
                  icon: netPositive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  iconColor:
                      netPositive ? VoidColors.success : VoidColors.danger,
                  bgColor: netPositive
                      ? VoidColors.successLight
                      : VoidColors.dangerLight,
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
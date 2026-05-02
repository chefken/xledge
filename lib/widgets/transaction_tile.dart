import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xledge/models/expense_model.dart';
import 'package:xledge/utils/category_utils.dart';
import 'package:xledge/utils/void_colors.dart';
import 'package:xledge/utils/void_text_styles.dart';

class TransactionTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onDismiss;
  final VoidCallback? onEdit;

  const TransactionTile({
    super.key,
    required this.expense,
    this.onDismiss,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final meta    = categoryMeta(expense.category);
    final isAllow = expense.isAllowance;
    final color   = isAllow ? VoidColors.success : VoidColors.danger;
    final prefix  = isAllow ? '+' : '-';

    return Dismissible(
      key: Key(expense.id),
      background: _swipeBg(
        color: VoidColors.primary,
        icon: Icons.edit_rounded,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _swipeBg(
        color: VoidColors.danger,
        icon: Icons.delete_rounded,
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (dir) async {
        HapticFeedback.mediumImpact();
        if (dir == DismissDirection.endToStart) {
          return await _confirmDelete(context);
        }
        onEdit?.call();
        return false;
      },
      onDismissed: (dir) {
        if (dir == DismissDirection.endToStart) onDismiss?.call();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isAllow
                    ? VoidColors.primaryLight
                    : VoidColors.iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isAllow ? Icons.savings_rounded : meta.icon,
                color: isAllow ? VoidColors.primary : VoidColors.iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: VoidTextStyles.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _smartDate(expense.date),
                    style: VoidTextStyles.labelSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$prefix₹${expense.amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _swipeBg({
    required Color color,
    required IconData icon,
    required Alignment alignment,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete?', style: VoidTextStyles.titleLarge),
            content: const Text('This cannot be undone.',
                style: VoidTextStyles.bodyMedium),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel',
                    style: TextStyle(color: VoidColors.textSecondary)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete',
                    style: TextStyle(
                        color: VoidColors.danger,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ) ??
        false;
  }

  String _smartDate(DateTime d) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date  = DateTime(d.year, d.month, d.day);
    final diff  = today.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    const m = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${m[d.month]}';
  }
}
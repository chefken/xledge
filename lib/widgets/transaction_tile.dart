import 'package:flutter/material.dart';
import 'package:xledge/utils/void_colors.dart';
import 'package:xledge/utils/category_utils.dart';
import 'package:xledge/models/expense_model.dart';

class TransactionTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onDismiss;

  const TransactionTile({
    super.key,
    required this.expense,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final meta = categoryMeta(expense.category);
    final dateStr =
        '${expense.date.day.toString().padLeft(2, '0')} '
        '${_month(expense.date.month)}';

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: VoidColors.dangerLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: VoidColors.danger),
      ),
      onDismissed: (_) => onDismiss?.call(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                  color: meta.lightColor, shape: BoxShape.circle),
              child: Icon(meta.icon, color: meta.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expense.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: VoidColors.textPrimary,
                        letterSpacing: -0.1,
                      )),
                  const SizedBox(height: 3),
                  Text('${expense.category}  ·  $dateStr',
                      style: const TextStyle(
                        fontSize: 12,
                        color: VoidColors.textSecondary,
                      )),
                ],
              ),
            ),
            Text(
              '-₹${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: VoidColors.danger,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _month(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];
}
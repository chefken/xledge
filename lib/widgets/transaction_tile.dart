import 'package:flutter/material.dart';
import 'package:xledge/models/expense_model.dart';
import 'package:xledge/utils/category_utils.dart';
import 'package:xledge/utils/void_colors.dart';

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
    final meta      = categoryMeta(expense.category);
    final isAllow   = expense.isAllowance;
    final amtColor  = isAllow ? VoidColors.success : VoidColors.danger;
    final amtPrefix = isAllow ? '+' : '-';

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
                color: isAllow ? VoidColors.successLight : meta.lightColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAllow ? Icons.savings_rounded : meta.icon,
                color: isAllow ? VoidColors.success : meta.color,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: VoidColors.textPrimary,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isAllow ? 'Allowance · ${_fmtDate(expense.date)}' : _fmtDate(expense.date),
                    style: const TextStyle(
                      fontSize: 12,
                      color: VoidColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$amtPrefix₹${expense.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: amtColor,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const m = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day.toString().padLeft(2, '0')} ${m[d.month]}';
  }
}
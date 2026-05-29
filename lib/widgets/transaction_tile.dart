import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xledge/models/expense_model.dart';
import 'package:xledge/utils/category_utils.dart';
import 'package:xledge/utils/theme_ext.dart';
import 'package:xledge/utils/void_colors.dart';

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

    return Dismissible(
      key: Key(expense.id),
      background: _swipeBg(
        color:     VoidColors.primary,
        icon:      Icons.edit_rounded,
        alignment: Alignment.centerLeft,
        context:   context,
      ),
      secondaryBackground: _swipeBg(
        color:     VoidColors.danger,
        icon:      Icons.delete_outlined,
        alignment: Alignment.centerRight,
        context:   context,
      ),
      confirmDismiss: (dir) async {
        HapticFeedback.lightImpact();
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: isAllow
                    ? VoidColors.primaryLight
                    : context.xIconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isAllow ? Icons.savings_outlined : meta.icon,
                color: isAllow
                    ? VoidColors.primary
                    : context.xIconColor,
                size: 19,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.xTxPri,
                      letterSpacing: -0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _smartDate(expense.date),
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 11,
                      color: context.xTxHint,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '₹${expense.amount.toInt()}',
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isAllow
                    ? VoidColors.primary
                    : context.xTxPri,
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
    required BuildContext context,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Icon(icon, color: color, size: 19),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Delete record?',
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: ctx.xTxPri,
                )),
            content: Text('This cannot be undone.',
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 13,
                  color: ctx.xTxSec,
                )),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel',
                    style: GoogleFonts.bricolageGrotesque(
                        color: ctx.xTxSec)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Delete',
                    style: GoogleFonts.bricolageGrotesque(
                      color: VoidColors.danger,
                      fontWeight: FontWeight.w600,
                    )),
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
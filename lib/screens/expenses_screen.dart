import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:xledge/utils/void_theme.dart';
import 'package:xledge/utils/category_utils.dart';
import 'package:xledge/providers/void_provider.dart';
import 'package:xledge/screens/add_expense_sheet.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VOID // EXPENSES'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: VoidColors.accent),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const AddExpenseSheet(),
            ),
          ),
        ],
      ),
      body: Consumer<VoidProvider>(
        builder: (context, provider, _) {
          final expenses = provider.expenses;
          if (expenses.isEmpty) {
            return const Center(
              child: Text(
                'NO DATA IN THE VOID',
                style: TextStyle(
                  color: VoidColors.textMuted,
                  letterSpacing: 3,
                  fontSize: 11,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: expenses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, i) {
              final e = expenses[i];
              final meta = categoryMeta(e.category);
              return Dismissible(
                key: Key(e.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: VoidColors.danger.withOpacity(0.15),
                  child: const Icon(Icons.delete_outline,
                      color: VoidColors.danger),
                ),
                onDismissed: (_) => provider.deleteExpense(e.id),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: VoidColors.card,
                    border: Border.all(color: VoidColors.border),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 36,
                        color: meta.color,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.title.toUpperCase(),
                              style: const TextStyle(
                                color: VoidColors.textPrimary,
                                fontSize: 12,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${e.category}  ·  ${e.date.day.toString().padLeft(2, '0')}.${e.date.month.toString().padLeft(2, '0')}.${e.date.year}',
                              style: const TextStyle(
                                color: VoidColors.textSecondary,
                                fontSize: 9,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${e.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: VoidColors.textPrimary,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
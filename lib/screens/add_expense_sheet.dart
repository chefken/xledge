import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xledge/providers/void_provider.dart';
import 'package:xledge/utils/category_utils.dart';
import 'package:xledge/utils/void_colors.dart';
import 'package:xledge/utils/void_constants.dart';
import 'package:xledge/utils/void_spacing.dart';
import 'package:xledge/utils/void_text_styles.dart';

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({super.key});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _titleCtrl  = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl   = TextEditingController();

  String   _category    = ExpenseCategory.food;
  DateTime _date        = DateTime.now();
  bool     _isAllowance = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              const ColorScheme.light(primary: VoidColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    final title  = _titleCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (title.isEmpty || amount == null || amount <= 0) return;

    context.read<VoidProvider>().addExpense(
          title:       title,
          amount:      amount,
          category:    _isAllowance ? 'Allowance' : _category,
          date:        _date,
          note:        _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
          isAllowance: _isAllowance,
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: VoidColors.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isAllowance ? 'Add Allowance' : 'Add Expense',
                    style: VoidTextStyles.titleLarge,
                  ),
                  _TypeToggle(
                    isAllowance: _isAllowance,
                    onChanged: (v) => setState(() => _isAllowance = v),
                  ),
                ],
              ),
              const SizedBox(height: VoidSpacing.md),
              TextField(
                controller: _titleCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                ),
              ),
              if (!_isAllowance) ...[
                const SizedBox(height: 16),
                Text('Category', style: VoidTextStyles.labelLarge),
                const SizedBox(height: 10),
                _CategoryGrid(
                  selected: _category,
                  onSelect: (c) => setState(() => _category = c),
                ),
              ],
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: VoidColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: VoidColors.outline),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: VoidColors.primary, size: 18),
                      const SizedBox(width: 10),
                      Text(_fmtDate(_date),
                          style: VoidTextStyles.bodyLarge),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteCtrl,
                decoration: const InputDecoration(
                    labelText: 'Note (optional)'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isAllowance
                      ? VoidColors.success
                      : VoidColors.primary,
                ),
                child: Text(
                    _isAllowance ? 'Save Allowance' : 'Save Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const m = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day.toString().padLeft(2, '0')} ${m[d.month]} ${d.year}';
  }
}

class _TypeToggle extends StatelessWidget {
  final bool isAllowance;
  final ValueChanged<bool> onChanged;

  const _TypeToggle({required this.isAllowance, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: VoidColors.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: VoidColors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Pill(
            label: 'Expense',
            active: !isAllowance,
            color: VoidColors.danger,
            onTap: () => onChanged(false),
          ),
          _Pill(
            label: 'Allowance',
            active: isAllowance,
            color: VoidColors.success,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : VoidColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _CategoryGrid({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ExpenseCategory.all.map((cat) {
        final meta     = categoryMeta(cat);
        final isActive = selected == cat;
        return GestureDetector(
          onTap: () => onSelect(cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
                horizontal: 4, vertical: 8),
            width: 64,
            decoration: BoxDecoration(
              color: isActive ? meta.lightColor : VoidColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive ? meta.color : VoidColors.outline,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Icon(meta.icon,
                    color: isActive
                        ? meta.color
                        : VoidColors.textSecondary,
                    size: 24),
                const SizedBox(height: 4),
                Text(
                  cat,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? meta.color
                        : VoidColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
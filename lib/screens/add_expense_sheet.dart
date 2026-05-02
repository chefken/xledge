import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xledge/models/expense_model.dart';
import 'package:xledge/providers/void_provider.dart';
import 'package:xledge/utils/category_utils.dart';
import 'package:xledge/utils/void_colors.dart';
import 'package:xledge/utils/void_constants.dart';
import 'package:xledge/utils/void_text_styles.dart';

class AddExpenseSheet extends StatefulWidget {
  final Expense? existingExpense;

  const AddExpenseSheet({super.key, this.existingExpense});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _amountCtrl;
  late String   _category;
  late DateTime _date;
  late bool     _isAllowance;

  bool get _isEditing => widget.existingExpense != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existingExpense;
    _titleCtrl   = TextEditingController(text: e?.title ?? '');
    _amountCtrl  = TextEditingController(
        text: e != null ? e.amount.toStringAsFixed(0) : '');
    _category    = e?.category ?? ExpenseCategory.food;
    _date        = e?.date ?? DateTime.now();
    _isAllowance = e?.isAllowance ?? false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
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

    final provider = context.read<VoidProvider>();

    if (_isEditing) {
      provider.deleteExpense(widget.existingExpense!.id);
    }

    provider.addExpense(
      title:       title,
      amount:      amount,
      category:    _isAllowance ? 'Allowance' : _category,
      date:        _date,
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
        decoration: const BoxDecoration(
          color: VoidColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: VoidColors.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_isEditing ? 'Edit Record' : 'New Record',
                      style: VoidTextStyles.headlineMedium),
                  _TypeToggle(
                    isAllowance: _isAllowance,
                    onChanged: (v) => setState(() => _isAllowance = v),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _FieldLabel('Item Name'),
              const SizedBox(height: 8),
              TextField(
                controller: _titleCtrl,
                textCapitalization: TextCapitalization.sentences,
                style: VoidTextStyles.bodyLarge,
                decoration: const InputDecoration(
                  hintText: '',
                ),
              ),
              const SizedBox(height: 16),
              _FieldLabel('Amount'),
              const SizedBox(height: 8),
              TextField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: VoidColors.textPrimary,
                  letterSpacing: -0.5,
                ),
                decoration: const InputDecoration(
                  prefixText: '₹ ',
                  hintText: '',
                ),
              ),
              if (!_isAllowance) ...[
                const SizedBox(height: 20),
                _FieldLabel('Category'),
                const SizedBox(height: 12),
                _CategoryPicker(
                  selected: _category,
                  onSelect: (c) => setState(() => _category = c),
                ),
              ],
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: VoidColors.outlineVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: VoidColors.primary, size: 18),
                      const SizedBox(width: 12),
                      Text(_fmtDate(_date),
                          style: VoidTextStyles.bodyLarge),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isAllowance
                      ? VoidColors.success
                      : VoidColors.primary,
                ),
                child: Text(_isEditing
                    ? 'Update Record'
                    : (_isAllowance ? 'Save Allowance' : 'Save Expense')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const m = ['','Jan','Feb','Mar','Apr','May','Jun',
                'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month]} ${d.year}';
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: VoidTextStyles.labelLarge
            .copyWith(color: VoidColors.textSecondary));
  }
}

class _TypeToggle extends StatelessWidget {
  final bool isAllowance;
  final ValueChanged<bool> onChanged;

  const _TypeToggle({required this.isAllowance, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: VoidColors.outlineVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Pill(label: 'Expense',
              active: !isAllowance,
              color: VoidColors.danger,
              onTap: () => onChanged(false)),
          _Pill(label: 'Allow',
              active: isAllowance,
              color: VoidColors.success,
              onTap: () => onChanged(true)),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : VoidColors.textSecondary,
            )),
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _CategoryPicker({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: ExpenseCategory.all.map((cat) {
        final meta   = categoryMeta(cat);
        final active = selected == cat;
        return GestureDetector(
          onTap: () => onSelect(cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            width: 66,
            decoration: BoxDecoration(
              color: active ? meta.lightColor : VoidColors.outlineVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: active ? meta.color : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Icon(meta.icon,
                    color: active ? meta.color : VoidColors.textHint,
                    size: 22),
                const SizedBox(height: 5),
                Text(cat,
                    style: TextStyle(
                      fontSize: 9, fontWeight: FontWeight.w600,
                      color: active ? meta.color : VoidColors.textHint,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
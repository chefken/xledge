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

class _AddExpenseSheetState extends State<AddExpenseSheet>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _amountCtrl;
  late String   _category;
  late DateTime _date;
  late bool     _isAllowance;

  late final AnimationController _slideCtrl;
  late final Animation<Offset>   _slide;
  late final Animation<double>   _fade;

  bool get _isEditing => widget.existingExpense != null;

  @override
  void initState() {
    super.initState();
    final e      = widget.existingExpense;
    _titleCtrl   = TextEditingController(text: e?.title ?? '');
    _amountCtrl  = TextEditingController(
        text: e != null ? e.amount.toStringAsFixed(0) : '');
    _category    = e?.category ?? ExpenseCategory.food;
    _date        = e?.date ?? DateTime.now();
    _isAllowance = e?.isAllowance ?? false;

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    )..forward();
    _slide = Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic),
    );
    _fade = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _slideCtrl.dispose();
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
          colorScheme: const ColorScheme.light(
            primary: VoidColors.primary,
          ),
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
    if (_isEditing) provider.deleteExpense(widget.existingExpense!.id);

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
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: VoidColors.surface,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      margin: const EdgeInsets.only(bottom: 22),
                      decoration: BoxDecoration(
                        color: VoidColors.outline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isEditing
                            ? 'Edit Record'
                            : (_isAllowance
                                ? 'Add Allowance'
                                : 'Add Allowance'),
                        style: VoidTextStyles.headlineMedium,
                      ),
                      _TypeToggle(
                        isAllowance: _isAllowance,
                        onChanged: (v) =>
                            setState(() => _isAllowance = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _Label('Item Name'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleCtrl,
                    textCapitalization:
                        TextCapitalization.sentences,
                    style: VoidTextStyles.bodyLarge,
                    decoration: const InputDecoration(
                        hintText: ''),
                  ),
                  const SizedBox(height: 18),
                  _Label('Amount'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: VoidColors.textPrimary,
                      letterSpacing: -0.8,
                    ),
                    decoration: const InputDecoration(
                      prefixText: '₹  ',
                      prefixStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: VoidColors.textHint,
                      ),
                      hintText: '',
                    ),
                  ),
                  if (!_isAllowance) ...[
                    const SizedBox(height: 22),
                    _Label('Category'),
                    const SizedBox(height: 12),
                    _CategoryGrid(
                      selected: _category,
                      onSelect: (c) => setState(() => _category = c),
                    ),
                  ],
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 15),
                      decoration: BoxDecoration(
                        color: VoidColors.outlineVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: VoidColors.textSecondary,
                            size: 16,
                          ),
                          const SizedBox(width: 10),
                          Text(_fmtDate(_date),
                              style: VoidTextStyles.bodyMedium
                                  .copyWith(
                                      color: VoidColors.textPrimary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _SubmitButton(
                    label: _isEditing
                        ? 'Update Record'
                        : (_isAllowance
                            ? 'Save Income'
                            : 'Save Expense'),
                    isAllowance: _isAllowance,
                    onTap: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const m = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${m[d.month]} ${d.year}';
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
          _Pill(
            label: 'Expense',
            active: !isAllowance,
            onTap: () => onChanged(false),
          ),
          _Pill(
            label: 'Income',
            active: isAllowance,
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
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? VoidColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
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

  const _CategoryGrid({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.9,
      ),
      itemCount: ExpenseCategory.all.length,
      itemBuilder: (_, i) {
        final cat    = ExpenseCategory.all[i];
        final meta   = categoryMeta(cat);
        final active = selected == cat;
        return GestureDetector(
          onTap: () => onSelect(cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: active
                  ? VoidColors.primaryLight
                  : VoidColors.outlineVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: active
                    ? VoidColors.primary.withOpacity(0.4)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  meta.icon,
                  size: 20,
                  color: active
                      ? VoidColors.primary
                      : VoidColors.iconColor,
                ),
                const SizedBox(height: 6),
                Text(
                  cat,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: active
                        ? VoidColors.primary
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
      },
    );
  }
}

class _SubmitButton extends StatefulWidget {
  final String label;
  final bool isAllowance;
  final VoidCallback onTap;

  const _SubmitButton({
    required this.label,
    required this.isAllowance,
    required this.onTap,
  });

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      value: 1,
    );
    _scale = Tween(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => _ctrl.reverse(),
      onTapUp:     (_) { _ctrl.forward(); widget.onTap(); },
      onTapCancel: ()  => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 17),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isAllowance
                  ? [
                      const Color(0xFFB49BFB),
                      const Color(0xFF7C5CFC),
                    ]
                  : [
                      VoidColors.gradientStart,
                      VoidColors.gradientEnd,
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: VoidColors.primary.withOpacity(0.28),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: VoidColors.textHint,
        letterSpacing: 0.4,
      ),
    );
  }
}
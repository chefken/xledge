import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xledge/models/expense_model.dart';
import 'package:xledge/providers/void_provider.dart';
import 'package:xledge/utils/category_utils.dart';
import 'package:xledge/utils/void_colors.dart';
import 'package:xledge/utils/void_constants.dart';
import 'package:xledge/utils/theme_ext.dart';
import 'package:xledge/services/category_service.dart';
import 'package:google_fonts/google_fonts.dart';

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
          colorScheme: ColorScheme.fromSeed(
            seedColor: VoidColors.primary,
            brightness: Theme.of(context).brightness,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              // Fix: Dynamic background matching your theme surface definition
              color: isDark ? VoidColors.darkSurface : VoidColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                        color: isDark ? VoidColors.darkBorder : VoidColors.outline,
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
                                : 'Add Expense'),
                        style: theme.textTheme.headlineMedium,
                      ),
                      _TypeToggle(
                        isAllowance: _isAllowance,
                        onChanged: (v) =>
                            setState(() => _isAllowance = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const _Label('Item Name'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: '',
                      hintStyle: TextStyle(color: isDark ? VoidColors.darkTextHint : VoidColors.textHint),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _Label('Amount'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: isDark ? VoidColors.darkTextPrimary : VoidColors.textPrimary,
                      letterSpacing: -0.8,
                    ),
                    decoration: InputDecoration(
                      prefixText: '₹  ',
                      prefixStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: isDark ? VoidColors.darkTextHint : VoidColors.textHint,
                      ),
                      hintText: '',
                      hintStyle: TextStyle(color: isDark ? VoidColors.darkTextHint : VoidColors.textHint),
                    ),
                  ),
                  if (!_isAllowance) ...[
                    const SizedBox(height: 22),
                    const _Label('Category'),
                    const SizedBox(height: 12),
                    _CategoryGrid(
                      selected: _category,
                      onSelect: (c) => setState(() => _category = c),
                    ),
                  ],
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                      decoration: BoxDecoration(
                        color: isDark ? VoidColors.darkCard : VoidColors.outlineVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: isDark ? VoidColors.darkTextSecondary : VoidColors.textSecondary,
                            size: 16,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _fmtDate(_date),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? VoidColors.darkTextPrimary : VoidColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _SubmitButton(
                    label: _isEditing
                        ? 'Update Record'
                        : (_isAllowance
                            ? 'Save Allowance'
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? VoidColors.darkCard : VoidColors.outlineVariant,
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
            label: 'Allowance',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? VoidColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active 
                ? Colors.white 
                : (isDark ? VoidColors.darkTextSecondary : VoidColors.textSecondary),
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
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final fill      = isDark ? VoidColors.darkCard    : VoidColors.outlineVariant;
    final border    = isDark ? VoidColors.darkBorder  : Colors.transparent;
    final iconCol   = isDark ? VoidColors.darkIconColor : VoidColors.iconColor;

    return Consumer<CategoryService>(
      builder: (context, catService, _) {
        final cats = catService.all;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.9,
          ),
          itemCount: cats.length + 1,
          itemBuilder: (_, i) {
            if (i == cats.length) {
              return GestureDetector(
                onTap: () => _showAddCategory(context, catService),
                child: Container(
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: BorderRadius.circular(16),
                    // Removed the old glowing border stroke completely
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_rounded,
                          size: 20,
                          color: VoidColors.primary),
                      const SizedBox(height: 6),
                      Text('Add',
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: VoidColors.primary,
                          ),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            }

            final cat    = cats[i];
            final meta   = categoryMeta(cat);
            final active = selected == cat;

            return GestureDetector(
              onTap: () => onSelect(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: active
                      ? (isDark ? VoidColors.primary.withOpacity(0.15) : VoidColors.primaryLight)
                      : fill,
                  borderRadius: BorderRadius.circular(16),
                  // Border stripped out entirely for a completely flat modern design
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      meta.icon,
                      size: 20,
                      color: active
                          ? VoidColors.primary
                          : iconCol,
                    ),
                    const SizedBox(height: 6),
                    Text(cat,
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: active
                              ? VoidColors.primary
                              : (isDark
                                  ? VoidColors.darkTextSecondary
                                  : VoidColors.textSecondary),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddCategory(BuildContext context, CategoryService service) {
    final ctrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 36),
          decoration: BoxDecoration(
            color: isDark ? VoidColors.darkSurface : VoidColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: isDark ? VoidColors.darkBorder : VoidColors.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('New Category',
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark ? VoidColors.darkTextPrimary : VoidColors.textPrimary,
                    letterSpacing: -0.4,
                  )),
              const SizedBox(height: 18),
              TextField(
                controller: ctrl,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 15,
                  color: isDark ? VoidColors.darkTextPrimary : VoidColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Subscriptions, Pets...',
                  hintStyle: GoogleFonts.bricolageGrotesque(
                    fontSize: 15,
                    color: isDark ? VoidColors.darkTextHint : VoidColors.textHint,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  final ok = await service.addCategory(ctrl.text);
                  if (context.mounted) {
                    Navigator.pop(context);
                    if (!ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Category already exists',
                              style: GoogleFonts.bricolageGrotesque(color: Colors.white)),
                          backgroundColor: VoidColors.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    } else {
                      onSelect(ctrl.text.trim());
                    }
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFA78BFA), Color(0xFF5B3FD4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: VoidColors.primary.withOpacity(0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text('Create Category',
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
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
            // Uses the exact solid color as your top toggle pills
            color: VoidColors.primary,
            borderRadius: BorderRadius.circular(18),
            // Stripped out BoxShadow entirely to kill the bottom glow effect
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: isDark ? VoidColors.darkTextHint : VoidColors.textHint,
        letterSpacing: 0.4,
      ),
    );
  }
}
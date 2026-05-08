import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:xledge/providers/void_provider.dart';
import 'package:xledge/utils/void_colors.dart';
import 'package:xledge/utils/void_text_styles.dart';

class AddDebtSheet extends StatefulWidget {
  const AddDebtSheet({super.key});

  @override
  State<AddDebtSheet> createState() => _AddDebtSheetState();
}

class _AddDebtSheetState extends State<AddDebtSheet>
    with SingleTickerProviderStateMixin {
  final _nameCtrl   = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _descCtrl   = TextEditingController();
  bool _isIOwe = true;

  late final AnimationController _slideCtrl;
  late final Animation<Offset>   _slide;
  late final Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    )..forward();
    _slide = Tween(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _slideCtrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(
        parent: _slideCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name   = _nameCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim());
    final desc   = _descCtrl.text.trim();
    if (name.isEmpty || amount == null || amount <= 0) return;

    context.read<VoidProvider>().addDebt(
          contactName: name,
          amount:      amount,
          description: desc.isEmpty ? 'No note' : desc,
          isIOwe:      _isIOwe,
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
                 Text('Add Debt',
                    style: VoidTextStyles.headlineMedium),
                
                const SizedBox(height: 20),
                _DebtTypeSelector(
                  isIOwe: _isIOwe,
                  onChanged: (v) => setState(() => _isIOwe = v),
                ),
                const SizedBox(height: 22),
                _SheetField(
                  controller: _nameCtrl,
                  hint: '',
                  label: 'Contact',
                  capitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 14),
                _SheetField(
                  controller: _amountCtrl,
                  hint: '',
                  label: 'Amount',
                  prefix: '₹  ',
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  isLarge: true,
                ),
                const SizedBox(height: 14),
                _SheetField(
                  controller: _descCtrl,
                  hint: '',
                  label: 'Reason',
                  capitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 28),
                _DebtSubmitBtn(
                  isIOwe: _isIOwe,
                  onTap:  _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DebtTypeSelector extends StatelessWidget {
  final bool isIOwe;
  final ValueChanged<bool> onChanged;

  const _DebtTypeSelector({
    required this.isIOwe,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TypeCard(
            label: 'I Owe',
            sublabel: 'I need to pay',
            icon: Icons.arrow_upward_rounded,
            active: isIOwe,
            onTap: () => onChanged(true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TypeCard(
            label: 'Owes Me',
            sublabel: 'They need to pay',
            icon: Icons.arrow_downward_rounded,
            active: !isIOwe,
            onTap: () => onChanged(false),
          ),
        ),
      ],
    );
  }
}

class _TypeCard extends StatelessWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _TypeCard({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: active ? VoidColors.primaryLight : VoidColors.outlineVariant,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active
                ? VoidColors.primary.withOpacity(0.35)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: active
                    ? VoidColors.primary.withOpacity(0.15)
                    : VoidColors.outline,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 15,
                color: active
                    ? VoidColors.primary
                    : VoidColors.textHint,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: active
                            ? VoidColors.primary
                            : VoidColors.textPrimary,
                      )),
                  Text(sublabel,
                      style: const TextStyle(
                        fontSize: 10,
                        color: VoidColors.textHint,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String label;
  final String? prefix;
  final TextInputType? keyboardType;
  final TextCapitalization capitalization;
  final bool isLarge;

  const _SheetField({
    required this.controller,
    required this.hint,
    required this.label,
    this.prefix,
    this.keyboardType,
    this.capitalization = TextCapitalization.none,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: VoidColors.textHint,
              letterSpacing: 0.4,
            )),
        const SizedBox(height: 6),
        TextField(
          controller:          controller,
          keyboardType:        keyboardType,
          textCapitalization:  capitalization,
          style: isLarge
              ? const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: VoidColors.textPrimary,
                  letterSpacing: -0.6,
                )
              : VoidTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText:    hint,
            prefixText:  prefix,
            prefixStyle: const TextStyle(
              fontSize: 16,
              color: VoidColors.textHint,
            ),
          ),
        ),
      ],
    );
  }
}

class _DebtSubmitBtn extends StatefulWidget {
  final bool isIOwe;
  final VoidCallback onTap;

  const _DebtSubmitBtn({required this.isIOwe, required this.onTap});

  @override
  State<_DebtSubmitBtn> createState() => _DebtSubmitBtnState();
}

class _DebtSubmitBtnState extends State<_DebtSubmitBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        value: 1);
    _scale = Tween(begin: 0.96, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
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
            gradient: const LinearGradient(
              colors: [
                Color(0xFF9B7EF8),
                Color(0xFF6C3CE1),
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
            widget.isIOwe ? 'Record Debt' : 'Record Credit',
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
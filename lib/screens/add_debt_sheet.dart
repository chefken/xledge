import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:xledge/utils/void_theme.dart';
import 'package:xledge/providers/void_provider.dart';

class AddDebtSheet extends StatefulWidget {
  const AddDebtSheet({super.key});

  @override
  State<AddDebtSheet> createState() => _AddDebtSheetState();
}

class _AddDebtSheetState extends State<AddDebtSheet> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isIOwe = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim());
    final desc = _descCtrl.text.trim();
    if (name.isEmpty || amount == null || amount <= 0 || desc.isEmpty) return;

    context.read<VoidProvider>().addDebt(
          contactName: name,
          amount: amount,
          description: desc,
          isIOwe: _isIOwe,
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VoidColors.surface,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'LOG DEBT',
                style: TextStyle(
                  color: VoidColors.accent,
                  fontSize: 12,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: VoidColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: VoidColors.card,
              border: Border.all(color: VoidColors.border),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              children: [
                _toggle('I OWE', true),
                _toggle('THEY OWE', false),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: VoidColors.textPrimary),
            decoration: const InputDecoration(labelText: 'CONTACT NAME'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              color: VoidColors.accent,
              fontSize: 18,
              letterSpacing: 2,
            ),
            decoration: const InputDecoration(
              labelText: 'AMOUNT',
              prefixText: '₹ ',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descCtrl,
            style: const TextStyle(color: VoidColors.textPrimary, fontSize: 12),
            decoration: const InputDecoration(labelText: 'REASON'),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isIOwe ? VoidColors.danger : VoidColors.success,
                foregroundColor: VoidColors.bg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'COMMIT',
                style: TextStyle(
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggle(String label, bool value) {
    final selected = _isIOwe == value;
    final color = value ? VoidColors.danger : VoidColors.success;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isIOwe = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.15) : Colors.transparent,
            border: Border.all(
              color: selected ? color : Colors.transparent,
              width: 0,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? color : VoidColors.textSecondary,
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
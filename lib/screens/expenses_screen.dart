import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:xledge/models/expense_model.dart';
import 'package:xledge/providers/void_provider.dart';
import 'package:xledge/screens/add_expense_sheet.dart';
import 'package:xledge/services/category_service.dart';
import 'package:xledge/utils/category_utils.dart';
import 'package:xledge/utils/theme_ext.dart';
import 'package:xledge/utils/void_colors.dart';
import 'package:xledge/utils/void_text_styles.dart';
import 'package:xledge/widgets/transaction_tile.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  static const _months = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  static const _short = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<VoidProvider>(
      builder: (context, provider, _) {
        final grouped = _group(provider.expenses);
        final dates   = grouped.keys.toList();

        return Scaffold(
          backgroundColor: context.xBg,
          floatingActionButton: _MiniPurpleFab(
            onTap: () => _addSheet(context),
          ),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      24, 64, 24, 20),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Expenses',
                          style: VoidTextStyles.headlineLarge),
                      Row(
                        children: [
                          _FilterChip(
                            label:
                                '${_months[provider.selectedMonth]} ${provider.selectedYear}',
                            onTap: () =>
                                _filterSheet(context, provider),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () =>
                                _categorySheet(context),
                            child: Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: context.xFill,
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.category_outlined,
                                color: context.xTxSec,
                                size: 17,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              grouped.isEmpty
                  ? SliverFillRemaining(child: _Empty())
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) {
                            final date  = dates[i];
                            final items = grouped[date]!;
                            final net   = items.fold(
                              0.0,
                              (s, e) => s +
                                  (e.isAllowance
                                      ? e.amount
                                      : -e.amount),
                            );
                            return _DateSection(
                              date:     date,
                              net:      net,
                              items:    items,
                              onDelete: (id) =>
                                  provider.deleteExpense(id),
                              onEdit:   (e) =>
                                  _editSheet(context, e),
                            );
                          },
                          childCount: dates.length,
                        ),
                      ),
                    ),
              const SliverToBoxAdapter(
                  child: SizedBox(height: 130)),
            ],
          ),
        );
      },
    );
  }

  void _addSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddExpenseSheet(),
    );
  }

  void _editSheet(BuildContext context, Expense e) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddExpenseSheet(existingExpense: e),
    );
  }

  void _filterSheet(BuildContext context, VoidProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FilterSheet(provider: provider),
    );
  }

  void _categorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _CategoryManagerSheet(),
    );
  }

  Map<String, List<Expense>> _group(List<Expense> expenses) {
    final map = <String, List<Expense>>{};
    for (final e in expenses) {
      final key = '${_short[e.date.month]} ${e.date.year}';
      map.putIfAbsent(key, () => []).add(e);
    }
    return map;
  }
}

class _CategoryManagerSheet extends StatelessWidget {
  const _CategoryManagerSheet();

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryService>(
      builder: (context, catService, _) {
        final custom = catService.custom;

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 40),
          decoration: BoxDecoration(
            color: context.xSurface,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28)),
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
                    color: context.xBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text('Categories',
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: context.xTxPri,
                        letterSpacing: -0.4,
                      )),
                  GestureDetector(
                    onTap: () =>
                        _showAddDialog(context, catService),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: VoidColors.primaryLight,
                        borderRadius:
                            BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_rounded,
                              color: VoidColors.primary,
                              size: 15),
                          const SizedBox(width: 4),
                          Text('Add',
                              style:
                                  GoogleFonts.bricolageGrotesque(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: VoidColors.primary,
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (custom.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20),
                  child: Center(
                    child: Text(
                      'No custom categories yet',
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 13,
                        color: context.xTxHint,
                      ),
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight:
                        MediaQuery.of(context).size.height *
                            0.4,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: custom.length,
                    separatorBuilder: (_, __) => Divider(
                        color: context.xBorder,
                        height: 1),
                    itemBuilder: (_, i) {
                      final cat = custom[i];
                      final meta = categoryMeta(cat);
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: context.xIconBg,
                                borderRadius:
                                    BorderRadius.circular(
                                        10),
                              ),
                              child: Icon(meta.icon,
                                  color: VoidColors.primary,
                                  size: 16),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(cat,
                                  style: GoogleFonts
                                      .bricolageGrotesque(
                                    fontSize: 14,
                                    fontWeight:
                                        FontWeight.w500,
                                    color: context.xTxPri,
                                  )),
                            ),
                            GestureDetector(
                              onTap: () => _showEditDialog(
                                  context, catService, cat),
                              child: Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(
                                  color:
                                      VoidColors.primaryLight,
                                  borderRadius:
                                      BorderRadius.circular(
                                          9),
                                ),
                                child: const Icon(
                                    Icons.edit_outlined,
                                    color: VoidColors.primary,
                                    size: 14),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () async {
                                final confirm =
                                    await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) =>
                                      AlertDialog(
                                    title: Text(
                                        'Delete "$cat"?',
                                        style: GoogleFonts
                                            .bricolageGrotesque(
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight.w600,
                                          color: ctx.xTxPri,
                                        )),
                                    content: Text(
                                        'This only removes the category, not existing expenses.',
                                        style: GoogleFonts
                                            .bricolageGrotesque(
                                          fontSize: 13,
                                          color: ctx.xTxSec,
                                        )),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(
                                                ctx, false),
                                        child: Text('Cancel',
                                            style: GoogleFonts
                                                .bricolageGrotesque(
                                                    color: ctx
                                                        .xTxSec)),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(
                                                ctx, true),
                                        child: Text('Delete',
                                            style: GoogleFonts
                                                .bricolageGrotesque(
                                              color: VoidColors
                                                  .danger,
                                              fontWeight:
                                                  FontWeight
                                                      .w600,
                                            )),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  catService
                                      .deleteCategory(cat);
                                }
                              },
                              child: Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(
                                  color:
                                      VoidColors.dangerLight,
                                  borderRadius:
                                      BorderRadius.circular(
                                          9),
                                ),
                                child: const Icon(
                                    Icons
                                        .delete_outline_rounded,
                                    color: VoidColors.danger,
                                    size: 14),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showAddDialog(
      BuildContext context, CategoryService service) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('New Category',
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: ctx.xTxPri,
            )),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: GoogleFonts.bricolageGrotesque(
              color: ctx.xTxPri),
          decoration: InputDecoration(
            hintText: 'e.g. Subscriptions',
            hintStyle: GoogleFonts.bricolageGrotesque(
                color: ctx.xTxHint),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.bricolageGrotesque(
                    color: ctx.xTxSec)),
          ),
          TextButton(
            onPressed: () async {
              final ok =
                  await service.addCategory(ctrl.text);
              if (ctx.mounted) Navigator.pop(ctx);
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Already exists',
                        style: GoogleFonts.bricolageGrotesque(
                            color: Colors.white)),
                    backgroundColor: VoidColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
            child: Text('Create',
                style: GoogleFonts.bricolageGrotesque(
                  color: VoidColors.primary,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context,
      CategoryService service, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Category',
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: ctx.xTxPri,
            )),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: GoogleFonts.bricolageGrotesque(
              color: ctx.xTxPri),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.bricolageGrotesque(
                    color: ctx.xTxSec)),
          ),
          TextButton(
            onPressed: () async {
              final ok = await service.editCategory(
                  current, ctrl.text);
              if (ctx.mounted) Navigator.pop(ctx);
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Name already exists',
                        style: GoogleFonts.bricolageGrotesque(
                            color: Colors.white)),
                    backgroundColor: VoidColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
            child: Text('Save',
                style: GoogleFonts.bricolageGrotesque(
                  color: VoidColors.primary,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ],
      ),
    );
  }
}

class _DateSection extends StatelessWidget {
  final String date;
  final double net;
  final List<Expense> items;
  final ValueChanged<String> onDelete;
  final ValueChanged<Expense> onEdit;

  const _DateSection({
    required this.date,
    required this.net,
    required this.items,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(date,
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: context.xTxHint,
                  letterSpacing: 0.3,
                )),
            Text(
              '₹${net.abs().toInt()}',
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: net >= 0
                    ? VoidColors.primary
                    : context.xTxPri,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((e) => TransactionTile(
              expense:   e,
              onDismiss: () => onDelete(e.id),
              onEdit:    () => onEdit(e),
            )),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: VoidColors.primaryLight,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: VoidColors.primary,
                )),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more_rounded,
                color: VoidColors.primary, size: 16),
          ],
        ),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final VoidProvider provider;
  const _FilterSheet({required this.provider});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October',
    'November', 'December'
  ];

  late int _month;
  late int _year;

  @override
  void initState() {
    super.initState();
    _month = widget.provider.selectedMonth;
    _year  = widget.provider.selectedYear;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      decoration: BoxDecoration(
        color: context.xSurface,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: context.xBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Filter by Month',
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: context.xTxPri,
                letterSpacing: -0.2,
              )),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Year',
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 13,
                    color: context.xTxSec,
                  )),
              Row(
                children: [
                  _ChipBtn(
                    label: '<',
                    onTap: () =>
                        setState(() => _year--),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16),
                    child: Text('$_year',
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: context.xTxPri,
                        )),
                  ),
                  _ChipBtn(
                    label: '>',
                    onTap: () =>
                        setState(() => _year++),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: List.generate(12, (i) {
              final m      = i + 1;
              final active = _month == m;
              return GestureDetector(
                onTap: () => setState(() => _month = m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: active
                        ? VoidColors.primary
                        : context.xFill,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    _monthNames[i].substring(0, 3),
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: active
                          ? Colors.white
                          : context.xTxSec,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () {
              widget.provider.setMonth(_year, _month);
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 17),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFA78BFA),
                    Color(0xFF6C3CE1)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color:
                        VoidColors.primary.withOpacity(0.26),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text('Apply',
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.1,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ChipBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: context.xFill,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: GoogleFonts.bricolageGrotesque(
              fontWeight: FontWeight.w700,
              color: context.xTxSec,
            )),
      ),
    );
  }
}

class _MiniPurpleFab extends StatelessWidget {
  final VoidCallback onTap;
  const _MiniPurpleFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52, height: 52,
        margin: const EdgeInsets.only(bottom: 98),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [VoidColors.gradStart, VoidColors.gradEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: VoidColors.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded,
            color: Colors.white, size: 24),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: VoidColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.receipt_long_rounded,
                color: VoidColors.primary, size: 28),
          ),
          const SizedBox(height: 14),
          Text('No expenses',
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: context.xTxPri,
              )),
          const SizedBox(height: 6),
          Text('Tap + to add your first record',
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 13,
                color: context.xTxSec,
              )),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:xledge/utils/void_colors.dart';
import 'package:xledge/utils/void_constants.dart';
import 'package:xledge/utils/category_utils.dart';

class CategoryScrollRow extends StatefulWidget {
  final ValueChanged<String?> onSelected;

  const CategoryScrollRow({super.key, required this.onSelected});

  @override
  State<CategoryScrollRow> createState() => _CategoryScrollRowState();
}

class _CategoryScrollRowState extends State<CategoryScrollRow> {
  String? _selected;

  static const _all = <String>['All', ...ExpenseCategory.all];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: _all.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) {
          final cat = _all[i];
          final isAll = cat == 'All';
          final meta = isAll ? null : categoryMeta(cat);
          final color = isAll ? VoidColors.primary : meta!.color;
          final bgColor = isAll ? VoidColors.primaryLight : meta!.lightColor;
          final icon = isAll ? Icons.grid_view_rounded : meta!.icon;
          final selected = _selected == (isAll ? null : cat);

          return GestureDetector(
            onTap: () {
              setState(() => _selected = isAll ? null : cat);
              widget.onSelected(isAll ? null : cat);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: selected ? color : bgColor,
                    shape: BoxShape.circle,
                    border: selected
                        ? null
                        : Border.all(color: VoidColors.outline, width: 1.5),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.28),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Icon(icon,
                      color: selected ? VoidColors.onPrimary : color,
                      size: 22),
                ),
                const SizedBox(height: 7),
                Text(
                  cat,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? color : VoidColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
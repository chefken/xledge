class CategoryTotal {
  final String category;
  final double total;
  final double percentage;

  const CategoryTotal({
    required this.category,
    required this.total,
    required this.percentage,
  });
}

class VoidAnalysis {
  final int year;
  final int month;
  final double totalSpend;
  final List<CategoryTotal> categoryBreakdown;
  final String? primaryLeak;
  final double? primaryLeakAmount;
  final double? primaryLeakPercentage;

  const VoidAnalysis({
    required this.year,
    required this.month,
    required this.totalSpend,
    required this.categoryBreakdown,
    this.primaryLeak,
    this.primaryLeakAmount,
    this.primaryLeakPercentage,
  });

  bool get hasData => totalSpend > 0;
}
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:xledge/models/expense_model.dart';
import 'package:xledge/models/debt_model.dart';
import 'package:xledge/models/void_analysis.dart';
import 'package:xledge/services/expense_service.dart';
import 'package:xledge/services/debt_service.dart';

class VoidProvider extends ChangeNotifier {
  final _expenseService = ExpenseService();
  final _debtService    = DebtService();
  final _uuid           = const Uuid();

  late int _year;
  late int _month;

  List<Expense> _expenses = [];
  List<Debt>    _debts    = [];
  VoidAnalysis? _analysis;

  VoidProvider() {
    final now = DateTime.now();
    _year  = now.year;
    _month = now.month;
    _load();
  }

  List<Expense> get expenses      => _expenses;
  List<Debt>    get debts         => _debts;
  VoidAnalysis? get analysis      => _analysis;
  int           get selectedYear  => _year;
  int           get selectedMonth => _month;

  List<Expense> get allowances   => _expenses.where((e) => e.isAllowance).toList();
  List<Expense> get spendingOnly => _expenses.where((e) => !e.isAllowance).toList();

  List<Debt> get activeDebts  => _debts.where((d) => !d.isSettled).toList();
  List<Debt> get iOweDebts    => activeDebts.where((d) => d.isIOwe).toList();
  List<Debt> get theyOweDebts => activeDebts.where((d) => !d.isIOwe).toList();
  double get totalIOwe        => _debtService.totalIOwe();
  double get totalTheyOwe     => _debtService.totalTheyOwe();

  double get totalAllowance =>
      allowances.fold(0, (sum, e) => sum + e.amount);

  double get netBalance =>
      totalAllowance - (analysis?.totalSpend ?? 0);

  void _load() {
    _expenses = _expenseService.getByMonth(_year, _month);
    _debts    = _debtService.getAll();
    _buildAnalysis();
  }

  void _buildAnalysis() {
    final monthly = _expenseService.getByMonth(_year, _month)
        .where((e) => !e.isAllowance)
        .toList();

    if (monthly.isEmpty) {
      _analysis = VoidAnalysis(
        year: _year, month: _month,
        totalSpend: 0, categoryBreakdown: [],
      );
      return;
    }

    final totals = <String, double>{};
    for (final e in monthly) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }

    final grand = totals.values.fold(0.0, (a, b) => a + b);

    final breakdown = totals.entries
        .map((e) => CategoryTotal(
              category:   e.key,
              total:      e.value,
              percentage: grand > 0 ? (e.value / grand) * 100 : 0,
            ))
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    final leak = breakdown.isNotEmpty ? breakdown.first : null;

    _analysis = VoidAnalysis(
      year:                  _year,
      month:                 _month,
      totalSpend:            grand,
      categoryBreakdown:     breakdown,
      primaryLeak:           leak?.category,
      primaryLeakAmount:     leak?.total,
      primaryLeakPercentage: leak?.percentage,
    );
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    String? note,
    bool isAllowance = false,
  }) async {
    await _expenseService.add(Expense(
      id:          _uuid.v4(),
      title:       title,
      amount:      amount,
      category:    category,
      date:        date,
      note:        note,
      isAllowance: isAllowance,
    ));
    _load();
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    await _expenseService.delete(id);
    _load();
    notifyListeners();
  }

  Future<void> addDebt({
    required String contactName,
    required double amount,
    required String description,
    required bool isIOwe,
  }) async {
    await _debtService.add(Debt(
      id:          _uuid.v4(),
      contactName: contactName,
      amount:      amount,
      description: description,
      createdAt:   DateTime.now(),
      isIOwe:      isIOwe,
    ));
    _load();
    notifyListeners();
  }

  Future<void> settleDebt(String id) async {
    await _debtService.settle(id);
    _load();
    notifyListeners();
  }

  Future<void> deleteDebt(String id) async {
    await _debtService.delete(id);
    _load();
    notifyListeners();
  }

  void setMonth(int year, int month) {
    _year  = year;
    _month = month;
    _load();
    notifyListeners();
  }

  List<Expense> getAllExpensesForMonth(int year, int month) =>
      _expenseService.getByMonth(year, month);
}
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:xledge/models/expense_model.dart';
import 'package:xledge/services/expense_service.dart';
import 'package:xledge/models/debt_model.dart';
import 'package:xledge/services/debt_service.dart';
import 'package:xledge/models/void_analysis.dart';

class VoidProvider extends ChangeNotifier {
  final _expenseService = ExpenseService();
  final _debtService = DebtService();
  final _uuid = const Uuid();

  late int _selectedYear;
  late int _selectedMonth;

  List<Expense> _expenses = [];
  List<Debt> _debts = [];
  VoidAnalysis? _analysis;

  VoidProvider() {
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _load();
  }

  List<Expense> get expenses => _expenses;
  List<Debt> get debts => _debts;
  VoidAnalysis? get analysis => _analysis;
  int get selectedYear => _selectedYear;
  int get selectedMonth => _selectedMonth;

  List<Debt> get activeDebts => _debts.where((d) => !d.isSettled).toList();
  List<Debt> get iOweDebts => activeDebts.where((d) => d.isIOwe).toList();
  List<Debt> get theyOweDebts => activeDebts.where((d) => !d.isIOwe).toList();
  double get totalIOwe => _debtService.totalIOwe();
  double get totalTheyOwe => _debtService.totalTheyOwe();

  void _load() {
    _expenses = _expenseService.getByMonth(_selectedYear, _selectedMonth);
    _debts = _debtService.getAll();
    _computeAnalysis();
  }

  void _computeAnalysis() {
    final monthly = _expenseService.getByMonth(_selectedYear, _selectedMonth);

    if (monthly.isEmpty) {
      _analysis = VoidAnalysis(
        year: _selectedYear,
        month: _selectedMonth,
        totalSpend: 0,
        categoryBreakdown: [],
      );
      return;
    }

    final totals = <String, double>{};
    for (final e in monthly) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }

    final grandTotal = totals.values.fold(0.0, (a, b) => a + b);

    final breakdown = totals.entries.map((entry) {
      return CategoryTotal(
        category: entry.key,
        total: entry.value,
        percentage: grandTotal > 0 ? (entry.value / grandTotal) * 100 : 0,
      );
    }).toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    final leak = breakdown.isNotEmpty ? breakdown.first : null;

    _analysis = VoidAnalysis(
      year: _selectedYear,
      month: _selectedMonth,
      totalSpend: grandTotal,
      categoryBreakdown: breakdown,
      primaryLeak: leak?.category,
      primaryLeakAmount: leak?.total,
      primaryLeakPercentage: leak?.percentage,
    );
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    String? note,
  }) async {
    final expense = Expense(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      category: category,
      date: date,
      note: note,
    );
    await _expenseService.add(expense);
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
    final debt = Debt(
      id: _uuid.v4(),
      contactName: contactName,
      amount: amount,
      description: description,
      createdAt: DateTime.now(),
      isIOwe: isIOwe,
    );
    await _debtService.add(debt);
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
    _selectedYear = year;
    _selectedMonth = month;
    _load();
    notifyListeners();
  }
}
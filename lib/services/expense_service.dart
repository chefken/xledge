import 'package:hive/hive.dart';
import 'package:xledge/models/expense_model.dart';
import 'package:xledge/utils/app_constants.dart';
class ExpenseService {
  Box<Expense> get _box => Hive.box<Expense>(HiveBoxes.expenses);

  List<Expense> getAll() => _box.values.toList();

  Future<void> add(Expense expense) async {
    await _box.put(expense.id, expense);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> update(Expense expense) async {
    await _box.put(expense.id, expense);
  }

  List<Expense> getByMonth(int year, int month) {
    return _box.values.where((e) {
      return e.date.year == year && e.date.month == month;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
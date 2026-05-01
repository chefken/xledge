import 'package:hive/hive.dart';
import 'package:xledge/models/debt_model.dart';
import 'package:xledge/utils/void_constants.dart';

class DebtService {
  Box<Debt> get _box => Hive.box<Debt>(HiveBoxes.debts);

  List<Debt> getAll() => _box.values.toList();

  List<Debt> getUnsettled() => _box.values.where((d) => !d.isSettled).toList();

  Future<void> add(Debt debt) async => await _box.put(debt.id, debt);

  Future<void> settle(String id) async {
    final debt = _box.get(id);
    if (debt == null) return;
    debt.isSettled = true;
    debt.settledAt = DateTime.now();
    await debt.save();
  }

  Future<void> delete(String id) async => await _box.delete(id);

  double totalIOwe() => getUnsettled()
      .where((d) => d.isIOwe)
      .fold(0, (sum, d) => sum + d.amount);

  double totalTheyOwe() => getUnsettled()
      .where((d) => !d.isIOwe)
      .fold(0, (sum, d) => sum + d.amount);
}
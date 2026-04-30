import 'package:hive/hive.dart';

part 'debt_model.g.dart';

enum DebtDirection { iOwe, theyOwe }

@HiveType(typeId: 1)
class Debt extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String contactName;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final bool isIOwe;

  @HiveField(6)
  bool isSettled;

  @HiveField(7)
  DateTime? settledAt;

  Debt({
    required this.id,
    required this.contactName,
    required this.amount,
    required this.description,
    required this.createdAt,
    required this.isIOwe,
    this.isSettled = false,
    this.settledAt,
  });

  DebtDirection get direction =>
      isIOwe ? DebtDirection.iOwe : DebtDirection.theyOwe;
}
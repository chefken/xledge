class HiveBoxes {
  HiveBoxes._();
  static const expenses = 'expenses';
  static const debts    = 'debts';
}

class ExpenseCategory {
  ExpenseCategory._();
  static const food          = 'Food';
  static const transport     = 'Transport';
  static const shopping      = 'Shopping';
  static const bills         = 'Bills';
  static const health        = 'Health';
  static const gym           = 'Gym';
  static const entertainment = 'Entertainment';
  static const other         = 'Other';

  static const all = [
    food, transport, shopping, bills,
    health, gym, entertainment, other,
  ];
}
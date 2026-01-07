enum EntryType {
  expense,
  income,
}

extension EntryTypeX on EntryType {
  String get dbValue => switch (this) {
        EntryType.expense => 'expense',
        EntryType.income => 'income',
      };

  String get displayName => switch (this) {
        EntryType.expense => '支出',
        EntryType.income => '收入',
      };

  static EntryType fromDb(String value) {
    switch (value) {
      case 'income':
        return EntryType.income;
      case 'expense':
      default:
        return EntryType.expense;
    }
  }
}

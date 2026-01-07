import 'package:intl/intl.dart';

import '../models/entry_type.dart';

class Format {
  static String moneyCents(int cents) {
    final value = cents / 100.0;
    return value.toStringAsFixed(2);
  }

  static String moneyWithSign(EntryType type, int cents) {
    final s = moneyCents(cents);
    return type == EntryType.expense ? '-$s￥' : '+$s￥';
  }

  static String monthTitle(DateTime month) {
    final f = DateFormat('yyyy年MM月');
    return f.format(month);
  }

  static String dateTitle(DateTime date) {
    final f = DateFormat('MM月dd日');
    return f.format(date);
  }
}

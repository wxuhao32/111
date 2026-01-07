class MonthRange {
  final DateTime start;
  final DateTime endExclusive;

  const MonthRange({required this.start, required this.endExclusive});

  static MonthRange forMonth(DateTime anyDateInMonth) {
    final start = DateTime(anyDateInMonth.year, anyDateInMonth.month, 1);
    final end = (anyDateInMonth.month == 12)
        ? DateTime(anyDateInMonth.year + 1, 1, 1)
        : DateTime(anyDateInMonth.year, anyDateInMonth.month + 1, 1);
    return MonthRange(start: start, endExclusive: end);
  }
}

enum StatsPeriod {
  week,
  month,
  year,
}

class PeriodRange {
  final DateTime start;
  final DateTime endExclusive;

  const PeriodRange({required this.start, required this.endExclusive});

  static PeriodRange forPeriod(StatsPeriod period, DateTime anchor) {
    switch (period) {
      case StatsPeriod.week:
        final end = DateTime(anchor.year, anchor.month, anchor.day).add(const Duration(days: 1));
        final start = end.subtract(const Duration(days: 7));
        return PeriodRange(start: start, endExclusive: end);
      case StatsPeriod.month:
        final m = MonthRange.forMonth(anchor);
        return PeriodRange(start: m.start, endExclusive: m.endExclusive);
      case StatsPeriod.year:
        final start = DateTime(anchor.year, 1, 1);
        final end = DateTime(anchor.year + 1, 1, 1);
        return PeriodRange(start: start, endExclusive: end);
    }
  }
}

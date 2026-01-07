class MonthSummary {
  final int totalExpenseCents;
  final int totalIncomeCents;

  const MonthSummary({
    required this.totalExpenseCents,
    required this.totalIncomeCents,
  });

  int get balanceCents => totalIncomeCents - totalExpenseCents;
}

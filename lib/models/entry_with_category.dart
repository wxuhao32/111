import 'category.dart';
import 'ledger_entry.dart';

class EntryWithCategory {
  final LedgerEntry entry;
  final Category category;

  const EntryWithCategory({
    required this.entry,
    required this.category,
  });
}

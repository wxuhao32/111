import 'package:flutter/foundation.dart';

import '../db/app_db.dart';
import '../models/category.dart';
import '../models/category_total.dart';
import '../models/entry_type.dart';
import '../models/entry_with_category.dart';
import '../models/ledger_entry.dart';
import '../models/month_summary.dart';
import '../utils/date_ranges.dart';

class LedgerService {
  final AppDb _appDb;

  /// Any data change increments this value, so pages can refresh without
  /// bringing in heavy state-management packages.
  final ValueNotifier<int> revision = ValueNotifier<int>(0);

  LedgerService(this._appDb);

  Future<List<Category>> categoriesByType(EntryType type) async {
    final rows = await _appDb.db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type.dbValue],
      orderBy: 'sort_order ASC, id ASC',
    );
    return rows.map(Category.fromMap).toList();
  }

  Future<MonthSummary> monthSummary(DateTime month) async {
    final r = MonthRange.forMonth(month);

    final expense = await _sumAmountCents(
      type: EntryType.expense,
      startMs: r.start.millisecondsSinceEpoch,
      endMs: r.endExclusive.millisecondsSinceEpoch,
    );
    final income = await _sumAmountCents(
      type: EntryType.income,
      startMs: r.start.millisecondsSinceEpoch,
      endMs: r.endExclusive.millisecondsSinceEpoch,
    );

    return MonthSummary(
      totalExpenseCents: expense,
      totalIncomeCents: income,
    );
  }

  Future<List<EntryWithCategory>> entriesForMonth(DateTime month) async {
    final r = MonthRange.forMonth(month);
    final rows = await _appDb.db.rawQuery('''
      SELECT
        e.id AS e_id,
        e.type AS e_type,
        e.category_id AS e_category_id,
        e.amount_cents AS e_amount_cents,
        e.note AS e_note,
        e.occurred_at AS e_occurred_at,
        c.id AS c_id,
        c.name AS c_name,
        c.type AS c_type,
        c.icon_key AS c_icon_key,
        c.sort_order AS c_sort_order
      FROM entries e
      JOIN categories c ON c.id = e.category_id
      WHERE e.occurred_at >= ? AND e.occurred_at < ?
      ORDER BY e.occurred_at DESC, e.id DESC
    ''', [
      r.start.millisecondsSinceEpoch,
      r.endExclusive.millisecondsSinceEpoch,
    ]);

    return rows.map((row) {
      final entry = LedgerEntry(
        id: row['e_id'] as int,
        type: EntryTypeX.fromDb(row['e_type'] as String),
        categoryId: row['e_category_id'] as int,
        amountCents: row['e_amount_cents'] as int,
        note: row['e_note'] as String?,
        occurredAt: DateTime.fromMillisecondsSinceEpoch(row['e_occurred_at'] as int),
      );

      final category = Category(
        id: row['c_id'] as int,
        name: row['c_name'] as String,
        type: EntryTypeX.fromDb(row['c_type'] as String),
        iconKey: row['c_icon_key'] as String,
        sortOrder: (row['c_sort_order'] as int?) ?? 0,
      );

      return EntryWithCategory(entry: entry, category: category);
    }).toList();
  }

  Future<int> addEntry(LedgerEntry entry) async {
    final id = await _appDb.db.insert('entries', entry.toMap()..remove('id'));
    revision.value++;
    return id;
  }

  Future<void> updateEntry(LedgerEntry entry) async {
    final id = entry.id;
    if (id == null) {
      throw ArgumentError('entry.id is required for update');
    }
    await _appDb.db.update('entries', entry.toMap()..remove('id'), where: 'id = ?', whereArgs: [id]);
    revision.value++;
  }

  Future<void> deleteEntry(int id) async {
    await _appDb.db.delete('entries', where: 'id = ?', whereArgs: [id]);
    revision.value++;
  }

  Future<List<CategoryTotal>> categoryTotals({
    required EntryType type,
    required DateTime start,
    required DateTime endExclusive,
  }) async {
    final rows = await _appDb.db.rawQuery('''
      SELECT
        c.id AS c_id,
        c.name AS c_name,
        c.type AS c_type,
        c.icon_key AS c_icon_key,
        c.sort_order AS c_sort_order,
        SUM(e.amount_cents) AS total_cents
      FROM entries e
      JOIN categories c ON c.id = e.category_id
      WHERE e.type = ? AND e.occurred_at >= ? AND e.occurred_at < ?
      GROUP BY c.id, c.name, c.type, c.icon_key, c.sort_order
      ORDER BY total_cents DESC
    ''', [
      type.dbValue,
      start.millisecondsSinceEpoch,
      endExclusive.millisecondsSinceEpoch,
    ]);

    return rows.map((row) {
      final category = Category(
        id: row['c_id'] as int,
        name: row['c_name'] as String,
        type: EntryTypeX.fromDb(row['c_type'] as String),
        iconKey: row['c_icon_key'] as String,
        sortOrder: (row['c_sort_order'] as int?) ?? 0,
      );

      final total = (row['total_cents'] as int?) ?? 0;
      return CategoryTotal(category: category, totalCents: total);
    }).toList();
  }

  Future<int> _sumAmountCents({
    required EntryType type,
    required int startMs,
    required int endMs,
  }) async {
    final rows = await _appDb.db.rawQuery(
      'SELECT SUM(amount_cents) AS total FROM entries WHERE type = ? AND occurred_at >= ? AND occurred_at < ?',
      [type.dbValue, startMs, endMs],
    );

    final total = rows.isNotEmpty ? rows.first['total'] : null;
    if (total == null) return 0;

    if (total is int) return total;
    if (total is num) return total.toInt();
    return 0;
  }
}

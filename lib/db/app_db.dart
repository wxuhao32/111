import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../models/entry_type.dart';

class AppDb {
  static const _dbName = 'lime_mvp.db';
  static const _dbVersion = 1;

  Database? _db;

  Database get db {
    final d = _db;
    if (d == null) {
      throw StateError('Database not initialized. Call AppDb.init() first.');
    }
    return d;
  }

  Future<void> init() async {
    final base = await getDatabasesPath();
    final path = p.join(base, _dbName);

    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );

    await _seedCategoriesIfNeeded();
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon_key TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        amount_cents INTEGER NOT NULL,
        note TEXT,
        occurred_at INTEGER NOT NULL,
        FOREIGN KEY(category_id) REFERENCES categories(id) ON DELETE RESTRICT
      )
    ''');

    await db.execute('CREATE INDEX idx_entries_occurred_at ON entries(occurred_at)');
    await db.execute('CREATE INDEX idx_entries_type ON entries(type)');
    await db.execute('CREATE INDEX idx_entries_category_id ON entries(category_id)');
    await db.execute('CREATE INDEX idx_categories_type ON categories(type)');
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Future<void> _seedCategoriesIfNeeded() async {
    final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(1) FROM categories'),
        ) ??
        0;

    if (count > 0) return;

    // Base categories for MVP (can be extended later without refactor)
    final expense = <Map<String, Object?>>[
      _cat('餐饮', EntryType.expense, 'food', 10),
      _cat('交通', EntryType.expense, 'transport', 20),
      _cat('购物', EntryType.expense, 'shopping', 30),
      _cat('住房', EntryType.expense, 'home', 40),
      _cat('娱乐', EntryType.expense, 'entertainment', 50),
      _cat('医疗', EntryType.expense, 'medical', 60),
      _cat('学习', EntryType.expense, 'education', 70),
      _cat('其他', EntryType.expense, 'other_expense', 99),
    ];

    final income = <Map<String, Object?>>[
      _cat('工资', EntryType.income, 'salary', 10),
      _cat('奖金', EntryType.income, 'bonus', 20),
      _cat('退款', EntryType.income, 'refund', 30),
      _cat('投资', EntryType.income, 'investment', 40),
      _cat('其他', EntryType.income, 'other_income', 99),
    ];

    final batch = db.batch();
    for (final item in [...expense, ...income]) {
      batch.insert('categories', item);
    }
    await batch.commit(noResult: true);
  }

  Map<String, Object?> _cat(
    String name,
    EntryType type,
    String iconKey,
    int sortOrder,
  ) {
    return {
      'name': name,
      'type': type.dbValue,
      'icon_key': iconKey,
      'sort_order': sortOrder,
    };
  }
}

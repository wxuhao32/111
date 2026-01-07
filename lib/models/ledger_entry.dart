import 'entry_type.dart';

class LedgerEntry {
  final int? id;
  final EntryType type;
  final int categoryId;
  final int amountCents;
  final String? note;
  final DateTime occurredAt;

  const LedgerEntry({
    this.id,
    required this.type,
    required this.categoryId,
    required this.amountCents,
    this.note,
    required this.occurredAt,
  });

  LedgerEntry copyWith({
    int? id,
    EntryType? type,
    int? categoryId,
    int? amountCents,
    String? note,
    DateTime? occurredAt,
  }) {
    return LedgerEntry(
      id: id ?? this.id,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      amountCents: amountCents ?? this.amountCents,
      note: note ?? this.note,
      occurredAt: occurredAt ?? this.occurredAt,
    );
  }

  static LedgerEntry fromMap(Map<String, Object?> map) {
    return LedgerEntry(
      id: map['id'] as int,
      type: EntryTypeX.fromDb(map['type'] as String),
      categoryId: map['category_id'] as int,
      amountCents: map['amount_cents'] as int,
      note: map['note'] as String?,
      occurredAt: DateTime.fromMillisecondsSinceEpoch(map['occurred_at'] as int),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'type': type.dbValue,
      'category_id': categoryId,
      'amount_cents': amountCents,
      'note': note,
      'occurred_at': occurredAt.millisecondsSinceEpoch,
    };
  }
}

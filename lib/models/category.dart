import 'package:flutter/material.dart';

import '../utils/category_icons.dart';
import 'entry_type.dart';

class Category {
  final int id;
  final String name;
  final EntryType type;
  final String iconKey;
  final int sortOrder;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.iconKey,
    required this.sortOrder,
  });

  IconData get icon => CategoryIcons.byKey(iconKey);

  static Category fromMap(Map<String, Object?> map) {
    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
      type: EntryTypeX.fromDb(map['type'] as String),
      iconKey: map['icon_key'] as String,
      sortOrder: (map['sort_order'] as int?) ?? 0,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.dbValue,
      'icon_key': iconKey,
      'sort_order': sortOrder,
    };
  }
}

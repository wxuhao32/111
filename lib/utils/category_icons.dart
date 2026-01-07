import 'package:flutter/material.dart';

/// A small, controlled icon set for MVP categories.
///
/// We store `iconKey` (string) in SQLite to avoid relying on IconData codepoints,
/// which may vary between font versions.
class CategoryIcons {
  static const Map<String, IconData> _map = {
    // Expense
    'food': Icons.restaurant,
    'transport': Icons.directions_bus,
    'shopping': Icons.shopping_bag,
    'home': Icons.home,
    'entertainment': Icons.movie,
    'medical': Icons.local_hospital,
    'education': Icons.school,
    'other_expense': Icons.category,

    // Income
    'salary': Icons.payments,
    'bonus': Icons.card_giftcard,
    'refund': Icons.replay,
    'investment': Icons.trending_up,
    'other_income': Icons.savings,
  };

  static IconData byKey(String key) {
    return _map[key] ?? Icons.category;
  }
}

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import '../models/category.dart';

class CategoryGrid extends StatelessWidget {
  final List<Category> categories;
  final int? selectedCategoryId;
  final ValueChanged<Category> onSelect;

  const CategoryGrid({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final primary = HexColor('#54C395');
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final c = categories[index];
        final selected = c.id == selectedCategoryId;
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onSelect(c),
          child: Container(
            decoration: BoxDecoration(
              color: selected ? primary.withOpacity(0.12) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? primary : HexColor('#E6E6E6'),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: HexColor('#F3F3F3'),
                  child: Icon(c.icon, color: primary),
                ),
                const SizedBox(height: 8),
                Text(
                  c.name,
                  style: TextStyle(
                    fontSize: 12,
                    color: HexColor('#666666'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

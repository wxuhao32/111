import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;

  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox, size: 48, color: HexColor('#C4C4C4')),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(fontSize: 16, color: HexColor('#666666')),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: HexColor('#999999')),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

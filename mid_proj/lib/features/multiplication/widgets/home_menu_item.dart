import 'package:flutter/material.dart';
import 'package:mid_proj/features/multiplication/models/menu_item.dart';

class HomeMenuItem extends StatelessWidget {
  final MenuItem item;

  const HomeMenuItem({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => item.route),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, size: 48),
          const SizedBox(height: 8),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 18,
              color: colorScheme.onPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 
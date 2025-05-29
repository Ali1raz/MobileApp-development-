import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final double bottomPadding;

  const SectionHeader({
    super.key,
    required this.title,
    this.bottomPadding = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: bottomPadding),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'card_section.dart';

class ValueCard extends StatelessWidget {
  final String label;
  final int value;

  const ValueCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CardSection(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(color: Colors.white)),
            Text('$value', style: TextStyle(color: Colors.white, fontSize: 30)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[800],
                  child: Icon(Icons.remove, color: Colors.white),
                ),
                SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.grey[800],
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

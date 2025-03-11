import 'package:flutter/material.dart';

class NavigationControls extends StatelessWidget {
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const NavigationControls({
    super.key,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [_buildButton("Prev", onPrev), _buildButton("Next", onNext)],
          );
        } else {
          return Column(
            children: [
              _buildButton("Prev", onPrev),
              const SizedBox(height: 10),
              _buildButton("Next", onNext),
            ],
          );
        }
      },
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(text),
    );
  }
}
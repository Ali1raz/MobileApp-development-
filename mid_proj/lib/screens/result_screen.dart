import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final int correct;
  final int wrong;

  const ResultScreen({super.key, required this.correct, required this.wrong});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Test Results')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildResultItem('Correct Answers', correct, Colors.green),
            const SizedBox(height: 20),
            _buildResultItem('Wrong Answers', wrong, colorScheme.error),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Try Again'),
                ),
                ElevatedButton(
                  onPressed:
                      () =>
                          Navigator.popUntil(context, (route) => route.isFirst),
                  child: const Text('Home'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 20, color: Colors.white70)),
        SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

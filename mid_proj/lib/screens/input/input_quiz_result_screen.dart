import 'package:flutter/material.dart';

class InputQuizResultScreen extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final VoidCallback onRetry;

  const InputQuizResultScreen({
    super.key,
    required this.results,
    required this.onRetry,
  });

  int get correctCount => results.where((r) => r['isCorrect']).length;

  int get wrongCount => results.length - correctCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildResultChip('Correct', correctCount, Colors.green),
                _buildResultChip('Wrong', wrongCount, Colors.red),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final result = results[index];
                  return ListTile(
                    leading: Icon(
                      result['isCorrect'] ? Icons.check : Icons.close,
                      color: result['isCorrect'] ? Colors.green : Colors.red,
                    ),
                    title: Text(result['question']),
                    subtitle: Text(
                      'Your answer: ${result['userAnswer']}\n'
                      'Correct answer: ${result['correctAnswer']}',
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
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

  Widget _buildResultChip(String label, int count, Color color) {
    return Chip(
      backgroundColor: color.withOpacity(0.2),
      label: Text(
        '$label: $count',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

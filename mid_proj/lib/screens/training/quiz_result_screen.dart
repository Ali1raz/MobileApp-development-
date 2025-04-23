import 'package:flutter/material.dart';

class QuizResultScreen extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final VoidCallback onRetry;

  const QuizResultScreen({
    super.key,
    required this.questions,
    required this.onRetry,
  });

  int get correctCount => questions.where((q) => q['isCorrect']).length;
  int get wrongCount => questions.length - correctCount;

  Widget _buildQuestionResult(int index) {
    final question = questions[index];
    final isCorrect = question['isCorrect'];

    return ListTile(
      leading: Icon(
        isCorrect ? Icons.check : Icons.close,
        color: isCorrect ? Colors.green : Colors.red,
      ),
      title: Text(question['question']),
      subtitle: Text(
        'Your answer: ${question['userAnswer']}\n'
            'Correct answer: ${question['correctAnswer']}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildResultChip('Correct', correctCount, Colors.green),
                _buildResultChip('Wrong', wrongCount, Colors.red),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) => _buildQuestionResult(index),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Retry Test'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  child: const Text('Return Home'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultChip(String label, int count, Color color) {
    return Chip(
      backgroundColor: color.withAlpha(2),
      label: Text(
        '$label: $count',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
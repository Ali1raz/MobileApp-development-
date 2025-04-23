import 'package:flutter/material.dart';
import 'package:mid_proj/screens/quiz/quiz_screen.dart';

class QuizResultScreen extends StatelessWidget {
  final int correct;
  final int wrong;
  final String quizType;
  final int number;

  const QuizResultScreen({
    super.key,
    required this.correct,
    required this.wrong,
    required this.quizType,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Results')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Correct Answers: $correct',
              style: const TextStyle(color: Colors.green, fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text(
              'Wrong Answers: $wrong',
              style: const TextStyle(color: Colors.red, fontSize: 24),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                QuizScreen(number: number, quizType: quizType),
                      ),
                    );
                  },
                  child: const Text('Retry'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text('Back'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

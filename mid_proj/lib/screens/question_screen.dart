import 'package:flutter/material.dart';
import 'package:mid_proj/db/db_helper.dart';
import 'dart:math';

import 'package:mid_proj/screens/result_screen.dart';

class QuestionScreen extends StatefulWidget {
  final List<String> selectedOperations;
  final int minValue;
  final int maxValue;

  final String difficultyLevel;

  const QuestionScreen({
    super.key,
    required this.selectedOperations,
    required this.minValue,
    required this.maxValue,
    required this.difficultyLevel,
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late List<Map<String, dynamic>> questions;
  int currentQuestionIndex = 0;
  int correctCount = 0;
  int wrongCount = 0;

  @override
  void initState() {
    super.initState();
    questions = generateQuestions();
  }

  String formatAnswer(double answer) {
    return answer % 1 == 0
        ? answer.toInt().toString()
        : answer.toStringAsFixed(2);
  }

  List<Map<String, dynamic>> generateQuestions() {
    Random random = Random();
    List<Map<String, dynamic>> generatedQuestions = [];

    for (int i = 0; i < 10; i++) {
      String operation =
          widget.selectedOperations[random.nextInt(
            widget.selectedOperations.length,
          )];

      int num1 =
          widget.minValue +
          random.nextInt(widget.maxValue - widget.minValue + 1);
      int num2 =
          widget.minValue +
          random.nextInt(widget.maxValue - widget.minValue + 1);

      if (widget.difficultyLevel == 'Easy' && operation == '-') {
        if (num1 < num2) {
          int temp = num1;
          num1 = num2;
          num2 = temp;
        }
      }

      if (operation == '/') {
        num2 =
            widget.minValue +
            random.nextInt(widget.maxValue - widget.minValue + 1);
        while (num2 == 0) {
          num2 =
              widget.minValue +
              random.nextInt(widget.maxValue - widget.minValue + 1);
        }
        int multiplier = random.nextInt((widget.maxValue ~/ num2)) + 1;
        num1 = num2 * multiplier;
        if (num1 > widget.maxValue) num1 = num2 * (widget.maxValue ~/ num2);
        if (num1 < widget.minValue) num1 = num2;
      }

      double correctAnswer;
      switch (operation) {
        case '+':
          correctAnswer = (num1 + num2).toDouble();
          break;
        case '-':
          correctAnswer = (num1 - num2).toDouble();
          break;
        case 'x':
          correctAnswer = (num1 * num2).toDouble();
          break;
        case '/':
          correctAnswer = (num1 / num2).toDouble();
          break;
        default:
          correctAnswer = 0.0;
      }

      bool isCorrect = random.nextBool();
      double displayedAnswer = correctAnswer;
      if (!isCorrect) {
        int offset = random.nextInt(5) + 1;
        displayedAnswer += random.nextBool() ? offset : -offset;
      }

      generatedQuestions.add({
        'num1': num1,
        'num2': num2,
        'operation': operation,
        'isCorrect': isCorrect,
        'displayedAnswer': displayedAnswer,
      });
    }
    return generatedQuestions;
  }

  void checkAnswer(bool userAnswer) {
    bool correct = questions[currentQuestionIndex]['isCorrect'];
    setState(() {
      if (userAnswer == correct) {
        correctCount++;
      } else {
        wrongCount++;
      }

      if (currentQuestionIndex < 9) {
        currentQuestionIndex++;
      } else {
        showResults();
      }
    });
  }

  void showResults() {
    DatabaseHelper().insertSession(correctCount, wrongCount).then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(correct: correctCount, wrong: wrongCount),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Question")),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${currentQuestionIndex + 1} / 10",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface.withAlpha(180),
                  )
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$correctCount",
                  style: TextStyle(fontSize: 28, color: Colors.green),
                ),
                const SizedBox(width: 40),
                Text(
                  "$wrongCount",
                  style: TextStyle(fontSize: 28, color: Colors.red),
                ),
              ],
            ),
            const Spacer(),
            Text(
              "${questions[currentQuestionIndex]['num1']} "
              "${questions[currentQuestionIndex]['operation']} "
              "${questions[currentQuestionIndex]['num2']} = "
              "${formatAnswer(questions[currentQuestionIndex]['displayedAnswer'])}?",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 38),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => checkAnswer(false),
                    child:  CircleAvatar(
                      radius: 40,
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                      child: Icon(Icons.close, size: 40),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => checkAnswer(true),
                    child: const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      child: Icon(Icons.check, size: 40),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

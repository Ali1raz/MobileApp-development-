import 'package:flutter/material.dart';
import 'dart:math';

import 'package:mid_proj/screens/training/quiz_result_screen.dart';

class TrainingTestScreen extends StatefulWidget {
  final List<String> selectedOperations;
  final int minValue;
  final int maxValue;

  const TrainingTestScreen({
    super.key,
    required this.selectedOperations,
    required this.minValue,
    required this.maxValue,
  });

  @override
  _TrainingTestScreenState createState() => _TrainingTestScreenState();
}

class _TrainingTestScreenState extends State<TrainingTestScreen> {
  late List<Map<String, dynamic>> questions;
  int currentQuestionIndex = 0;
  int correctCount = 0;
  int wrongCount = 0;
  int? selectedAnswerIndex;
  bool showFeedback = false;
  late Random random;

  @override
  void initState() {
    super.initState();
    random = Random();
    questions = _generateQuestions();
  }

  List<Map<String, dynamic>> _generateQuestions() {
    return List.generate(10, (index) => _generateQuestion(index));
  }

  Map<String, dynamic> _generateQuestion(int index) {
    final operation =
        widget.selectedOperations[random.nextInt(
          widget.selectedOperations.length,
        )];
    late int num1, num2, correctAnswer;
    String question;

    switch (operation) {
      case '+':
        num1 = _generateRandomNumber();
        num2 = _generateRandomNumber();
        correctAnswer = num1 + num2;
        question = '$num1 + $num2 = ?';
        break;

      case '-':
        num1 = _generateRandomNumber();
        num2 = _generateRandomNumber();
        correctAnswer = num1 - num2;
        question = '$num1 - $num2 = ?';
        break;

      case '×':
        num1 = _generateRandomNumber();
        num2 = _generateRandomNumber();
        correctAnswer = num1 * num2;
        question = '$num1 × $num2 = ?';
        break;

      case '÷':
        num2 = _generateRandomNumber();
        int multiplier = random.nextInt(10) + 1;
        num1 = num2 * multiplier;
        correctAnswer = multiplier;
        question = '$num1 ÷ $num2 = ?';
        break;

      default:
        throw Exception('Invalid operation');
    }

    final options = _generateOptions(correctAnswer);
    return {
      'question': question,
      'correctAnswer': correctAnswer,
      'options': options,
      'userAnswer': null,
      'isCorrect': false,
    };
  }

  List<int> _generateOptions(int correct) {
    final options = <int>{correct};
    while (options.length < 4) {
      final offset = random.nextInt(10) + 1;
      final wrong = correct + (random.nextBool() ? offset : -offset);
      if (wrong != correct) options.add(wrong);
    }
    return options.toList()..shuffle();
  }

  int _generateRandomNumber() {
    return widget.minValue +
        random.nextInt(widget.maxValue - widget.minValue + 1);
  }

  void _handleAnswer(int selectedIndex) {
    final currentQuestion = questions[currentQuestionIndex];
    final isCorrect =
        currentQuestion['options'][selectedIndex] ==
        currentQuestion['correctAnswer'];

    setState(() {
      questions[currentQuestionIndex]['userAnswer'] =
          currentQuestion['options'][selectedIndex];
      questions[currentQuestionIndex]['isCorrect'] = isCorrect;
      selectedAnswerIndex = selectedIndex;
      showFeedback = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (currentQuestionIndex < 9) {
        setState(() {
          currentQuestionIndex++;
          selectedAnswerIndex = null;
          showFeedback = false;
        });
      } else {
        _navigateToResults();
      }
    });
  }

  void _navigateToResults() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => QuizResultScreen(
              questions: questions,
              onRetry:
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => TrainingTestScreen(
                            selectedOperations: widget.selectedOperations,
                            minValue: widget.minValue,
                            maxValue: widget.maxValue,
                          ),
                    ),
                  ),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    var currentQuestion = questions[currentQuestionIndex];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                '${currentQuestionIndex + 1}/10',
                style: const TextStyle(fontSize: 20, color: Colors.grey),
              ),
              const Spacer(),
              Text(
                currentQuestion['question'],
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              GridView.builder(
                shrinkWrap: true,
                itemCount: currentQuestion['options'].length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.2,
                ),
                itemBuilder: (context, index) {
                  int option = currentQuestion['options'][index];
                  bool isCorrect = option == currentQuestion['correctAnswer'];

                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor:
                          showFeedback
                              ? (isCorrect
                                  ? Colors.green
                                  : (index == selectedAnswerIndex
                                      ? Colors.red
                                      : Colors.indigoAccent))
                              : Colors.indigoAccent,
                    ),
                    onPressed: showFeedback ? null : () => _handleAnswer(index),
                    child: Text(
                      option.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

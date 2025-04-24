import 'package:flutter/material.dart';
import 'dart:math';

import 'package:mid_proj/screens/input/input_quiz_result_screen.dart';

class InputTrainingScreen extends StatefulWidget {
  final List<String> selectedOperations;
  final int minValue;
  final int maxValue;

  const InputTrainingScreen({
    super.key,
    required this.selectedOperations,
    required this.minValue,
    required this.maxValue,
  });

  @override
  _InputTrainingScreenState createState() => _InputTrainingScreenState();
}

class _InputTrainingScreenState extends State<InputTrainingScreen> {
  late List<Map<String, dynamic>> questions;
  int currentQuestionIndex = 0;
  late Random random;
  String userAnswer = '';
  List<Map<String, dynamic>> results = [];
  int correctAnswersCount = 0;
  int incorrectAnswersCount = 0;

  @override
  void initState() {
    super.initState();
    random = Random();
    questions = _generateQuestions();
  }

  List<Map<String, dynamic>> _generateQuestions() {
    return List.generate(10, (index) => _generateQuestion());
  }

  Map<String, dynamic> _generateQuestion() {
    final operation =
        widget.selectedOperations[random.nextInt(
          widget.selectedOperations.length,
        )];
    late String question;
    late int correctAnswer;

    // Randomly select which part to hide (0: a, 1: b, 2: result)
    final hiddenPart = random.nextInt(3);

    switch (operation) {
      case '+':
        final a = _generateRandomNumber();
        final b = _generateRandomNumber();
        final result = a + b;
        correctAnswer = [a, b, result][hiddenPart];
        question = _buildQuestionString(hiddenPart, [
          '? + $b = $result',
          '$a + ? = $result',
          '$a + $b = ?',
        ]);
        break;

      case '-':
        var a = _generateRandomNumber();
        var b = _generateRandomNumber();
        // Ensure non-negative results
        if (a < b) {
          final temp = a;
          a = b;
          b = temp;
        }
        final result = a - b;
        correctAnswer = [a, b, result][hiddenPart];
        question = _buildQuestionString(hiddenPart, [
          '? - $b = $result',
          '$a - ? = $result',
          '$a - $b = ?',
        ]);
        break;

      case '×':
        final a = _generateRandomNumber();
        final b = _generateRandomNumber();
        final result = a * b;
        correctAnswer = [a, b, result][hiddenPart];
        question = _buildQuestionString(hiddenPart, [
          '? × $b = $result',
          '$a × ? = $result',
          '$a × $b = ?',
        ]);
        break;

      case '÷':
        final b = _generateRandomNumber(isDivision: true);
        final result = _generateRandomNumber();
        final a = b * result;
        correctAnswer = [a, b, result][hiddenPart];
        question = _buildQuestionString(hiddenPart, [
          '? ÷ $b = $result',
          '$a ÷ ? = $result',
          '$a ÷ $b = ?',
        ]);
        break;

      default:
        throw Exception('Invalid operation');
    }

    return {
      'question': question,
      'correctAnswer': correctAnswer,
      'userAnswer': null,
    };
  }

  String _buildQuestionString(int hiddenPart, List<String> templates) {
    return templates[hiddenPart];
  }

  int _generateRandomNumber({bool isDivision = false}) {
    if (isDivision) {
      // Ensure divisor is never zero
      return widget.minValue +
          random.nextInt(widget.maxValue - widget.minValue + 1) +
          1;
    }
    return widget.minValue +
        random.nextInt(widget.maxValue - widget.minValue + 1);
  }

  void _handleNumberInput(String number) {
    setState(() {
      userAnswer += number;
    });
  }

  void _handleDelete() {
    setState(() {
      if (userAnswer.isNotEmpty) {
        userAnswer = userAnswer.substring(0, userAnswer.length - 1);
      }
    });
  }

  void _submitAnswer() {
    final currentQuestion = questions[currentQuestionIndex];
    final isCorrect = userAnswer == currentQuestion['correctAnswer'].toString();

    setState(() {
      if (isCorrect) {
        correctAnswersCount++;
      } else {
        incorrectAnswersCount++;
      }
    });

    results.add({
      'question': currentQuestion['question'],
      'correctAnswer': currentQuestion['correctAnswer'],
      'userAnswer': userAnswer,
      'isCorrect': isCorrect,
    });

    if (currentQuestionIndex < 9) {
      setState(() {
        currentQuestionIndex++;
        userAnswer = '';
      });
    } else {
      _navigateToResults();
    }
  }

  void _navigateToResults() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => InputQuizResultScreen(
              results: results,
              onRetry:
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => InputTrainingScreen(
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

  Widget _buildNumberButton(String number) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(70, 70),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () => _handleNumberInput(number),
      child: Text(number, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[currentQuestionIndex];

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    '${currentQuestionIndex + 1} / 10',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withAlpha(180),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        correctAnswersCount.toString(),
                        style: textTheme.headlineMedium?.copyWith(
                          color: colorScheme.tertiary,
                        ),
                      ),
                      const SizedBox(width: 44),
                      Text(
                        incorrectAnswersCount.toString(),
                        style: textTheme.headlineMedium?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentQuestion['question'],
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    userAnswer,
                    style: textTheme.displayMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.5,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      for (var i = 1; i <= 9; i++)
                        _buildNumberButton(i.toString()),
                      _buildNumberButton('0'),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.error,
                          foregroundColor: colorScheme.onError,
                        ),
                        onPressed: userAnswer.isNotEmpty ? _handleDelete : null,
                        child: const Icon(Icons.backspace),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor:
                          userAnswer.isNotEmpty
                              ? colorScheme.primary
                              : colorScheme.surface,
                    ),
                    onPressed: userAnswer.isNotEmpty ? _submitAnswer : null,
                    child: Text(
                      'Submit',
                      style: textTheme.titleLarge?.copyWith(
                        color:
                            userAnswer.isNotEmpty
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

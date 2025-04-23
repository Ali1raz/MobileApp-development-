import 'package:flutter/material.dart';
import 'dart:math';

import 'package:mid_proj/screens/quiz/quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final int number;
  final String quizType;

  const QuizScreen({super.key, required this.number, required this.quizType});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, dynamic>> questions = [];
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
    generateQuestions();
  }

  void generateQuestions() {
    questions = [];
    for (int i = 0; i < 10; i++) {
      if (widget.quizType == 'multiplication') {
        int b = random.nextInt(10) + 1;
        int correctAnswer = widget.number * b;
        List<int> options = generateOptions(correctAnswer);
        questions.add({
          'question': '${widget.number} × $b = ?',
          'correctAnswer': correctAnswer,
          'options': options,
        });
      } else {
        int b = random.nextInt(10) + 1;
        int correctAnswer = b;
        int c = widget.number * b;
        List<int> options = generateOptions(correctAnswer);
        questions.add({
          'question': '$c ÷ ${widget.number} = ?',
          'correctAnswer': correctAnswer,
          'options': options,
        });
      }
    }
  }

  List<int> generateOptions(int correct) {
    Set<int> options = {correct};
    while (options.length < 4) {
      int offset = random.nextInt(5) + 1;
      bool add = random.nextBool();
      int wrong = correct + (add ? offset : -offset);
      if (wrong != correct && wrong > 0 && !options.contains(wrong)) {
        options.add(wrong);
      }
    }
    List<int> optionsList = options.toList();
    optionsList.shuffle();
    return optionsList;
  }

  void handleAnswer(int selectedIndex) {
    int correctAnswer = questions[currentQuestionIndex]['correctAnswer'];
    List<int> options = questions[currentQuestionIndex]['options'];
    bool isCorrect = options[selectedIndex] == correctAnswer;

    setState(() {
      selectedAnswerIndex = selectedIndex;
      showFeedback = true;
      if (isCorrect) {
        correctCount++;
      } else {
        wrongCount++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (currentQuestionIndex < 9) {
        setState(() {
          currentQuestionIndex++;
          selectedAnswerIndex = null;
          showFeedback = false;
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => QuizResultScreen(
                  correct: correctCount,
                  wrong: wrongCount,
                  quizType: widget.quizType,
                  number: widget.number,
                ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    var currentQuestion = questions[currentQuestionIndex];
    String question = currentQuestion['question'];
    List<int> options = currentQuestion['options'];
    int correctAnswer = currentQuestion['correctAnswer'];

    return Scaffold(
      // appBar: AppBar(title: Text('${widget.quizType} Quiz - ${widget.number}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              '${currentQuestionIndex + 1}/10',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              question,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ...options.asMap().entries.map((entry) {
              int idx = entry.key;
              int option = entry.value;
              bool isCorrect = option == correctAnswer;
              bool isSelected = idx == selectedAnswerIndex;
              Color? backgroundColor;
              if (showFeedback) {
                backgroundColor =
                    isCorrect ? Colors.green : (isSelected ? Colors.red : null);
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: backgroundColor,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    if (!showFeedback) {
                      handleAnswer(idx);
                    }
                  },
                  child: Text(
                    option.toString(),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

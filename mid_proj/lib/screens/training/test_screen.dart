import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  final int number;
  final String quizType;

  const TestScreen({
    super.key,
    required this.number,
    required this.quizType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$quizType Test for $number'),
      ),
      body: const Center(
        child: Text('Test Screen Content'),
      ),
    );
  }
}

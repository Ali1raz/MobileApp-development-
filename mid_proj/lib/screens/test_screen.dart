import 'package:flutter/material.dart';
import 'package:mid_proj/db/db_helper.dart';
import 'package:mid_proj/screens/question_screen.dart';
import 'package:mid_proj/utils/constants.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  String selectedDifficulty = 'Easy';

  Widget _buildDifficultyOption(String label) {
    final isSelected = selectedDifficulty == label;
    return GestureDetector(
      onTap: () => setState(() => selectedDifficulty = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.inversePrimary
                  : Colors.grey[900],
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = difficultySettings[selectedDifficulty]!;

    return Scaffold(
      appBar: AppBar(title: const Text('Test Mode'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Select Difficulty:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDifficultyOption('Easy'),
                const SizedBox(width: 15),
                _buildDifficultyOption('Medium'),
                const SizedBox(width: 15),
                _buildDifficultyOption('Hard'),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              "Statistics:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            FutureBuilder<Map<String, int>>(
              future: DatabaseHelper().getTotalStats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: const CircularProgressIndicator(
                      strokeWidth: 4,
                      padding: EdgeInsets.all(12),
                    ),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Text('Error loading stats');
                }
                final stats = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Text('Total Tests: ${stats['totalTests']}'),
                    Text(
                      'Correct: ${stats['totalCorrect']}',
                      style: TextStyle(color: Colors.green),
                    ),
                    Text(
                      'Incorrect: ${stats['totalWrong']}',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                );
              },
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  shape: StadiumBorder(),
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                ),
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => QuestionScreen(
                              selectedOperations:
                                  settings['ops']! as List<String>,
                              minValue: settings['min']! as int,
                              maxValue: settings['max']! as int,
                              difficultyLevel: settings['level']! as String,
                            ),
                      ),
                    ),
                child: const Text(
                  "Start Test",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

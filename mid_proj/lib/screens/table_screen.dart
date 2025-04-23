import 'package:flutter/material.dart';
import 'package:mid_proj/screens/quiz/quiz_screen.dart';

class TableScreen extends StatelessWidget {
  final int selectedNumber;

  const TableScreen({super.key, required this.selectedNumber});

  List<Widget> _buildTableRows(BuildContext context) {
    List<Widget> tableRows = [];
    for (int i = 1; i <= 10; i++) {
      tableRows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
          child: Text(
            '$selectedNumber x $i = ${selectedNumber * i}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
      if (i < 10) {
        tableRows.add(const Divider(indent: 40, endIndent: 40, height: 1));
      }
    }
    return tableRows;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table of $selectedNumber'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: ListView(
                shrinkWrap: true,
                children: _buildTableRows(context),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => QuizScreen(
                              number: selectedNumber,
                              quizType: 'multiplication',
                            ),
                      ),
                    );
                  },
                  child: const Text('Start Multiply'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => QuizScreen(
                              number: selectedNumber,
                              quizType: 'division',
                            ),
                      ),
                    );
                  },
                  child: const Text('Start Division'),
                ),
              ],
            ),
          ),
          SizedBox(height: 28,)
        ],
      ),
    );
  }
}

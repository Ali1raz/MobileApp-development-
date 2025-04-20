import 'package:flutter/material.dart';
import 'package:mid_proj/screens/question_screen.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Statistics", style: TextStyle(fontSize: 18)),
            // Other Widgets to show Statistics coming soon ...
            SizedBox(height: 14),
            Text("test Mode"),
            // Other Widgets to choose game mode coming soon ... [easy middle, hard]
            Spacer(),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  shape: StadiumBorder(),
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => QuestionScreen()),
                  );
                },
                child: Text("Start Test", style: TextStyle(fontSize: 18,)),
              ),
            ),
            SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

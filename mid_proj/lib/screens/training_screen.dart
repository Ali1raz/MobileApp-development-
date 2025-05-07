import 'package:flutter/material.dart';
import 'package:mid_proj/screens/input/input_quiz_screen.dart';
import 'package:mid_proj/screens/question_screen.dart';
import 'package:mid_proj/screens/training/test_screen.dart';
import 'package:mid_proj/utils/constants.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  TrainingScreenState createState() => TrainingScreenState();
}

class TrainingScreenState extends State<TrainingScreen> {
  final List<String> selectedOperations = [];
  final TextEditingController min = TextEditingController(text: "1");
  final TextEditingController max = TextEditingController(text: "100");

  late String selectedGameType;

  @override
  void initState() {
    super.initState();
    selectedGameType = gameTypes[1];
  }

  void toggleOperators(String op) {
    setState(() {
      if (selectedOperations.contains(op)) {
        selectedOperations.remove(op);
      } else {
        selectedOperations.add(op);
      }
    });
  }

  void selectGame(String type) {
    setState(() {
      selectedGameType = type;
    });
  }

  bool isValidRange() {
    final left = int.tryParse(min.text);
    final right = int.tryParse(max.text);
    if (left == null || right == null) return false;
    if (left < 0 ||
        right <= 0 ||
        left >= right ||
        left > 1000 ||
        right > 1000) {
      return false;
    }
    return true;
  }

  Widget _buildOperators(String op) {
    final selected = selectedOperations.contains(op);
    return GestureDetector(
      onTap: () => toggleOperators(op),
      child: CircleAvatar(
        radius: 28,
        backgroundColor:
            selected
                ? Theme.of(context).colorScheme.inversePrimary
                : Theme.of(context).colorScheme.surfaceContainer,
        child: Center(
          child: Text(
            op,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildGameOption(String label, IconData icon) {
    final selected = selectedGameType == label;
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => selectGame(label),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor:
                selected
                    ? colorScheme.inversePrimary
                    : colorScheme.surfaceContainer,
            child: Icon(icon, color: colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: colorScheme.onSurface)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Select difficulty'), centerTitle: true),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What would you like to train?",
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: operators.map((op) => _buildOperators(op)).toList(),
            ),
            const SizedBox(height: 32),
            Text(
              "Difficulty max = 1000",
              style: textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNumberBox(min),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text("-", style: TextStyle(fontSize: 12)),
                ),
                _buildNumberBox(max),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGameOption("Test", Icons.hourglass_bottom),
                _buildGameOption("True / False", Icons.cancel),
                _buildGameOption("Input", Icons.dialpad_rounded),
              ],
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.inversePrimary,
                  foregroundColor: colorScheme.onSurface,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 16,
                  ),
                ),
                onPressed: () {
                  if (selectedOperations.isEmpty) {
                    _showMessage("Select operators first");
                  } else if (!isValidRange()) {
                    _showMessage("Valid range: 0 ≤ min < max ≤ 1000");
                  } else {
                    if (selectedGameType == 'True / False') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => QuestionScreen(
                                selectedOperations: selectedOperations,
                                minValue: int.parse(min.text),
                                maxValue: int.parse(max.text),
                                difficultyLevel: 'Training',
                              ),
                        ),
                      );
                    } else if (selectedGameType == 'Test') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => TestScreen(
                                number: int.parse(min.text),
                                quizType: 'Training',
                              ),
                        ),
                      );
                    } else if (selectedGameType == 'Input') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => InputTrainingScreen(
                                selectedOperations: selectedOperations,
                                minValue: int.parse(min.text),
                                maxValue: int.parse(max.text),
                              ),
                        ),
                      );
                    }
                  }
                },
                child: const Text("Start game", style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberBox(TextEditingController controller) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          border: const OutlineInputBorder(),
        ),
        style: TextStyle(color: colorScheme.onSurface, fontSize: 18),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        showCloseIcon: true,
      ),
    );
  }
}

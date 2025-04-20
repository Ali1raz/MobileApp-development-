import 'package:flutter/material.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  TrainingScreenState createState() => TrainingScreenState();
}

class TrainingScreenState extends State<TrainingScreen> {
  final List<String> selectedOperations = [];
  final TextEditingController min = TextEditingController(text: "1");
  final TextEditingController max = TextEditingController(text: "1000");

  final operators = ['+', "-", "x", "/"];
  final gameTypes = ['Test', 'True/False', 'Input'];
  String selectedGameType = 'Input';

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
                : Colors.grey[700],
        child: Center(child: Text(op, style: TextStyle(fontSize: 28))),
      ),
    );
  }

  Widget _buildGameOption(String label, IconData icon) {
    final selected = selectedGameType == label;
    return GestureDetector(
      onTap: () => selectGame(label),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor:
                selected
                    ? Theme.of(context).colorScheme.inversePrimary
                    : Colors.grey[700],
            child: Icon(icon, color: Theme.of(context).colorScheme.onSurface,),
          ),
          SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select difficulty'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What would you like to train?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: operators.map((op) => _buildOperators(op)).toList(),
            ),
            SizedBox(height: 32),
            Text(
              "Difficulty max = 10000",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNumberBox(min),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text("-", style: TextStyle(fontSize: 12)),
                ),
                _buildNumberBox(max),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGameOption("Test", Icons.hourglass_bottom),
                _buildGameOption("True / False", Icons.cancel),
                _buildGameOption("Input", Icons.dialpad_rounded),
              ],
            ),
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
                  if (selectedOperations.isEmpty) {
                    _showMessage("Select operators first");
                  } else if (!isValidRange()) {
                    _showMessage(
                      "Enter valid Range, non-negative, min cant be greater than max, max = 1000",
                    );
                  } else {
                    _showMessage(
                      "Staring Game with: $selectedGameType, $selectedOperations, ${min.text}, ${max.text}",
                    );
                  }
                },
                child: Text(
                  "Start game",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberBox(TextEditingController controller) {
    return Expanded(
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.black26,
          border: OutlineInputBorder(),
        ),
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        showCloseIcon: true,
      ),
    );
  }
}

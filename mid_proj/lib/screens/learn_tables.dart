import 'package:flutter/material.dart';
import 'package:mid_proj/screens/table_screen.dart';

class LearnTables extends StatelessWidget {
  LearnTables({super.key});

  final List<int> _numbers = List.generate(10, (index) => index + 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Table'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: _numbers.length,
        itemBuilder: (context, index) {
          final number = _numbers[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: ListTile(
              title: Text(
                'Multiplication Table for $number',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              trailing: const Icon(Icons.arrow_forward_rounded),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TableScreen(selectedNumber: number),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

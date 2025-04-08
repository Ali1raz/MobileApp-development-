import 'package:flutter/material.dart';

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
      body: Center(
        child: ListView(shrinkWrap: true, children: _buildTableRows(context)),
      ),
    );
  }
}

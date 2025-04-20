import 'package:flutter/material.dart';
import 'package:mid_proj/screens/learn_tables.dart';
import 'package:mid_proj/screens/test_screen.dart';
import 'package:mid_proj/screens/training_screen.dart';

final List<Map<String, dynamic>> routes = [
  {
    'icon': Icons.table_chart,
    'label': 'Learn Tables',
    'route': LearnTables(),
  },
  {'icon': Icons.calculate, 'label': 'Training', 'route': TrainingScreen()},
  {'icon': Icons.edit, 'label': 'Start Test', 'route': TestScreen()},
];
import 'package:flutter/material.dart';
import 'package:mid_proj/screens/learn_tables.dart';
import 'package:mid_proj/screens/test_screen.dart';
import 'package:mid_proj/screens/training_screen.dart';

class MenuItem {
  final String label;
  final IconData icon;
  final Widget route;

  const MenuItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  static final List<MenuItem> items = [
    MenuItem(
      label: 'Learn Tables',
      icon: Icons.school,
      route: LearnTables(),
    ),
    MenuItem(
      label: 'Practice',
      icon: Icons.school_outlined,
      route: const TrainingScreen(),
    ),
    MenuItem(
      label: 'Test',
      icon: Icons.quiz,
      route: const TestScreen(),
    ),
  ];
} 
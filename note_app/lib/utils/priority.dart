import 'package:flutter/material.dart';

enum Priority {
  urgent(color: Colors.red, title: "Urgent"),
  high(color: Colors.orange, title: "High"),
  low(color: Colors.green, title: "Low");

  const Priority({required this.color, required this.title});

  static Priority fromString(String value) {
    switch (value) {
      case "Urgent":
        return Priority.urgent;
      case "High":
        return Priority.high;
      case "Low":
        return Priority.low;
      default:
        return Priority.low;
    }
  }

  final Color color;
  final String title;
}

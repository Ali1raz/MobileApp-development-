

import 'package:note_app/utils/priority.dart';

class Note {
  int? id;
  String? title;
  String? description;
  String? date;
  Priority priority;

  Note({
    this.id,
    this.title,
    this.description,
    this.date,
    required this.priority,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'priority': priority.title,
    };
  }

  factory Note.fromMapObject(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: map['date'],
      priority: Priority.fromString(map['priority']),
    );
  }
}

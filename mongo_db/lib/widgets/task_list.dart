import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task) onTaskToggled;

  const TaskList({super.key, required this.tasks, required this.onTaskToggled});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          child: ListTile(
            leading: Checkbox(
              value: task.completed,
              onChanged: (value) => onTaskToggled(task),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.completed ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text('Priority: ${task.priority}'),
          ),
        );
      },
    );
  }
}

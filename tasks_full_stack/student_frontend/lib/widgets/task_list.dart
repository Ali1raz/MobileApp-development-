import 'package:flutter/material.dart';
import '../models/task.dart';
import 'task_card.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task) onTaskTapped;
  final Future<void> Function() onRefresh;

  const TaskList({
    super.key,
    required this.tasks,
    required this.onTaskTapped,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text('No tasks for this period', style: TextStyle(fontSize: 16)),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return TaskCard(task: tasks[index], onTaskTapped: onTaskTapped);
        },
      ),
    );
  }
}

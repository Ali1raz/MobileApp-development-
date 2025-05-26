import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskListTabView extends StatelessWidget {
  final List<Task> tasks;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final TabController tabController;
  final Widget Function(List<Task>) taskListBuilder;
  final List<Task> Function(int) filterTasksByPeriod;

  const TaskListTabView({
    super.key,
    required this.tasks,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.tabController,
    required this.taskListBuilder,
    required this.filterTasksByPeriod,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }

    return TabBarView(
      controller: tabController,
      children: [
        taskListBuilder(tasks), // All Tasks
        taskListBuilder(filterTasksByPeriod(0)), // Today
        taskListBuilder(filterTasksByPeriod(3)), // 3 Days
      ],
    );
  }
}

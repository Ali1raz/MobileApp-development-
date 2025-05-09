import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../pages/task_details.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task) onTaskToggled;
  final Function(Task) onTaskUpdated;

  const TaskList({
    super.key, 
    required this.tasks, 
    required this.onTaskToggled,
    required this.onTaskUpdated,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM d, y HH:mm').format(date);
  }

  void _showTaskDetails(BuildContext context, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailsPage(
          task: task,
          onTaskUpdated: onTaskUpdated,
        ),
      ),
    );
  }

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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.flag,
                      size: 16,
                      color: task.priority > 0 ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text('Priority: ${task.priority}'),
                  ],
                ),
                if (task.createdAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(task.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: task.completed ? Colors.green.shade100 : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                task.status ?? (task.completed ? 'Completed' : 'Pending'),
                style: TextStyle(
                  color: task.completed ? Colors.green.shade900 : Colors.orange.shade900,
                  fontSize: 12,
                ),
              ),
            ),
            onTap: () => _showTaskDetails(context, task),
          ),
        );
      },
    );
  }
}


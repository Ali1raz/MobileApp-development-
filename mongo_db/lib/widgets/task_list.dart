import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task) onTaskToggled;

  const TaskList({super.key, required this.tasks, required this.onTaskToggled});

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM d, y HH:mm').format(date);
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
              style: TextStyle(
                decoration: task.completed ? TextDecoration.lineThrough : null,
              ),
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
                    'Created: ${_formatDate(task.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (task.updatedAt != null && task.updatedAt != task.createdAt) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Updated: ${_formatDate(task.updatedAt)}',
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
          ),
        );
      },
    );
  }
}

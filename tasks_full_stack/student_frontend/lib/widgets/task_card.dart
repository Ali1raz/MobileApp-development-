import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Function(Task) onTaskTapped;

  const TaskCard({super.key, required this.task, required this.onTaskTapped});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => onTaskTapped(task),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _buildDescription(),
              const SizedBox(height: 8),
              _buildDueDate(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            task.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            task.isCompleted
                ? Colors.green
                : task.isOverdue
                ? Colors.red
                : Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        task.isCompleted
            ? 'Completed'
            : task.isOverdue
            ? 'Overdue'
            : 'Pending',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      task.description,
      style: const TextStyle(fontSize: 14),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDueDate() {
    return Row(
      children: [
        const Icon(Icons.calendar_today, size: 16),
        const SizedBox(width: 8),
        Text(
          'Due: ${DateFormat('MMM dd, yyyy').format(task.dueDate)}',
          style: TextStyle(
            fontSize: 12,
            color: task.isOverdue ? Colors.red : Colors.grey,
          ),
        ),
      ],
    );
  }
}

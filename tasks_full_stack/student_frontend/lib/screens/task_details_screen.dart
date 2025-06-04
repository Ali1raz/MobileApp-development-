import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class TaskDetailsScreen extends StatefulWidget {
  final Task task;
  final Function(Task)? onTaskUpdated;

  const TaskDetailsScreen({super.key, required this.task, this.onTaskUpdated});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late Task _task;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  Future<void> _toggleCompletion() async {
    if (_task.isOverdue) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cannot mark overdue tasks as completed'),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          showCloseIcon: true,
          closeIconColor: Theme.of(context).colorScheme.onErrorContainer,
        ),
      );
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final authService = AuthService();
      final token = await authService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final apiService = ApiService(token: token);
      await apiService.post('student/tasks/${_task.id}/complete', {
        'is_completed': !_task.isCompleted ? 1 : 0,
      });

      setState(() {
        _task = _task.copyWith(isCompleted: !_task.isCompleted);
      });

      if (widget.onTaskUpdated != null) {
        widget.onTaskUpdated!(_task);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task marked as completed'),
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            showCloseIcon: true,
            closeIconColor: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            showCloseIcon: true,
            closeIconColor: Theme.of(context).colorScheme.onErrorContainer,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: const Text('Task Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _task.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _task.isCompleted
                                  ? Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer
                                  : _task.isOverdue
                                  ? Theme.of(context).colorScheme.errorContainer
                                  : Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _task.isCompleted
                              ? 'Completed'
                              : _task.isOverdue
                              ? 'Overdue'
                              : 'Pending',
                          style: TextStyle(
                            color:
                                _task.isCompleted
                                    ? Theme.of(
                                      context,
                                    ).colorScheme.onSecondaryContainer
                                    : _task.isOverdue
                                    ? Theme.of(
                                      context,
                                    ).colorScheme.onErrorContainer
                                    : Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow(
                    icon: Icons.description,
                    title: 'Description',
                    content: _task.description,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.calendar_today,
                    title: 'Due Date',
                    content: _task.dueDate.toString().split(' ')[0],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.access_time,
                    title: 'Created',
                    content: _task.createdAt.toString().split('.')[0],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.update,
                    title: 'Last Updated',
                    content: _task.updatedAt.toString().split('.')[0],
                  ),
                  if (!_task.isOverdue) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            (_isUpdating || _task.isCompleted)
                                ? null
                                : _toggleCompletion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _task.isCompleted
                                  ? Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer
                                  : Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                          foregroundColor:
                              _task.isCompleted
                                  ? Theme.of(
                                    context,
                                  ).colorScheme.onSecondaryContainer
                                  : Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child:
                            _isUpdating
                                ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                )
                                : Text(
                                  _task.isCompleted
                                      ? 'Task marked as completed'
                                      : 'Mark as Completed',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String content,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

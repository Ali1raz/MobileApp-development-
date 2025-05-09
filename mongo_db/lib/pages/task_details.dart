import 'package:flutter/material.dart';
import 'package:mongo_db/models/task.dart';
import 'package:intl/intl.dart';
import '../services/task_service.dart';

class TaskDetailsPage extends StatefulWidget {
  final Task task;
  final Function(Task) onTaskUpdated;

  const TaskDetailsPage({
    super.key, 
    required this.task,
    required this.onTaskUpdated,
  });

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  late Task _task;
  late Task _originalTask;  // Store original task state
  late TextEditingController _titleController;
  late int _priority;
  bool _isEditing = false;
  final TaskService _taskService = TaskService();

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _originalTask = widget.task;  // Store original state
    _titleController = TextEditingController(text: _task.title);
    _priority = _task.priority;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not available';
    return DateFormat('MMMM d, y HH:mm').format(date);
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 0:
        return Colors.grey;
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.deepOrange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _saveChanges() async {
    try {
      final updatedTask = Task(
        id: _task.id,
        title: _titleController.text,
        priority: _priority,
        completed: _task.completed,
      );

      final result = await _taskService.updateTask(updatedTask);
      setState(() {
        _task = result;
        _isEditing = false;
      });
      
      widget.onTaskUpdated(result);  // Notify parent of the update

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double cornerRadius = 16.0;
    const double sectionPadding = 24.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: _isEditing
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'save',
                  onPressed: _saveChanges,
                  child: const Icon(Icons.save),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: 'cancel',
                  onPressed: () => setState(() {
                    _isEditing = false;
                    _task = Task(
                      id: _originalTask.id,
                      title: _originalTask.title,
                      priority: _originalTask.priority,
                      completed: _originalTask.completed,
                    );
                    _titleController.text = _originalTask.title;
                    _priority = _originalTask.priority;
                  }),
                  child: const Icon(Icons.close),
                ),
              ],
            )
          : FloatingActionButton(
              onPressed: () => setState(() => _isEditing = true),
              child: const Icon(Icons.edit),
            ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Timestamps Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),

            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.create,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(_task.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_task.updatedAt != null &&
                    _task.updatedAt != _task.createdAt)
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.update,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(_task.updatedAt),
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child:
                          _isEditing
                              ? TextField(
                                controller: _titleController,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                                decoration: const InputDecoration(
                                  hintText: 'Enter task title',
                                  border: InputBorder.none,
                                ),
                              )
                              : Text(
                                _task.title,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                    ),
                    if (_isEditing)
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: sectionPadding),

          // Priority Section
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: _getPriorityColor(_priority).withOpacity(0.3),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(cornerRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.flag, color: _getPriorityColor(_priority)),
                    const SizedBox(width: 8),
                    Text(
                      'Priority',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    if (_isEditing)
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Set Priority'),
                                  content: DropdownButton<int>(
                                    value: _priority,
                                    items:
                                        List.generate(6, (index) => index).map((
                                          level,
                                        ) {
                                          return DropdownMenuItem(
                                            value: level,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.flag,
                                                  color: _getPriorityColor(
                                                    level,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text('Level $level'),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() => _priority = value);
                                        Navigator.pop(context);
                                      }
                                    },
                                  ),
                                ),
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Level $_priority',
                  style: TextStyle(
                    color: _getPriorityColor(_priority),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: sectionPadding),

          // Status Section
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: _task.completed
                  ? Colors.green.withAlpha(26)  // 0.1 * 255 ≈ 26
                  : Colors.orange.withAlpha(26),
              borderRadius: BorderRadius.circular(cornerRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      _task.completed ? Icons.check_circle : Icons.pending,
                      color: _task.completed ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    if (_isEditing)
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          setState(() {
                            _task = Task(
                              id: _task.id,
                              title: _task.title,
                              priority: _task.priority,
                              completed: !_task.completed,
                            );
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _task.status ??
                          (_task.completed ? 'Completed' : 'Pending'),
                      style: TextStyle(
                        color: _task.completed ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_isEditing) ...[
                      const Spacer(),
                      Switch(
                        value: _task.completed,
                        onChanged: (value) {
                          setState(() {
                            _task = Task(
                              id: _task.id,
                              title: _task.title,
                              priority: _task.priority,
                              completed: value,
                            );
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskForm extends StatefulWidget {
  final Function(Task) onTaskAdded;

  const TaskForm({super.key, required this.onTaskAdded});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  int _priority = 0;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      widget.onTaskAdded(
        Task(title: _titleController.text, priority: _priority),
      );
      _titleController.clear();
      setState(() {
        _priority = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Task Title',
              border: OutlineInputBorder(),
              hintText: 'Enter task title',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              if (value.length > 200) {
                return 'Title cannot be longer than 200 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _priority,
            decoration: const InputDecoration(
              labelText: 'Priority',
              border: OutlineInputBorder(),
            ),
            items:
                List.generate(6, (index) => index).map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text('Priority $priority'),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                _priority = value ?? 0;
              });
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitForm,
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Add Task'),
            ),
          ),
        ],
      ),
    );
  }
}

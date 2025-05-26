import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class EditTaskDialog extends StatefulWidget {
  final Map<String, dynamic> task;

  const EditTaskDialog({super.key, required this.task});

  @override
  State<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;
  List<String> _selectedStudents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.task['title'];
    _descriptionController.text = widget.task['description'] ?? '';
    _dueDate = DateTime.tryParse(widget.task['due_date'] ?? '');
    _selectedStudents =
        (widget.task['students'] as List<dynamic>? ?? [])
            .map((student) => student['registration_number'] as String)
            .toList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final students = auth.students ?? [];

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Edit Task', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Due Date'),
                subtitle: Text(
                  _dueDate != null
                      ? '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}'
                      : 'No due date selected',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  // Calculate the minimum allowed date
                  final DateTime minimumDate =
                      _dueDate != null && _dueDate!.isBefore(DateTime.now())
                          ? _dueDate!
                          : DateTime.now();

                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now(),
                    firstDate: minimumDate, // Allow original due date or today
                    lastDate: DateTime(2030), // Reasonable future date limit
                  );
                  if (date != null) {
                    setState(() => _dueDate = date);
                  }
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Assigned Students',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final isSelected = _selectedStudents.contains(
                      student['registration_number'],
                    );
                    return CheckboxListTile(
                      title: Text(student['name']),
                      subtitle: Text(student['registration_number']),
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedStudents.add(
                              student['registration_number'],
                            );
                          } else {
                            _selectedStudents.remove(
                              student['registration_number'],
                            );
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : () async {
                              if (!_formKey.currentState!.validate()) return;

                              setState(() => _isLoading = true);

                              try {
                                await auth.updateTask(
                                  taskId: widget.task['id'],
                                  title: _titleController.text,
                                  description: _descriptionController.text,
                                  dueDate:
                                      _dueDate != null
                                          ? '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}'
                                          : null,
                                  registrationNumbers: _selectedStudents,
                                );

                                if (mounted) {
                                  Navigator.pop(context, true);
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error updating task: $e'),
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() => _isLoading = false);
                                }
                              }
                            },
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Update'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

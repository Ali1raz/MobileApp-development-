import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      await auth.fetchTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading tasks: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _fetchTasks,
                child:
                    auth.tasks != null && auth.tasks!.isNotEmpty
                        ? ListView.builder(
                          itemCount: auth.tasks!.length,
                          itemBuilder: (context, index) {
                            final task = auth.tasks![index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ExpansionTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getStatusColor(
                                    task['status'] ?? 'pending',
                                  ),
                                  child: Icon(
                                    _getStatusIcon(task['status'] ?? 'pending'),
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(task['title'] ?? ''),
                                subtitle: Text(
                                  'Due: ${task['due_date'] ?? 'No due date'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Description:',
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          task['description'] ??
                                              'No description',
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Assigned Students:',
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 8),
                                        if (task['assigned_students'] != null &&
                                            task['assigned_students']
                                                .isNotEmpty)
                                          ...task['assigned_students']
                                              .map<Widget>(
                                                (student) => ListTile(
                                                  dense: true,
                                                  leading: const Icon(
                                                    Icons.person,
                                                  ),
                                                  title: Text(
                                                    student['name'] ?? '',
                                                  ),
                                                  subtitle: Text(
                                                    student['email'] ?? '',
                                                  ),
                                                ),
                                              )
                                        else
                                          const Text('No students assigned'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                        : const Center(child: Text('No tasks found')),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Show add task dialog
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'in_progress':
        return Icons.work;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }
}

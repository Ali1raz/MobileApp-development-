import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/create_task_dialog.dart';

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
                            final students =
                                task['students'] as List<dynamic>? ?? [];
                            final completedCount =
                                students
                                    .where(
                                      (student) =>
                                          student['pivot']?['is_completed'] ==
                                          1,
                                    )
                                    .length;
                            final totalStudents = students.length;

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ExpansionTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getStatusColor(
                                    task['is_completed'] == 1
                                        ? 'completed'
                                        : 'pending',
                                  ),
                                  child: Icon(
                                    _getStatusIcon(
                                      task['is_completed'] == 1
                                          ? 'completed'
                                          : 'pending',
                                    ),
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(task['title'] ?? ''),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Due: ${task['due_date'] ?? 'No due date'}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    LinearProgressIndicator(
                                      value:
                                          totalStudents > 0
                                              ? completedCount / totalStudents
                                              : 0,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        completedCount == totalStudents
                                            ? Colors.green
                                            : Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Progress: $completedCount/$totalStudents completed',
                                      style: TextStyle(
                                        color:
                                            completedCount == totalStudents
                                                ? Colors.green
                                                : Colors.blue,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
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
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Assigned Students:',
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.titleMedium,
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    completedCount ==
                                                            totalStudents
                                                        ? Colors.green
                                                            .withOpacity(0.1)
                                                        : Colors.blue
                                                            .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                '$completedCount/$totalStudents completed',
                                                style: TextStyle(
                                                  color:
                                                      completedCount ==
                                                              totalStudents
                                                          ? Colors.green
                                                          : Colors.blue,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        if (students.isNotEmpty)
                                          ...students.map<Widget>(
                                            (student) => Card(
                                              margin: const EdgeInsets.only(
                                                bottom: 8,
                                              ),
                                              child: ListTile(
                                                leading: CircleAvatar(
                                                  backgroundColor:
                                                      student['pivot']?['is_completed'] ==
                                                              1
                                                          ? Colors.green
                                                          : Colors.grey,
                                                  child: Icon(
                                                    student['pivot']?['is_completed'] ==
                                                            1
                                                        ? Icons.check
                                                        : Icons.person,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                title: Text(
                                                  student['name'] ?? '',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        student['pivot']?['is_completed'] ==
                                                                1
                                                            ? Colors.green
                                                            : null,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  student['registration_number'] ??
                                                      '',
                                                ),
                                                trailing:
                                                    student['pivot']?['is_completed'] ==
                                                            1
                                                        ? const Chip(
                                                          label: Text(
                                                            'Completed',
                                                          ),
                                                          backgroundColor:
                                                              Colors.green,
                                                          labelStyle: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        )
                                                        : const Chip(
                                                          label: Text(
                                                            'Pending',
                                                          ),
                                                          backgroundColor:
                                                              Colors.orange,
                                                          labelStyle: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
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
        onPressed: () async {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          try {
            await auth.studentService.fetchStudents();
            if (mounted) {
              showDialog(
                context: context,
                builder: (context) => const CreateTaskDialog(),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error loading students: $e')),
              );
            }
          }
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

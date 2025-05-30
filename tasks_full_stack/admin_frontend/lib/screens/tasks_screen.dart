import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/create_task_dialog.dart';
import '../screens/task_details_screen.dart';
import '../widgets/search_text_field.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool _isLoading = true;
  String _searchTitle = '';
  DateTime? _filterDueDate;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleUnfocus() {
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }
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

  List<Map<String, dynamic>> _getFilteredTasks(
    List<Map<String, dynamic>> tasks,
  ) {
    return tasks.where((task) {
      final matchesTitle = task['title'].toString().toLowerCase().contains(
        _searchTitle.toLowerCase(),
      );
      final matchesDueDate =
          _filterDueDate == null ||
          (task['due_date'] != null &&
              DateTime.parse(
                    task['due_date'],
                  ).toLocal().toString().split(' ')[0] ==
                  _filterDueDate!.toLocal().toString().split(' ')[0]);
      return matchesTitle && matchesDueDate;
    }).toList();
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

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return GestureDetector(
      onTap: _handleUnfocus,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: SearchTextField(
                      hintText: 'Search by title...',
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: (value) {
                        setState(() {
                          _searchTitle = value;
                        });
                      },
                      onClear: () {
                        setState(() {
                          _searchTitle = '';
                        });
                        _handleUnfocus();
                      },
                      onSubmitted: (_) => _handleUnfocus(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _filterDueDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setState(() {
                          _filterDueDate = date;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color:
                                _filterDueDate != null
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                          ),
                          if (_filterDueDate != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${_filterDueDate!.day}/${_filterDueDate!.month}/${_filterDueDate!.year}',
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _filterDueDate = null;
                                });
                              },
                              child: const Icon(Icons.close, size: 16),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                        onRefresh: _fetchTasks,
                        child:
                            auth.tasks != null && auth.tasks!.isNotEmpty
                                ? Builder(
                                  builder: (context) {
                                    final filteredTasks = _getFilteredTasks(
                                      auth.tasks!,
                                    );
                                    return filteredTasks.isEmpty
                                        ? const Center(
                                          child: Text(
                                            'No matching tasks found',
                                          ),
                                        )
                                        : ListView.builder(
                                          itemCount: filteredTasks.length,
                                          itemBuilder: (context, index) {
                                            final task = filteredTasks[index];
                                            final students =
                                                task['students']
                                                    as List<dynamic>? ??
                                                [];
                                            final completedCount =
                                                students
                                                    .where(
                                                      (student) =>
                                                          student['pivot']?['is_completed'] ==
                                                          1,
                                                    )
                                                    .length;
                                            final totalStudents =
                                                students.length;

                                            return Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Colors.grey
                                                      .withOpacity(0.2),
                                                ),
                                              ),
                                              child: InkWell(
                                                onTap: () async {
                                                  final result =
                                                      await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder:
                                                              (context) =>
                                                                  TaskDetailsScreen(
                                                                    task: task,
                                                                  ),
                                                        ),
                                                      );
                                                  if (result == true &&
                                                      mounted) {
                                                    await _fetchTasks();
                                                  }
                                                },
                                                child: ExpansionTile(
                                                  leading: CircleAvatar(
                                                    backgroundColor:
                                                        _getStatusColor(
                                                          task['status'] ??
                                                              'pending',
                                                        ),
                                                    child: Icon(
                                                      _getStatusIcon(
                                                        task['status'] ??
                                                            'pending',
                                                      ),
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  title: Text(
                                                    task['title'] ?? '',
                                                  ),
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const SizedBox(height: 4),
                                                      LinearProgressIndicator(
                                                        value:
                                                            totalStudents > 0
                                                                ? completedCount /
                                                                    totalStudents
                                                                : 0,
                                                        backgroundColor: Colors
                                                            .grey
                                                            .withOpacity(0.2),
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                              Color
                                                            >(
                                                              completedCount ==
                                                                      totalStudents
                                                                  ? Colors.green
                                                                  : Colors.blue,
                                                            ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        'Due Date: ${task['due_date'] != null ? DateTime.parse(task['due_date']).toLocal().toString().split(' ')[0] : 'No due date'}',
                                                        style: TextStyle(
                                                          color:
                                                              task['due_date'] !=
                                                                          null &&
                                                                      DateTime.parse(
                                                                        task['due_date'],
                                                                      ).isBefore(
                                                                        DateTime.now(),
                                                                      )
                                                                  ? Colors.red
                                                                  : null,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            16.0,
                                                          ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Description:',
                                                            style:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .textTheme
                                                                    .titleMedium,
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          Text(
                                                            task['description'] ??
                                                                'No description',
                                                          ),
                                                          const SizedBox(
                                                            height: 16,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                'Assigned Students:',
                                                                style:
                                                                    Theme.of(
                                                                          context,
                                                                        )
                                                                        .textTheme
                                                                        .titleMedium,
                                                              ),
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          8,
                                                                      vertical:
                                                                          4,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  color:
                                                                      completedCount ==
                                                                              totalStudents
                                                                          ? Colors.green.withOpacity(
                                                                            0.1,
                                                                          )
                                                                          : Colors.blue.withOpacity(
                                                                            0.1,
                                                                          ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        12,
                                                                      ),
                                                                ),
                                                                child: Text(
                                                                  '$completedCount/$totalStudents completed',
                                                                  style: TextStyle(
                                                                    color:
                                                                        completedCount ==
                                                                                totalStudents
                                                                            ? Colors.green
                                                                            : Colors.blue,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          if (students
                                                              .isNotEmpty)
                                                            ...students.map<
                                                              Widget
                                                            >(
                                                              (
                                                                student,
                                                              ) => Container(
                                                                margin:
                                                                    const EdgeInsets.only(
                                                                      bottom: 8,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8,
                                                                      ),
                                                                  border: Border.all(
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                          0.2,
                                                                        ),
                                                                  ),
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
                                                                          ? Icons
                                                                              .check
                                                                          : Icons
                                                                              .person,
                                                                      color:
                                                                          Colors
                                                                              .white,
                                                                    ),
                                                                  ),
                                                                  title: Text(
                                                                    student['name'] ??
                                                                        '',
                                                                    style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
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
                                                                ),
                                                              ),
                                                            )
                                                          else
                                                            const Text(
                                                              'No students assigned',
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                  },
                                )
                                : const Center(child: Text('No tasks found')),
                      ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final auth = Provider.of<AuthProvider>(context, listen: false);
            try {
              await auth.studentService.fetchStudents();
              if (mounted) {
                final result = await showDialog(
                  context: context,
                  builder: (context) => const CreateTaskDialog(),
                );
                if (result == true && mounted) {
                  await _fetchTasks();
                }
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'models/task.dart';
import 'services/task_service.dart';
import 'widgets/task_form.dart';
import 'widgets/task_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalTasks = 0;
  bool? _filterCompleted;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      final isOnline = result != ConnectivityResult.none;
      if (isOnline && !_isOnline) {
        // Connection restored, sync offline changes
        _syncOfflineChanges();
      }
      setState(() {
        _isOnline = isOnline;
      });
    });
  }

  Future<void> _syncOfflineChanges() async {
    try {
      await _taskService.syncOfflineChanges();
      _loadTasks(); // Reload tasks after sync
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sync failed: ${e.toString()}')));
      }
    }
  }

  Future<void> _loadTasks() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final result = await _taskService.getTasks(
        page: _currentPage,
        completed: _filterCompleted,
      );
      setState(() {
        _tasks = result['tasks'] as List<Task>;
        _currentPage = result['currentPage'] as int;
        _totalPages = result['totalPages'] as int;
        _totalTasks = result['totalTasks'] as int;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addTask(Task task) async {
    try {
      setState(() {
        _error = null;
      });
      final newTask = await _taskService.createTask(task);
      setState(() {
        _tasks.insert(0, newTask);
        _totalTasks++;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task added successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Future<void> _toggleTask(Task task) async {
    try {
      setState(() {
        _error = null;
      });
      final updatedTask = Task(
        id: task.id,
        title: task.title,
        priority: task.priority,
        completed: !task.completed,
      );
      final result = await _taskService.updateTask(updatedTask);
      setState(() {
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = result;
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  void _setFilter(bool? completed) {
    setState(() {
      _filterCompleted = completed;
      _currentPage = 1;
    });
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Task Manager"),
        actions: [
          if (!_isOnline)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.cloud_off, color: Colors.red),
            ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTasks),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                color: Colors.red.shade100,
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _error = null),
                    ),
                  ],
                ),
              ),
            TaskForm(onTaskAdded: _addTask),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DropdownButton<bool?>(
                  value: _filterCompleted,
                  hint: const Text('Filter'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All')),
                    DropdownMenuItem(value: false, child: Text('Pending')),
                    DropdownMenuItem(value: true, child: Text('Completed')),
                  ],
                  onChanged: _setFilter,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Showing ${_tasks.length} of $_totalTasks tasks (Page $_currentPage of $_totalPages)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                        children: [
                          Expanded(
                            child: TaskList(
                              tasks: _tasks,
                              onTaskToggled: _toggleTask,
                              onTaskUpdated: (updatedTask) {
                                setState(() {
                                  final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
                                  if (index != -1) {
                                    _tasks[index] = updatedTask;
                                  }
                                });
                              },
                            ),
                          ),
                          if (_totalPages > 1)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left),
                                    onPressed:
                                        _currentPage > 1
                                            ? () {
                                              setState(() => _currentPage--);
                                              _loadTasks();
                                            }
                                            : null,
                                  ),
                                  Text('Page $_currentPage of $_totalPages'),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    onPressed:
                                        _currentPage < _totalPages
                                            ? () {
                                              setState(() => _currentPage++);
                                              _loadTasks();
                                            }
                                            : null,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

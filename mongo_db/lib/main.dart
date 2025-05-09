import 'package:flutter/material.dart';
import 'models/task.dart';
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
  final List<Task> _tasks = [
    Task(title: 'Complete project documentation', priority: 3),
    Task(title: 'Review pull requests', priority: 2, completed: true),
    Task(title: 'Update dependencies', priority: 1),
    Task(title: 'Fix UI bugs', priority: 4),
    Task(title: 'Write unit tests', priority: 2),
  ];

  void _addTask(Task task) {
    setState(() {
      _tasks.add(task);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Task added successfully')));
  }

  void _toggleTask(Task task) {
    setState(() {
      task.completed = !task.completed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Task Manager"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TaskForm(onTaskAdded: _addTask),
            const SizedBox(height: 24),
            Expanded(
              child: TaskList(tasks: _tasks, onTaskToggled: _toggleTask),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'services/theme_service.dart';
import 'screens/profile_screen.dart';
import 'screens/task_details_screen.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'models/task.dart';
import 'constants/app_constants.dart';
import 'widgets/task_list.dart';
import 'widgets/task_list_tab_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  final _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final themeMode = await _themeService.getThemeMode();
    setState(() {
      _themeMode = themeMode;
    });
  }

  void setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    _themeService.setThemeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ).copyWith(surface: Colors.grey[900]),
      ),
      themeMode: _themeMode,
      initialRoute: AppConstants.loginRoute,
      routes: {
        AppConstants.loginRoute: (context) => const LoginScreen(),
        AppConstants.homeRoute: (context) => const MyHomePage(),
        AppConstants.profileRoute: (context) => const ProfileScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  List<Task> _tasks = [];
  bool _isLoading = true;
  String? _errorMessage;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final apiService = ApiService(token: token);
      final response = await apiService.get('student/tasks');

      if (mounted) {
        setState(() {
          _tasks =
              (response['tasks'] as List)
                  .map((task) => Task.fromJson(task))
                  .toList();
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  List<Task> _filterTasksByPeriod(int periodInDays) {
    final now = DateTime.now();
    return _tasks.where((task) {
      final dueDate = task.dueDate;
      final difference = dueDate.difference(now).inDays;

      switch (periodInDays) {
        case 0: // Today
          return dueDate.year == now.year &&
              dueDate.month == now.month &&
              dueDate.day == now.day;
        case 3: // Next 3 days
          return difference >= 0 && difference <= 3;
        default:
          return false;
      }
    }).toList();
  }

  Future<void> _onTaskTapped(Task task) async {
    final updatedTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                TaskDetailsScreen(task: task, onTaskUpdated: _updateTask),
      ),
    );

    if (updatedTask != null) {
      _updateTask(updatedTask);
    }
  }

  void _updateTask(Task updatedTask) {
    setState(() {
      final taskIndex = _tasks.indexWhere((t) => t.id == updatedTask.id);
      if (taskIndex != -1) {
        _tasks[taskIndex] = updatedTask;
      }
    });
  }

  void _navigateToProfile() {
    Navigator.pushNamed(context, AppConstants.profileRoute);
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: const Text("Student Dashboard"),
      actions: [
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: _navigateToProfile,
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'All Tasks'),
          Tab(text: 'Today'),
          Tab(text: 'in 3 Days'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: TaskListTabView(
        tasks: _tasks,
        isLoading: _isLoading,
        errorMessage: _errorMessage,
        onRetry: _loadTasks,
        tabController: _tabController,
        filterTasksByPeriod: _filterTasksByPeriod,
        taskListBuilder:
            (tasks) => TaskList(
              tasks: tasks,
              onTaskTapped: _onTaskTapped,
              onRefresh: _loadTasks,
            ),
      ),
    );
  }
}

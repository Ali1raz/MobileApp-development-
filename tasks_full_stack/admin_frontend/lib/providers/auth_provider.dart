import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/student_service.dart';
import '../services/task_service.dart';
import '../services/user_service.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  static const String _baseUrl = 'http://192.168.213.66:8000/api';
  String? _token;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _dashboardData;
  List<Map<String, dynamic>>? _tasks;
  bool _isLoading = false;
  bool _isInitialized = false;

  late ApiService api;
  late UserService _userService;
  late StudentService _studentService;
  late TaskService _taskService;

  bool get isAuthenticated => _token != null;
  bool get isInitialized => _isInitialized;
  String? get token => _token;
  Map<String, dynamic>? get userData => _userData;
  Map<String, dynamic>? get dashboardData => _dashboardData;
  List<Map<String, dynamic>>? get tasks => _tasks;
  bool get isLoading => _isLoading;
  StudentService get studentService => _studentService;
  List<Map<String, dynamic>>? get students => _studentService.students;

  AuthProvider() {
    _initializeServices();
    initAuth();
  }

  void _initializeServices() {
    api = ApiService(token: _token);
    _userService = UserService(_token);
    _studentService = StudentService(_token);
    _taskService = TaskService(_token);
  }

  Future<void> initAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      final userDataStr = prefs.getString('userData');

      if (_token != null && userDataStr != null) {
        _userData = json.decode(userDataStr);
        _initializeServices();

        try {
          // Fetch initial data in parallel
          await Future.wait([fetchUserData(), fetchDashboardData()]);
        } catch (e) {
          print('Error during initial data fetch: $e');
          await logout();
        }
      } else {
        await logout();
      }
    } catch (e) {
      print('Error during auth initialization: $e');
      await logout();
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      _token = token;
      _initializeServices();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to save authentication token');
    }
  }

  Future<void> login(String email, String password) async {
    if (isAuthenticated) {
      throw Exception('Already logged in');
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _userService.login(email, password);
      await _saveToken(response['token']);
      _userData = response['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userData', json.encode(_userData));

      // Initialize services with new token
      _initializeServices();

      // Fetch initial data
      await Future.wait([fetchUserData(), fetchDashboardData()]);
    } catch (e) {
      // If anything fails during login, ensure we're logged out
      await logout();
      throw Exception(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserData() async {
    if (_token == null) return;

    try {
      _userData = await _userService.fetchUserData();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userData', json.encode(_userData));
      notifyListeners();
    } catch (e) {
      if (e.toString().contains('Session expired')) {
        await logout();
      }
      throw Exception('Failed to fetch user data: $e');
    }
  }

  Future<void> fetchDashboardData() async {
    if (_token == null) return;

    try {
      final data = await _userService.fetchDashboardData();

      _dashboardData = data;
      notifyListeners();
    } catch (e) {
      print('Error fetching dashboard data: $e');
      if (e.toString().contains('Session expired')) {
        await logout();
      }
      throw Exception('Failed to fetch dashboard data: $e');
    }
  }

  Future<void> updateProfile(
    String name,
    String email,
    String? password,
  ) async {
    if (_token == null) {
      throw Exception('Not authenticated');
    }

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/admin/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          if (password != null) 'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _userData = data['user'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userData', json.encode(_userData));
        notifyListeners();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      if (e.toString().contains('Unauthenticated')) {
        await logout();
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      // First try to call the logout API
      await _userService.logout();
    } catch (e) {
      rethrow;
    } finally {
      // Always clear local data, even if the API call fails
      _token = null;
      _userData = null;
      _dashboardData = null;
      _tasks = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('userData');

      _initializeServices();
      _studentService.clear();
      notifyListeners();
    }
  }

  // Task-related methods
  Future<void> fetchTasks() async {
    if (_token == null) throw Exception('Not authenticated');
    try {
      await _taskService.fetchTasks();
      _tasks = _taskService.tasks;
      notifyListeners();
    } catch (e) {
      if (e.toString().contains('Session expired')) {
        await logout();
      }
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  Future<Map<String, dynamic>> createTask({
    required String title,
    required String description,
    required String dueDate,
    required List<String> registrationNumbers,
  }) async {
    if (_token == null) throw Exception('Not authenticated');
    try {
      final response = await _taskService.createTask(
        title: title,
        description: description,
        dueDate: dueDate,
        registrationNumbers: registrationNumbers,
      );
      await fetchTasks();
      await fetchDashboardData();
      return response;
    } catch (e) {
      if (e.toString().contains('Session expired')) {
        await logout();
      }
      throw Exception('Failed to create task: $e');
    }
  }

  Future<Map<String, dynamic>> updateTask({
    required int taskId,
    String? title,
    String? description,
    String? dueDate,
    List<String>? registrationNumbers,
  }) async {
    if (_token == null) throw Exception('Not authenticated');
    try {
      final response = await _taskService.updateTask(
        taskId: taskId,
        title: title,
        description: description,
        dueDate: dueDate,
        registrationNumbers: registrationNumbers,
      );
      await fetchTasks();
      await fetchDashboardData();
      return response;
    } catch (e) {
      if (e.toString().contains('Session expired')) {
        await logout();
      }
      throw Exception('Failed to update task: $e');
    }
  }

  Future<Map<String, dynamic>> getTaskProgress(int taskId) async {
    if (_token == null) throw Exception('Not authenticated');
    try {
      return await _taskService.getTaskProgress(taskId);
    } catch (e) {
      if (e.toString().contains('Session expired')) {
        await logout();
      }
      throw Exception('Failed to get task progress: $e');
    }
  }

  Future<void> deleteTask(int taskId) async {
    if (_token == null) throw Exception('Not authenticated');
    try {
      await _taskService.deleteTask(taskId);
      await fetchTasks();
      await fetchDashboardData();
    } catch (e) {
      if (e.toString().contains('Session expired')) {
        await logout();
      }
      throw Exception('Failed to delete task: $e');
    }
  }

  Future<Map<String, dynamic>> registerStudent({
    required String name,
    required String email,
  }) async {
    if (_token == null) throw Exception('Not authenticated');
    try {
      final response = await _studentService.registerStudent(
        name: name,
        email: email,
      );
      await fetchDashboardData();
      return response;
    } catch (e) {
      if (e.toString().contains('Session expired')) {
        await logout();
      }
      throw Exception('Failed to register student: $e');
    }
  }

  Future<Map<String, dynamic>> changeStudentPassword(
    String registrationNumber,
    String password,
  ) async {
    if (_token == null) throw Exception('Not authenticated');
    try {
      final response = await _studentService.changeStudentPassword(
        registrationNumber,
        password,
      );
      return response;
    } catch (e) {
      if (e.toString().contains('Session expired')) {
        await logout();
      }
      throw Exception('Failed to change student password: $e');
    }
  }
}

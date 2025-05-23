import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/student_service.dart';
import '../services/task_service.dart';
import '../services/user_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _dashboardData;
  List<Map<String, dynamic>>? _students;
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
  List<Map<String, dynamic>>? get students => _students;
  List<Map<String, dynamic>>? get tasks => _tasks;
  bool get isLoading => _isLoading;

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
          await fetchUserData();
          await fetchDashboardData();
        } catch (e) {
          await logout();
        }
      } else {
        await logout();
      }
    } catch (e) {
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

      await fetchDashboardData();
    } catch (e) {
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
      _dashboardData = await _userService.fetchDashboardData();
      notifyListeners();
    } catch (e) {
      if (e.toString().contains('Session expired')) {
        await logout();
      }
      throw Exception('Failed to fetch dashboard data: $e');
    }
  }

  Future<void> updateProfile(String name, String email) async {
    if (_token == null) throw Exception('Not authenticated');

    try {
      _userData = await _userService.updateProfile(name, email);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userData', json.encode(_userData));
      notifyListeners();
    } catch (e) {
      if (e.toString().contains('Session expired')) {
        await logout();
      }
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> logout() async {
    try {
      _token = null;
      _userData = null;
      _dashboardData = null;
      _students = null;
      _tasks = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('userData');

      _initializeServices();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to logout properly');
    }
  }

  Future<void> fetchStudents() async {
    if (_token == null) throw Exception('Not authenticated');
    try {
      _students = await _studentService.getStudents();
      notifyListeners();
    } catch (e) {
      if (e.toString().contains('Session expired')) {
        await logout();
      }
      rethrow;
    }
  }

  Future<void> fetchTasks() async {
    if (_token == null) throw Exception('Not authenticated');
    try {
      _tasks = await _taskService.getTasks();
      notifyListeners();
    } catch (e) {
      if (e.toString().contains('Session expired')) {
        await logout();
      }
      throw Exception('Failed to fetch tasks: $e');
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
      // Refresh students list after adding new student
      await fetchStudents();
      return response;
    } catch (e) {
      if (e.toString().contains('Session expired')) {
        await logout();
      }
      throw Exception('Failed to register student: $e');
    }
  }
}

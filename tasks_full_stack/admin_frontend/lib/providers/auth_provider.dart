import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _dashboardData;
  List<Map<String, dynamic>>? _students;
  List<Map<String, dynamic>>? _tasks;
  bool _isLoading = false;

  bool get isAuthenticated => _token != null;
  String? get token => _token;
  Map<String, dynamic>? get userData => _userData;
  Map<String, dynamic>? get dashboardData => _dashboardData;
  List<Map<String, dynamic>>? get students => _students;
  List<Map<String, dynamic>>? get tasks => _tasks;
  bool get isLoading => _isLoading;

  static const String baseUrl =
      'http://192.168.137.99:8000/api'; //replace with machine ip

  AuthProvider() {
    initAuth();
    debugPrint("AuthProvider initialized");
  }

  Future<void> initAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      final userDataStr = prefs.getString('userData');

      if (_token != null && userDataStr != null) {
        _userData = json.decode(userDataStr);
        // Verify token is still valid
        try {
          await fetchUserData();
          await fetchDashboardData();
        } catch (e) {
          // If token is invalid, clear everything
          await logout();
        }
      } else {
        await logout();
      }
      notifyListeners();
    } catch (e) {
      await logout();
    }
  }

  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      _token = token;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to save authentication token');
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/login'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'email': email, 'password': password}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        await _saveToken(data['token']);
        await fetchUserData();
        await fetchDashboardData();
      } else {
        throw data['message'] ?? 'Login failed';
      }
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
      final response = await http.get(
        Uri.parse('$baseUrl/admin/profile'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        _userData = data;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userData', json.encode(_userData));
        notifyListeners();
      } else {
        throw data['message'] ?? 'Failed to fetch user data';
      }
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
  }

  Future<void> fetchDashboardData() async {
    if (_token == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/dashboard'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        _dashboardData = data;
        notifyListeners();
      } else {
        throw data['message'] ?? 'Failed to fetch dashboard data';
      }
    } catch (e) {
      throw Exception('Failed to fetch dashboard data: $e');
    }
  }

  Future<void> updateProfile(String name, String email) async {
    if (_token == null) throw Exception('Not authenticated');

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/profile'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({'name': name, 'email': email}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        _userData = data;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userData', json.encode(_userData));
        notifyListeners();
      } else {
        throw data['message'] ?? 'Failed to update profile';
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> logout() async {
    try {
      _token = null;
      _userData = null;
      _dashboardData = null;

      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('userData');

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to logout properly');
    }
  }

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final userDataStr = prefs.getString('userData');
    if (userDataStr != null) {
      _userData = json.decode(userDataStr);
    }
    notifyListeners();
  }

  Future<void> fetchStudents() async {
    if (_token == null) throw Exception('Not authenticated');

    try {
      debugPrint('Token: $_token');
      debugPrint('Fetching students from: $baseUrl/admin/students');

      final response = await http.get(
        Uri.parse('$baseUrl/admin/students'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response headers: ${response.headers}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Decoded data: $data');

        if (data['success'] == true) {
          if (data['students'] != null) {
            _students = List<Map<String, dynamic>>.from(data['students']);
            debugPrint('Parsed students: $_students');
            notifyListeners();
          } else {
            throw Exception('No students data in response');
          }
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch students');
        }
      } else if (response.statusCode == 401) {
        await logout();
        throw Exception('Session expired. Please login again.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ??
              'Failed to fetch students (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('Error fetching students: $e');
      throw Exception('Failed to fetch students: $e');
    }
  }

  Future<void> fetchTasks() async {
    if (_token == null) throw Exception('Not authenticated');

    try {
      debugPrint('Fetching tasks...');
      final response = await http.get(
        Uri.parse('$baseUrl/admin/tasks'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _tasks = List<Map<String, dynamic>>.from(data['tasks']);
          notifyListeners();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch tasks');
        }
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        await logout();
        throw Exception('Session expired. Please login again.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch tasks');
      }
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
      throw Exception('Failed to fetch tasks: $e');
    }
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;

  bool get isAuthenticated => _token != null;
  String? get token => _token;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;

  static const String baseUrl = 'http://192.168.213.66:8000/api';

  AuthProvider() {
    initAuth();
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
          await _fetchUserData();
        } catch (e) {
          // If token is invalid, clear everything
          await logout();
        }
      } else {
        await logout();
      }
      notifyListeners();
    } catch (e) {
      print('Error initializing auth: $e');
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
      print('Error saving token: $e');
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
        await _fetchUserData();
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

  Future<void> _fetchUserData() async {
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
      print('Error fetching user data: $e');
      throw Exception('Failed to fetch user data: $e');
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

      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('userData');

      notifyListeners();
    } catch (e) {
      print('Error during logout: $e');
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
}

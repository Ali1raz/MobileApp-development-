import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  static const int _sessionDurationInSeconds = 3600; // 1 hour in seconds

  AuthService() : _apiService = ApiService();

  Future<Map<String, dynamic>> login(
    String registrationNumber,
    String password,
  ) async {
    try {
      final data = await _apiService.post(AppConstants.loginEndpoint, {
        'registration_number': registrationNumber,
        'password': password,
      });

      // Store the token, user data, and session start time
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, data['token']);
      await prefs.setString(AppConstants.userKey, jsonEncode(data['user']));
      await prefs.setInt(
        'session_start_time',
        DateTime.now().millisecondsSinceEpoch,
      );
      return data;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);

      if (token != null) {
        final apiService = ApiService(token: token);
        await apiService.post(AppConstants.logoutEndpoint, {});
      }

      // Clear stored data
      await prefs.remove(AppConstants.tokenKey);
      await prefs.remove(AppConstants.userKey);
      await prefs.remove('session_start_time');
    } catch (e) {
      // Even if the API call fails, we still want to clear local data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.tokenKey);
      await prefs.remove(AppConstants.userKey);
      await prefs.remove('session_start_time');
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final sessionStartTime = prefs.getInt('session_start_time');

    if (token == null || sessionStartTime == null) {
      return false;
    }

    // Check if session has expired
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final sessionAge =
        (currentTime - sessionStartTime) ~/ 1000; // Convert to seconds

    if (sessionAge >= _sessionDurationInSeconds) {
      // Session expired, clear the data
      await logout();
      return false;
    }

    return true;
  }

  Future<String?> getToken() async {
    if (!await isLoggedIn()) {
      return null;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  Future<Map<String, dynamic>?> getUser() async {
    if (!await isLoggedIn()) {
      return null;
    }
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(AppConstants.userKey);
    if (userStr != null) {
      return jsonDecode(userStr);
    }
    return null;
  }
}

import 'package:flutter/foundation.dart';
import 'api_service.dart';

class UserService {
  final ApiService _api;

  UserService(String? token) : _api = ApiService(token: token);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _api.post('/admin/login', {
        'email': email,
        'password': password,
      });

      if (response['token'] == null) {
        throw Exception('No token received from server');
      }

      return response;
    } catch (e) {
      
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchUserData() async {
    try {
      final response = await _api.get('/admin/profile');
      return response;
    } catch (e) {
      
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchDashboardData() async {
    try {
      final response = await _api.get('/admin/dashboard');
      return response;
    } catch (e) {
      
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfile(String name, String email) async {
    try {
      final response = await _api.put('/admin/profile', {
        'name': name,
        'email': email,
      });
      return response;
    } catch (e) {
      
      rethrow;
    }
  }
}

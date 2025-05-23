import 'package:flutter/foundation.dart';
import 'api_service.dart';

class StudentService {
  final ApiService _api;

  StudentService(String? token) : _api = ApiService(token: token);

  Future<List<Map<String, dynamic>>> getStudents() async {
    try {
      final response = await _api.get('/admin/students');
      if (response['students'] != null) {
        return List<Map<String, dynamic>>.from(response['students']);
      }
      throw Exception('No students data in response');
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching students: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getStudent(String registrationNumber) async {
    try {
      final response = await _api.get('/admin/students/$registrationNumber');
      return response['student'];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching student: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> registerStudent({
    required String name,
    required String email,
  }) async {
    try {
      final response = await _api.post('/admin/register-student', {
        'name': name,
        'email': email,
      });
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error registering student: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateStudent(
    String registrationNumber, {
    String? name,
    String? email,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;

      final response = await _api.put(
        '/admin/students/$registrationNumber',
        data,
      );
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating student: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteStudent(String registrationNumber) async {
    try {
      await _api.delete('/admin/students/$registrationNumber');
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting student: $e');
      }
      rethrow;
    }
  }
}

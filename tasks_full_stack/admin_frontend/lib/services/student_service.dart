import 'package:flutter/foundation.dart';
import 'api_service.dart';

class StudentService extends ChangeNotifier {
  final ApiService _api;
  List<Map<String, dynamic>>? _students;
  bool _isLoading = false;

  StudentService(String? token) : _api = ApiService(token: token);

  List<Map<String, dynamic>>? get students => _students;
  bool get isLoading => _isLoading;

  Future<void> fetchStudents() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.get('/admin/students');
      if (response['students'] != null) {
        _students = List<Map<String, dynamic>>.from(response['students']);
      } else {
        throw Exception('No students data in response');
      }
    } catch (e) {
      if (e.toString().contains('Session expired')) {
        throw Exception('Session expired. Please login again.');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getStudent(String registrationNumber) async {
    try {
      final response = await _api.get('/admin/students/$registrationNumber');
      if (response['student'] == null) {
        throw Exception('Student not found');
      }
      return response['student'];
    } catch (e) {
      if (e.toString().contains('Session expired')) {
        throw Exception('Session expired. Please login again.');
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
      await fetchStudents(); // Refresh the students list
      return response;
    } catch (e) {
      if (e.toString().contains('Session expired')) {
        throw Exception('Session expired. Please login again.');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateStudent(
    String registrationNumber, {
    required String name,
    required String email,
  }) async {
    try {
      final response = await _api.put('/admin/students/$registrationNumber', {
        'name': name,
        'email': email,
      });
      await fetchStudents(); // Refresh the students list
      return response;
    } catch (e) {
      if (e.toString().contains('Session expired')) {
        throw Exception('Session expired. Please login again.');
      }
      rethrow;
    }
  }

  Future<void> deleteStudent(String registrationNumber) async {
    try {
      await _api.delete('/admin/students/$registrationNumber');
      await fetchStudents(); // Refresh the students list
    } catch (e) {
      if (e.toString().contains('Session expired')) {
        throw Exception('Session expired. Please login again.');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> changeStudentPassword(
    String registrationNumber,
    String password,
  ) async {
    try {
      final response = await _api.put('/admin/students/$registrationNumber', {
        'password': password,
      });
      return response;
    } catch (e) {
      if (e.toString().contains('Session expired')) {
        throw Exception('Session expired. Please login again.');
      }
      rethrow;
    }
  }

  void clear() {
    _students = null;
    notifyListeners();
  }
}

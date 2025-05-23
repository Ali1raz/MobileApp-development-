import 'package:flutter/foundation.dart';
import 'api_service.dart';

class TaskService {
  final ApiService _api;

  TaskService(String? token) : _api = ApiService(token: token);

  Future<List<Map<String, dynamic>>> getTasks() async {
    try {
      final response = await _api.get('/admin/tasks');
      if (response['tasks'] != null) {
        return List<Map<String, dynamic>>.from(response['tasks']);
      }
      throw Exception('No tasks data in response');
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching tasks: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createTask({
    required String title,
    required String description,
    required String dueDate,
    required List<String> registrationNumbers,
  }) async {
    try {
      final response = await _api.post('/admin/tasks', {
        'title': title,
        'description': description,
        'due_date': dueDate,
        'registration_numbers': registrationNumbers,
      });
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating task: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getTaskProgress(int taskId) async {
    try {
      final response = await _api.post('/admin/tasks/$taskId/progress', {});
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching task progress: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> markTaskComplete(int taskId) async {
    try {
      final response = await _api.post('/student/tasks/$taskId/complete', {});
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error marking task complete: $e');
      }
      rethrow;
    }
  }
}

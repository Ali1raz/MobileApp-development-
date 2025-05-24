import 'package:flutter/foundation.dart';
import 'api_service.dart';

class TaskService extends ChangeNotifier {
  final ApiService _api;
  List<Map<String, dynamic>>? _tasks;
  bool _isLoading = false;

  TaskService(String? token) : _api = ApiService(token: token);

  List<Map<String, dynamic>>? get tasks => _tasks;
  bool get isLoading => _isLoading;

  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.get('/admin/tasks');
      if (response['tasks'] != null) {
        _tasks = List<Map<String, dynamic>>.from(response['tasks']);
      } else {
        throw Exception('No tasks data in response');
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
      await fetchTasks(); // Refresh the tasks list
      return response;
    } catch (e) {
      if (e.toString().contains('Session expired')) {
        throw Exception('Session expired. Please login again.');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateTask({
    required int taskId,
    String? title,
    String? description,
    String? dueDate,
    List<String>? registrationNumbers,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (dueDate != null) data['due_date'] = dueDate;
      if (registrationNumbers != null) {
        data['registration_numbers'] = registrationNumbers;
      }
      final response = await _api.put('/admin/tasks/$taskId', data);
      await fetchTasks(); // Refresh the tasks list
      return response;
    } catch (e) {
      if (e.toString().contains('Session expired')) {
        throw Exception('Session expired. Please login again.');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getTaskProgress(int taskId) async {
    try {
      final response = await _api.post('/admin/tasks/$taskId/progress', {});
      return response;
    } catch (e) {
      if (e.toString().contains('Session expired')) {
        throw Exception('Session expired. Please login again.');
      }
      rethrow;
    }
  }

  Future<void> deleteTask(int taskId) async {
    try {
      await _api.delete('/admin/tasks/$taskId');
      await fetchTasks(); // Refresh the tasks list
    } catch (e) {
      if (e.toString().contains('Session expired')) {
        throw Exception('Session expired. Please login again.');
      }
      rethrow;
    }
  }

  void clear() {
    _tasks = null;
    notifyListeners();
  }
}

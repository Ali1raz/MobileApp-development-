import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class TaskService {
  static const String baseUrl = 'http://192.168.236.66:4444/api/tasks';
  static const Map<String, String> _headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  String _buildUrl({int? page, int? limit, bool? completed}) {
    final queryParams = <String, String>{};
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();
    if (completed != null) queryParams['completed'] = completed.toString();
    
    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    return uri.toString();
  }

  Future<Map<String, dynamic>> getTasks({int page = 1, int limit = 10, bool? completed}) async {
    try {
      final response = await http.get(
        Uri.parse(_buildUrl(page: page, limit: limit, completed: completed)),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = json.decode(response.body);
          final List<dynamic> tasksJson = data['tasks'] ?? [];
          
          return {
            'tasks': tasksJson.map((json) => Task.fromJson(json)).toList(),
            'currentPage': data['currentPage'] ?? page,
            'totalPages': data['totalPages'] ?? 1,
            'totalTasks': data['totalTasks'] ?? 0,
          };
        } catch (e) {
          throw Exception('Failed to parse response: $e');
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('Network error: Please check if the server is running and accessible');
      }
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<Task> createTask(Task task) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: _headers,
        body: json.encode(task.toJson()),
      );

      if (response.statusCode == 201) {
        try {
          return Task.fromJson(json.decode(response.body));
        } catch (e) {
          throw Exception('Failed to parse created task: $e');
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to create task: ${response.statusCode}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('Network error: Please check if the server is running and accessible');
      }
      throw Exception('Failed to create task: $e');
    }
  }

  Future<Task> updateTask(Task task) async {
    if (task.id == null) {
      throw Exception('Task ID is required for update');
    }

    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/${task.id}'),
        headers: _headers,
        body: json.encode(task.toJson()),
      );

      if (response.statusCode == 200) {
        try {
          return Task.fromJson(json.decode(response.body));
        } catch (e) {
          throw Exception('Failed to parse updated task: $e');
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to update task: ${response.statusCode}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('Network error: Please check if the server is running and accessible');
      }
      throw Exception('Failed to update task: $e');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete task: ${response.statusCode}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('Network error: Please check if the server is running and accessible');
      }
      throw Exception('Failed to delete task: $e');
    }
  }
}

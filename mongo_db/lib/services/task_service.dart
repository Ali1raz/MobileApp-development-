import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class TaskService {
  static const String baseUrl = 'http://192.168.236.66:4444/api/tasks';

  String get _url {
    return baseUrl;
  }

  Future<List<Task>> getTasks() async {
    try {
      final response = await http.get(Uri.parse(_url));

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = json.decode(response.body);

          if (data['tasks'] == null) {
            return [];
          }

          final List<dynamic> tasksJson = data['tasks'];

          return tasksJson.map((json) {
            return Task.fromJson(json);
          }).toList();
        } catch (e) {
          throw Exception('Failed to parse response: $e');
        }
      } else {
        throw Exception(
          'Failed to load tasks: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception(
          'Network error: Please check if the server is running and accessible',
        );
      }
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<Task> createTask(Task task) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'}, // Refer to backend-api/README.md
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
        throw Exception(
          error['message'] ?? 'Failed to create task: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception(
          'Network error: Please check if the server is running and accessible',
        );
      }
      throw Exception('Failed to create task: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    if (task.id == null) {
      throw Exception('Task ID is required for update');
    }

    try {
      final response = await http.patch(
        Uri.parse('$_url/${task.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.toJson()),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(
          error['message'] ?? 'Failed to update task: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception(
          'Network error: Please check if the server is running and accessible',
        );
      }
      throw Exception('Failed to update task: $e');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      final response = await http.delete(Uri.parse('$_url/$id'));

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(
          error['message'] ?? 'Failed to delete task: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception(
          'Network error: Please check if the server is running and accessible',
        );
      }
      throw Exception('Failed to delete task: $e');
    }
  }
}

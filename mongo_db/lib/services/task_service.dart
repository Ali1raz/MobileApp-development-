import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/task.dart';
import '../config/api_config.dart';
import 'local_db_service.dart';

class TaskService {
  final LocalDbService _localDb = LocalDbService();
  bool _isConnected = true;

  TaskService() {
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _isConnected = connectivityResult != ConnectivityResult.none;
  }

  Future<Map<String, dynamic>> getTasks({int page = 1, bool? completed}) async {
    await _checkConnection();
    if (!_isConnected) {
      final tasks = await _localDb.getTasks();
      return {
        'tasks': tasks,
        'currentPage': 1,
        'totalPages': 1,
        'totalTasks': tasks.length,
      };
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}?page=$page${completed != null ? '&completed=$completed' : ''}'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tasks = (data['tasks'] as List).map((t) => Task.fromJson(t)).toList();
        
        // Save to local DB for offline access
        for (var task in tasks) {
          await _localDb.saveTask(task);
        }

        return {
          'tasks': tasks,
          'currentPage': data['currentPage'] ?? page,
          'totalPages': data['totalPages'] ?? 1,
          'totalTasks': data['totalTasks'] ?? tasks.length,
        };
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      // Fallback to local DB if server fails
      final tasks = await _localDb.getTasks();
      return {
        'tasks': tasks,
        'currentPage': 1,
        'totalPages': 1,
        'totalTasks': tasks.length,
      };
    }
  }

  Future<Task> createTask(Task task) async {
    await _checkConnection();
    if (!_isConnected) {
      await _localDb.saveTask(task);
      return task;
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.baseUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(task.toJson()),
      );

      if (response.statusCode == 201) {
        final createdTask = Task.fromJson(json.decode(response.body));
        await _localDb.saveTask(createdTask);
        return createdTask;
      } else {
        throw Exception('Failed to create task');
      }
    } catch (e) {
      // Save locally if server fails
      await _localDb.saveTask(task);
      return task;
    }
  }

  Future<Task> updateTask(Task task) async {
    await _checkConnection();
    if (!_isConnected) {
      await _localDb.saveTask(task);
      return task;
    }

    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/${task.id}'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(task.toJson()),
      );

      if (response.statusCode == 200) {
        final updatedTask = Task.fromJson(json.decode(response.body));
        await _localDb.saveTask(updatedTask);
        return updatedTask;
      } else {
        throw Exception('Failed to update task');
      }
    } catch (e) {
      // Save locally if server fails
      await _localDb.saveTask(task);
      return task;
    }
  }

  Future<void> deleteTask(String id) async {
    await _checkConnection();
    if (!_isConnected) {
      await _localDb.deleteTask(id);
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/$id'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        await _localDb.deleteTask(id);
      } else {
        throw Exception('Failed to delete task');
      }
    } catch (e) {
      // Delete locally if server fails
      await _localDb.deleteTask(id);
    }
  }
}

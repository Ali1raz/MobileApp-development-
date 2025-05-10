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

  Future<void> syncOfflineChanges() async {
    if (!_isConnected) return;

    final unsyncedTasks = await _localDb.getUnsyncedTasks();
    for (var taskData in unsyncedTasks) {
      try {
        final task = Task.fromJson(json.decode(taskData['data'] as String));
        await updateTask(task);
        if (task.id != null) {
          await _localDb.markTaskAsSynced(task.id!);
        }
      } catch (e) {
        print('Failed to sync task ${taskData['id']}: $e');
      }
    }
  }

  Future<Map<String, dynamic>> getTasks({int page = 1, bool? completed}) async {
    await _checkConnection();

    try {
      if (_isConnected) {
        final response = await http.get(
          Uri.parse(
            '${ApiConfig.baseUrl}?page=$page${completed != null ? '&completed=$completed' : ''}',
          ),
          headers: {'Accept': 'application/json'},
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final tasks =
              (data['tasks'] as List).map((t) => Task.fromJson(t)).toList();

          // Save to local DB for offline access
          for (var task in tasks) {
            await _localDb.saveTask(task, isSynced: true);
          }

          return {
            'tasks': tasks,
            'currentPage': data['currentPage'] ?? page,
            'totalPages': data['totalPages'] ?? 1,
            'totalTasks': data['totalTasks'] ?? tasks.length,
          };
        }
      }

      // Fallback to local DB
      final tasks = await _localDb.getTasks();
      return {
        'tasks': tasks,
        'currentPage': 1,
        'totalPages': 1,
        'totalTasks': tasks.length,
      };
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

    try {
      if (_isConnected) {
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
          await _localDb.saveTask(createdTask, isSynced: true);
          return createdTask;
        }
      }

      // Save locally if offline or server fails
      await _localDb.saveTask(task, isSynced: false);
      return task;
    } catch (e) {
      // Save locally if server fails
      await _localDb.saveTask(task, isSynced: false);
      return task;
    }
  }

  Future<Task> updateTask(Task task) async {
    await _checkConnection();

    try {
      if (_isConnected) {
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
          await _localDb.saveTask(updatedTask, isSynced: true);
          return updatedTask;
        }
      }

      // Save locally if offline or server fails
      await _localDb.saveTask(task, isSynced: false);
      return task;
    } catch (e) {
      // Save locally if server fails
      await _localDb.saveTask(task, isSynced: false);
      return task;
    }
  }

  Future<void> deleteTask(String id) async {
    await _checkConnection();

    try {
      if (_isConnected) {
        final response = await http.delete(
          Uri.parse('${ApiConfig.baseUrl}/$id'),
          headers: {'Accept': 'application/json'},
        );

        if (response.statusCode == 200) {
          await _localDb.deleteTask(id);
        }
      } else {
        // Save delete operation locally if offline
        await _localDb.deleteTask(id);
      }
    } catch (e) {
      // Save delete operation locally if server fails
      await _localDb.deleteTask(id);
    }
  }
}

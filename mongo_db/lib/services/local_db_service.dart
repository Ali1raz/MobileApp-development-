import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

class LocalDbService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tasks.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE tasks(
            id TEXT PRIMARY KEY,
            title TEXT,
            priority INTEGER,
            completed INTEGER,
            createdAt TEXT,
            updatedAt TEXT
          )
        ''');
      },
    );
  }

  Future<void> saveTask(Task task) async {
    final db = await database;
    await db.insert(
      'tasks',
      {
        'id': task.id,
        'title': task.title,
        'priority': task.priority,
        'completed': task.completed ? 1 : 0,
        'createdAt': task.createdAt?.toIso8601String(),
        'updatedAt': task.updatedAt?.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) {
      return Task(
        id: maps[i]['id'],
        title: maps[i]['title'],
        priority: maps[i]['priority'],
        completed: maps[i]['completed'] == 1,
        createdAt: maps[i]['createdAt'] != null ? DateTime.parse(maps[i]['createdAt']) : null,
        updatedAt: maps[i]['updatedAt'] != null ? DateTime.parse(maps[i]['updatedAt']) : null,
      );
    });
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearTasks() async {
    final db = await database;
    await db.delete('tasks');
  }
} 
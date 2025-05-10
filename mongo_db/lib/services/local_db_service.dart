import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

class LocalDbService {
  static Database? _database;
  static const String tableName = 'tasks';
  static const String syncTableName = 'sync_queue';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tasks.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (Database db, int version) async {
        // Create tasks table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS $tableName(
            id TEXT PRIMARY KEY,
            title TEXT,
            priority INTEGER,
            completed INTEGER,
            createdAt TEXT,
            updatedAt TEXT,
            isSynced INTEGER DEFAULT 1
          )
        ''');

        // Create sync queue table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS $syncTableName(
            id TEXT PRIMARY KEY,
            operation TEXT,
            data TEXT,
            timestamp INTEGER
          )
        ''');
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          // Add isSynced column to existing table
          await db.execute(
            'ALTER TABLE $tableName ADD COLUMN isSynced INTEGER DEFAULT 1',
          );
          // Create sync queue table if it doesn't exist
          await db.execute('''
            CREATE TABLE IF NOT EXISTS $syncTableName(
              id TEXT PRIMARY KEY,
              operation TEXT,
              data TEXT,
              timestamp INTEGER
            )
          ''');
        }
      },
    );
  }

  Future<void> saveTask(Task task, {bool isSynced = false}) async {
    final db = await database;
    await db.insert(tableName, {
      'id': task.id,
      'title': task.title,
      'priority': task.priority,
      'completed': task.completed ? 1 : 0,
      'createdAt': task.createdAt?.toIso8601String(),
      'updatedAt': task.updatedAt?.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    if (!isSynced) {
      await _addToSyncQueue(task, 'update');
    }
  }

  Future<void> _addToSyncQueue(Task task, String operation) async {
    final db = await database;
    await db.insert(syncTableName, {
      'id': task.id,
      'operation': operation,
      'data': task.toJson().toString(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) {
      return Task(
        id: maps[i]['id'],
        title: maps[i]['title'],
        priority: maps[i]['priority'],
        completed: maps[i]['completed'] == 1,
        createdAt:
            maps[i]['createdAt'] != null
                ? DateTime.parse(maps[i]['createdAt'])
                : null,
        updatedAt:
            maps[i]['updatedAt'] != null
                ? DateTime.parse(maps[i]['updatedAt'])
                : null,
      );
    });
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
    await _addToSyncQueue(
      Task(id: id, title: '', priority: 0, completed: false),
      'delete',
    );
  }

  Future<List<Map<String, dynamic>>> getUnsyncedTasks() async {
    final db = await database;
    return await db.query(tableName, where: 'isSynced = ?', whereArgs: [0]);
  }

  Future<void> markTaskAsSynced(String id) async {
    final db = await database;
    await db.update(
      tableName,
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearSyncQueue() async {
    final db = await database;
    await db.delete(syncTableName);
  }

  Future<void> clearTasks() async {
    final db = await database;
    await db.delete(tableName);
    await db.delete(syncTableName);
  }
}

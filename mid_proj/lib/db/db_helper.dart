import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  final tableName = 'history';
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'scores.db');
    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute('''
            create table $tableName(
                id integer primary key autoincrement,
                correct integer,
                wrong integer,
                timestamp integer
            )''');
      },
      version: 1,
    );
  }

  Future<int> insertSession(int correct, int wrong) async {
    final db = await database;
    return db.insert(tableName, {
      'correct': correct,
      'wrong': wrong,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<Map<String, int>> getTotalStats() async {
    final db = await database;
    final totalCorrectResult = await db.rawQuery(
      'SELECT SUM(correct) AS total FROM $tableName',
    );
    final totalWrongResult = await db.rawQuery(
      'SELECT SUM(wrong) AS total FROM $tableName',
    );
    final totalTestsResult = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM $tableName',
    );

    return {
      'totalCorrect': totalCorrectResult.first['total'] as int? ?? 0,
      'totalWrong': totalWrongResult.first['total'] as int? ?? 0,
      'totalTests': totalTestsResult.first['count'] as int? ?? 0,
    };
  }
}

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static Future<void> initDB() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi; // use ffi db
    final dbPath = join(await databaseFactory.getDatabasesPath(), 'cms.dart');
    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        create table committee (
          id integer primary key autoincrement,
        )
        ''');
        await db.execute('''
        create table user (
          id integer primary key autoincrement,
          name text not null
        )
      ''');
      },
    );
  }

  static Database? get db => _database;
}

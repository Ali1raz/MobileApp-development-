import 'package:note_app/models/note.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static Database? _database;

  String noteTable = 'note';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  Future<Database?> get database async {
    _database ??= await initializeDB();
    return _database;
  }

  Future<Database> initializeDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, 'notes.db');
    var notesDB = await openDatabase(path, version: 1, onCreate: _createDB);
    return notesDB;
  }

  void _createDB(Database db, int v) async {
    await db.execute('''
      create table $noteTable(
        id integer primary key autoincrement,
        title text,
        description text,
        priority text,
        date text
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> getNoteList() async {
    final db = await database;
    return await db!.query(noteTable, orderBy: 'priority ASC');
  }

  Future<int> addNote(Note note) async {
    final db = await database;
    return await db!.insert(noteTable, note.toMap());
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return db!.update(
      noteTable,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db!.delete(noteTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getNotesCount() async {
    final db = await database;
    final x = await db!.rawQuery('select count(*) from $noteTable');
    return Sqflite.firstIntValue(x) ?? 0;
  }

  // Optional: Method to get a list of Note objects directly
  Future<List<Note>> getNoteObjectList() async {
    var noteMapList = await getNoteList();
    int count = noteMapList.length;

    List<Note> noteList = <Note>[];
    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }
}

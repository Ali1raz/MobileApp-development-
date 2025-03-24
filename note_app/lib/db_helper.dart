import "package:sqflite/sqflite.dart";
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import 'note.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    debugPrint("initDB");
    String path = join(await getDatabasesPath(), 'notes.db');
    return await openDatabase(
      path,
      version: 2, // Changed from 1 to 2
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Drop old table and recreate
          await db.execute('DROP TABLE IF EXISTS notes');
          await _onCreate(db, newVersion);
        }
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    debugPrint("on create");
    await db.execute('''
      create table notes (
        id integer primary key autoincrement,
        title text,
        content text,
        date text
      )
    ''');
  }

  Future<int> addNote(Note note) async {
    debugPrint("add note");
    final db = await database;
    return await db.insert('notes', {
      'title': note.title,
      'content': note.content,
      'date': DateTime.now().toString(),
    });
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    debugPrint("get note");
    final db = await database;
    return db.query("notes", orderBy: 'date desc');
  }

  Future<int> deleteNote(int id) async {
    debugPrint("delete note");
    final db = await database;
    return db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}

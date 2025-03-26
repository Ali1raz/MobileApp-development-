import 'package:dart_cms/comittee.dart';
import 'package:dart_cms/user.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  Database? _db;
  DatabaseHelper._internal();

  Database get db {
    if (_db != null) {
      return _db!;
    }
    _db = initDB();
    return _db!;
  }

  Database initDB() {
    try {
      final dbPath = join(Directory.current.path, 'cms.db');
      final database = sqlite3.open(dbPath);
      _createTables(database);

      return database;
    } catch (e) {
      rethrow;
    }
  }

  void _createTables(Database db) {
    db.execute('''
      CREATE TABLE if not exists comittee (
        id INTEGER primary key,
        balance REAL,
        installment_price REAL,
        total_duration INTEGER,
        installments_number INTEGER,
        current_installment INTEGER,
        installments_completed INTEGER,
        comittee_created INTEGER
      );
    ''');

    db.execute('''
      create table if not exists users (
        id integer primary key,
        name text,
        total_deposited real,
        total_received real,
        is_selected integer,
        comittee_id integer,
        foreign key(comittee_id) references comittee(id)
      )
    ''');
  }

  void close() {
    if (_db != null) {
      _db!.dispose();
      _db = null;
    }
  }

  int insertComittee(Comittee c) {
    try {
      final db_ = db;

      final stmt = db_.prepare('''
        INSERT INTO comittee (
          balance, installment_price, total_duration, 
          installments_number, current_installment, 
          installments_completed, comittee_created
        ) VALUES (?, ?, ?, ?, ?, ?, ?)
      ''');

      stmt.execute([
        c.balance,
        c.installment_price,
        c.total_duration,
        c.installments_number,
        c.current_installment,
        c.installments_completed,
        c.comittee_created,
      ]);

      final id = db_.lastInsertRowId;
      stmt.dispose();

      return id;
    } catch (e) {
      return -1;
    }
  }

  Comittee? getComittee() {
    final db_ = db;
    final result = db_.select('select * from comittee limit 1');
    if (result.isEmpty) return null;
    return Comittee.fromMap(result.first);
  }

  void updateComittee(Comittee com) {
    final db_ = db;
    final stmt = db_.prepare('''
      update comittee set
        balance = ?,
        installment_price = ?,
        total_duration = ?,
        installments_number = ?,
        current_installment = ?,
        installments_completed = ?,
        comittee_created = ?
      WHERE id = ?
    ''');

    stmt.execute([
      com.balance,
      com.installment_price,
      com.total_duration,
      com.installments_number,
      com.current_installment,
      com.installments_completed,
      com.comittee_created,
      com.id,
    ]);

    stmt.dispose();
  }

  int insertUser(User user) {
    final db_ = db;
    final stmt = db_.prepare('''
      insert into users (
        name, total_deposited, total_received, 
        is_selected, comittee_id
      ) VALUES (?, ?, ?, ?, ?)
    ''');

    stmt.execute([
      user.name,
      user.total_deposited,
      user.total_received,
      user.is_selected ? 1 : 0,
      user.comitteeId,
    ]);

    final id = db_.lastInsertRowId;
    stmt.dispose();
    return id;
  }

  List<User> getUsersByComittee(int cid) {
    final db_ = db;
    final stmt = db_.prepare('select * from users where comittee_id = ?');
    stmt.execute([cid]);
    final result = stmt.select();
    stmt.dispose();
    return result.map((map) => User.fromMap(map)).toList();
  }

  void updateUser(User user) {
    final db_ = db;
    final stmt = db_.prepare('''
      update users set 
        name = ?,
        total_deposited = ?,
        total_received = ?,
        is_selected = ?,
        comittee_id = ?
      WHERE id = ?
    ''');

    stmt.execute([
      user.name,
      user.total_deposited,
      user.total_received,
      user.is_selected ? 1 : 0,
      user.comitteeId,
      user.id,
    ]);

    stmt.dispose();
  }
}

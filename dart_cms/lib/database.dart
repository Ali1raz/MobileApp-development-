import 'package:dart_cms/comittee.dart';
import 'package:dart_cms/user.dart';
import 'package:dart_cms/utils.dart';
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
    print("[db]: Initializing database...");
    _db = initDB();
    return _db!;
  }

  Database initDB() {
    try {
      final dbPath = join(Directory.current.path, 'cms.db');
      final database = sqlite3.open(dbPath);
      database.execute('PRAGMA foreign_keys = ON;');
      _createTables(database);
      return database;
    } catch (e) {
      error("[db]: Database initialization failed: $e");
      rethrow;
    }
  }

  void _createTables(Database db) {
    db.execute('''
      create table if not exists comittee (
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
        foreign key(comittee_id) references comittee(id) on delete cascade
      )
    ''');
  }

  void close() {
    if (_db != null) {
      warning("[db]: Closing database connection...");
      _db!.dispose();
      _db = null;
      warning("[db]: Database connection closed.");
    }
  }

  int insertComittee(Comittee c) {
    info("[db]: Inserting comittee details...");
    try {
      final db_ = db;

      final stmt = db_.prepare('''
      insert into comittee (
        balance, installment_price, total_duration, 
        installments_number, current_installment, 
        installments_completed, comittee_created
      ) values (?, ?, ?, ?, ?, ?, ?)
    ''');

      stmt.execute([
        c.balance,
        c.installment_price,
        c.total_duration,
        c.installments_number,
        c.current_installment,
        c.installments_completed,
        c.comittee_created ? 1 : 0,
      ]);

      final id = db_.lastInsertRowId;
      stmt.dispose();
      return id > 0 ? id : -1;
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

  /// will be used in FUTURE
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
      com.comittee_created ? 1 : 0,
      com.id,
    ]);

    stmt.dispose();
  }

  void deleteComittee(int id) {
    warning("[db]: Deleting comittee with id: $id...");

    final db_ = db;
    final stmt = db_.prepare('DELETE FROM comittee WHERE id = ?');
    stmt.execute([id]);
    stmt.dispose();
    success("[db]: Comittee deleted successfully.");
  }

  // user related methods ...

  int insertUser(User user) {
    final db_ = db;
    final stmt = db_.prepare('''
      insert into users (
        name, total_deposited, total_received, 
        is_selected, comittee_id
      ) values (?, ?, ?, ?, ?)
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
    try {
      final stmt = db_.prepare('SELECT * FROM users WHERE comittee_id = ?');
      final result = stmt.select([cid]);
      stmt.dispose();
      if (result.isEmpty) {
        warning("[db]: No users found for comittee with id: $cid.");
        return [];
      }
      return result.map((map) => User.fromMap(map)).toList();
    } catch (e) {
      error("[db]: Error fetching users for committee $cid: $e");
      return [];
    }
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

  User? getUser(int id) {
    if (id < 0) {
      error("[db]: Invalid user ID: $id.");
      return null;
    }
    if (id == 0) {
      error("[db]: User ID cannot be 0.");
      return null;
    }

    final db_ = db;
    final stmt = db_.prepare('Select * from users Where id = ?');
    final result = stmt.select([id]);
    stmt.dispose();
    if (result.isEmpty) {
      error("[db]: No user found with id: $id.");
      return null;
    }
    return User.fromMap(result.first);
  }

  /// will be used in FUTURE
  void deleteUser(int id) {
    final db_ = db;
    final stmt = db_.prepare('delete from users where id = ?');
    stmt.execute([id]);
    stmt.dispose();
    success("[db]: User with id: $id deleted successfully.");
  }
}

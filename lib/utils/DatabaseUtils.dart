import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseUtils {
  static final DatabaseUtils instance = DatabaseUtils._init();
  static Database? _database;

  DatabaseUtils._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE broker (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        alias VARCHAR(256) NOT NULL,
        connect_type VARCHAR(256) NOT NULL,
        host VARCHAR(256) NOT NULL,
        port INTEGER NOT NULL,
        username VARCHAR(256),
        password VARCHAR(256),
        client_id VARCHAR(256) NOT NULL,
        created_time INTEGER,
        modified_time INTEGER
      )
    ''');

    await db.execute('''
       CREATE TABLE conversation (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        broker_id INTEGER NOT NULL,
        published_topic VARCHAR(256),
        subscribed_topic VARCHAR(256),
        unread_amount INTEGER,
        created_time INTEGER,
        modified_time INTEGER
      )
    ''');

    await db.execute('''
       CREATE TABLE message (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        conversation_id INTEGER NOT NULL,
        type INTEGER NOT NULL,
        topic VARCHAR(256) NOT NULL,
        content VARCHAR(256),
        created_time INTEGER
      )
    ''');
  }
}

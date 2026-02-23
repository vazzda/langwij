import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../shared/lib/constants.dart';

/// Singleton database provider. Manages schema creation and upgrades.
class DatabaseProvider {
  DatabaseProvider._();

  static Database? _database;

  /// Returns the singleton database, initializing if needed.
  static Future<Database> get database async {
    if (_database != null) {
      try {
        await _database!.rawQuery('SELECT 1');
        return _database!;
      } catch (_) {
        _database = null;
      }
    }
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);
    return openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE daily_activity (
        date TEXT PRIMARY KEY,
        correct INTEGER NOT NULL DEFAULT 0,
        wrong INTEGER NOT NULL DEFAULT 0,
        word_ids TEXT NOT NULL DEFAULT '[]'
      )
    ''');
    await db.execute('''
      CREATE TABLE test_results (
        group_id TEXT PRIMARY KEY,
        percentage INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE group_progress (
        group_id TEXT PRIMARY KEY,
        serbian_cards_progress REAL NOT NULL DEFAULT 0,
        english_cards_progress REAL NOT NULL DEFAULT 0,
        write_progress REAL NOT NULL DEFAULT 0,
        peak_retention REAL NOT NULL DEFAULT 0,
        last_session_date TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE session_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        group_id TEXT NOT NULL,
        date TEXT NOT NULL,
        score REAL NOT NULL,
        mode TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Prototyping mode: drop and recreate
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' "
      "AND name NOT LIKE 'sqlite_%' AND name != 'android_metadata'",
    );
    for (final table in tables) {
      await db.execute('DROP TABLE IF EXISTS ${table['name']}');
    }
    await _onCreate(db, newVersion);
  }

  /// Close the database connection.
  static Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  /// Delete the database file entirely.
  static Future<void> deleteAllData() async {
    await close();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

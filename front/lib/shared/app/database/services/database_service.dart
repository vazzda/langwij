import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:langwij/shared/app/config/config.dart';
import 'package:langwij/shared/app/database/database.dart';

const _databaseName = 'langwij.db';
const _databaseVersion = 6;

class DatabaseService {
  DatabaseService._();

  static Database? _preloaded;

  static void preload(Database db) => _preloaded = db;

  static final database = FutureProvider<Database>((ref) async {
    if (_preloaded != null) return _preloaded!;
    return _initDatabase();
  });

  static Future<Database> openEagerly() async {
    if (_preloaded != null) return _preloaded!;
    final db = await _initDatabase();
    _preloaded = db;
    return db;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${DbSchema.tableDailyActivity} (
        ${DbSchema.colDate} TEXT NOT NULL,
        ${DbSchema.colTargetLang} TEXT NOT NULL,
        ${DbSchema.colCorrect} INTEGER NOT NULL DEFAULT 0,
        ${DbSchema.colWrong} INTEGER NOT NULL DEFAULT 0,
        ${DbSchema.colWordIds} TEXT NOT NULL DEFAULT '[]',
        PRIMARY KEY (${DbSchema.colDate}, ${DbSchema.colTargetLang})
      )
    ''');
    await db.execute('''
      CREATE TABLE ${DbSchema.tableDeckProgress} (
        ${DbSchema.colTargetLang} TEXT NOT NULL,
        ${DbSchema.colDeckId} TEXT NOT NULL,
        ${DbSchema.colProgress} REAL NOT NULL DEFAULT 0,
        ${DbSchema.colPeakRetention} REAL NOT NULL DEFAULT 0,
        ${DbSchema.colLastRoundDate} TEXT,
        PRIMARY KEY (${DbSchema.colTargetLang}, ${DbSchema.colDeckId})
      )
    ''');
    await db.execute('''
      CREATE TABLE ${DbSchema.tableRoundRecords} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbSchema.colTargetLang} TEXT NOT NULL,
        ${DbSchema.colDeckId} TEXT NOT NULL,
        ${DbSchema.colDate} TEXT NOT NULL,
        ${DbSchema.colScore} REAL NOT NULL,
        ${DbSchema.colMode} TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE ${DbSchema.tableLanguageStats} (
        ${DbSchema.colTargetLang} TEXT PRIMARY KEY,
        ${DbSchema.colTermsTouchedIds} TEXT NOT NULL DEFAULT '[]'
      )
    ''');
    await db.execute('''
      CREATE TABLE ${DbSchema.tableAppSettings} (
        ${DbSchema.colKey} TEXT PRIMARY KEY,
        ${DbSchema.colValue} TEXT NOT NULL
      )
    ''');
    await db.insert(DbSchema.tableAppSettings, {
      DbSchema.colKey: DbSchema.colTargetLang,
      DbSchema.colValue: LangCodes.serbian,
    });
    await db.insert(DbSchema.tableAppSettings, {
      DbSchema.colKey: DbSchema.colNativeLang,
      DbSchema.colValue: LangCodes.english,
    });
    await db.insert(DbSchema.tableAppSettings, {
      DbSchema.colKey: DbSchema.colUiLang,
      DbSchema.colValue: LangCodes.english,
    });
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' "
      "AND name NOT LIKE 'sqlite_%' AND name != 'android_metadata'",
    );
    for (final table in tables) {
      await db.execute('DROP TABLE IF EXISTS ${table['name']}');
    }
    await _onCreate(db, newVersion);
  }

  static Future<void> close() async {
    await _preloaded?.close();
    _preloaded = null;
  }

  static Future<void> deleteAllData() async {
    await close();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:srpski_card/shared/lib/constants.dart';
import 'package:srpski_card/shared/repositories/db_schema.dart';
import 'package:srpski_card/entities/language/lang_codes.dart';

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
      CREATE TABLE ${DbSchema.tableGroupProgress} (
        ${DbSchema.colTargetLang} TEXT NOT NULL,
        ${DbSchema.colGroupId} TEXT NOT NULL,
        ${DbSchema.colTargetShownProgress} REAL NOT NULL DEFAULT 0,
        ${DbSchema.colNativeShownProgress} REAL NOT NULL DEFAULT 0,
        ${DbSchema.colWriteProgress} REAL NOT NULL DEFAULT 0,
        ${DbSchema.colPeakRetention} REAL NOT NULL DEFAULT 0,
        ${DbSchema.colLastSessionDate} TEXT,
        PRIMARY KEY (${DbSchema.colTargetLang}, ${DbSchema.colGroupId})
      )
    ''');
    await db.execute('''
      CREATE TABLE ${DbSchema.tableSessionRecords} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbSchema.colTargetLang} TEXT NOT NULL,
        ${DbSchema.colGroupId} TEXT NOT NULL,
        ${DbSchema.colDate} TEXT NOT NULL,
        ${DbSchema.colScore} REAL NOT NULL,
        ${DbSchema.colMode} TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE ${DbSchema.tableLanguageStats} (
        ${DbSchema.colTargetLang} TEXT PRIMARY KEY,
        ${DbSchema.colConceptsTouchedIds} TEXT NOT NULL DEFAULT '[]'
      )
    ''');
    await db.execute('''
      CREATE TABLE ${DbSchema.tableAppSettings} (
        ${DbSchema.colKey} TEXT PRIMARY KEY,
        ${DbSchema.colValue} TEXT NOT NULL
      )
    ''');
    // Default language settings
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

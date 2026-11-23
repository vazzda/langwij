import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'package:langwij/shared/app/database/database.dart';
import '../model/app_settings.dart';

class AppSettingsRepository {
  AppSettingsRepository({required Database db}) : _db = db;

  final Database _db;

  Future<AppSettings> getSettings() async {
    return const AppSettings();
  }

  Future<void> saveSettings(AppSettings settings) async {}

  Future<Map<String, bool>> getLevelFoldOverrides(String targetLang) async {
    final storedValue = await _readStoredValueForKey(
      _levelFoldOverridesKeyForTargetLanguage(targetLang),
    );
    if (storedValue == null) return {};
    final decoded = jsonDecode(storedValue) as Map<String, dynamic>;
    return decoded.map(
      (levelId, isExpanded) => MapEntry(levelId, isExpanded as bool),
    );
  }

  Future<void> setLevelFoldOverride(
    String targetLang,
    String levelId,
    bool isExpanded,
  ) async {
    final current = await getLevelFoldOverrides(targetLang);
    current[levelId] = isExpanded;
    await _writeStoredValueForKey(
      _levelFoldOverridesKeyForTargetLanguage(targetLang),
      jsonEncode(current),
    );
  }

  static String _levelFoldOverridesKeyForTargetLanguage(String targetLang) =>
      DbSchema.appSettingsKeyLevelFoldOverridesPrefix + targetLang;

  Future<String?> _readStoredValueForKey(String key) async {
    final rows = await _db.query(
      DbSchema.tableAppSettings,
      where: '${DbSchema.colKey} = ?',
      whereArgs: [key],
    );
    if (rows.isEmpty) return null;
    return rows.first[DbSchema.colValue] as String;
  }

  Future<void> _writeStoredValueForKey(String key, String value) async {
    await _db.insert(
      DbSchema.tableAppSettings,
      {DbSchema.colKey: key, DbSchema.colValue: value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

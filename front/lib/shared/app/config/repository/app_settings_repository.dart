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
    final key = DbSchema.colLevelFoldOverridesPrefix + targetLang;
    final rows = await _db.query(
      DbSchema.tableAppSettings,
      where: '${DbSchema.colKey} = ?',
      whereArgs: [key],
    );
    if (rows.isEmpty) return {};
    final raw = rows.first[DbSchema.colValue] as String;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v as bool));
  }

  Future<void> setLevelFoldOverride(
    String targetLang,
    String levelId,
    bool isExpanded,
  ) async {
    final key = DbSchema.colLevelFoldOverridesPrefix + targetLang;
    final current = await getLevelFoldOverrides(targetLang);
    current[levelId] = isExpanded;
    await _db.insert(
      DbSchema.tableAppSettings,
      {DbSchema.colKey: key, DbSchema.colValue: jsonEncode(current)},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

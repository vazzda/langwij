import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'package:langwij/shared/app/database/database.dart';
import '../model/app_settings.dart';
import '../model/decay_formula.dart';

class AppSettingsRepository {
  AppSettingsRepository({required Database db}) : _db = db;

  final Database _db;

  Future<AppSettings> getSettings() async {
    final rows = await _db.query(
      DbSchema.tableAppSettings,
      where: '${DbSchema.colKey} = ?',
      whereArgs: [DbSchema.colDecayFormula],
    );
    if (rows.isEmpty) return const AppSettings();
    final value = rows.first[DbSchema.colValue] as String;
    return AppSettings(
      decayFormula: DecayFormulaExtension.fromKey(value),
    );
  }

  Future<void> setDecayFormula(DecayFormula formula) async {
    await _db.insert(
      DbSchema.tableAppSettings,
      {DbSchema.colKey: DbSchema.colDecayFormula, DbSchema.colValue: formula.key},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    await setDecayFormula(settings.decayFormula);
  }

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

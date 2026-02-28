import 'package:sqflite/sqflite.dart';

import 'db_schema.dart';
import 'models/app_settings.dart';
import 'models/decay_formula.dart';

/// Persists and reads app settings via SQLite.
class AppSettingsRepository {
  AppSettingsRepository({required Database db}) : _db = db;

  final Database _db;

  /// Returns current app settings.
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

  /// Updates the decay formula.
  Future<void> setDecayFormula(DecayFormula formula) async {
    await _db.insert(
      DbSchema.tableAppSettings,
      {DbSchema.colKey: DbSchema.colDecayFormula, DbSchema.colValue: formula.key},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Saves full settings.
  Future<void> saveSettings(AppSettings settings) async {
    await setDecayFormula(settings.decayFormula);
  }
}

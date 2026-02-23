import 'package:sqflite/sqflite.dart';

import 'models/app_settings.dart';
import 'models/decay_formula.dart';

/// Persists and reads app settings via SQLite.
class AppSettingsRepository {
  AppSettingsRepository({required Database db}) : _db = db;

  final Database _db;

  /// Returns current app settings.
  Future<AppSettings> getSettings() async {
    final rows = await _db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: ['decay_formula'],
    );
    if (rows.isEmpty) return const AppSettings();
    final value = rows.first['value'] as String;
    return AppSettings(
      decayFormula: DecayFormulaExtension.fromKey(value),
    );
  }

  /// Updates the decay formula.
  Future<void> setDecayFormula(DecayFormula formula) async {
    await _db.insert(
      'app_settings',
      {'key': 'decay_formula', 'value': formula.key},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Saves full settings.
  Future<void> saveSettings(AppSettings settings) async {
    await setDecayFormula(settings.decayFormula);
  }
}

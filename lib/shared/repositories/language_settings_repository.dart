import 'package:sqflite/sqflite.dart';

import '../../entities/language/language_settings.dart';
import 'db_schema.dart';

/// Reads and writes language settings (target, native, UI) from app_settings table.
class LanguageSettingsRepository {
  LanguageSettingsRepository({required Database db}) : _db = db;

  final Database _db;

  /// Reads current language settings. Returns defaults if not set.
  Future<LanguageSettings> load() async {
    final rows = await _db.query(
      DbSchema.tableAppSettings,
      where: "${DbSchema.colKey} IN "
          "('${DbSchema.colTargetLang}', '${DbSchema.colNativeLang}', '${DbSchema.colUiLang}')",
    );

    String targetLang = LanguageSettings.defaultSettings.targetLang;
    String nativeLang = LanguageSettings.defaultSettings.nativeLang;
    String uiLang = LanguageSettings.defaultSettings.uiLang;

    for (final row in rows) {
      final key = row[DbSchema.colKey] as String;
      final value = row[DbSchema.colValue] as String;
      switch (key) {
        case DbSchema.colTargetLang:
          targetLang = value;
        case DbSchema.colNativeLang:
          nativeLang = value;
        case DbSchema.colUiLang:
          uiLang = value;
      }
    }

    return LanguageSettings(
      targetLang: targetLang,
      nativeLang: nativeLang,
      uiLang: uiLang,
    );
  }

  /// Persists a single language setting.
  Future<void> _set(String key, String value) async {
    await _db.insert(
      DbSchema.tableAppSettings,
      {DbSchema.colKey: key, DbSchema.colValue: value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates target language.
  Future<void> setTargetLang(String code) => _set(DbSchema.colTargetLang, code);

  /// Updates native language.
  Future<void> setNativeLang(String code) => _set(DbSchema.colNativeLang, code);

  /// Updates UI language.
  Future<void> setUiLang(String code) => _set(DbSchema.colUiLang, code);
}

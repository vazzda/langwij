import 'package:sqflite/sqflite.dart';

import 'package:langwij/shared/app/database/database.dart';
import '../model/language_settings.dart';

class LanguageSettingsRepository {
  LanguageSettingsRepository({required Database db}) : _db = db;

  final Database _db;

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

  Future<void> _set(String key, String value) async {
    await _db.insert(
      DbSchema.tableAppSettings,
      {DbSchema.colKey: key, DbSchema.colValue: value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> setTargetLang(String code) => _set(DbSchema.colTargetLang, code);
  Future<void> setNativeLang(String code) => _set(DbSchema.colNativeLang, code);
  Future<void> setUiLang(String code) => _set(DbSchema.colUiLang, code);
}

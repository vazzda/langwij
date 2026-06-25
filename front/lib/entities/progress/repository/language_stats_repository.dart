import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'package:langwij/shared/app/database/database.dart';

class LanguageStatsRepository {
  LanguageStatsRepository({required Database db}) : _db = db;

  final Database _db;

  Future<Set<String>> getTermsTouched(String targetLang) async {
    final rows = await _db.query(
      DbSchema.tableLanguageStats,
      where: '${DbSchema.colTargetLang} = ?',
      whereArgs: [targetLang],
    );
    if (rows.isEmpty) return {};
    final json = rows.first[DbSchema.colTermsTouchedIds] as String;
    return (jsonDecode(json) as List<dynamic>).cast<String>().toSet();
  }

  Future<void> deleteForLanguage(String targetLang) async {
    await _db.delete(
      DbSchema.tableLanguageStats,
      where: '${DbSchema.colTargetLang} = ?',
      whereArgs: [targetLang],
    );
  }

  Future<int> addTermsTouched(
      String targetLang, Set<String> newTermIds) async {
    final existing = await getTermsTouched(targetLang);
    existing.addAll(newTermIds);

    await _db.insert(
      DbSchema.tableLanguageStats,
      {
        DbSchema.colTargetLang: targetLang,
        DbSchema.colTermsTouchedIds: jsonEncode(existing.toList()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return existing.length;
  }
}

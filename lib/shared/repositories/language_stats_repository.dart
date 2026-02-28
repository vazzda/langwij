import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'db_schema.dart';

/// Tracks which concepts have been touched per target language (running total).
class LanguageStatsRepository {
  LanguageStatsRepository({required Database db}) : _db = db;

  final Database _db;

  /// Returns the set of concept IDs ever touched for a target language.
  Future<Set<String>> getConceptsTouched(String targetLang) async {
    final rows = await _db.query(
      DbSchema.tableLanguageStats,
      where: '${DbSchema.colTargetLang} = ?',
      whereArgs: [targetLang],
    );
    if (rows.isEmpty) return {};
    final json = rows.first[DbSchema.colConceptsTouchedIds] as String;
    return (jsonDecode(json) as List<dynamic>).cast<String>().toSet();
  }

  /// Merges new concept IDs into the running set for a target language.
  Future<int> addConceptsTouched(
      String targetLang, Set<String> newConceptIds) async {
    final existing = await getConceptsTouched(targetLang);
    existing.addAll(newConceptIds);

    await _db.insert(
      DbSchema.tableLanguageStats,
      {
        DbSchema.colTargetLang: targetLang,
        DbSchema.colConceptsTouchedIds: jsonEncode(existing.toList()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return existing.length;
  }
}

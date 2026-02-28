import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'db_schema.dart';

/// Per-day stats: correct, wrong, and distinct word IDs touched today.
class DailyActivityStats {
  const DailyActivityStats({
    this.correct = 0,
    this.wrong = 0,
    this.wordsTouched = 0,
  });

  final int correct;
  final int wrong;
  final int wordsTouched;
}

String _dateKey(DateTime date) {
  final y = date.year;
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Persists and reads daily activity per (calendar day, target language).
class DailyActivityRepository {
  DailyActivityRepository({required Database db}) : _db = db;

  final Database _db;

  /// Returns today's stats for a target language (local date).
  Future<DailyActivityStats> readToday(String targetLang) async {
    final key = _dateKey(DateTime.now());
    final rows = await _db.query(
      DbSchema.tableDailyActivity,
      where: '${DbSchema.colDate} = ? AND ${DbSchema.colTargetLang} = ?',
      whereArgs: [key, targetLang],
    );
    if (rows.isEmpty) return const DailyActivityStats();
    final row = rows.first;
    final correct = (row[DbSchema.colCorrect] as int?) ?? 0;
    final wrong = (row[DbSchema.colWrong] as int?) ?? 0;
    final wordIdsJson = (row[DbSchema.colWordIds] as String?) ?? '[]';
    final wordIds = (jsonDecode(wordIdsJson) as List<dynamic>).cast<String>();
    return DailyActivityStats(
      correct: correct,
      wrong: wrong,
      wordsTouched: wordIds.length,
    );
  }

  /// Merges a completed session into today's totals for a target language.
  Future<DailyActivityStats> addSession({
    required String targetLang,
    required int correct,
    required int wrong,
    required Set<String> wordIds,
  }) async {
    final key = _dateKey(DateTime.now());
    final rows = await _db.query(
      DbSchema.tableDailyActivity,
      where: '${DbSchema.colDate} = ? AND ${DbSchema.colTargetLang} = ?',
      whereArgs: [key, targetLang],
    );

    int totalCorrect = correct;
    int totalWrong = wrong;
    final Set<String> allIds = Set.from(wordIds);

    if (rows.isNotEmpty) {
      final row = rows.first;
      totalCorrect += (row[DbSchema.colCorrect] as int?) ?? 0;
      totalWrong += (row[DbSchema.colWrong] as int?) ?? 0;
      final existingJson = (row[DbSchema.colWordIds] as String?) ?? '[]';
      final existingIds =
          (jsonDecode(existingJson) as List<dynamic>).cast<String>();
      allIds.addAll(existingIds);
    }

    await _db.insert(
      DbSchema.tableDailyActivity,
      {
        DbSchema.colDate: key,
        DbSchema.colTargetLang: targetLang,
        DbSchema.colCorrect: totalCorrect,
        DbSchema.colWrong: totalWrong,
        DbSchema.colWordIds: jsonEncode(allIds.toList()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return DailyActivityStats(
      correct: totalCorrect,
      wrong: totalWrong,
      wordsTouched: allIds.length,
    );
  }
}

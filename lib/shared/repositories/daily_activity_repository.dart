import 'dart:convert';

import 'package:sqflite/sqflite.dart';

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

/// Persists and reads daily activity (correct, wrong, distinct words) per calendar day.
class DailyActivityRepository {
  DailyActivityRepository({required Database db}) : _db = db;

  final Database _db;

  /// Returns today's stats (local date).
  Future<DailyActivityStats> readToday() async {
    final key = _dateKey(DateTime.now());
    final rows = await _db.query(
      'daily_activity',
      where: 'date = ?',
      whereArgs: [key],
    );
    if (rows.isEmpty) return const DailyActivityStats();
    final row = rows.first;
    final correct = (row['correct'] as int?) ?? 0;
    final wrong = (row['wrong'] as int?) ?? 0;
    final wordIdsJson = (row['word_ids'] as String?) ?? '[]';
    final wordIds = (jsonDecode(wordIdsJson) as List<dynamic>).cast<String>();
    return DailyActivityStats(
      correct: correct,
      wrong: wrong,
      wordsTouched: wordIds.length,
    );
  }

  /// Merges a completed session into today's totals. [wordIds] = distinct word IDs from that session.
  /// Returns the new daily stats after the merge (so UI can update without reading back).
  Future<DailyActivityStats> addSession({
    required int correct,
    required int wrong,
    required Set<String> wordIds,
  }) async {
    final key = _dateKey(DateTime.now());
    final rows = await _db.query(
      'daily_activity',
      where: 'date = ?',
      whereArgs: [key],
    );

    int totalCorrect = correct;
    int totalWrong = wrong;
    final Set<String> allIds = Set.from(wordIds);

    if (rows.isNotEmpty) {
      final row = rows.first;
      totalCorrect += (row['correct'] as int?) ?? 0;
      totalWrong += (row['wrong'] as int?) ?? 0;
      final existingJson = (row['word_ids'] as String?) ?? '[]';
      final existingIds =
          (jsonDecode(existingJson) as List<dynamic>).cast<String>();
      allIds.addAll(existingIds);
    }

    await _db.insert(
      'daily_activity',
      {
        'date': key,
        'correct': totalCorrect,
        'wrong': totalWrong,
        'word_ids': jsonEncode(allIds.toList()),
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

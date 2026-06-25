import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'package:langwij/shared/app/database/database.dart';
import '../model/daily_activity_stats.dart';

String _dateKey(DateTime date) {
  final y = date.year;
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

class DailyActivityRepository {
  DailyActivityRepository({required Database db}) : _db = db;

  final Database _db;

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

  Future<void> deleteForLanguage(String targetLang) async {
    await _db.delete(
      DbSchema.tableDailyActivity,
      where: '${DbSchema.colTargetLang} = ?',
      whereArgs: [targetLang],
    );
  }

  Future<DailyActivityStats> addRound({
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

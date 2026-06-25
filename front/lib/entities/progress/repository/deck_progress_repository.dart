import 'package:sqflite/sqflite.dart';

import 'package:langwij/shared/app/database/database.dart';
import '../model/deck_progress.dart';
import '../model/progress_constants.dart';
import '../model/quiz_mode.dart';
import '../model/round_record.dart';

class DeckProgressRepository {
  DeckProgressRepository({required Database db}) : _db = db;

  final Database _db;

  Future<DeckProgress> getProgress(String targetLang, String deckId) async {
    final rows = await _db.query(
      DbSchema.tableDeckProgress,
      where: '${DbSchema.colTargetLang} = ? AND ${DbSchema.colDeckId} = ?',
      whereArgs: [targetLang, deckId],
    );
    final rounds = await _getRecentRounds(targetLang, deckId);

    if (rows.isEmpty) return DeckProgress(deckId: deckId);

    final row = rows.first;
    return DeckProgress(
      deckId: deckId,
      progress: (row[DbSchema.colProgress] as num).toDouble(),
      peakRetention: (row[DbSchema.colPeakRetention] as num).toDouble(),
      recentRounds: rounds,
      lastRoundDate: row[DbSchema.colLastRoundDate] != null
          ? DateTime.parse(row[DbSchema.colLastRoundDate] as String)
          : null,
    );
  }

  Future<Map<String, DeckProgress>> getAllProgress(String targetLang) async {
    final rows = await _db.query(
      DbSchema.tableDeckProgress,
      where: '${DbSchema.colTargetLang} = ?',
      whereArgs: [targetLang],
    );
    final results = <String, DeckProgress>{};

    for (final row in rows) {
      final deckId = row[DbSchema.colDeckId] as String;
      final rounds = await _getRecentRounds(targetLang, deckId);
      results[deckId] = DeckProgress(
        deckId: deckId,
        progress: (row[DbSchema.colProgress] as num).toDouble(),
        peakRetention: (row[DbSchema.colPeakRetention] as num).toDouble(),
        recentRounds: rounds,
        lastRoundDate: row[DbSchema.colLastRoundDate] != null
            ? DateTime.parse(row[DbSchema.colLastRoundDate] as String)
            : null,
      );
    }
    return results;
  }

  Future<bool> recordRound({
    required String targetLang,
    required String deckId,
    required double score,
    required QuizMode mode,
    required double modeCap,
    required double coverage,
    required double accuracy,
  }) async {
    final current = await getProgress(targetLang, deckId);
    final now = DateTime.now();

    await _insertRoundRecord(targetLang, deckId, now, score, mode);

    if (current.progress >= modeCap) {
      await _upsertProgress(targetLang, deckId, current.progress,
          current.peakRetention, now);
      return false;
    }

    final contribution =
        coverage * accuracy * ProgressConstants.baseContribution;
    final newProgress =
        (current.progress + contribution).clamp(0.0, modeCap);

    await _upsertProgress(
        targetLang, deckId, newProgress, current.peakRetention, now);
    return true;
  }

  Future<bool> recordTestResult({
    required String targetLang,
    required String deckId,
    required double firstPassScore,
    required double roundScore,
    required QuizMode mode,
  }) async {
    final current = await getProgress(targetLang, deckId);
    final now = DateTime.now();

    await _insertRoundRecord(targetLang, deckId, now, roundScore, mode);

    final newProgress = firstPassScore > current.progress
        ? firstPassScore.clamp(0.0, ProgressConstants.capTest)
        : current.progress;
    final progressed = newProgress > current.progress;

    await _upsertProgress(
        targetLang, deckId, newProgress, current.peakRetention, now);
    return progressed;
  }

  Future<void> updatePeakRetention(
      String targetLang, String deckId, double currentRetention) async {
    final current = await getProgress(targetLang, deckId);
    if (currentRetention > current.peakRetention) {
      await _db.update(
        DbSchema.tableDeckProgress,
        {DbSchema.colPeakRetention: currentRetention},
        where:
            '${DbSchema.colTargetLang} = ? AND ${DbSchema.colDeckId} = ?',
        whereArgs: [targetLang, deckId],
      );
    }
  }

  Future<Map<String, double>> getSumProgressAllLanguages() async {
    final rows = await _db.query(DbSchema.tableDeckProgress);
    final Map<String, double> sumByLang = {};
    for (final row in rows) {
      final lang = row[DbSchema.colTargetLang] as String;
      final progress = (row[DbSchema.colProgress] as num).toDouble();
      sumByLang[lang] = (sumByLang[lang] ?? 0.0) + progress;
    }
    return sumByLang;
  }

  Future<void> deleteForLanguage(String targetLang) async {
    await _db.delete(
      DbSchema.tableDeckProgress,
      where: '${DbSchema.colTargetLang} = ?',
      whereArgs: [targetLang],
    );
    await _db.delete(
      DbSchema.tableRoundRecords,
      where: '${DbSchema.colTargetLang} = ?',
      whereArgs: [targetLang],
    );
  }

  Future<void> _insertRoundRecord(String targetLang, String deckId,
      DateTime now, double score, QuizMode mode) async {
    await _db.insert(DbSchema.tableRoundRecords, {
      DbSchema.colTargetLang: targetLang,
      DbSchema.colDeckId: deckId,
      DbSchema.colDate: now.toIso8601String(),
      DbSchema.colScore: score,
      DbSchema.colMode: mode.name,
    });

    await _db.rawDelete('''
      DELETE FROM ${DbSchema.tableRoundRecords}
      WHERE ${DbSchema.colTargetLang} = ? AND ${DbSchema.colDeckId} = ? AND id NOT IN (
        SELECT id FROM ${DbSchema.tableRoundRecords}
        WHERE ${DbSchema.colTargetLang} = ? AND ${DbSchema.colDeckId} = ?
        ORDER BY ${DbSchema.colDate} DESC
        LIMIT 3
      )
    ''', [targetLang, deckId, targetLang, deckId]);
  }

  Future<void> _upsertProgress(String targetLang, String deckId,
      double progress, double peakRetention, DateTime now) async {
    await _db.insert(
      DbSchema.tableDeckProgress,
      {
        DbSchema.colTargetLang: targetLang,
        DbSchema.colDeckId: deckId,
        DbSchema.colProgress: progress,
        DbSchema.colPeakRetention: peakRetention,
        DbSchema.colLastRoundDate: now.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<RoundRecord>> _getRecentRounds(
      String targetLang, String deckId) async {
    final rows = await _db.query(
      DbSchema.tableRoundRecords,
      where:
          '${DbSchema.colTargetLang} = ? AND ${DbSchema.colDeckId} = ?',
      whereArgs: [targetLang, deckId],
      orderBy: '${DbSchema.colDate} DESC',
      limit: 3,
    );
    return rows
        .map((row) => RoundRecord(
              date: DateTime.parse(row[DbSchema.colDate] as String),
              score: (row[DbSchema.colScore] as num).toDouble(),
              mode: QuizMode.values.firstWhere(
                (m) => m.name == row[DbSchema.colMode],
                orElse: () => QuizMode.write,
              ),
            ))
        .toList();
  }
}

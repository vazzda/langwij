import 'package:sqflite/sqflite.dart';

import 'db_schema.dart';
import 'models/deck_progress.dart';
import 'models/round_record.dart';
import '../../features/quiz/quiz_mode.dart';
import 'package:langwij/shared/lib/progress_constants.dart';

/// Persists and reads deck progress via SQLite, scoped by target language.
class DeckProgressRepository {
  DeckProgressRepository({required Database db}) : _db = db;

  final Database _db;

  /// Returns progress for a deck in a target language, or empty progress if none exists.
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

  /// Returns all progress for a target language as a map of deckId → DeckProgress.
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

  /// Records an incremental (non-test) round and updates progress.
  ///
  /// [modeCap] — ceiling for this mode (from [ProgressConstants]).
  /// [coverage] — termsInRound / totalTermsInDeck (0–1).
  /// [accuracy] — correctCount / totalAttempts (0–1).
  ///
  /// Returns `true` if progress was actually increased, `false` if over-cap.
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

    // Insert round record (for retention calculation)
    await _insertRoundRecord(targetLang, deckId, now, score, mode);

    // Check if already at or above mode cap
    if (current.progress >= modeCap) {
      // Still update last_round_date even if no progress gained
      await _upsertProgress(targetLang, deckId, current.progress,
          current.peakRetention, now);
      return false;
    }

    // Calculate contribution
    final contribution =
        coverage * accuracy * ProgressConstants.baseContribution;
    final newProgress =
        (current.progress + contribution).clamp(0.0, modeCap);

    await _upsertProgress(
        targetLang, deckId, newProgress, current.peakRetention, now);
    return true;
  }

  /// Records a test result. Ratchet: only upgrades, never degrades.
  ///
  /// [firstPassScore] — percentage of cards correct on first attempt (0–100).
  ///
  /// Returns `true` if progress was actually increased.
  Future<bool> recordTestResult({
    required String targetLang,
    required String deckId,
    required double firstPassScore,
    required double roundScore,
    required QuizMode mode,
  }) async {
    final current = await getProgress(targetLang, deckId);
    final now = DateTime.now();

    // Insert round record (for retention calculation)
    await _insertRoundRecord(targetLang, deckId, now, roundScore, mode);

    // Ratchet: only upgrade
    final newProgress = firstPassScore > current.progress
        ? firstPassScore.clamp(0.0, ProgressConstants.capTest)
        : current.progress;
    final progressed = newProgress > current.progress;

    await _upsertProgress(
        targetLang, deckId, newProgress, current.peakRetention, now);
    return progressed;
  }

  /// Updates peak retention for a deck (call after calculating current retention).
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

  /// Returns summed progress per target language across all decks.
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

  /// Deletes all progress and round records for a target language.
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

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<void> _insertRoundRecord(String targetLang, String deckId,
      DateTime now, double score, QuizMode mode) async {
    await _db.insert(DbSchema.tableRoundRecords, {
      DbSchema.colTargetLang: targetLang,
      DbSchema.colDeckId: deckId,
      DbSchema.colDate: now.toIso8601String(),
      DbSchema.colScore: score,
      DbSchema.colMode: mode.name,
    });

    // Trim to last 3 round records per (target_lang, deck)
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

  /// Returns the last 3 round records for a (target_lang, deck), newest first.
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

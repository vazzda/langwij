import 'dart:math' as math;

import 'package:sqflite/sqflite.dart';

import 'package:langwij/shared/app/database/database.dart';
import '../model/card_result.dart';
import '../model/deck_progress.dart';
import '../model/progress_calculator.dart';
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
    return _progressFromRow(row, deckId, rounds);
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
      results[deckId] = _progressFromRow(row, deckId, rounds);
    }
    return results;
  }

  DeckProgress _progressFromRow(
    Map<String, Object?> row,
    String deckId,
    List<RoundRecord> rounds,
  ) {
    final practice = (row[DbSchema.colPractice] as num).toDouble();
    final mastery = (row[DbSchema.colMastery] as num).toInt();
    final lastPracticeDateStr = row[DbSchema.colLastPracticeDate] as String?;
    final lastPracticeDate =
        lastPracticeDateStr != null ? DateTime.parse(lastPracticeDateStr) : null;

    final decayedPractice = ProgressCalculator.applyPracticeDecay(
      practice: practice,
      mastery: mastery,
      lastPracticeDate: lastPracticeDate,
    );

    return DeckProgress(
      deckId: deckId,
      progress: (row[DbSchema.colProgress] as num).toDouble(),
      peakRetention: (row[DbSchema.colPeakRetention] as num).toDouble(),
      recentRounds: rounds,
      lastRoundDate: row[DbSchema.colLastRoundDate] != null
          ? DateTime.parse(row[DbSchema.colLastRoundDate] as String)
          : null,
      practice: decayedPractice,
      mastery: mastery,
      lastPracticeDate: lastPracticeDate,
    );
  }

  Future<void> recordVocabRound({
    required String targetLang,
    required String deckId,
    required QuizMode mode,
    required List<CardResult> cardResults,
    required int totalDeckTerms,
    required double roundScore,
  }) async {
    final now = DateTime.now();

    await _db.transaction((txn) async {
      final currentRow = await txn.query(
        DbSchema.tableDeckProgress,
        where: '${DbSchema.colTargetLang} = ? AND ${DbSchema.colDeckId} = ?',
        whereArgs: [targetLang, deckId],
      );

      final existingCoverage = currentRow.isNotEmpty
          ? (currentRow.first[DbSchema.colProgress] as num).toDouble()
          : 0.0;
      final coverageLocked = existingCoverage >= ProgressConstants.coverageMax;

      double deckCoverage;
      if (coverageLocked) {
        deckCoverage = existingCoverage;
      } else {
        for (final result in cardResults) {
          await _updateTermCoverage(
            txn: txn,
            targetLang: targetLang,
            deckId: deckId,
            termId: result.termId,
            mode: mode,
            hadWrongAttempt: result.hadWrongAttempt,
          );
        }
        deckCoverage = await _recalcDeckCoverage(
          txn,
          targetLang,
          deckId,
          totalDeckTerms,
        );
      }

      double newPractice = 0.0;
      int newMastery = 0;
      double peakRetention = 0.0;
      String? lastPracticeDateStr;

      if (currentRow.isNotEmpty) {
        final stored = currentRow.first;
        final storedPractice = (stored[DbSchema.colPractice] as num).toDouble();
        newMastery = (stored[DbSchema.colMastery] as num).toInt();
        peakRetention = (stored[DbSchema.colPeakRetention] as num).toDouble();
        lastPracticeDateStr = stored[DbSchema.colLastPracticeDate] as String?;
        final lastPracticeDate = lastPracticeDateStr != null
            ? DateTime.parse(lastPracticeDateStr)
            : null;

        newPractice = ProgressCalculator.applyPracticeDecay(
          practice: storedPractice,
          mastery: newMastery,
          lastPracticeDate: lastPracticeDate,
        );
      }

      if (deckCoverage >= ProgressConstants.coverageMax) {
        final practiceGain =
            cardResults.length * ProgressConstants.practicePerAnswer;
        final oldPractice = newPractice;
        newPractice = math.min(
          newPractice + practiceGain,
          ProgressConstants.practiceMax.toDouble(),
        );
        if (newPractice >= ProgressConstants.practiceMax &&
            oldPractice < ProgressConstants.practiceMax) {
          newMastery += 1;
        }
        lastPracticeDateStr = now.toIso8601String();
      }

      await txn.insert(
        DbSchema.tableDeckProgress,
        {
          DbSchema.colTargetLang: targetLang,
          DbSchema.colDeckId: deckId,
          DbSchema.colProgress: deckCoverage,
          DbSchema.colPeakRetention: peakRetention,
          DbSchema.colLastRoundDate: now.toIso8601String(),
          DbSchema.colPractice: newPractice,
          DbSchema.colMastery: newMastery,
          DbSchema.colLastPracticeDate: lastPracticeDateStr,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });

    await _insertRoundRecord(targetLang, deckId, now, roundScore, mode);
  }

  Future<Map<String, int>> getTermCoverages(
    String targetLang,
    String deckId,
  ) async {
    final rows = await _db.query(
      DbSchema.tableTermCoverage,
      where: '${DbSchema.colTargetLang} = ? AND ${DbSchema.colDeckId} = ?',
      whereArgs: [targetLang, deckId],
    );
    return {
      for (final row in rows)
        row[DbSchema.colTermId] as String:
            (row[DbSchema.colCoverage] as num).toInt(),
    };
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
    await _db.delete(
      DbSchema.tableTermCoverage,
      where: '${DbSchema.colTargetLang} = ?',
      whereArgs: [targetLang],
    );
  }

  Future<void> _updateTermCoverage({
    required Transaction txn,
    required String targetLang,
    required String deckId,
    required String termId,
    required QuizMode mode,
    required bool hadWrongAttempt,
  }) async {
    final rows = await txn.query(
      DbSchema.tableTermCoverage,
      where:
          '${DbSchema.colTargetLang} = ? AND ${DbSchema.colDeckId} = ? AND ${DbSchema.colTermId} = ?',
      whereArgs: [targetLang, deckId, termId],
    );
    int coverage =
        rows.isEmpty ? 0 : (rows.first[DbSchema.colCoverage] as num).toInt();

    final isWrite = mode == QuizMode.write;

    if (isWrite &&
        hadWrongAttempt &&
        coverage > ProgressConstants.coverageWriteFloor) {
      coverage = ProgressConstants.coverageWriteFloor;
    }

    if (isWrite) {
      coverage = math.min(
        coverage + ProgressConstants.coverageWriteIncrement,
        ProgressConstants.coverageMax,
      );
    } else if (coverage < ProgressConstants.coveragePickCap) {
      coverage = math.min(
        coverage + ProgressConstants.coveragePickIncrement,
        ProgressConstants.coveragePickCap,
      );
    }

    await txn.insert(
      DbSchema.tableTermCoverage,
      {
        DbSchema.colTargetLang: targetLang,
        DbSchema.colDeckId: deckId,
        DbSchema.colTermId: termId,
        DbSchema.colCoverage: coverage,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<double> _recalcDeckCoverage(
    Transaction txn,
    String targetLang,
    String deckId,
    int totalDeckTerms,
  ) async {
    if (totalDeckTerms <= 0) return 0.0;

    final result = await txn.rawQuery(
      'SELECT COALESCE(SUM(${DbSchema.colCoverage}), 0) as total '
      'FROM ${DbSchema.tableTermCoverage} '
      'WHERE ${DbSchema.colTargetLang} = ? AND ${DbSchema.colDeckId} = ?',
      [targetLang, deckId],
    );

    final sum = (result.first['total'] as num).toDouble();
    return sum / totalDeckTerms;
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

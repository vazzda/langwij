import 'dart:math' as math;

import 'package:sqflite/sqflite.dart';

import 'package:langwij/shared/app/database/database.dart';
import '../model/card_result.dart';
import '../model/deck_progress.dart';
import '../model/progress_calculator.dart';
import '../model/progress_constants.dart';
import '../model/quiz_mode.dart';

class DeckProgressRepository {
  DeckProgressRepository({required Database db}) : _db = db;

  final Database _db;

  Future<DeckProgress> getProgress(String targetLang, String deckId) async {
    final rows = await _db.query(
      DbSchema.tableDeckProgress,
      where: '${DbSchema.colTargetLang} = ? AND ${DbSchema.colDeckId} = ?',
      whereArgs: [targetLang, deckId],
    );

    if (rows.isEmpty) return DeckProgress(deckId: deckId);

    return _progressFromRow(rows.first, deckId);
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
      results[deckId] = _progressFromRow(row, deckId);
    }
    return results;
  }

  DeckProgress _progressFromRow(
    Map<String, Object?> row,
    String deckId,
  ) {
    final practice = (row[DbSchema.colPractice] as num).toDouble();
    final mastery = (row[DbSchema.colMastery] as num).toInt();
    final lastPracticeDateStr = row[DbSchema.colLastPracticeDate] as String?;
    final lastPracticeDate =
        lastPracticeDateStr != null ? DateTime.parse(lastPracticeDateStr) : null;

    final decayedPractice = ProgressCalculator.applyPracticeDecay(
      practice: practice,
      lastPracticeDate: lastPracticeDate,
    );

    return DeckProgress(
      deckId: deckId,
      progress: (row[DbSchema.colProgress] as num).toDouble(),
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
      String? lastPracticeDateStr;

      if (currentRow.isNotEmpty) {
        final stored = currentRow.first;
        final storedPractice = (stored[DbSchema.colPractice] as num).toDouble();
        newMastery = (stored[DbSchema.colMastery] as num).toInt();
        lastPracticeDateStr = stored[DbSchema.colLastPracticeDate] as String?;
        final lastPracticeDate = lastPracticeDateStr != null
            ? DateTime.parse(lastPracticeDateStr)
            : null;

        newPractice = ProgressCalculator.applyPracticeDecay(
          practice: storedPractice,
          lastPracticeDate: lastPracticeDate,
        );
      }

      if (deckCoverage >= ProgressConstants.coverageMax) {
        final correctCount =
            cardResults.where((r) => !r.hadWrongAttempt).length;
        final practiceGain = ProgressCalculator.calculateRoundPracticeGain(
          correctCount,
          cardResults.length,
        );
        newPractice = math.min(
          newPractice + practiceGain,
          ProgressConstants.practiceMax.toDouble(),
        );
        if (newPractice >= ProgressConstants.practiceMax) {
          newMastery += 1;
          newPractice = 0;
        }
        lastPracticeDateStr = now.toIso8601String();
      }

      await txn.insert(
        DbSchema.tableDeckProgress,
        {
          DbSchema.colTargetLang: targetLang,
          DbSchema.colDeckId: deckId,
          DbSchema.colProgress: deckCoverage,
          DbSchema.colLastRoundDate: now.toIso8601String(),
          DbSchema.colPractice: newPractice,
          DbSchema.colMastery: newMastery,
          DbSchema.colLastPracticeDate: lastPracticeDateStr,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
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

    if (current.progress >= modeCap) {
      await _upsertProgress(targetLang, deckId, current.progress, now);
      return false;
    }

    final contribution =
        coverage * accuracy * ProgressConstants.baseContribution;
    final newProgress =
        (current.progress + contribution).clamp(0.0, modeCap);

    await _upsertProgress(targetLang, deckId, newProgress, now);
    return true;
  }

  Future<void> recordTestResult({
    required String targetLang,
    required String deckId,
    required double testCoverage,
  }) async {
    final now = DateTime.now();
    final currentRow = await _db.query(
      DbSchema.tableDeckProgress,
      where: '${DbSchema.colTargetLang} = ? AND ${DbSchema.colDeckId} = ?',
      whereArgs: [targetLang, deckId],
    );

    final practice = currentRow.isNotEmpty
        ? (currentRow.first[DbSchema.colPractice] as num?)?.toDouble() ?? 0.0
        : 0.0;
    final mastery = currentRow.isNotEmpty
        ? (currentRow.first[DbSchema.colMastery] as num?)?.toInt() ?? 0
        : 0;
    final lastPracticeDateStr = currentRow.isNotEmpty
        ? currentRow.first[DbSchema.colLastPracticeDate] as String?
        : null;

    await _db.insert(
      DbSchema.tableDeckProgress,
      {
        DbSchema.colTargetLang: targetLang,
        DbSchema.colDeckId: deckId,
        DbSchema.colProgress: testCoverage,
        DbSchema.colLastRoundDate: now.toIso8601String(),
        DbSchema.colPractice: practice,
        DbSchema.colMastery: mastery,
        DbSchema.colLastPracticeDate: lastPracticeDateStr,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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

  Future<void> _upsertProgress(String targetLang, String deckId,
      double progress, DateTime now) async {
    await _db.insert(
      DbSchema.tableDeckProgress,
      {
        DbSchema.colTargetLang: targetLang,
        DbSchema.colDeckId: deckId,
        DbSchema.colProgress: progress,
        DbSchema.colLastRoundDate: now.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

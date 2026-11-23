import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import 'package:langwij/entities/dictionary/dictionary.dart';
import 'package:langwij/shared/app/database/database.dart';

import '../model/progress_seed.dart';

/// Reads a developer seed from the bundled assets and writes it into the
/// progress tables.
class SeedLoaderService {
  SeedLoaderService._();

  static const String _seedAssetDirectory = 'assets/seeds';
  static const String _seedAssetFilePrefix = 'seed_';
  static const String _seedAssetFileExtension = '.json';

  /// A seeded round is dated at this hour of its day.
  static const int _hourOfSeededRound = 12;

  static Future<ProgressSeed> readSeedFromAssets(String seedName) async {
    final seedText = await rootBundle.loadString(
      '$_seedAssetDirectory/'
      '$_seedAssetFilePrefix$seedName$_seedAssetFileExtension',
    );
    return ProgressSeed.fromJson(jsonDecode(seedText) as Map<String, dynamic>);
  }

  /// Replaces the stored progress with the seed. A seed that does not fit
  /// [decksById] is refused before anything is deleted.
  static Future<void> replaceStoredProgressWithSeed(
    Database db, {
    required ProgressSeed seed,
    required Map<String, VocabDeckModel> decksById,
  }) async {
    final seededDeckCoverages = seed.assignCoverageToTermsOfDecks(decksById);
    final termIdsOfSeededDecks = {
      for (final seededDeckCoverage in seededDeckCoverages)
        ...seededDeckCoverage.coveragePercentByTermId.keys,
    };

    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);

    await db.transaction((txn) async {
      await _truncateDataTables(txn);
      for (final seededDeckCoverage in seededDeckCoverages) {
        await _writeTermCoverageOfDeck(
          txn: txn,
          targetLang: seed.targetLang,
          seededDeckCoverage: seededDeckCoverage,
        );
        await _writeDeckProgress(
          txn: txn,
          targetLang: seed.targetLang,
          seededDeckCoverage: seededDeckCoverage,
          todayDate: todayDate,
        );
      }
      await _writeDailyActivity(
        txn: txn,
        dailyActivity: seed.dailyActivity,
        targetLang: seed.targetLang,
        todayDate: todayDate,
        termIdsOfSeededDecks: termIdsOfSeededDecks.toList(),
      );
      await _writeLanguageStats(
        txn: txn,
        targetLang: seed.targetLang,
        termIdsOfSeededDecks: termIdsOfSeededDecks,
      );
    });
  }

  static Future<void> truncateDataTables(Database db) async {
    await db.transaction(_truncateDataTables);
  }

  static Future<void> _truncateDataTables(Transaction txn) async {
    await txn.delete(DbSchema.tableDeckProgress);
    await txn.delete(DbSchema.tableDailyActivity);
    await txn.delete(DbSchema.tableLanguageStats);
    await txn.delete(DbSchema.tableTermCoverage);
  }

  /// A term without coverage gets no row, as after a real round.
  static Future<void> _writeTermCoverageOfDeck({
    required Transaction txn,
    required String targetLang,
    required SeededDeckCoverage seededDeckCoverage,
  }) async {
    final coverageOfTerms = seededDeckCoverage.coveragePercentByTermId.entries;
    for (final coverageOfTerm in coverageOfTerms) {
      final coveragePercent = coverageOfTerm.value;
      if (coveragePercent <= 0) continue;
      await txn.insert(DbSchema.tableTermCoverage, {
        DbSchema.colTargetLang: targetLang,
        DbSchema.colDeckId: seededDeckCoverage.deckSeed.deckId,
        DbSchema.colTermId: coverageOfTerm.key,
        DbSchema.colCoverage: coveragePercent,
      });
    }
  }

  static Future<void> _writeDeckProgress({
    required Transaction txn,
    required String targetLang,
    required SeededDeckCoverage seededDeckCoverage,
    required DateTime todayDate,
  }) async {
    final deckSeed = seededDeckCoverage.deckSeed;
    final studiedPercentOfDeck = seededDeckCoverage.studiedPercentOfDeck;
    final isDeckUntouched =
        studiedPercentOfDeck <= 0 && deckSeed.practicePercent <= 0;
    if (isDeckUntouched) return;

    final lastPracticeDaysAgo = deckSeed.lastPracticeDaysAgo;
    final lastRoundDaysAgo = lastPracticeDaysAgo ?? deckSeed.lastRoundDaysAgo;

    await txn.insert(DbSchema.tableDeckProgress, {
      DbSchema.colTargetLang: targetLang,
      DbSchema.colDeckId: deckSeed.deckId,
      DbSchema.colProgress: studiedPercentOfDeck,
      DbSchema.colLastRoundDate:
          _roundDateTextOrNull(todayDate, lastRoundDaysAgo),
      DbSchema.colPractice: deckSeed.practicePercent,
      DbSchema.colMastery: deckSeed.masteryCount,
      DbSchema.colLastPracticeDate:
          _roundDateTextOrNull(todayDate, lastPracticeDaysAgo),
    });
  }

  static String? _roundDateTextOrNull(DateTime todayDate, int? daysAgo) {
    if (daysAgo == null) return null;
    return DateTime(
      todayDate.year,
      todayDate.month,
      todayDate.day - daysAgo,
      _hourOfSeededRound,
    ).toIso8601String();
  }

  static Future<void> _writeDailyActivity({
    required Transaction txn,
    required DailyActivitySeed dailyActivity,
    required String targetLang,
    required DateTime todayDate,
    required List<String> termIdsOfSeededDecks,
  }) async {
    final historyDays = dailyActivity.historyDays;
    final wordCountPerDay = dailyActivity.wordCountPerDay;

    for (var dayIndex = 0; dayIndex <= historyDays; dayIndex++) {
      final date = DateTime(
        todayDate.year,
        todayDate.month,
        todayDate.day - historyDays + dayIndex,
      );

      final termIdsOfDay = <String>[];
      if (termIdsOfSeededDecks.isNotEmpty) {
        for (var wordIndex = 0; wordIndex < wordCountPerDay; wordIndex++) {
          final termIndex = (dayIndex * wordCountPerDay + wordIndex) %
              termIdsOfSeededDecks.length;
          termIdsOfDay.add(termIdsOfSeededDecks[termIndex]);
        }
      }

      await txn.insert(DbSchema.tableDailyActivity, {
        DbSchema.colDate: _dateKey(date),
        DbSchema.colTargetLang: targetLang,
        DbSchema.colCorrect: dailyActivity.correctCountPerDay,
        DbSchema.colWrong: dailyActivity.wrongCountPerDay,
        DbSchema.colWordIds: jsonEncode(termIdsOfDay),
      });
    }
  }

  static Future<void> _writeLanguageStats({
    required Transaction txn,
    required String targetLang,
    required Set<String> termIdsOfSeededDecks,
  }) async {
    await txn.insert(DbSchema.tableLanguageStats, {
      DbSchema.colTargetLang: targetLang,
      DbSchema.colTermsTouchedIds: jsonEncode(termIdsOfSeededDecks.toList()),
    });
  }

  static String _dateKey(DateTime date) {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

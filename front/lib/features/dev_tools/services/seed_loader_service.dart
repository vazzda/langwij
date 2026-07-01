import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import 'package:langwij/shared/app/database/database.dart';

class SeedLoaderService {
  static Future<void> loadSeeds(
    Database db, {
    String seedName = 'full',
  }) async {
    final seedJson =
        await rootBundle.loadString('assets/seeds/seed_$seedName.json');
    final seed = jsonDecode(seedJson) as Map<String, dynamic>;

    final levelsJson =
        await rootBundle.loadString('assets/data/levels.json');
    final levelsData = jsonDecode(levelsJson) as Map<String, dynamic>;
    final deckTermsMap = _buildDeckTermsMap(levelsData);

    final targetLang = seed['target_lang'] as String;
    final decks = seed['decks'] as List<dynamic>;
    final activity = seed['activity'] as Map<String, dynamic>;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    await db.transaction((txn) async {
      await _truncateDataTables(txn);
      final allTouchedTerms = await _seedDeckProgressAndCoverage(
        txn: txn,
        decks: decks,
        targetLang: targetLang,
        todayDate: todayDate,
        deckTermsMap: deckTermsMap,
      );
      await _seedDailyActivity(
        txn: txn,
        activity: activity,
        targetLang: targetLang,
        todayDate: todayDate,
        allTerms: allTouchedTerms.toList(),
      );
      await _seedLanguageStats(
        txn: txn,
        targetLang: targetLang,
        allTouchedTerms: allTouchedTerms,
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

  static Future<Set<String>> _seedDeckProgressAndCoverage({
    required Transaction txn,
    required List<dynamic> decks,
    required String targetLang,
    required DateTime todayDate,
    required Map<String, List<String>> deckTermsMap,
  }) async {
    final allTouchedTerms = <String>{};

    for (final deck in decks) {
      final deckId = deck['deck_id'] as String;
      final terms = deckTermsMap[deckId] ?? [];
      final termCoveragesRaw =
          deck['term_coverages'] as Map<String, dynamic>?;
      final practice = (deck['practice'] as num?)?.toDouble() ?? 0.0;
      final mastery = (deck['mastery'] as num?)?.toInt() ?? 0;
      final lastPracticeDaysAgo = deck['last_practice_days_ago'] as int?;
      final lastRoundDaysAgo = deck['last_round_days_ago'] as int?;

      double deckCoverage = 0.0;

      if (termCoveragesRaw != null && terms.isNotEmpty) {
        final assignments = _expandTermCoverages(termCoveragesRaw, terms);
        int coverageSum = 0;

        for (final entry in assignments.entries) {
          if (entry.value > 0) {
            await txn.insert(DbSchema.tableTermCoverage, {
              DbSchema.colTargetLang: targetLang,
              DbSchema.colDeckId: deckId,
              DbSchema.colTermId: entry.key,
              DbSchema.colCoverage: entry.value,
            });
          }
          coverageSum += entry.value;
        }

        deckCoverage = coverageSum / terms.length;
        allTouchedTerms.addAll(
          assignments.entries
              .where((e) => e.value > 0)
              .map((e) => e.key),
        );
      }

      String? lastRoundDate;
      String? lastPracticeDate;

      if (lastPracticeDaysAgo != null) {
        final date = DateTime(
          todayDate.year,
          todayDate.month,
          todayDate.day - lastPracticeDaysAgo,
          12,
        );
        final iso = date.toIso8601String();
        lastRoundDate = iso;
        lastPracticeDate = iso;
      } else if (lastRoundDaysAgo != null) {
        final date = DateTime(
          todayDate.year,
          todayDate.month,
          todayDate.day - lastRoundDaysAgo,
          12,
        );
        lastRoundDate = date.toIso8601String();
      }

      if (deckCoverage > 0 || practice > 0) {
        await txn.insert(DbSchema.tableDeckProgress, {
          DbSchema.colTargetLang: targetLang,
          DbSchema.colDeckId: deckId,
          DbSchema.colProgress: deckCoverage,
          DbSchema.colLastRoundDate: lastRoundDate,
          DbSchema.colPractice: practice,
          DbSchema.colMastery: mastery,
          DbSchema.colLastPracticeDate: lastPracticeDate,
        });
      }

      if (terms.isNotEmpty && termCoveragesRaw != null) {
        allTouchedTerms.addAll(terms);
      }
    }

    return allTouchedTerms;
  }

  static Map<String, int> _expandTermCoverages(
    Map<String, dynamic> coverageMap,
    List<String> terms,
  ) {
    final result = <String, int>{};
    int termIndex = 0;

    final sorted = coverageMap.entries.toList()
      ..sort((a, b) =>
          int.parse(b.key).compareTo(int.parse(a.key)));

    for (final entry in sorted) {
      final coverageValue = int.parse(entry.key);
      final count = (entry.value as num).toInt();
      for (var i = 0; i < count && termIndex < terms.length; i++) {
        result[terms[termIndex]] = coverageValue;
        termIndex++;
      }
    }

    for (; termIndex < terms.length; termIndex++) {
      result[terms[termIndex]] = 0;
    }

    return result;
  }

  static Future<void> _seedDailyActivity({
    required Transaction txn,
    required Map<String, dynamic> activity,
    required String targetLang,
    required DateTime todayDate,
    required List<String> allTerms,
  }) async {
    final activityDays = activity['history_days'] as int;
    final correct = activity['correct'] as int;
    final wrong = activity['wrong'] as int;
    final wordsPerDay = activity['words_per_day'] as int;

    for (var i = 0; i <= activityDays; i++) {
      final date = DateTime(
        todayDate.year,
        todayDate.month,
        todayDate.day - activityDays + i,
      );

      final dayTerms = <String>[];
      for (var w = 0; w < wordsPerDay && allTerms.isNotEmpty; w++) {
        dayTerms.add(allTerms[(i * wordsPerDay + w) % allTerms.length]);
      }

      await txn.insert(DbSchema.tableDailyActivity, {
        DbSchema.colDate: _dateKey(date),
        DbSchema.colTargetLang: targetLang,
        DbSchema.colCorrect: correct,
        DbSchema.colWrong: wrong,
        DbSchema.colWordIds: jsonEncode(dayTerms),
      });
    }
  }

  static Future<void> _seedLanguageStats({
    required Transaction txn,
    required String targetLang,
    required Set<String> allTouchedTerms,
  }) async {
    await txn.insert(DbSchema.tableLanguageStats, {
      DbSchema.colTargetLang: targetLang,
      DbSchema.colTermsTouchedIds: jsonEncode(allTouchedTerms.toList()),
    });
  }

  static Map<String, List<String>> _buildDeckTermsMap(
    Map<String, dynamic> levelsData,
  ) {
    final decks = levelsData['decks'] as List<dynamic>;
    final map = <String, List<String>>{};
    for (final deck in decks) {
      final id = deck['id'] as String;
      final terms = (deck['terms'] as List<dynamic>).cast<String>();
      map[id] = terms;
    }
    return map;
  }

  static String _dateKey(DateTime date) {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

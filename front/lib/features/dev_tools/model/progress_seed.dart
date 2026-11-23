import 'package:langwij/entities/dictionary/dictionary.dart';
import 'package:langwij/entities/progress/progress.dart';

/// A fault of a developer seed: the document is misshapen, or it does not fit
/// the decks the app holds.
class ProgressSeedException implements Exception {
  const ProgressSeedException(this.message);

  final String message;

  @override
  String toString() => 'ProgressSeedException: $message';
}

/// A developer seed, as read from assets/seeds: the stored progress the app is
/// filled with to show its screens in use.
class ProgressSeed {
  const ProgressSeed({
    required this.targetLang,
    required this.deckSeeds,
    required this.dailyActivity,
  });

  static const String _targetLangJsonKey = 'target_lang';
  static const String _deckSeedsJsonKey = 'decks';
  static const String _dailyActivityJsonKey = 'activity';

  final String targetLang;
  final List<DeckProgressSeed> deckSeeds;
  final DailyActivitySeed dailyActivity;

  factory ProgressSeed.fromJson(Map<String, dynamic> json) {
    final deckSeeds = (json[_deckSeedsJsonKey] as List<dynamic>)
        .map(
          (deckSeedJson) =>
              DeckProgressSeed.fromJson(deckSeedJson as Map<String, dynamic>),
        )
        .toList();
    _refuseDeckListedTwice(deckSeeds);
    return ProgressSeed(
      targetLang: json[_targetLangJsonKey] as String,
      deckSeeds: deckSeeds,
      dailyActivity: DailyActivitySeed.fromJson(
        json[_dailyActivityJsonKey] as Map<String, dynamic>,
      ),
    );
  }

  /// Gives every seeded deck the coverage of each of its terms. Refuses a seed
  /// that names a deck [decksById] does not hold, or that counts more terms
  /// than the deck holds.
  List<SeededDeckCoverage> assignCoverageToTermsOfDecks(
    Map<String, VocabDeckModel> decksById,
  ) {
    return [
      for (final deckSeed in deckSeeds)
        SeededDeckCoverage(
          deckSeed: deckSeed,
          coveragePercentByTermId: deckSeed.assignCoverageToTerms(
            _findTermIdsOfSeededDeck(deckSeed.deckId, decksById),
          ),
        ),
    ];
  }

  static void _refuseDeckListedTwice(List<DeckProgressSeed> deckSeeds) {
    final deckIdsSeen = <String>{};
    for (final deckSeed in deckSeeds) {
      final isListedForTheFirstTime = deckIdsSeen.add(deckSeed.deckId);
      if (!isListedForTheFirstTime) {
        throw ProgressSeedException(
          'deck "${deckSeed.deckId}" is listed twice',
        );
      }
    }
  }

  static List<String> _findTermIdsOfSeededDeck(
    String deckId,
    Map<String, VocabDeckModel> decksById,
  ) {
    final deck = decksById[deckId];
    if (deck == null) {
      throw ProgressSeedException('the app holds no deck "$deckId"');
    }
    return deck.termIds;
  }
}

/// The seeded progress of one deck: how far its terms are studied, and how
/// its practice stands.
class DeckProgressSeed {
  const DeckProgressSeed({
    required this.deckId,
    required this.coverage,
    required this.practicePercent,
    required this.masteryCount,
    this.lastPracticeDaysAgo,
    this.lastRoundDaysAgo,
  });

  static const String _deckIdJsonKey = 'deck_id';
  static const String _coverageOfAllTermsJsonKey = 'all_terms_coverage';
  static const String _termCountByCoverageJsonKey = 'term_coverages';
  static const String _practicePercentJsonKey = 'practice';
  static const String _masteryCountJsonKey = 'mastery';
  static const String _lastPracticeDaysAgoJsonKey = 'last_practice_days_ago';
  static const String _lastRoundDaysAgoJsonKey = 'last_round_days_ago';

  static const double _practicePercentWhenNotStated = 0.0;
  static const int _masteryCountWhenNotStated = 0;
  static const int _coveragePercentOfTermOutsideTheCount = 0;
  static const int _lowestCoveragePercent = 0;
  static const int _smallestTermCountOfCoverageStep = 1;

  final String deckId;
  final DeckCoverageSeed coverage;
  final double practicePercent;
  final int masteryCount;

  /// Days since the last practice round; such a round is the last round too.
  final int? lastPracticeDaysAgo;

  /// Days since the last round of a deck that has no practice round yet.
  final int? lastRoundDaysAgo;

  factory DeckProgressSeed.fromJson(Map<String, dynamic> json) {
    final deckId = json[_deckIdJsonKey] as String;
    return DeckProgressSeed(
      deckId: deckId,
      coverage: _parseCoverage(deckId, json),
      practicePercent: (json[_practicePercentJsonKey] as num?)?.toDouble() ??
          _practicePercentWhenNotStated,
      masteryCount: (json[_masteryCountJsonKey] as num?)?.toInt() ??
          _masteryCountWhenNotStated,
      lastPracticeDaysAgo: json[_lastPracticeDaysAgoJsonKey] as int?,
      lastRoundDaysAgo: json[_lastRoundDaysAgoJsonKey] as int?,
    );
  }

  /// The coverage percent of every term of the deck, in the deck's order.
  Map<String, int> assignCoverageToTerms(List<String> termIds) {
    return switch (coverage) {
      SameCoverageOfAllTerms(:final coveragePercent) => {
          for (final termId in termIds) termId: coveragePercent,
        },
      CoverageByTermCount(:final termCountByCoveragePercent) =>
        _assignCountedCoverageToTerms(termIds, termCountByCoveragePercent),
    };
  }

  /// The highest coverage goes to the first terms of the deck; the terms the
  /// count does not reach stay unstudied.
  Map<String, int> _assignCountedCoverageToTerms(
    List<String> termIds,
    Map<int, int> termCountByCoveragePercent,
  ) {
    final countedTermCount = termCountByCoveragePercent.values.fold(
      0,
      (termCountSum, termCount) => termCountSum + termCount,
    );
    if (countedTermCount > termIds.length) {
      throw ProgressSeedException(
        'deck "$deckId": the seed counts $countedTermCount terms, '
        'the deck holds ${termIds.length}',
      );
    }

    final coverageStepsFromHighest = termCountByCoveragePercent.entries.toList()
      ..sort((step, otherStep) => otherStep.key.compareTo(step.key));
    final coveragePercentsInDeckOrder = [
      for (final coverageStep in coverageStepsFromHighest)
        for (var counted = 0; counted < coverageStep.value; counted++)
          coverageStep.key,
    ];

    return {
      for (var termIndex = 0; termIndex < termIds.length; termIndex++)
        termIds[termIndex]: termIndex < coveragePercentsInDeckOrder.length
            ? coveragePercentsInDeckOrder[termIndex]
            : _coveragePercentOfTermOutsideTheCount,
    };
  }

  static DeckCoverageSeed _parseCoverage(
    String deckId,
    Map<String, dynamic> json,
  ) {
    final coverageOfAllTermsJson = json[_coverageOfAllTermsJsonKey];
    final termCountByCoverageJson = json[_termCountByCoverageJsonKey];
    final statesCoverageOfAllTerms = coverageOfAllTermsJson != null;
    final statesTermCountByCoverage = termCountByCoverageJson != null;
    if (statesCoverageOfAllTerms == statesTermCountByCoverage) {
      throw ProgressSeedException(
        'deck "$deckId" must state exactly one of '
        '"$_coverageOfAllTermsJsonKey" and "$_termCountByCoverageJsonKey"',
      );
    }

    if (statesCoverageOfAllTerms) {
      return SameCoverageOfAllTerms(
        _parseCoveragePercent(deckId, coverageOfAllTermsJson),
      );
    }
    final termCountByCoverageMap =
        termCountByCoverageJson as Map<String, dynamic>;
    return CoverageByTermCount({
      for (final coverageStep in termCountByCoverageMap.entries)
        _parseCoveragePercent(deckId, coverageStep.key):
            _parseTermCountOfCoverageStep(deckId, coverageStep.value),
    });
  }

  /// The percent arrives as a number, or as text when it is a JSON key.
  static int _parseCoveragePercent(String deckId, Object? coveragePercentJson) {
    final coveragePercent = switch (coveragePercentJson) {
      final int percent => percent,
      final String percentText => int.tryParse(percentText),
      _ => null,
    };
    if (coveragePercent == null ||
        coveragePercent < _lowestCoveragePercent ||
        coveragePercent > ProgressConstants.coverageMax) {
      throw ProgressSeedException(
        'deck "$deckId": "$coveragePercentJson" is not a coverage from '
        '$_lowestCoveragePercent to ${ProgressConstants.coverageMax}',
      );
    }
    return coveragePercent;
  }

  static int _parseTermCountOfCoverageStep(String deckId, Object? termCountJson) {
    if (termCountJson is! int ||
        termCountJson < _smallestTermCountOfCoverageStep) {
      throw ProgressSeedException(
        'deck "$deckId": "$termCountJson" is not a count of terms',
      );
    }
    return termCountJson;
  }
}

/// How a deck seed spreads coverage over the terms of its deck.
sealed class DeckCoverageSeed {
  const DeckCoverageSeed();
}

/// Every term of the deck holds the same coverage, whatever the deck's size.
final class SameCoverageOfAllTerms extends DeckCoverageSeed {
  const SameCoverageOfAllTerms(this.coveragePercent);

  final int coveragePercent;
}

/// A counted number of terms holds each stated coverage.
final class CoverageByTermCount extends DeckCoverageSeed {
  const CoverageByTermCount(this.termCountByCoveragePercent);

  final Map<int, int> termCountByCoveragePercent;
}

/// A deck seed together with the coverage it gives each term of its deck.
class SeededDeckCoverage {
  const SeededDeckCoverage({
    required this.deckSeed,
    required this.coveragePercentByTermId,
  });

  static const double _studiedPercentOfDeckWithoutTerms = 0.0;

  final DeckProgressSeed deckSeed;

  /// Every term of the deck, in the deck's order, with its coverage percent.
  final Map<String, int> coveragePercentByTermId;

  /// The studied percent of the deck: the mean coverage of its terms.
  double get studiedPercentOfDeck {
    if (coveragePercentByTermId.isEmpty) {
      return _studiedPercentOfDeckWithoutTerms;
    }
    final coveragePercentSum = coveragePercentByTermId.values.fold(
      0,
      (percentSum, coveragePercent) => percentSum + coveragePercent,
    );
    return coveragePercentSum / coveragePercentByTermId.length;
  }
}

/// The seeded history of daily activity: the same figures on every day.
class DailyActivitySeed {
  const DailyActivitySeed({
    required this.historyDays,
    required this.correctCountPerDay,
    required this.wrongCountPerDay,
    required this.wordCountPerDay,
  });

  static const String _historyDaysJsonKey = 'history_days';
  static const String _correctCountPerDayJsonKey = 'correct';
  static const String _wrongCountPerDayJsonKey = 'wrong';
  static const String _wordCountPerDayJsonKey = 'words_per_day';

  final int historyDays;
  final int correctCountPerDay;
  final int wrongCountPerDay;
  final int wordCountPerDay;

  factory DailyActivitySeed.fromJson(Map<String, dynamic> json) {
    return DailyActivitySeed(
      historyDays: json[_historyDaysJsonKey] as int,
      correctCountPerDay: json[_correctCountPerDayJsonKey] as int,
      wrongCountPerDay: json[_wrongCountPerDayJsonKey] as int,
      wordCountPerDay: json[_wordCountPerDayJsonKey] as int,
    );
  }
}

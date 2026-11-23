import 'package:langwij/entities/dictionary/dictionary.dart';

import 'vocab_deck_card_data.dart';

class VocabLevelData {
  VocabLevelData({
    required this.level,
    required this.name,
    required this.tier,
    required this.levelProgress,
    required this.decks,
    required this.totalCardCount,
    required this.isEveryDeckFullyStudied,
    required this.lowestDeckMastery,
    required this.averagePracticePercent,
    this.description,
    this.latestDate,
  });

  final Level level;
  final String name;
  final String? description;
  final LevelTier tier;
  final double levelProgress;
  final List<VocabDeckCardData> decks;
  final DateTime? latestDate;
  final int totalCardCount;

  /// True once every deck of the level is fully studied; level training and
  /// the mastery figures are shown from then on.
  final bool isEveryDeckFullyStudied;

  /// The mastery of the least mastered deck of the level.
  final int lowestDeckMastery;

  /// Average practice of the decks, 0 to 100; 0 until every deck is fully
  /// studied.
  final double averagePracticePercent;
}

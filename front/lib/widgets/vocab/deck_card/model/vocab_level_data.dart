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
}

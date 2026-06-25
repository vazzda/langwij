import 'package:langwij/entities/dictionary/dictionary.dart';
import 'package:langwij/entities/progress/progress.dart';

class VocabDeckTileData {
  VocabDeckTileData({
    required this.deck,
    required this.name,
    required this.cardCount,
    required this.retention,
    required this.words,
    this.icon,
    this.percentage,
    this.progress,
  });

  final VocabDeckModel deck;
  final String name;
  final String? icon;
  final int cardCount;
  final List<String> words;
  final int? percentage;
  final DeckProgress? progress;
  final double retention;
}

class VocabLevelData {
  VocabLevelData({
    required this.level,
    required this.name,
    required this.tier,
    required this.levelProgress,
    required this.decks,
    required this.strengthLevel,
    required this.totalCardCount,
    this.description,
    this.latestDate,
  });

  final Level level;
  final String name;
  final String? description;
  final LevelTier tier;
  final double levelProgress;
  final List<VocabDeckTileData> decks;
  final DateTime? latestDate;
  final RetentionLevel strengthLevel;
  final int totalCardCount;
}

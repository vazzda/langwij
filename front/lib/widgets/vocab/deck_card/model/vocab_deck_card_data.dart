import 'package:langwij/entities/dictionary/dictionary.dart';
import 'package:langwij/entities/progress/progress.dart';

class VocabDeckCardData {
  VocabDeckCardData({
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

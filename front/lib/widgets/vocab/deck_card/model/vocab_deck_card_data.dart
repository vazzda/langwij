import 'package:langwij/entities/dictionary/dictionary.dart';
import 'package:langwij/entities/progress/progress.dart';

import 'vocab_deck_study_phase.dart';

class VocabDeckCardData {
  VocabDeckCardData({
    required this.deck,
    required this.name,
    required this.cardCount,
    required this.practice,
    required this.mastery,
    required this.words,
    required this.studyPhase,
    this.deckNumber,
    this.icon,
    this.coverage,
    this.progress,
  });

  final VocabDeckModel deck;
  final String name;

  /// The deck's running number in the main vocabulary list, starting at 1;
  /// null for a deck outside that list.
  final int? deckNumber;

  final String? icon;
  final int cardCount;
  final List<String> words;
  final int? coverage;
  final DeckProgress? progress;
  final double practice;
  final int mastery;
  final VocabDeckStudyPhase studyPhase;

  /// The deck name, led by the deck's running number when it has one:
  /// "36. Plugged In".
  String get numberedName => deckNumber == null ? name : '$deckNumber. $name';
}

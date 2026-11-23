import 'level.dart';
import 'term.dart';
import 'vocab_deck_model.dart';
import 'vocabulary_level_segment.dart';

class Dictionary {
  const Dictionary({
    required this.terms,
    required this.decks,
    required this.levels,
    required this.vocabularyLevelSegments,
  });

  static const String _termsJsonKey = 'terms';
  static const String _decksJsonKey = 'decks';
  static const String _levelsJsonKey = 'levels';
  static const String _vocabularyLevelSegmentsJsonKey = 'segments';

  final Map<String, Term> terms;
  final List<VocabDeckModel> decks;
  final List<Level> levels;
  final List<VocabularyLevelSegment> vocabularyLevelSegments;

  Set<String> get termIds => terms.keys.toSet();

  Map<String, VocabDeckModel> get decksById =>
      {for (final deck in decks) deck.id: deck};

  /// Builds the dictionary from its two bundled documents: dictionary.json
  /// (terms) and levels.json (decks, levels, segments).
  factory Dictionary.fromDictionaryAndLevelsJson({
    required Map<String, dynamic> dictionaryJson,
    required Map<String, dynamic> levelsJson,
  }) {
    return Dictionary(
      terms: _parseTermsByTermId(dictionaryJson),
      decks: _parseDecks(levelsJson),
      levels: _parseLevels(levelsJson),
      vocabularyLevelSegments: _parseVocabularyLevelSegments(levelsJson),
    );
  }

  static Map<String, Term> _parseTermsByTermId(
    Map<String, dynamic> dictionaryJson,
  ) {
    final termsJson = dictionaryJson[_termsJsonKey] as Map<String, dynamic>;
    return termsJson.map(
      (termId, termJson) => MapEntry(
        termId,
        Term.fromJson(termId, termJson as Map<String, dynamic>),
      ),
    );
  }

  static List<VocabDeckModel> _parseDecks(Map<String, dynamic> levelsJson) {
    final decksJson = levelsJson[_decksJsonKey] as List<dynamic>;
    return decksJson
        .map(
          (deckJson) =>
              VocabDeckModel.fromJson(deckJson as Map<String, dynamic>),
        )
        .toList();
  }

  static List<Level> _parseLevels(Map<String, dynamic> levelsJson) {
    final levelListJson = levelsJson[_levelsJsonKey] as List<dynamic>;
    return levelListJson
        .map((levelJson) => Level.fromJson(levelJson as Map<String, dynamic>))
        .toList();
  }

  static List<VocabularyLevelSegment> _parseVocabularyLevelSegments(
    Map<String, dynamic> levelsJson,
  ) {
    final segmentsJson =
        levelsJson[_vocabularyLevelSegmentsJsonKey] as List<dynamic>;
    return segmentsJson
        .map(
          (segmentJson) => VocabularyLevelSegment.fromJson(
            segmentJson as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}

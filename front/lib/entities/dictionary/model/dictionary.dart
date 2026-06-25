import 'level.dart';
import 'term.dart';
import 'vocab_deck_model.dart';

class Dictionary {
  const Dictionary({
    required this.terms,
    required this.decks,
    required this.levels,
  });

  final Map<String, Term> terms;
  final List<VocabDeckModel> decks;
  final List<Level> levels;

  Set<String> get termIds => terms.keys.toSet();

  Map<String, VocabDeckModel> get decksById =>
      {for (final g in decks) g.id: g};

  factory Dictionary.fromJson(Map<String, dynamic> json) {
    final termsJson = json['terms'] as Map<String, dynamic>;
    final terms = termsJson.map(
      (id, data) =>
          MapEntry(id, Term.fromJson(id, data as Map<String, dynamic>)),
    );

    final decksJson = json['decks'] as List<dynamic>;
    final decks = decksJson
        .map((g) => VocabDeckModel.fromJson(g as Map<String, dynamic>))
        .toList();

    final levelsJson = json['levels'] as List<dynamic>;
    final levels = levelsJson
        .map((l) => Level.fromJson(l as Map<String, dynamic>))
        .toList();

    return Dictionary(terms: terms, decks: decks, levels: levels);
  }
}

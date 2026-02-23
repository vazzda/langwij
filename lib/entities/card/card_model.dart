/// A single flashcard. For "words" groups: infinitive ↔ English.
/// For "endings" groups: pronoun + conjugated form ↔ English.
abstract interface class CardModel {
  String get serbian;
  String get english;

  /// Serbian side used for display and grading. For endings: pronoun + form; for words: infinitive.
  String get serbianAnswer;
}

/// Word card: infinitive (neutral) form ↔ English.
class WordCard implements CardModel {
  const WordCard({required this.serbian, required this.english});

  @override
  final String serbian;
  @override
  final String english;

  @override
  String get serbianAnswer => serbian;

  factory WordCard.fromJson(Map<String, dynamic> json) => WordCard(
        serbian: json['serbian'] as String,
        english: json['english'] as String,
      );
}

/// Noun card with gender for agreement sessions.
class NounCard implements CardModel {
  const NounCard({
    required this.serbian,
    required this.english,
    required this.gender,
  });

  @override
  final String serbian;
  @override
  final String english;
  /// "m", "f", or "n"
  final String gender;

  @override
  String get serbianAnswer => serbian;

  factory NounCard.fromJson(Map<String, dynamic> json) => NounCard(
        serbian: json['serbian'] as String,
        english: json['english'] as String,
        gender: json['gender'] as String,
      );
}

/// Adjective card with all three gender forms.
class AdjectiveCard implements CardModel {
  const AdjectiveCard({
    required this.serbian,
    required this.english,
    required this.feminine,
    required this.neuter,
  });

  /// Masculine form (used in vocabulary mode).
  @override
  final String serbian;
  @override
  final String english;
  final String feminine;
  final String neuter;

  @override
  String get serbianAnswer => serbian;

  String formForGender(String gender) => switch (gender) {
        'm' => serbian,
        'f' => feminine,
        'n' => neuter,
        _ => serbian,
      };

  factory AdjectiveCard.fromJson(Map<String, dynamic> json) => AdjectiveCard(
        serbian: json['serbian'] as String,
        english: json['english'] as String,
        feminine: json['feminine'] as String,
        neuter: json['neuter'] as String,
      );
}

/// Runtime-generated phrase (adjective + noun in agreement).
class PhraseCard implements CardModel {
  const PhraseCard({required this.serbian, required this.english});

  @override
  final String serbian;
  @override
  final String english;

  @override
  String get serbianAnswer => serbian;
}

/// Ending card: pronoun + conjugated form ↔ English.
class EndingCard implements CardModel {
  const EndingCard({
    required this.pronoun,
    required this.serbian,
    required this.english,
  });

  final String pronoun;
  @override
  final String serbian;
  @override
  final String english;

  @override
  String get serbianAnswer => '$pronoun $serbian';

  factory EndingCard.fromJson(Map<String, dynamic> json) => EndingCard(
        pronoun: json['pronoun'] as String,
        serbian: json['serbian'] as String,
        english: json['english'] as String,
      );
}

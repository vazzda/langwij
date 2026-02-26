/// A concept's translation in a single language.
///
/// Discriminated by key structure in JSON:
///   "imperfective" present  →  [AspectPairEntry]
///   "m" present             →  [AdjectiveEntry]
///   "text" present          →  [SimpleEntry]
sealed class LangEntry {
  const LangEntry({this.note});

  final String? note;

  factory LangEntry.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('imperfective')) return AspectPairEntry.fromJson(json);
    if (json.containsKey('m')) return AdjectiveEntry.fromJson(json);
    return SimpleEntry.fromJson(json);
  }
}

/// A single-form entry: verb, noun, adverb, phrase, etc.
class SimpleEntry extends LangEntry {
  const SimpleEntry({
    required this.text,
    this.gender,
    super.note,
  });

  /// Primary display and answer text.
  final String text;

  /// Grammatical gender for nouns: "m", "f", "n".
  final String? gender;

  factory SimpleEntry.fromJson(Map<String, dynamic> json) => SimpleEntry(
        text: json['text'] as String,
        gender: json['gender'] as String?,
        note: json['note'] as String?,
      );
}

/// A verb aspect pair: imperfective and perfective forms.
class AspectPairEntry extends LangEntry {
  const AspectPairEntry({
    required this.imperfective,
    required this.perfective,
    super.note,
  });

  final String imperfective;
  final String perfective;

  factory AspectPairEntry.fromJson(Map<String, dynamic> json) =>
      AspectPairEntry(
        imperfective: json['imperfective'] as String,
        perfective: json['perfective'] as String,
        note: json['note'] as String?,
      );
}

/// An adjective with all three grammatical gender forms.
class AdjectiveEntry extends LangEntry {
  const AdjectiveEntry({
    required this.m,
    required this.f,
    required this.n,
    super.note,
  });

  /// Masculine form (citation/dictionary form).
  final String m;
  final String f;
  final String n;

  factory AdjectiveEntry.fromJson(Map<String, dynamic> json) => AdjectiveEntry(
        m: json['m'] as String,
        f: json['f'] as String,
        n: json['n'] as String,
        note: json['note'] as String?,
      );
}

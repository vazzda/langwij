import 'grammatical_gender.dart';
import 'verb_aspect.dart';

sealed class LangEntry {
  const LangEntry({this.note});

  final String? note;

  /// The one word that stands for the entry where a single word is shown:
  /// the text of a simple entry, the imperfective of an aspect pair, the
  /// masculine form of an adjective.
  String get headword;

  factory LangEntry.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('imperfective')) return AspectPairEntry.fromJson(json);
    if (json.containsKey('m')) return AdjectiveEntry.fromJson(json);
    return SimpleEntry.fromJson(json);
  }
}

class SimpleEntry extends LangEntry {
  const SimpleEntry({
    required this.text,
    this.gender,
    this.article,
    this.aspect,
    super.note,
  });

  final String text;

  /// The gender of a noun, in the languages whose nouns have one.
  final GrammaticalGender? gender;

  /// The article of a noun, in the languages that store it beside the gender.
  final String? article;

  /// The aspect of a verb that stands alone, where the files mark it.
  final VerbAspect? aspect;

  @override
  String get headword => text;

  factory SimpleEntry.fromJson(Map<String, dynamic> json) {
    final genderCode = json['gender'] as String?;
    final aspectCode = json['aspect'] as String?;

    return SimpleEntry(
      text: json['text'] as String,
      gender: genderCode == null ? null : GrammaticalGender.fromCode(genderCode),
      article: json['article'] as String?,
      aspect: aspectCode == null ? null : VerbAspect.values.byName(aspectCode),
      note: json['note'] as String?,
    );
  }
}

class AspectPairEntry extends LangEntry {
  const AspectPairEntry({
    required this.imperfective,
    required this.perfective,
    super.note,
  });

  final String imperfective;
  final String perfective;

  @override
  String get headword => imperfective;

  factory AspectPairEntry.fromJson(Map<String, dynamic> json) =>
      AspectPairEntry(
        imperfective: json['imperfective'] as String,
        perfective: json['perfective'] as String,
        note: json['note'] as String?,
      );
}

class AdjectiveEntry extends LangEntry {
  const AdjectiveEntry({
    required this.m,
    required this.f,
    this.n,
    super.note,
  });

  final String m;
  final String f;
  final String? n;

  @override
  String get headword => m;

  factory AdjectiveEntry.fromJson(Map<String, dynamic> json) => AdjectiveEntry(
        m: json['m'] as String,
        f: json['f'] as String,
        n: json['n'] as String?,
        note: json['note'] as String?,
      );
}

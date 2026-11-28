import 'grammatical_gender.dart';
import 'verb_aspect.dart';

sealed class LangEntry {
  const LangEntry({this.note});

  final String? note;

  /// The one word that stands for the entry where a single word is shown:
  /// the text of a simple entry, the imperfective of an aspect pair, the
  /// default form of a word stored with its gender forms.
  String get headword;

  factory LangEntry.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('imperfective')) return AspectPairEntry.fromJson(json);
    if (json.containsKey('m')) return GenderFormsEntry.fromJson(json);
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

/// A word that changes by gender, stored with one form for each gender: an
/// adjective, and the pronouns and numerals that change in the same way.
class GenderFormsEntry extends LangEntry {
  const GenderFormsEntry({
    required this.m,
    required this.f,
    this.n,
    this.defaultGender = GrammaticalGender.masculine,
    super.note,
  });

  final String m;
  final String f;
  final String? n;

  /// The gender whose form stands for the word. It is the masculine unless
  /// the `default` field of the translation files names another; the app's
  /// validator sees to it that the named form is one the entry holds.
  final GrammaticalGender defaultGender;

  /// Every form the entry holds, the masculine first.
  List<String> get forms {
    final neuterForm = n;
    return [m, f, if (neuterForm != null) neuterForm];
  }

  @override
  String get headword => switch (defaultGender) {
        GrammaticalGender.masculine => m,
        GrammaticalGender.feminine => f,
        GrammaticalGender.neuter => n!,
      };

  factory GenderFormsEntry.fromJson(Map<String, dynamic> json) {
    final defaultGenderCode = json['default'] as String?;

    return GenderFormsEntry(
      m: json['m'] as String,
      f: json['f'] as String,
      n: json['n'] as String?,
      defaultGender: defaultGenderCode == null
          ? GrammaticalGender.masculine
          : GrammaticalGender.fromCode(defaultGenderCode),
      note: json['note'] as String?,
    );
  }
}

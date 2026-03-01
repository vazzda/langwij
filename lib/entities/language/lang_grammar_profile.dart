import 'lang_codes.dart';

/// Describes the grammatical characteristics of a language that affect
/// how translation entries are structured and validated.
class LanguageGrammarProfile {
  const LanguageGrammarProfile({
    required this.hasNeuter,
    required this.hasAspectPairs,
  });

  /// Whether adjectives require a neuter gender form ("n" field).
  /// True for Serbian, Russian, German. False for Italian, English.
  final bool hasNeuter;

  /// Whether verbs use an imperfective/perfective aspect pair.
  /// Currently true only for Serbian.
  final bool hasAspectPairs;
}

/// Per-language grammar profiles. Add a new entry here when registering
/// a new language. Unknown languages fall back to [_default].
abstract final class LangGrammarProfiles {
  static const _default = LanguageGrammarProfile(
    hasNeuter: true,
    hasAspectPairs: false,
  );

  static const Map<String, LanguageGrammarProfile> _profiles = {
    LangCodes.english: LanguageGrammarProfile(
      hasNeuter: false,
      hasAspectPairs: false,
    ),
    LangCodes.serbian: LanguageGrammarProfile(
      hasNeuter: true,
      hasAspectPairs: true,
    ),
    LangCodes.russian: LanguageGrammarProfile(
      hasNeuter: true,
      hasAspectPairs: false,
    ),
    LangCodes.italian: LanguageGrammarProfile(
      hasNeuter: false,
      hasAspectPairs: false,
    ),
    LangCodes.french: LanguageGrammarProfile(
      hasNeuter: false,
      hasAspectPairs: false,
    ),
    LangCodes.spanish: LanguageGrammarProfile(
      hasNeuter: false,
      hasAspectPairs: false,
    ),
    LangCodes.portuguese: LanguageGrammarProfile(
      hasNeuter: false,
      hasAspectPairs: false,
    ),
    LangCodes.german: LanguageGrammarProfile(
      hasNeuter: true,
      hasAspectPairs: false,
    ),
  };

  static LanguageGrammarProfile of(String langCode) =>
      _profiles[langCode] ?? _default;
}

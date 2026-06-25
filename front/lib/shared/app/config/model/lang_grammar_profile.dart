import 'lang_codes.dart';

class LanguageGrammarProfile {
  const LanguageGrammarProfile({
    required this.hasNeuter,
    required this.hasAspectPairs,
  });

  final bool hasNeuter;
  final bool hasAspectPairs;
}

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

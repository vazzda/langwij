import 'lang_codes.dart';

/// User's language configuration.
class LanguageSettings {
  const LanguageSettings({
    required this.targetLang,
    required this.nativeLang,
    required this.uiLang,
  });

  /// Language the user is learning (e.g., "sr").
  final String targetLang;

  /// Language the user already knows — used as hint side of cards (e.g., "en").
  final String nativeLang;

  /// Language for the app UI — determines which ARB file is used (e.g., "en").
  final String uiLang;

  static const defaultSettings = LanguageSettings(
    targetLang: LangCodes.serbian,
    nativeLang: LangCodes.english,
    uiLang: LangCodes.english,
  );

  LanguageSettings copyWith({
    String? targetLang,
    String? nativeLang,
    String? uiLang,
  }) {
    return LanguageSettings(
      targetLang: targetLang ?? this.targetLang,
      nativeLang: nativeLang ?? this.nativeLang,
      uiLang: uiLang ?? this.uiLang,
    );
  }
}

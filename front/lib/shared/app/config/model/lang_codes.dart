abstract final class LangCodes {
  static const String english    = 'en';
  static const String serbian    = 'sr';
  static const String russian    = 'ru';
  static const String italian    = 'it';
  static const String french     = 'fr';
  static const String spanish    = 'es';
  static const String portuguese = 'pt';
  static const String german     = 'de';

  static String? flagCountryCode(String langCode) => const {
    english:    'GB',
    serbian:    'RS',
    russian:    'RU',
    italian:    'IT',
    french:     'FR',
    spanish:    'ES',
    portuguese: 'PT',
    german:     'DE',
  }[langCode];

  static const String _latinScriptCode = 'Latn';

  /// Script the interface is shown in, for languages whose platform default
  /// script differs from the one the dictionary is written in. Null means
  /// the platform default script.
  static String? interfaceScriptCodeForLanguageCode(String languageCode) => const {
    serbian: _latinScriptCode,
  }[languageCode];
}

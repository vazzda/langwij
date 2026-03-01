/// Canonical language code constants. Use these everywhere a language code
/// is needed as a string identifier — never raw literals like 'en' or 'sr'.
abstract final class LangCodes {
  static const String english    = 'en';
  static const String serbian    = 'sr';
  static const String russian    = 'ru';
  static const String italian    = 'it';
  static const String french     = 'fr';
  static const String spanish    = 'es';
  static const String portuguese = 'pt';
  static const String german     = 'de';

  /// Maps a language code to an ISO 3166-1 alpha-2 country code for flag display.
  /// Returns null for unknown codes.
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
}

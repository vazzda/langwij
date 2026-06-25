import 'app_localizations.dart';

extension AppLocalizationsLangLabel on AppLocalizations {
  /// Resolves a language labelKey (e.g., "lang_english") to its localized string.
  /// Throws [ArgumentError] on unknown key — never silently returns raw string.
  /// When adding a new language: add its ARB key AND a case here.
  String langLabel(String labelKey) {
    switch (labelKey) {
      case 'lang_english':
        return lang_english;
      case 'lang_serbian':
        return lang_serbian;
      case 'lang_russian':
        return lang_russian;
      case 'lang_italian':
        return lang_italian;
      case 'lang_french':
        return lang_french;
      case 'lang_spanish':
        return lang_spanish;
      case 'lang_portuguese':
        return lang_portuguese;
      case 'lang_german':
        return lang_german;
      default:
        throw ArgumentError(
          'langLabel: unknown labelKey "$labelKey" — add it to app_en.arb and this extension',
        );
    }
  }

  String groupLabel(String labelKey) {
    switch (labelKey) {
      case 'groupWords':
        return groupWords;
      case 'groupEndingsImEAti':
        return groupEndingsImEAti;
      case 'groupEndingsImEEti':
        return groupEndingsImEEti;
      case 'groupEndingsImEIti':
        return groupEndingsImEIti;
      case 'groupEndingsAmAju':
        return groupEndingsAmAju;
      case 'groupEndingsEmUGati':
        return groupEndingsEmUGati;
      case 'groupEndingsEmUHati':
        return groupEndingsEmUHati;
      case 'groupEndingsEmUKati':
        return groupEndingsEmUKati;
      case 'groupEndingsEmUAvati':
        return groupEndingsEmUAvati;
      case 'groupEndingsEmUIvati':
        return groupEndingsEmUIvati;
      case 'groupEndingsEmUOvati':
        return groupEndingsEmUOvati;
      case 'groupEndingsEmUCi':
        return groupEndingsEmUCi;
      case 'groupEndingsEmEju':
        return groupEndingsEmEju;
      case 'groupIrregular':
        return groupIrregular;
      default:
        return labelKey;
    }
  }
}

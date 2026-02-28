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
      default:
        throw ArgumentError(
          'langLabel: unknown labelKey "$labelKey" — add it to app_en.arb and this extension',
        );
    }
  }
}

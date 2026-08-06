import 'package:langwij/shared/app/config/config.dart';

/// Per-language pronunciation data. Values are working assumptions,
/// tuned per language from field experience — edit the maps, not call sites.
abstract final class PronunciationConfig {
  static const String wordToken = '{word}';

  static const String googleSearchHost = 'www.google.com';
  static const String googleSearchPath = '/search';
  static const String translateHost = 'translate.google.com';

  /// BCP-47 tags handed to the device speech engine.
  static const Map<String, String> speechLocales = {
    LangCodes.english:    'en-US',
    LangCodes.serbian:    'sr-RS',
    LangCodes.russian:    'ru-RU',
    LangCodes.italian:    'it-IT',
    LangCodes.french:     'fr-FR',
    LangCodes.spanish:    'es-ES',
    LangCodes.portuguese: 'pt-PT',
    LangCodes.german:     'de-DE',
  };

  /// Google search queries known to surface a dictionary box.
  /// A language absent here has no known define box (Serbian).
  static const Map<String, String> defineQueries = {
    LangCodes.english:    'define {word}',
    LangCodes.russian:    '{word} значение',
    LangCodes.italian:    '{word} significato',
    LangCodes.french:     '{word} définition',
    LangCodes.spanish:    '{word} significado',
    LangCodes.portuguese: '{word} significado',
    LangCodes.german:     '{word} bedeutung',
  };
}

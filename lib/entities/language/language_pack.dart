import 'lang_entry.dart';

/// A loaded language translation pack with completeness info.
///
/// Contains all translations for a single language, plus metadata
/// about how complete the pack is relative to the universal dictionary.
class LanguagePack {
  const LanguagePack({
    required this.code,
    required this.labelKey,
    required this.translations,
    required this.totalConcepts,
  });

  /// ISO-ish language code: "en", "sr", "ru".
  final String code;

  /// ARB key for the language's display name (e.g., "lang_english").
  final String labelKey;

  /// Concept ID → one translation entry per concept.
  final Map<String, LangEntry> translations;

  /// Total number of concepts in the universal dictionary.
  final int totalConcepts;

  /// How many concepts have at least one translation in this pack.
  int get translatedCount => translations.length;

  /// How many concepts are missing from this pack.
  int get missingCount => totalConcepts - translatedCount;

  /// Whether all dictionary concepts have translations.
  bool get isComplete => translatedCount >= totalConcepts;

  /// List of concept IDs that are missing translations.
  List<String> missingConcepts(Set<String> allConceptIds) {
    return allConceptIds
        .where((id) => !translations.containsKey(id))
        .toList();
  }
}

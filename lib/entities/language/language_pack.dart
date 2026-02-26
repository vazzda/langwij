import 'lang_entry.dart';
import '../level/level_meta.dart';

/// A loaded language translation pack with completeness info.
///
/// Contains all translations for a single language, plus localized metadata
/// for levels and groups (used for display names and descriptions).
class LanguagePack {
  const LanguagePack({
    required this.code,
    required this.labelKey,
    required this.translations,
    required this.totalConcepts,
    this.levelMeta = const {},
    this.groupMeta = const {},
  });

  /// ISO-ish language code: "en", "sr", "ru".
  final String code;

  /// ARB key for the language's display name (e.g., "lang_english").
  final String labelKey;

  /// Concept ID → one translation entry per concept.
  final Map<String, LangEntry> translations;

  /// Total number of concepts in the universal dictionary.
  final int totalConcepts;

  /// Level ID → localized display metadata (name, description).
  final Map<String, LevelMeta> levelMeta;

  /// Group ID → localized display metadata (name, description).
  final Map<String, GroupMeta> groupMeta;

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

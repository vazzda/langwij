import 'lang_entry.dart';
import '../level/level_meta.dart';

/// A loaded language translation pack with completeness info.
///
/// Contains all translations for a single language, plus localized metadata
/// for levels and decks (used for display names and descriptions).
class LanguagePack {
  const LanguagePack({
    required this.code,
    required this.labelKey,
    required this.isPublic,
    required this.translations,
    required this.totalTerms,
    this.levelMeta = const {},
    this.deckMeta = const {},
    required this.humanVerified,
    this.nativeNote,
  });

  /// ISO-ish language code: "en", "sr", "ru".
  final String code;

  /// ARB key for the language's display name (e.g., "lang_english").
  final String labelKey;

  /// Whether this pack is visible outside dev mode.
  final bool isPublic;

  /// Term ID → one translation entry per term.
  final Map<String, LangEntry> translations;

  /// Total number of terms in the universal dictionary.
  final int totalTerms;

  /// Level ID → localized display metadata (name, description).
  final Map<String, LevelMeta> levelMeta;

  /// Deck ID → localized display metadata (name, description).
  final Map<String, DeckMeta> deckMeta;

  /// Optional note shown when this language is selected as native.
  final String? nativeNote;

  /// Percentage of dictionary entries that are human-verified (0–100).
  final int humanVerified;

  /// How many terms have at least one translation in this pack.
  int get translatedCount => translations.length;

  /// How many terms are missing from this pack.
  int get missingCount => totalTerms - translatedCount;

  /// Whether all dictionary terms have translations.
  bool get isComplete => translatedCount >= totalTerms;

  /// List of term IDs that are missing translations.
  List<String> missingTerms(Set<String> allTermIds) {
    return allTermIds
        .where((id) => !translations.containsKey(id))
        .toList();
  }
}

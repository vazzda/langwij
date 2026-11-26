import 'deck_meta.dart';
import 'lang_entry.dart';
import 'level_meta.dart';
import 'plan_note.dart';
import 'vocabulary_level_segment_meta.dart';

class LanguagePack {
  const LanguagePack({
    required this.code,
    required this.labelKey,
    required this.isPublic,
    required this.translations,
    required this.totalTerms,
    this.levelMeta = const {},
    this.deckMeta = const {},
    this.vocabularyLevelSegmentMeta = const {},
    required this.humanVerified,
    required this.isAiGenerated,
    this.nativeNote,
  });

  final String code;
  final String labelKey;
  final bool isPublic;
  final Map<String, LangEntry> translations;
  final int totalTerms;
  final Map<String, LevelMeta> levelMeta;
  final Map<String, DeckMeta> deckMeta;
  final Map<String, VocabularyLevelSegmentMeta> vocabularyLevelSegmentMeta;

  /// The note for those who speak this language, or none.
  final PlanNote? nativeNote;
  final int humanVerified;

  /// Whether the language is listed among the AI generated ones, apart from
  /// the languages offered without that warning.
  final bool isAiGenerated;

  int get translatedCount => translations.length;
  int get missingCount => totalTerms - translatedCount;
  bool get isComplete => translatedCount >= totalTerms;

  List<String> missingTerms(Set<String> allTermIds) {
    return allTermIds
        .where((id) => !translations.containsKey(id))
        .toList();
  }
}

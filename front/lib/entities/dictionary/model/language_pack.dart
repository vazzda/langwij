import 'lang_entry.dart';
import 'level_meta.dart';

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

  final String code;
  final String labelKey;
  final bool isPublic;
  final Map<String, LangEntry> translations;
  final int totalTerms;
  final Map<String, LevelMeta> levelMeta;
  final Map<String, DeckMeta> deckMeta;
  final String? nativeNote;
  final int humanVerified;

  int get translatedCount => translations.length;
  int get missingCount => totalTerms - translatedCount;
  bool get isComplete => translatedCount >= totalTerms;

  List<String> missingTerms(Set<String> allTermIds) {
    return allTermIds
        .where((id) => !translations.containsKey(id))
        .toList();
  }
}

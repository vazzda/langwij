import 'dart:convert';

import 'package:flutter/services.dart';

import '../model/dictionary.dart';
import '../model/lang_entry.dart';
import '../model/language_entry.dart';
import '../model/language_pack.dart';
import '../model/deck_meta.dart';
import '../model/level_meta.dart';
import '../model/vocabulary_level_segment_meta.dart';

class DictionaryRepository {
  static const String _dictionaryPath = 'assets/data/dictionary.json';
  static const String _levelsPath     = 'assets/data/levels.json';
  static const String _translationsDir = 'assets/data/translations';

  static const String _metaJsonKey = 'meta';
  static const String _levelMetaJsonKey = 'levels';
  static const String _deckMetaJsonKey = 'decks';
  static const String _vocabularyLevelSegmentMetaJsonKey = 'segments';

  Dictionary? _cachedDictionary;
  final Map<String, LanguagePack> _cachedPacks = {};

  Future<Dictionary> loadDictionary() async {
    if (_cachedDictionary != null) return _cachedDictionary!;
    _cachedDictionary = Dictionary.fromDictionaryAndLevelsJson(
      dictionaryJson: await _loadJsonAsset(_dictionaryPath),
      levelsJson: await _loadJsonAsset(_levelsPath),
    );
    return _cachedDictionary!;
  }

  /// Loads the pack of one language of plan.json: its translations and
  /// names, with what the plan states about the language.
  Future<LanguagePack> loadLanguagePack(
    LanguageEntry languageEntry, {
    required bool isPublic,
  }) async {
    final langCode = languageEntry.code;
    if (_cachedPacks.containsKey(langCode)) return _cachedPacks[langCode]!;

    final dictionary = await loadDictionary();
    final translationDocument =
        await _loadJsonAsset('$_translationsDir/$langCode.json');
    final metaJson =
        translationDocument[_metaJsonKey] as Map<String, dynamic>? ?? const {};

    final pack = LanguagePack(
      code: langCode,
      labelKey: languageEntry.labelKey,
      isPublic: isPublic,
      translations: _parseTranslationsByTermId(translationDocument),
      totalTerms: dictionary.terms.length,
      levelMeta: _parseMetaEntriesById(
        metaJson,
        _levelMetaJsonKey,
        LevelMeta.fromJson,
      ),
      deckMeta: _parseMetaEntriesById(
        metaJson,
        _deckMetaJsonKey,
        DeckMeta.fromJson,
      ),
      vocabularyLevelSegmentMeta: _parseMetaEntriesById(
        metaJson,
        _vocabularyLevelSegmentMetaJsonKey,
        VocabularyLevelSegmentMeta.fromJson,
      ),
      nativeNote: languageEntry.nativeNote,
      humanVerified: languageEntry.humanVerified,
      isAiGenerated: languageEntry.isAiGenerated,
    );

    _cachedPacks[langCode] = pack;
    return pack;
  }

  Future<List<LanguagePack>> loadPacks(
    Iterable<LanguageEntry> entries,
    Set<String> publicCodes,
  ) async {
    final packs = <LanguagePack>[];
    for (final entry in entries) {
      packs.add(
        await loadLanguagePack(
          entry,
          isPublic: publicCodes.contains(entry.code),
        ),
      );
    }
    return packs;
  }

  static Future<Map<String, dynamic>> _loadJsonAsset(String assetPath) async {
    final assetText = await rootBundle.loadString(assetPath);
    return jsonDecode(assetText) as Map<String, dynamic>;
  }

  /// Every top-level entry of a translation file is a term translation,
  /// except the `meta` block.
  static Map<String, LangEntry> _parseTranslationsByTermId(
    Map<String, dynamic> translationDocument,
  ) {
    return {
      for (final documentEntry in translationDocument.entries)
        if (documentEntry.key != _metaJsonKey)
          documentEntry.key: LangEntry.fromJson(
            documentEntry.value as Map<String, dynamic>,
          ),
    };
  }

  /// Parses one block of the `meta` object (levels, decks or segments) into
  /// entries keyed by the id they describe. A missing block gives no entries.
  static Map<String, MetaEntry> _parseMetaEntriesById<MetaEntry>(
    Map<String, dynamic> metaJson,
    String metaBlockJsonKey,
    MetaEntry Function(Map<String, dynamic> metaEntryJson) parseMetaEntry,
  ) {
    final metaBlockJson =
        metaJson[metaBlockJsonKey] as Map<String, dynamic>? ?? const {};
    return {
      for (final metaBlockEntry in metaBlockJson.entries)
        metaBlockEntry.key: parseMetaEntry(
          metaBlockEntry.value as Map<String, dynamic>,
        ),
    };
  }
}

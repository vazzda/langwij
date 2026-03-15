import 'dart:convert';

import 'package:flutter/services.dart';

import '../../entities/language/dictionary.dart';
import '../../entities/language/lang_entry.dart';
import '../../entities/language/language_pack.dart';
import '../../entities/level/level_meta.dart';
import '../../entities/plan/language_entry.dart';

/// Loads the universal dictionary and per-language translation packs from assets.
class DictionaryRepository {
  static const String _dictionaryPath = 'assets/data/dictionary.json';
  static const String _levelsPath     = 'assets/data/levels.json';
  static const String _translationsDir = 'assets/data/translations';

  Dictionary? _cachedDictionary;
  final Map<String, LanguagePack> _cachedPacks = {};

  /// Loads the universal dictionary (terms + decks + levels).
  Future<Dictionary> loadDictionary() async {
    if (_cachedDictionary != null) return _cachedDictionary!;
    final termsJson = await rootBundle.loadString(_dictionaryPath);
    final levelsJson = await rootBundle.loadString(_levelsPath);
    final levelsData = jsonDecode(levelsJson) as Map<String, dynamic>;
    final data = <String, dynamic>{
      'terms':
          (jsonDecode(termsJson) as Map<String, dynamic>)['terms'],
      'decks': levelsData['decks'],
      'levels': levelsData['levels'],
    };
    _cachedDictionary = Dictionary.fromJson(data);
    return _cachedDictionary!;
  }

  /// Loads a language translation pack.
  /// [labelKey] must come from the plan (via [LanguageEntry]) — not looked up internally.
  Future<LanguagePack> loadLanguagePack(
    String langCode, {
    required String labelKey,
    required bool isPublic,
    required int humanVerified,
    String? nativeNote,
  }) async {
    if (_cachedPacks.containsKey(langCode)) return _cachedPacks[langCode]!;

    final dictionary = await loadDictionary();
    final path = '$_translationsDir/$langCode.json';
    final json = await rootBundle.loadString(path);
    final data = jsonDecode(json) as Map<String, dynamic>;

    final metaJson = data['meta'] as Map<String, dynamic>?;
    final levelMeta = <String, LevelMeta>{};
    final deckMeta = <String, DeckMeta>{};
    if (metaJson != null) {
      final levelsJson =
          metaJson['levels'] as Map<String, dynamic>? ?? const {};
      for (final e in levelsJson.entries) {
        levelMeta[e.key] = LevelMeta.fromJson(e.value as Map<String, dynamic>);
      }
      final decksJson =
          metaJson['decks'] as Map<String, dynamic>? ?? const {};
      for (final e in decksJson.entries) {
        deckMeta[e.key] = DeckMeta.fromJson(e.value as Map<String, dynamic>);
      }
    }

    final translations = <String, LangEntry>{};
    for (final entry in data.entries) {
      if (entry.key == 'meta') continue;
      translations[entry.key] =
          LangEntry.fromJson(entry.value as Map<String, dynamic>);
    }

    final pack = LanguagePack(
      code: langCode,
      labelKey: labelKey,
      isPublic: isPublic,
      translations: translations,
      totalTerms: dictionary.terms.length,
      levelMeta: levelMeta,
      deckMeta: deckMeta,
      nativeNote: nativeNote,
      humanVerified: humanVerified,
    );

    _cachedPacks[langCode] = pack;
    return pack;
  }

  /// Loads the given language entries, marking each as public or not.
  Future<List<LanguagePack>> loadPacks(
    Iterable<LanguageEntry> entries,
    Set<String> publicCodes,
  ) async {
    final packs = <LanguagePack>[];
    for (final entry in entries) {
      packs.add(
        await loadLanguagePack(
          entry.code,
          labelKey: entry.labelKey,
          isPublic: publicCodes.contains(entry.code),
          nativeNote: entry.nativeNote,
          humanVerified: entry.humanVerified,
        ),
      );
    }
    return packs;
  }
}

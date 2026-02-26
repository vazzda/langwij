import 'dart:convert';

import 'package:flutter/services.dart';

import '../../entities/language/dictionary.dart';
import '../../entities/language/lang_entry.dart';
import '../../entities/language/language_pack.dart';

/// Available language packs. Add entries here when adding a new language.
const _languagePacks = <String, String>{
  'en': 'lang_english',
  'sr': 'lang_serbian',
  'ru': 'lang_russian',
};

/// Available UI languages (those with complete ARB translations).
const availableUiLanguages = <String>['en'];

/// Loads the universal dictionary and per-language translation packs from assets.
class DictionaryRepository {
  static const String _dictionaryPath = 'assets/data/dictionary.json';
  static const String _translationsDir = 'assets/data/translations';

  Dictionary? _cachedDictionary;
  final Map<String, LanguagePack> _cachedPacks = {};

  /// Loads the universal dictionary (concepts + groups).
  Future<Dictionary> loadDictionary() async {
    if (_cachedDictionary != null) return _cachedDictionary!;
    final json = await rootBundle.loadString(_dictionaryPath);
    final data = jsonDecode(json) as Map<String, dynamic>;
    _cachedDictionary = Dictionary.fromJson(data);
    return _cachedDictionary!;
  }

  /// Loads a language translation pack.
  Future<LanguagePack> loadLanguagePack(String langCode) async {
    if (_cachedPacks.containsKey(langCode)) return _cachedPacks[langCode]!;

    final dictionary = await loadDictionary();
    final path = '$_translationsDir/$langCode.json';
    final json = await rootBundle.loadString(path);
    final data = jsonDecode(json) as Map<String, dynamic>;

    final translations = <String, LangEntry>{};
    for (final entry in data.entries) {
      translations[entry.key] =
          LangEntry.fromJson(entry.value as Map<String, dynamic>);
    }

    final pack = LanguagePack(
      code: langCode,
      labelKey: _languagePacks[langCode] ?? 'lang_$langCode',
      translations: translations,
      totalConcepts: dictionary.concepts.length,
    );

    _cachedPacks[langCode] = pack;
    return pack;
  }

  /// Loads all available language packs.
  Future<List<LanguagePack>> loadAllPacks() async {
    final packs = <LanguagePack>[];
    for (final code in _languagePacks.keys) {
      packs.add(await loadLanguagePack(code));
    }
    return packs;
  }

  /// Returns the set of all available language codes.
  Set<String> get availableLanguages => _languagePacks.keys.toSet();
}

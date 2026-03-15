import '../../entities/language/lang_grammar_profile.dart';

/// Thrown when any config file contains invalid or inconsistent data.
class ConfigValidationError implements Exception {
  const ConfigValidationError(this.message);
  final String message;

  @override
  String toString() => 'ConfigValidationError: $message';
}

/// Return type for [ConfigValidator.validateCore].
class CoreValidationIds {
  const CoreValidationIds({
    required this.termIds,
    required this.deckIds,
    required this.levelIds,
  });

  final Set<String> termIds;
  final Set<String> deckIds;
  final Set<String> levelIds;
}

/// Validates all config JSON maps and their cross-references.
/// Throws [ConfigValidationError] with exact file, field path, and bad value.
class ConfigValidator {
  static const _allowedPos = {'verb', 'noun', 'adjective', 'adverb', 'other'};

  /// Validates core config files (dictionary, levels, plan structure).
  /// Does NOT validate translation files or check that every declared
  /// language has a corresponding translation file.
  static CoreValidationIds validateCore({
    required Map<String, dynamic> planData,
    required Map<String, dynamic> dictionaryData,
    required Map<String, dynamic> levelsData,
  }) {
    final termIds = _validateDictionary(dictionaryData);
    final (deckIds, levelIds) = _validateLevels(levelsData, termIds);
    _validatePlanStructure(planData, levelIds);
    return CoreValidationIds(
      termIds: termIds,
      deckIds: deckIds,
      levelIds: levelIds,
    );
  }

  /// Validates a single translation file against dictionary/levels.
  static void validateTranslation(
    String langCode,
    Map<String, dynamic> data,
    Set<String> termIds,
    Set<String> levelIds,
    Set<String> deckIds,
  ) {
    _validateTranslation(
      langCode,
      data,
      termIds,
      levelIds,
      deckIds,
      LangGrammarProfiles.of(langCode),
    );
  }

  /// Full validation: core + all translations + plan↔translation cross-check.
  /// Used by the dev validation button — not at startup.
  static void validateAll({
    required Map<String, dynamic> planData,
    required Map<String, dynamic> dictionaryData,
    required Map<String, dynamic> levelsData,
    required Map<String, Map<String, dynamic>> translationsByCode,
  }) {
    final termIds = _validateDictionary(dictionaryData);
    final (deckIds, levelIds) = _validateLevels(levelsData, termIds);
    _validatePlanFull(planData, levelIds, translationsByCode.keys.toSet());
    for (final entry in translationsByCode.entries) {
      _validateTranslation(
        entry.key,
        entry.value,
        termIds,
        levelIds,
        deckIds,
        LangGrammarProfiles.of(entry.key),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // dictionary.json
  // ---------------------------------------------------------------------------

  static Set<String> _validateDictionary(Map<String, dynamic> data) {
    final termsRaw = data['terms'];
    if (termsRaw == null) {
      throw const ConfigValidationError(
        'dictionary.json: missing required key "terms"',
      );
    }
    if (termsRaw is! Map<String, dynamic>) {
      throw ConfigValidationError(
        'dictionary.json: "terms" must be an object, got ${termsRaw.runtimeType}',
      );
    }

    final termIds = <String>{};
    for (final entry in termsRaw.entries) {
      final id = entry.key;
      final value = entry.value;
      if (value is! Map<String, dynamic>) {
        throw ConfigValidationError(
          'dictionary.json: term "$id" must be an object',
        );
      }
      final pos = value['pos'];
      if (pos == null) {
        throw ConfigValidationError(
          'dictionary.json: term "$id" missing required field "pos"',
        );
      }
      if (!_allowedPos.contains(pos)) {
        throw ConfigValidationError(
          'dictionary.json: term "$id" has invalid pos "$pos". '
          'Allowed: ${_allowedPos.join(", ")}',
        );
      }
      termIds.add(id);
    }
    return termIds;
  }

  // ---------------------------------------------------------------------------
  // levels.json
  // ---------------------------------------------------------------------------

  static (Set<String>, Set<String>) _validateLevels(
    Map<String, dynamic> data,
    Set<String> termIds,
  ) {
    final deckIds = _validateDecks(data, termIds);
    final levelIds = _validateLevelsList(data, deckIds);
    return (deckIds, levelIds);
  }

  static Set<String> _validateDecks(
    Map<String, dynamic> data,
    Set<String> termIds,
  ) {
    final decksRaw = data['decks'];
    if (decksRaw == null) {
      throw const ConfigValidationError('levels.json: missing required key "decks"');
    }
    if (decksRaw is! List<dynamic>) {
      throw const ConfigValidationError('levels.json: "decks" must be an array');
    }

    final deckIds = <String>{};
    for (int i = 0; i < decksRaw.length; i++) {
      final deck = decksRaw[i];
      if (deck is! Map<String, dynamic>) {
        throw ConfigValidationError('levels.json: decks[$i] must be an object');
      }
      final id = deck['id'];
      if (id == null) {
        throw ConfigValidationError('levels.json: decks[$i] missing required field "id"');
      }
      if (id is! String) {
        throw ConfigValidationError('levels.json: decks[$i].id must be a string');
      }
      if (deckIds.contains(id)) {
        throw ConfigValidationError('levels.json: duplicate deck id "$id"');
      }
      final terms = deck['terms'];
      if (terms == null) {
        throw ConfigValidationError(
          'levels.json: deck "$id" missing required field "terms"',
        );
      }
      if (terms is! List<dynamic>) {
        throw ConfigValidationError(
          'levels.json: deck "$id".terms must be an array',
        );
      }
      for (int j = 0; j < terms.length; j++) {
        final termId = terms[j];
        if (termId is! String) {
          throw ConfigValidationError(
            'levels.json: deck "$id".terms[$j] must be a string',
          );
        }
        if (!termIds.contains(termId)) {
          throw ConfigValidationError(
            'levels.json: deck "$id".terms[$j] = "$termId" does not exist in dictionary.json',
          );
        }
      }
      deckIds.add(id);
    }
    return deckIds;
  }

  static Set<String> _validateLevelsList(
    Map<String, dynamic> data,
    Set<String> deckIds,
  ) {
    final levelsRaw = data['levels'];
    if (levelsRaw == null) {
      throw const ConfigValidationError('levels.json: missing required key "levels"');
    }
    if (levelsRaw is! List<dynamic>) {
      throw const ConfigValidationError('levels.json: "levels" must be an array');
    }

    final levelIds = <String>{};
    for (int i = 0; i < levelsRaw.length; i++) {
      final level = levelsRaw[i];
      if (level is! Map<String, dynamic>) {
        throw ConfigValidationError('levels.json: levels[$i] must be an object');
      }
      final id = level['id'];
      if (id == null) {
        throw ConfigValidationError('levels.json: levels[$i] missing required field "id"');
      }
      if (id is! String) {
        throw ConfigValidationError('levels.json: levels[$i].id must be a string');
      }
      if (levelIds.contains(id)) {
        throw ConfigValidationError('levels.json: duplicate level id "$id"');
      }
      final decks = level['decks'];
      if (decks == null) {
        throw ConfigValidationError(
          'levels.json: level "$id" missing required field "decks"',
        );
      }
      if (decks is! List<dynamic>) {
        throw ConfigValidationError('levels.json: level "$id".decks must be an array');
      }
      for (int j = 0; j < decks.length; j++) {
        final deckId = decks[j];
        if (deckId is! String) {
          throw ConfigValidationError(
            'levels.json: level "$id".decks[$j] must be a string',
          );
        }
        if (!deckIds.contains(deckId)) {
          throw ConfigValidationError(
            'levels.json: level "$id".decks[$j] = "$deckId" does not exist in decks',
          );
        }
      }
      levelIds.add(id);
    }
    return levelIds;
  }

  // ---------------------------------------------------------------------------
  // plan.json
  // ---------------------------------------------------------------------------

  /// Validates plan structure only (language entries, public/ui lists, courses).
  /// Does NOT check that every declared language has a translation file.
  static void _validatePlanStructure(
    Map<String, dynamic> data,
    Set<String> levelIds,
  ) {
    final declaredCodes = _validatePlanLanguageEntries(data);
    _validatePlanPublicLanguages(data, declaredCodes);
    _validatePlanUiLanguages(data, declaredCodes);
    _validatePlanCourses(data, levelIds);
  }

  /// Full plan validation — also checks every declared language has a loaded
  /// translation file. Used by [validateAll] only.
  static void _validatePlanFull(
    Map<String, dynamic> data,
    Set<String> levelIds,
    Set<String> loadedCodes,
  ) {
    final declaredCodes = _validatePlanLanguageEntries(data);
    for (final code in declaredCodes) {
      if (!loadedCodes.contains(code)) {
        throw ConfigValidationError(
          'plan.json: language "$code" declared but '
          'no translation file found at assets/data/translations/$code.json',
        );
      }
    }
    _validatePlanPublicLanguages(data, declaredCodes);
    _validatePlanUiLanguages(data, declaredCodes);
    _validatePlanCourses(data, levelIds);
  }

  /// Validates language entries structure. Returns declared codes.
  static Set<String> _validatePlanLanguageEntries(Map<String, dynamic> data) {
    final langsRaw = data['languages'];
    if (langsRaw == null) {
      throw const ConfigValidationError('plan.json: missing required key "languages"');
    }
    if (langsRaw is! List<dynamic>) {
      throw const ConfigValidationError('plan.json: "languages" must be an array');
    }

    final declaredCodes = <String>{};
    for (int i = 0; i < langsRaw.length; i++) {
      final lang = langsRaw[i];
      if (lang is! Map<String, dynamic>) {
        throw ConfigValidationError('plan.json: languages[$i] must be an object');
      }
      final code = lang['code'];
      if (code == null) {
        throw ConfigValidationError(
          'plan.json: languages[$i] missing required field "code"',
        );
      }
      if (code is! String) {
        throw ConfigValidationError('plan.json: languages[$i].code must be a string');
      }
      final labelKey = lang['labelKey'];
      if (labelKey == null) {
        throw ConfigValidationError(
          'plan.json: languages[$i] (code="$code") missing required field "labelKey"',
        );
      }
      if (labelKey is! String) {
        throw ConfigValidationError(
          'plan.json: languages[$i].labelKey must be a string',
        );
      }
      final nativeNote = lang['nativeNote'];
      if (nativeNote != null && nativeNote is! String) {
        throw ConfigValidationError(
          'plan.json: languages[$i].nativeNote must be a string',
        );
      }
      final humanVerified = lang['humanVerified'];
      if (humanVerified == null) {
        throw ConfigValidationError(
          'plan.json: languages[$i] (code="$code") missing required field "humanVerified"',
        );
      }
      if (humanVerified is! int) {
        throw ConfigValidationError(
          'plan.json: languages[$i].humanVerified must be an integer',
        );
      }
      if (humanVerified < 0 || humanVerified > 100) {
        throw ConfigValidationError(
          'plan.json: languages[$i].humanVerified must be 0–100, got $humanVerified',
        );
      }
      if (declaredCodes.contains(code)) {
        throw ConfigValidationError('plan.json: duplicate language code "$code"');
      }
      declaredCodes.add(code);
    }
    return declaredCodes;
  }

  static void _validatePlanPublicLanguages(
    Map<String, dynamic> data,
    Set<String> declaredCodes,
  ) {
    final publicLangs = data['public_languages'];
    if (publicLangs == null) {
      throw const ConfigValidationError(
        'plan.json: missing required key "public_languages"',
      );
    }
    if (publicLangs is! List<dynamic>) {
      throw const ConfigValidationError(
        'plan.json: "public_languages" must be an array',
      );
    }
    for (int i = 0; i < publicLangs.length; i++) {
      final code = publicLangs[i];
      if (code is! String) {
        throw ConfigValidationError('plan.json: public_languages[$i] must be a string');
      }
      if (!declaredCodes.contains(code)) {
        throw ConfigValidationError(
          'plan.json: public_languages[$i] = "$code" is not declared in "languages"',
        );
      }
    }
  }

  static void _validatePlanUiLanguages(
    Map<String, dynamic> data,
    Set<String> declaredCodes,
  ) {
    final uiLangs = data['ui_languages'];
    if (uiLangs == null) {
      throw const ConfigValidationError('plan.json: missing required key "ui_languages"');
    }
    if (uiLangs is! List<dynamic>) {
      throw const ConfigValidationError('plan.json: "ui_languages" must be an array');
    }
    for (int i = 0; i < uiLangs.length; i++) {
      final code = uiLangs[i];
      if (code is! String) {
        throw ConfigValidationError('plan.json: ui_languages[$i] must be a string');
      }
      if (!declaredCodes.contains(code)) {
        throw ConfigValidationError(
          'plan.json: ui_languages[$i] = "$code" is not declared in "languages"',
        );
      }
    }
  }

  static void _validatePlanCourses(
    Map<String, dynamic> data,
    Set<String> levelIds,
  ) {
    final coursesRaw = data['courses'];
    if (coursesRaw == null) {
      throw const ConfigValidationError('plan.json: missing required key "courses"');
    }
    if (coursesRaw is! Map<String, dynamic>) {
      throw const ConfigValidationError('plan.json: "courses" must be an object');
    }
    for (final courseEntry in coursesRaw.entries) {
      final courseId = courseEntry.key;
      final course = courseEntry.value;
      if (course is! Map<String, dynamic>) {
        throw ConfigValidationError('plan.json: course "$courseId" must be an object');
      }
      final note = course['note'];
      if (note != null && note is! String) {
        throw ConfigValidationError(
          'plan.json: course "$courseId".note must be a string',
        );
      }
      final free = course['free'];
      if (free == null) {
        throw ConfigValidationError(
          'plan.json: course "$courseId" missing required key "free"',
        );
      }
      if (free is! List<dynamic>) {
        throw ConfigValidationError(
          'plan.json: course "$courseId".free must be an array',
        );
      }
      for (int i = 0; i < free.length; i++) {
        final levelId = free[i];
        if (levelId is! String) {
          throw ConfigValidationError(
            'plan.json: course "$courseId".free[$i] must be a string',
          );
        }
        if (!levelIds.contains(levelId)) {
          throw ConfigValidationError(
            'plan.json: course "$courseId".free[$i] = "$levelId" does not exist in levels.json',
          );
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // translations/{code}.json
  // ---------------------------------------------------------------------------

  static void _validateTranslation(
    String langCode,
    Map<String, dynamic> data,
    Set<String> termIds,
    Set<String> levelIds,
    Set<String> deckIds,
    LanguageGrammarProfile profile,
  ) {
    for (final entry in data.entries) {
      if (entry.key == 'meta') continue;
      final termId = entry.key;
      if (!termIds.contains(termId)) {
        throw ConfigValidationError(
          'translations/$langCode.json: key "$termId" does not exist in dictionary.json',
        );
      }
      final value = entry.value;
      if (value is! Map<String, dynamic>) {
        throw ConfigValidationError(
          'translations/$langCode.json: entry "$termId" must be an object',
        );
      }
      _validateLangEntry(langCode, termId, value, profile);
    }

    final meta = data['meta'];
    if (meta == null) return;
    if (meta is! Map<String, dynamic>) {
      throw ConfigValidationError(
        'translations/$langCode.json: "meta" must be an object',
      );
    }
    _validateTranslationMeta(langCode, meta, levelIds, deckIds);
  }

  static void _validateTranslationMeta(
    String langCode,
    Map<String, dynamic> meta,
    Set<String> levelIds,
    Set<String> deckIds,
  ) {
    final levelsMetaRaw = meta['levels'];
    if (levelsMetaRaw != null) {
      if (levelsMetaRaw is! Map<String, dynamic>) {
        throw ConfigValidationError(
          'translations/$langCode.json: meta.levels must be an object',
        );
      }
      for (final e in levelsMetaRaw.entries) {
        if (!levelIds.contains(e.key)) {
          throw ConfigValidationError(
            'translations/$langCode.json: meta.levels["${e.key}"] does not exist in levels.json',
          );
        }
        final entry = e.value;
        if (entry is! Map<String, dynamic>) {
          throw ConfigValidationError(
            'translations/$langCode.json: meta.levels["${e.key}"] must be an object',
          );
        }
        if (entry['name'] == null) {
          throw ConfigValidationError(
            'translations/$langCode.json: meta.levels["${e.key}"] missing required field "name"',
          );
        }
      }
    }

    final decksMetaRaw = meta['decks'];
    if (decksMetaRaw != null) {
      if (decksMetaRaw is! Map<String, dynamic>) {
        throw ConfigValidationError(
          'translations/$langCode.json: meta.decks must be an object',
        );
      }
      for (final e in decksMetaRaw.entries) {
        if (!deckIds.contains(e.key)) {
          throw ConfigValidationError(
            'translations/$langCode.json: meta.decks["${e.key}"] does not exist in levels.json',
          );
        }
        final entry = e.value;
        if (entry is! Map<String, dynamic>) {
          throw ConfigValidationError(
            'translations/$langCode.json: meta.decks["${e.key}"] must be an object',
          );
        }
        if (entry['name'] == null) {
          throw ConfigValidationError(
            'translations/$langCode.json: meta.decks["${e.key}"] missing required field "name"',
          );
        }
      }
    }
  }

  static void _validateLangEntry(
    String langCode,
    String termId,
    Map<String, dynamic> entry,
    LanguageGrammarProfile profile,
  ) {
    if (entry.containsKey('imperfective') || entry.containsKey('perfective')) {
      if (!entry.containsKey('imperfective')) {
        throw ConfigValidationError(
          'translations/$langCode.json: "$termId" has "perfective" but missing "imperfective"',
        );
      }
      if (!entry.containsKey('perfective')) {
        throw ConfigValidationError(
          'translations/$langCode.json: "$termId" has "imperfective" but missing "perfective"',
        );
      }
      if (entry['imperfective'] is! String) {
        throw ConfigValidationError(
          'translations/$langCode.json: "$termId".imperfective must be a string',
        );
      }
      if (entry['perfective'] is! String) {
        throw ConfigValidationError(
          'translations/$langCode.json: "$termId".perfective must be a string',
        );
      }
    } else if (entry.containsKey('m') || entry.containsKey('f') || entry.containsKey('n')) {
      if (!entry.containsKey('m')) {
        throw ConfigValidationError(
          'translations/$langCode.json: "$termId" (adjective) missing required field "m"',
        );
      }
      if (!entry.containsKey('f')) {
        throw ConfigValidationError(
          'translations/$langCode.json: "$termId" (adjective) missing required field "f"',
        );
      }
      if (profile.hasNeuter && !entry.containsKey('n')) {
        throw ConfigValidationError(
          'translations/$langCode.json: "$termId" (adjective) missing required field "n"',
        );
      }
      if (entry['m'] is! String) {
        throw ConfigValidationError(
          'translations/$langCode.json: "$termId".m must be a string',
        );
      }
      if (entry['f'] is! String) {
        throw ConfigValidationError(
          'translations/$langCode.json: "$termId".f must be a string',
        );
      }
      if (entry.containsKey('n') && entry['n'] is! String) {
        throw ConfigValidationError(
          'translations/$langCode.json: "$termId".n must be a string',
        );
      }
    } else {
      if (!entry.containsKey('text')) {
        throw ConfigValidationError(
          'translations/$langCode.json: "$termId" (simple) missing required field "text"',
        );
      }
      if (entry['text'] is! String) {
        throw ConfigValidationError(
          'translations/$langCode.json: "$termId".text must be a string',
        );
      }
    }
  }
}

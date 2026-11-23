import 'package:langwij/shared/app/config/config.dart';

import '../model/config_validation_error.dart';
import '../model/core_validation_ids.dart';

class ConfigValidationService {
  static const _allowedPos = {'verb', 'noun', 'adjective', 'adverb', 'pronoun', 'conjunction', 'preposition', 'numeral', 'phrase', 'interrogative'};

  static const String _levelsMetaBlockKey = 'levels';
  static const String _decksMetaBlockKey = 'decks';
  static const String _segmentsMetaBlockKey = 'segments';

  static CoreValidationIds validateCore({
    required Map<String, dynamic> planData,
    required Map<String, dynamic> dictionaryData,
    required Map<String, dynamic> levelsData,
  }) {
    final coreIds = _validateDictionaryAndLevels(dictionaryData, levelsData);
    _validatePlanStructure(planData, coreIds.levelIds);
    return coreIds;
  }

  static void validateTranslation(
    String langCode,
    Map<String, dynamic> data,
    CoreValidationIds coreIds,
  ) {
    _validateTranslation(
      langCode,
      data,
      coreIds,
      LangGrammarProfiles.of(langCode),
    );
  }

  static void validateAll({
    required Map<String, dynamic> planData,
    required Map<String, dynamic> dictionaryData,
    required Map<String, dynamic> levelsData,
    required Map<String, Map<String, dynamic>> translationsByCode,
  }) {
    final coreIds = _validateDictionaryAndLevels(dictionaryData, levelsData);
    _validatePlanFull(
      planData,
      coreIds.levelIds,
      translationsByCode.keys.toSet(),
    );
    for (final entry in translationsByCode.entries) {
      _validateTranslation(
        entry.key,
        entry.value,
        coreIds,
        LangGrammarProfiles.of(entry.key),
      );
    }
  }

  static CoreValidationIds _validateDictionaryAndLevels(
    Map<String, dynamic> dictionaryData,
    Map<String, dynamic> levelsData,
  ) {
    final termIds = _validateDictionary(dictionaryData);
    final deckIds = _validateDecks(levelsData, termIds);
    final levelIds = _validateLevelsList(levelsData, deckIds);
    final segmentIds = _validateSegmentsList(levelsData, levelIds);
    return CoreValidationIds(
      termIds: termIds,
      deckIds: deckIds,
      levelIds: levelIds,
      segmentIds: segmentIds,
    );
  }

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

  static Set<String> _validateSegmentsList(
    Map<String, dynamic> data,
    Set<String> levelIds,
  ) {
    final segmentsRaw = data['segments'];
    if (segmentsRaw == null) {
      throw const ConfigValidationError('levels.json: missing required key "segments"');
    }
    if (segmentsRaw is! List<dynamic>) {
      throw const ConfigValidationError('levels.json: "segments" must be an array');
    }

    final segmentIds = <String>{};
    final segmentIdByLevelId = <String, String>{};
    for (int i = 0; i < segmentsRaw.length; i++) {
      final segment = segmentsRaw[i];
      if (segment is! Map<String, dynamic>) {
        throw ConfigValidationError('levels.json: segments[$i] must be an object');
      }
      final id = segment['id'];
      if (id == null) {
        throw ConfigValidationError('levels.json: segments[$i] missing required field "id"');
      }
      if (id is! String) {
        throw ConfigValidationError('levels.json: segments[$i].id must be a string');
      }
      if (segmentIds.contains(id)) {
        throw ConfigValidationError('levels.json: duplicate segment id "$id"');
      }
      final levels = segment['levels'];
      if (levels == null) {
        throw ConfigValidationError(
          'levels.json: segment "$id" missing required field "levels"',
        );
      }
      if (levels is! List<dynamic>) {
        throw ConfigValidationError('levels.json: segment "$id".levels must be an array');
      }
      for (int j = 0; j < levels.length; j++) {
        final levelId = levels[j];
        if (levelId is! String) {
          throw ConfigValidationError(
            'levels.json: segment "$id".levels[$j] must be a string',
          );
        }
        if (!levelIds.contains(levelId)) {
          throw ConfigValidationError(
            'levels.json: segment "$id".levels[$j] = "$levelId" does not exist in levels',
          );
        }
        final segmentIdAlreadyListingLevel = segmentIdByLevelId[levelId];
        if (segmentIdAlreadyListingLevel != null) {
          throw ConfigValidationError(
            'levels.json: segment "$id".levels[$j] = "$levelId" is already listed '
            'in segment "$segmentIdAlreadyListingLevel"',
          );
        }
        segmentIdByLevelId[levelId] = id;
      }
      segmentIds.add(id);
    }
    return segmentIds;
  }

  static void _validatePlanStructure(
    Map<String, dynamic> data,
    Set<String> levelIds,
  ) {
    final declaredCodes = _validatePlanLanguageEntries(data);
    _validatePlanPublicLanguages(data, declaredCodes);
    _validatePlanCourses(data, levelIds);
  }

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
    _validatePlanCourses(data, levelIds);
  }

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

  static void _validateTranslation(
    String langCode,
    Map<String, dynamic> data,
    CoreValidationIds coreIds,
    LanguageGrammarProfile profile,
  ) {
    for (final entry in data.entries) {
      if (entry.key == 'meta') continue;
      final termId = entry.key;
      if (!coreIds.termIds.contains(termId)) {
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
    _validateTranslationMeta(langCode, meta, coreIds);
  }

  static void _validateTranslationMeta(
    String langCode,
    Map<String, dynamic> meta,
    CoreValidationIds coreIds,
  ) {
    _validateTranslationMetaBlock(
      langCode,
      meta,
      metaBlockKey: _levelsMetaBlockKey,
      idsDeclaredInLevelsFile: coreIds.levelIds,
    );
    _validateTranslationMetaBlock(
      langCode,
      meta,
      metaBlockKey: _decksMetaBlockKey,
      idsDeclaredInLevelsFile: coreIds.deckIds,
    );
    _validateTranslationMetaBlock(
      langCode,
      meta,
      metaBlockKey: _segmentsMetaBlockKey,
      idsDeclaredInLevelsFile: coreIds.segmentIds,
    );
  }

  /// Checks one optional block of `meta` (levels, decks or segments): every
  /// key is an id declared in levels.json and every entry carries a name.
  static void _validateTranslationMetaBlock(
    String langCode,
    Map<String, dynamic> meta, {
    required String metaBlockKey,
    required Set<String> idsDeclaredInLevelsFile,
  }) {
    final metaBlockRaw = meta[metaBlockKey];
    if (metaBlockRaw == null) return;
    if (metaBlockRaw is! Map<String, dynamic>) {
      throw ConfigValidationError(
        'translations/$langCode.json: meta.$metaBlockKey must be an object',
      );
    }
    for (final metaBlockEntry in metaBlockRaw.entries) {
      final describedId = metaBlockEntry.key;
      if (!idsDeclaredInLevelsFile.contains(describedId)) {
        throw ConfigValidationError(
          'translations/$langCode.json: meta.$metaBlockKey["$describedId"] does not exist in levels.json',
        );
      }
      final metaEntry = metaBlockEntry.value;
      if (metaEntry is! Map<String, dynamic>) {
        throw ConfigValidationError(
          'translations/$langCode.json: meta.$metaBlockKey["$describedId"] must be an object',
        );
      }
      if (metaEntry['name'] == null) {
        throw ConfigValidationError(
          'translations/$langCode.json: meta.$metaBlockKey["$describedId"] missing required field "name"',
        );
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

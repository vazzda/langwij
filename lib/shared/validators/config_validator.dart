/// Thrown when any config file contains invalid or inconsistent data.
class ConfigValidationError implements Exception {
  const ConfigValidationError(this.message);
  final String message;

  @override
  String toString() => 'ConfigValidationError: $message';
}

/// Validates all config JSON maps and their cross-references.
/// Call [validateAll] with already-decoded maps — it throws [ConfigValidationError]
/// with the exact file, field path, and bad value on any issue.
class ConfigValidator {
  static const _allowedPos = {'verb', 'noun', 'adjective', 'adverb', 'other'};

  static void validateAll({
    required Map<String, dynamic> planData,
    required Map<String, dynamic> dictionaryData,
    required Map<String, dynamic> levelsData,
    required Map<String, Map<String, dynamic>> translationsByCode,
  }) {
    final conceptIds = _validateDictionary(dictionaryData);
    final (groupIds, levelIds) = _validateLevels(levelsData, conceptIds);
    _validatePlan(planData, levelIds, translationsByCode.keys.toSet());
    for (final entry in translationsByCode.entries) {
      _validateTranslation(entry.key, entry.value, conceptIds, levelIds, groupIds);
    }
  }

  // ---------------------------------------------------------------------------
  // dictionary.json
  // ---------------------------------------------------------------------------

  static Set<String> _validateDictionary(Map<String, dynamic> data) {
    final conceptsRaw = data['concepts'];
    if (conceptsRaw == null) {
      throw const ConfigValidationError(
        'dictionary.json: missing required key "concepts"',
      );
    }
    if (conceptsRaw is! Map<String, dynamic>) {
      throw ConfigValidationError(
        'dictionary.json: "concepts" must be an object, got ${conceptsRaw.runtimeType}',
      );
    }

    final conceptIds = <String>{};
    for (final entry in conceptsRaw.entries) {
      final id = entry.key;
      final value = entry.value;
      if (value is! Map<String, dynamic>) {
        throw ConfigValidationError(
          'dictionary.json: concept "$id" must be an object',
        );
      }
      final pos = value['pos'];
      if (pos == null) {
        throw ConfigValidationError(
          'dictionary.json: concept "$id" missing required field "pos"',
        );
      }
      if (!_allowedPos.contains(pos)) {
        throw ConfigValidationError(
          'dictionary.json: concept "$id" has invalid pos "$pos". '
          'Allowed: ${_allowedPos.join(", ")}',
        );
      }
      conceptIds.add(id);
    }
    return conceptIds;
  }

  // ---------------------------------------------------------------------------
  // levels.json
  // ---------------------------------------------------------------------------

  static (Set<String>, Set<String>) _validateLevels(
    Map<String, dynamic> data,
    Set<String> conceptIds,
  ) {
    final groupIds = _validateGroups(data, conceptIds);
    final levelIds = _validateLevelsList(data, groupIds);
    return (groupIds, levelIds);
  }

  static Set<String> _validateGroups(
    Map<String, dynamic> data,
    Set<String> conceptIds,
  ) {
    final groupsRaw = data['groups'];
    if (groupsRaw == null) {
      throw const ConfigValidationError('levels.json: missing required key "groups"');
    }
    if (groupsRaw is! List<dynamic>) {
      throw const ConfigValidationError('levels.json: "groups" must be an array');
    }

    final groupIds = <String>{};
    for (int i = 0; i < groupsRaw.length; i++) {
      final group = groupsRaw[i];
      if (group is! Map<String, dynamic>) {
        throw ConfigValidationError('levels.json: groups[$i] must be an object');
      }
      final id = group['id'];
      if (id == null) {
        throw ConfigValidationError('levels.json: groups[$i] missing required field "id"');
      }
      if (id is! String) {
        throw ConfigValidationError('levels.json: groups[$i].id must be a string');
      }
      if (groupIds.contains(id)) {
        throw ConfigValidationError('levels.json: duplicate group id "$id"');
      }
      final concepts = group['concepts'];
      if (concepts == null) {
        throw ConfigValidationError(
          'levels.json: group "$id" missing required field "concepts"',
        );
      }
      if (concepts is! List<dynamic>) {
        throw ConfigValidationError(
          'levels.json: group "$id".concepts must be an array',
        );
      }
      for (int j = 0; j < concepts.length; j++) {
        final conceptId = concepts[j];
        if (conceptId is! String) {
          throw ConfigValidationError(
            'levels.json: group "$id".concepts[$j] must be a string',
          );
        }
        if (!conceptIds.contains(conceptId)) {
          throw ConfigValidationError(
            'levels.json: group "$id".concepts[$j] = "$conceptId" does not exist in dictionary.json',
          );
        }
      }
      groupIds.add(id);
    }
    return groupIds;
  }

  static Set<String> _validateLevelsList(
    Map<String, dynamic> data,
    Set<String> groupIds,
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
      final groups = level['groups'];
      if (groups == null) {
        throw ConfigValidationError(
          'levels.json: level "$id" missing required field "groups"',
        );
      }
      if (groups is! List<dynamic>) {
        throw ConfigValidationError('levels.json: level "$id".groups must be an array');
      }
      for (int j = 0; j < groups.length; j++) {
        final groupId = groups[j];
        if (groupId is! String) {
          throw ConfigValidationError(
            'levels.json: level "$id".groups[$j] must be a string',
          );
        }
        if (!groupIds.contains(groupId)) {
          throw ConfigValidationError(
            'levels.json: level "$id".groups[$j] = "$groupId" does not exist in groups',
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

  static void _validatePlan(
    Map<String, dynamic> data,
    Set<String> levelIds,
    Set<String> loadedCodes,
  ) {
    final declaredCodes = _validatePlanLanguages(data, loadedCodes);
    _validatePlanPublicLanguages(data, declaredCodes);
    _validatePlanUiLanguages(data, declaredCodes);
    _validatePlanCourses(data, levelIds);
  }

  static Set<String> _validatePlanLanguages(
    Map<String, dynamic> data,
    Set<String> loadedCodes,
  ) {
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
      if (!loadedCodes.contains(code)) {
        throw ConfigValidationError(
          'plan.json: languages[$i].code = "$code" — '
          'no translation file found at assets/data/translations/$code.json',
        );
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
    Set<String> conceptIds,
    Set<String> levelIds,
    Set<String> groupIds,
  ) {
    for (final entry in data.entries) {
      if (entry.key == 'meta') continue;
      final conceptId = entry.key;
      if (!conceptIds.contains(conceptId)) {
        throw ConfigValidationError(
          'translations/$langCode.json: key "$conceptId" does not exist in dictionary.json',
        );
      }
      final value = entry.value;
      if (value is! Map<String, dynamic>) {
        throw ConfigValidationError(
          'translations/$langCode.json: entry "$conceptId" must be an object',
        );
      }
      _validateLangEntry(langCode, conceptId, value);
    }

    final meta = data['meta'];
    if (meta == null) return;
    if (meta is! Map<String, dynamic>) {
      throw ConfigValidationError(
        'translations/$langCode.json: "meta" must be an object',
      );
    }
    _validateTranslationMeta(langCode, meta, levelIds, groupIds);
  }

  static void _validateTranslationMeta(
    String langCode,
    Map<String, dynamic> meta,
    Set<String> levelIds,
    Set<String> groupIds,
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

    final groupsMetaRaw = meta['groups'];
    if (groupsMetaRaw != null) {
      if (groupsMetaRaw is! Map<String, dynamic>) {
        throw ConfigValidationError(
          'translations/$langCode.json: meta.groups must be an object',
        );
      }
      for (final e in groupsMetaRaw.entries) {
        if (!groupIds.contains(e.key)) {
          throw ConfigValidationError(
            'translations/$langCode.json: meta.groups["${e.key}"] does not exist in levels.json',
          );
        }
        final entry = e.value;
        if (entry is! Map<String, dynamic>) {
          throw ConfigValidationError(
            'translations/$langCode.json: meta.groups["${e.key}"] must be an object',
          );
        }
        if (entry['name'] == null) {
          throw ConfigValidationError(
            'translations/$langCode.json: meta.groups["${e.key}"] missing required field "name"',
          );
        }
      }
    }
  }

  static void _validateLangEntry(
    String langCode,
    String conceptId,
    Map<String, dynamic> entry,
  ) {
    if (entry.containsKey('imperfective') || entry.containsKey('perfective')) {
      if (!entry.containsKey('imperfective')) {
        throw ConfigValidationError(
          'translations/$langCode.json: "$conceptId" has "perfective" but missing "imperfective"',
        );
      }
      if (!entry.containsKey('perfective')) {
        throw ConfigValidationError(
          'translations/$langCode.json: "$conceptId" has "imperfective" but missing "perfective"',
        );
      }
      if (entry['imperfective'] is! String) {
        throw ConfigValidationError(
          'translations/$langCode.json: "$conceptId".imperfective must be a string',
        );
      }
      if (entry['perfective'] is! String) {
        throw ConfigValidationError(
          'translations/$langCode.json: "$conceptId".perfective must be a string',
        );
      }
    } else if (entry.containsKey('m') || entry.containsKey('f') || entry.containsKey('n')) {
      if (!entry.containsKey('m')) {
        throw ConfigValidationError(
          'translations/$langCode.json: "$conceptId" (adjective) missing required field "m"',
        );
      }
      if (!entry.containsKey('f')) {
        throw ConfigValidationError(
          'translations/$langCode.json: "$conceptId" (adjective) missing required field "f"',
        );
      }
      if (!entry.containsKey('n')) {
        throw ConfigValidationError(
          'translations/$langCode.json: "$conceptId" (adjective) missing required field "n"',
        );
      }
      if (entry['m'] is! String) {
        throw ConfigValidationError(
          'translations/$langCode.json: "$conceptId".m must be a string',
        );
      }
      if (entry['f'] is! String) {
        throw ConfigValidationError(
          'translations/$langCode.json: "$conceptId".f must be a string',
        );
      }
      if (entry['n'] is! String) {
        throw ConfigValidationError(
          'translations/$langCode.json: "$conceptId".n must be a string',
        );
      }
    } else {
      if (!entry.containsKey('text')) {
        throw ConfigValidationError(
          'translations/$langCode.json: "$conceptId" (simple) missing required field "text"',
        );
      }
      if (entry['text'] is! String) {
        throw ConfigValidationError(
          'translations/$langCode.json: "$conceptId".text must be a string',
        );
      }
    }
  }
}

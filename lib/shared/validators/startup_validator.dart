import 'dart:convert';

import 'package:flutter/services.dart';

import 'config_validator.dart';

/// Runs at app startup (before runApp) to validate all config files.
/// Any invalid or inconsistent data throws [ConfigValidationError] with the
/// exact file, field, and bad value — crashing before any screen renders.
class StartupValidator {
  static const String _planPath        = 'assets/data/plan.json';
  static const String _dictionaryPath  = 'assets/data/dictionary.json';
  static const String _levelsPath      = 'assets/data/levels.json';
  static const String _translationsDir = 'assets/data/translations';

  static Future<void> validate() async {
    // Step 1: load plan.json and extract language codes (fail-fast if missing)
    final planRaw = await rootBundle.loadString(_planPath);
    final planData = jsonDecode(planRaw) as Map<String, dynamic>;

    final langsRaw = planData['languages'];
    if (langsRaw == null || langsRaw is! List<dynamic>) {
      throw const ConfigValidationError(
        'plan.json: missing required key "languages"',
      );
    }

    final langCodes = <String>[];
    for (int i = 0; i < langsRaw.length; i++) {
      final entry = langsRaw[i];
      if (entry is! Map<String, dynamic>) {
        throw ConfigValidationError(
          'plan.json: languages[$i] must be an object',
        );
      }
      final code = entry['code'];
      if (code == null || code is! String) {
        throw ConfigValidationError(
          'plan.json: languages[$i].code must be a non-null string',
        );
      }
      langCodes.add(code);
    }

    // Step 2: load dictionary and levels
    final dictRaw   = await rootBundle.loadString(_dictionaryPath);
    final levelsRaw = await rootBundle.loadString(_levelsPath);

    // Step 3: load each translation file — throw immediately if any missing
    final translationsByCode = <String, Map<String, dynamic>>{};
    for (final code in langCodes) {
      final path = '$_translationsDir/$code.json';
      try {
        final json = await rootBundle.loadString(path);
        translationsByCode[code] = jsonDecode(json) as Map<String, dynamic>;
      } catch (_) {
        throw ConfigValidationError(
          'plan.json declares language "$code" but $path was not found',
        );
      }
    }

    // Step 4: full cross-validation
    ConfigValidator.validateAll(
      planData: planData,
      dictionaryData: jsonDecode(dictRaw) as Map<String, dynamic>,
      levelsData: jsonDecode(levelsRaw) as Map<String, dynamic>,
      translationsByCode: translationsByCode,
    );
  }
}

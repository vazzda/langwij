import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'config_validator.dart';

/// Runs at app startup to validate core config files and active translations.
/// Any invalid or inconsistent data throws [ConfigValidationError] with the
/// exact file, field, and bad value — crashing before any screen renders.
class StartupValidator {
  static const String _planPath = 'assets/data/plan.json';
  static const String _dictionaryPath = 'assets/data/dictionary.json';
  static const String _levelsPath = 'assets/data/levels.json';
  static const String _translationsDir = 'assets/data/translations';

  /// Validates core configs + active language translations only.
  /// Loads 5 files: plan + dictionary + levels + target + native.
  static Future<void> validate({
    required String targetLang,
    required String nativeLang,
  }) async {
    final sw = Stopwatch()..start();
    debugPrint('[BOOT] validate: plan.json loading...');
    final planRaw = await rootBundle.loadString(_planPath);
    debugPrint('[BOOT] validate: plan.json loaded (${sw.elapsedMilliseconds}ms)');
    final planData = jsonDecode(planRaw) as Map<String, dynamic>;

    debugPrint('[BOOT] validate: dictionary.json loading...');
    final dictRaw = await rootBundle.loadString(_dictionaryPath);
    debugPrint('[BOOT] validate: dictionary.json loaded (${sw.elapsedMilliseconds}ms)');

    debugPrint('[BOOT] validate: levels.json loading...');
    final levelsRaw = await rootBundle.loadString(_levelsPath);
    debugPrint('[BOOT] validate: levels.json loaded (${sw.elapsedMilliseconds}ms)');

    // Core validation (plan structure, dictionary, levels).
    final ids = ConfigValidator.validateCore(
      planData: planData,
      dictionaryData: jsonDecode(dictRaw) as Map<String, dynamic>,
      levelsData: jsonDecode(levelsRaw) as Map<String, dynamic>,
    );
    debugPrint('[BOOT] validate: core validation done (${sw.elapsedMilliseconds}ms)');

    // Load and validate only the active translations.
    final codesToValidate = {targetLang, nativeLang};
    for (final code in codesToValidate) {
      final path = '$_translationsDir/$code.json';
      try {
        debugPrint('[BOOT] validate: $code.json loading...');
        final raw = await rootBundle.loadString(path);
        debugPrint('[BOOT] validate: $code.json loaded (${sw.elapsedMilliseconds}ms)');
        final data = jsonDecode(raw) as Map<String, dynamic>;
        ConfigValidator.validateTranslation(
          code,
          data,
          ids.termIds,
          ids.levelIds,
          ids.deckIds,
        );
      } catch (e) {
        if (e is ConfigValidationError) rethrow;
        throw ConfigValidationError(
          'plan.json declares language "$code" but $path was not found',
        );
      }
    }
    debugPrint('[BOOT] validate: DONE (${sw.elapsedMilliseconds}ms)');
  }

  /// Full validation of ALL config files including every translation.
  /// Used by the dev validation button — not at startup.
  static Future<void> validateAll() async {
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

    final dictRaw = await rootBundle.loadString(_dictionaryPath);
    final levelsRaw = await rootBundle.loadString(_levelsPath);

    final translationsByCode = <String, Map<String, dynamic>>{};
    for (final code in langCodes) {
      final path = '$_translationsDir/$code.json';
      try {
        final raw = await rootBundle.loadString(path);
        translationsByCode[code] = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {
        throw ConfigValidationError(
          'plan.json declares language "$code" but $path was not found',
        );
      }
    }

    ConfigValidator.validateAll(
      planData: planData,
      dictionaryData: jsonDecode(dictRaw) as Map<String, dynamic>,
      levelsData: jsonDecode(levelsRaw) as Map<String, dynamic>,
      translationsByCode: translationsByCode,
    );
  }
}

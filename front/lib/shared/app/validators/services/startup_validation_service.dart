import 'dart:convert';

import 'package:flutter/services.dart';

import '../model/config_validation_error.dart';
import 'config_validation_service.dart';

class StartupValidationService {
  static const String _planPath = 'assets/data/plan.json';
  static const String _dictionaryPath = 'assets/data/dictionary.json';
  static const String _levelsPath = 'assets/data/levels.json';
  static const String _translationsDir = 'assets/data/translations';

  static Future<void> validate({
    required String targetLang,
    required String nativeLang,
  }) async {
    final planRaw = await rootBundle.loadString(_planPath);
    final planData = jsonDecode(planRaw) as Map<String, dynamic>;

    final dictRaw = await rootBundle.loadString(_dictionaryPath);
    final levelsRaw = await rootBundle.loadString(_levelsPath);

    final ids = ConfigValidationService.validateCore(
      planData: planData,
      dictionaryData: jsonDecode(dictRaw) as Map<String, dynamic>,
      levelsData: jsonDecode(levelsRaw) as Map<String, dynamic>,
    );

    final codesToValidate = {targetLang, nativeLang};
    for (final code in codesToValidate) {
      final path = '$_translationsDir/$code.json';
      try {
        final raw = await rootBundle.loadString(path);
        final data = jsonDecode(raw) as Map<String, dynamic>;
        ConfigValidationService.validateTranslation(
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
  }

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

    ConfigValidationService.validateAll(
      planData: planData,
      dictionaryData: jsonDecode(dictRaw) as Map<String, dynamic>,
      levelsData: jsonDecode(levelsRaw) as Map<String, dynamic>,
      translationsByCode: translationsByCode,
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../model/app_settings.dart';
import '../model/decay_formula.dart';
import '../model/language_settings.dart';
import '../repository/language_settings_repository.dart';
import 'config_internal_service.dart';

const _hasConfiguredLanguagesKey = 'has_configured_languages';

class ConfigService {
  ConfigService(this._ref);
  final Ref _ref;

  static final instance = Provider((ref) => ConfigService(ref));

  // Pre-DI escape hatch — used by boot before the Riverpod container exists.
  static Future<LanguageSettings> loadEagerly(Database db) async {
    return LanguageSettingsRepository(db: db).load();
  }

  static Future<bool> hasConfiguredLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasConfiguredLanguagesKey) ?? false;
  }

  static Future<void> _markLanguagesConfigured() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasConfiguredLanguagesKey, true);
  }

  static final languageSettings = FutureProvider<LanguageSettings>((ref) async {
    ref.watch(ConfigInternalService.revision);
    final repo = await ref.read(ConfigInternalService.langSettingsRepository.future);
    return repo.load();
  });

  static final appSettings = FutureProvider<AppSettings>((ref) async {
    ref.watch(ConfigInternalService.revision);
    final repo = await ref.read(ConfigInternalService.appSettingsRepository.future);
    return repo.getSettings();
  });

  static final levelFoldOverrides = FutureProvider<Map<String, bool>>((ref) async {
    ref.watch(ConfigInternalService.revision);
    final langSettings = await ref.watch(ConfigService.languageSettings.future);
    final repo = await ref.read(ConfigInternalService.appSettingsRepository.future);
    return repo.getLevelFoldOverrides(langSettings.targetLang);
  });

  Future<void> setTargetLang(String code) async {
    final repo = await _ref.read(ConfigInternalService.langSettingsRepository.future);
    await repo.setTargetLang(code);
    await _markLanguagesConfigured();
    _ref.read(ConfigInternalService.revision.notifier).state++;
  }

  Future<void> setNativeLang(String code) async {
    final repo = await _ref.read(ConfigInternalService.langSettingsRepository.future);
    await repo.setNativeLang(code);
    await _markLanguagesConfigured();
    _ref.read(ConfigInternalService.revision.notifier).state++;
  }

  Future<void> setUiLang(String code) async {
    final repo = await _ref.read(ConfigInternalService.langSettingsRepository.future);
    await repo.setUiLang(code);
    _ref.read(ConfigInternalService.revision.notifier).state++;
  }

  Future<void> setDecayFormula(DecayFormula formula) async {
    final repo = await _ref.read(ConfigInternalService.appSettingsRepository.future);
    await repo.setDecayFormula(formula);
    _ref.read(ConfigInternalService.revision.notifier).state++;
  }

  Future<void> toggleLevelFold(
    String levelId, {
    required bool currentlyExpanded,
  }) async {
    final langSettings = await _ref.read(ConfigService.languageSettings.future);
    final repo = await _ref.read(ConfigInternalService.appSettingsRepository.future);
    await repo.setLevelFoldOverride(langSettings.targetLang, levelId, !currentlyExpanded);
    _ref.read(ConfigInternalService.revision.notifier).state++;
  }

  void bumpRevision() {
    _ref.read(ConfigInternalService.revision.notifier).state++;
  }
}

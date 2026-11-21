import 'dart:ui' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'package:langwij/l10n/app_localizations.dart';
import '../model/app_settings.dart';
import '../model/lang_codes.dart';
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

  static Future<void> markLanguagesConfigured() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasConfiguredLanguagesKey, true);
  }

  static final languageSettings = FutureProvider<LanguageSettings>((ref) async {
    ref.watch(ConfigInternalService.revision);
    final repo = await ref.read(ConfigInternalService.langSettingsRepository.future);
    return repo.load();
  });

  /// Language settings read before the first frame. Overridden at startup
  /// with the stored values, so the first frame already uses them.
  static final languageSettingsLoadedAtStartup = Provider<LanguageSettings>(
    (_) => LanguageSettings.defaultSettings,
  );

  /// Locale of the interface, derived from the native ("I speak") language.
  static final interfaceLocale = Provider<Locale>((ref) {
    final languageSettingsAtStartup = ref.watch(languageSettingsLoadedAtStartup);
    final currentLanguageSettings =
        ref.watch(languageSettings).valueOrNull ?? languageSettingsAtStartup;
    return interfaceLocaleForLanguageCode(currentLanguageSettings.nativeLang);
  });

  /// Every locale the interface is translated into.
  static List<Locale> get supportedInterfaceLocales => [
    for (final translatedLocale in AppLocalizations.supportedLocales)
      interfaceLocaleForLanguageCode(translatedLocale.languageCode),
  ];

  static Locale interfaceLocaleForLanguageCode(String languageCode) {
    return Locale.fromSubtags(
      languageCode: languageCode,
      scriptCode: LangCodes.interfaceScriptCodeForLanguageCode(languageCode),
    );
  }

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

  Future<void> setLanguagePair({
    required String targetLang,
    required String nativeLang,
  }) async {
    final repo = await _ref.read(ConfigInternalService.langSettingsRepository.future);
    await repo.setTargetLang(targetLang);
    await repo.setNativeLang(nativeLang);
    await markLanguagesConfigured();
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

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../entities/language/dictionary.dart';
import '../../entities/language/language_pack.dart';
import '../../entities/plan/language_entry.dart';
import '../../shared/repositories/dictionary_repository.dart';
import 'dev_section_provider.dart';
import 'language_settings_provider.dart';
import 'plan_provider.dart';

/// Singleton DictionaryRepository provider.
final dictionaryRepositoryProvider = Provider<DictionaryRepository>((ref) {
  return DictionaryRepository();
});

/// Universal dictionary (concepts + groups + levels). Loaded once from assets.
final dictionaryProvider = FutureProvider<Dictionary>((ref) async {
  final repo = ref.watch(dictionaryRepositoryProvider);
  return repo.loadDictionary();
});

/// All declared languages from plan.json.
final _planLanguagesProvider = FutureProvider<List<LanguageEntry>>((ref) async {
  final planRepo = ref.watch(planRepositoryProvider);
  return planRepo.getLanguages();
});

/// Public language codes from the plan.
final _publicLanguageCodesProvider = FutureProvider<Set<String>>((ref) async {
  final planRepo = ref.watch(planRepositoryProvider);
  return (await planRepo.getPublicLanguages()).toSet();
});

/// UI-capable language codes from the plan.
final uiLanguagesProvider = FutureProvider<Set<String>>((ref) async {
  final planRepo = ref.watch(planRepositoryProvider);
  return planRepo.getUiLanguages();
});

/// Target language pack. Reloads when target language changes.
final targetPackProvider = FutureProvider<LanguagePack>((ref) async {
  final repo = ref.watch(dictionaryRepositoryProvider);
  final settings = ref.watch(languageSettingsProvider);
  final publicCodes = await ref.watch(_publicLanguageCodesProvider.future);
  final languages = await ref.watch(_planLanguagesProvider.future);
  final entry = languages.firstWhere(
    (l) => l.code == settings.targetLang,
    orElse: () => throw StateError(
      'Target language "${settings.targetLang}" not found in plan.json',
    ),
  );
  return repo.loadLanguagePack(
    entry.code,
    labelKey: entry.labelKey,
    isPublic: publicCodes.contains(entry.code),
    nativeNote: entry.nativeNote,
    humanVerified: entry.humanVerified,
  );
});

/// Native language pack. Reloads when native language changes.
final nativePackProvider = FutureProvider<LanguagePack>((ref) async {
  final repo = ref.watch(dictionaryRepositoryProvider);
  final settings = ref.watch(languageSettingsProvider);
  final publicCodes = await ref.watch(_publicLanguageCodesProvider.future);
  final languages = await ref.watch(_planLanguagesProvider.future);
  final entry = languages.firstWhere(
    (l) => l.code == settings.nativeLang,
    orElse: () => throw StateError(
      'Native language "${settings.nativeLang}" not found in plan.json',
    ),
  );
  return repo.loadLanguagePack(
    entry.code,
    labelKey: entry.labelKey,
    isPublic: publicCodes.contains(entry.code),
    nativeNote: entry.nativeNote,
    humanVerified: entry.humanVerified,
  );
});

/// All visible language packs (for language selection screen).
/// In dev mode: all packs. In production: public packs only.
final allPacksProvider = FutureProvider<List<LanguagePack>>((ref) async {
  final repo = ref.watch(dictionaryRepositoryProvider);
  final isDevMode = ref.watch(devSectionEnabledProvider);
  final publicCodes = await ref.watch(_publicLanguageCodesProvider.future);
  final languages = await ref.watch(_planLanguagesProvider.future);
  final entriesToLoad = isDevMode
      ? languages
      : languages.where((l) => publicCodes.contains(l.code)).toList();
  return repo.loadPacks(entriesToLoad, publicCodes);
});

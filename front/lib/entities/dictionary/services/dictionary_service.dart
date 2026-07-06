import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:langwij/shared/app/config/config.dart';
import 'package:langwij/shared/dev_section/dev_section.dart';
import '../model/dictionary.dart';
import '../model/language_pack.dart';
import '../model/level_tier.dart';
import 'dictionary_internal_service.dart';

class DictionaryService {
  static final dictionary = FutureProvider<Dictionary>((ref) async {
    final repo = ref.watch(DictionaryInternalService.dictionaryRepository);
    return repo.loadDictionary();
  });

  static final uiLanguages = FutureProvider<Set<String>>((ref) async {
    final repo = ref.watch(DictionaryInternalService.planRepository);
    return repo.getUiLanguages();
  });

  static final targetPack = FutureProvider<LanguagePack>((ref) async {
    final repo = ref.watch(DictionaryInternalService.dictionaryRepository);
    final langSettings = await ref.watch(ConfigService.languageSettings.future);
    final publicCodes = await ref.watch(DictionaryInternalService.publicLanguageCodes.future);
    final languages = await ref.watch(DictionaryInternalService.planLanguages.future);
    final entry = languages.firstWhere(
      (l) => l.code == langSettings.targetLang,
      orElse: () => throw StateError(
        'Target language "${langSettings.targetLang}" not found in plan.json',
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

  static final nativePack = FutureProvider<LanguagePack>((ref) async {
    final repo = ref.watch(DictionaryInternalService.dictionaryRepository);
    final langSettings = await ref.watch(ConfigService.languageSettings.future);
    final publicCodes = await ref.watch(DictionaryInternalService.publicLanguageCodes.future);
    final languages = await ref.watch(DictionaryInternalService.planLanguages.future);
    final entry = languages.firstWhere(
      (l) => l.code == langSettings.nativeLang,
      orElse: () => throw StateError(
        'Native language "${langSettings.nativeLang}" not found in plan.json',
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

  static final allPacks = FutureProvider<List<LanguagePack>>((ref) async {
    final repo = ref.watch(DictionaryInternalService.dictionaryRepository);
    final isDevMode = ref.watch(DevSectionService.enabled);
    final publicCodes = await ref.watch(DictionaryInternalService.publicLanguageCodes.future);
    final languages = await ref.watch(DictionaryInternalService.planLanguages.future);
    final entriesToLoad = isDevMode
        ? languages
        : languages.where((l) => publicCodes.contains(l.code)).toList();
    return repo.loadPacks(entriesToLoad, publicCodes);
  });

  static final levelTiers = FutureProvider<Map<String, LevelTier>>((ref) async {
    final repo = ref.watch(DictionaryInternalService.planRepository);
    final langSettings = await ref.watch(ConfigService.languageSettings.future);
    final dict = await ref.watch(dictionary.future);
    final courseId = '${langSettings.targetLang}→${langSettings.nativeLang}';
    final levelIds = dict.levels.map((l) => l.id).toList();
    return repo.getTiers(courseId, levelIds);
  });

  static final availableCourseIds = FutureProvider<Set<String>>((ref) async {
    final repo = ref.watch(DictionaryInternalService.planRepository);
    return repo.getAvailableCourseIds();
  });

  static final courseNote = FutureProvider<String?>((ref) async {
    final repo = ref.watch(DictionaryInternalService.planRepository);
    final langSettings = await ref.watch(ConfigService.languageSettings.future);
    final courseId = '${langSettings.targetLang}→${langSettings.nativeLang}';
    return repo.getCourseNote(courseId);
  });
}

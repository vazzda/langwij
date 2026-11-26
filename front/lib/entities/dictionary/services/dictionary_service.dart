import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:langwij/shared/app/config/config.dart';
import 'package:langwij/shared/dev_section/dev_section.dart';
import '../model/dictionary.dart';
import '../model/language_pack.dart';
import '../model/level_tier.dart';
import '../model/plan_note.dart';
import 'dictionary_internal_service.dart';

class DictionaryService {
  static final dictionary = FutureProvider<Dictionary>((ref) async {
    final repo = ref.watch(DictionaryInternalService.dictionaryRepository);
    return repo.loadDictionary();
  });

  static const String _targetLanguageRoleName = 'Target';
  static const String _nativeLanguageRoleName = 'Native';

  static final targetPack = FutureProvider<LanguagePack>((ref) async {
    final langSettings = await ref.watch(ConfigService.languageSettings.future);
    return _loadLanguagePackForLanguageCode(
      ref,
      langSettings.targetLang,
      languageRoleName: _targetLanguageRoleName,
    );
  });

  static final nativePack = FutureProvider<LanguagePack>((ref) async {
    final langSettings = await ref.watch(ConfigService.languageSettings.future);
    return _loadLanguagePackForLanguageCode(
      ref,
      langSettings.nativeLang,
      languageRoleName: _nativeLanguageRoleName,
    );
  });

  static Future<LanguagePack> _loadLanguagePackForLanguageCode(
    Ref ref,
    String languageCode, {
    required String languageRoleName,
  }) async {
    final repo = ref.watch(DictionaryInternalService.dictionaryRepository);
    final publicCodes = await ref.watch(DictionaryInternalService.publicLanguageCodes.future);
    final languages = await ref.watch(DictionaryInternalService.planLanguages.future);
    final entry = languages.firstWhere(
      (l) => l.code == languageCode,
      orElse: () => throw StateError(
        '$languageRoleName language "$languageCode" not found in plan.json',
      ),
    );
    return repo.loadLanguagePack(
      entry,
      isPublic: publicCodes.contains(entry.code),
    );
  }

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

  /// The ids of the terms whose words the card of a chosen language shows,
  /// in the order they are shown.
  static final languageCardTermIds = FutureProvider<List<String>>((ref) async {
    final repo = ref.watch(DictionaryInternalService.planRepository);
    return repo.getLanguageCardTermIds();
  });

  static final courseNote = FutureProvider<PlanNote?>((ref) async {
    final repo = ref.watch(DictionaryInternalService.planRepository);
    final langSettings = await ref.watch(ConfigService.languageSettings.future);
    final courseId = '${langSettings.targetLang}→${langSettings.nativeLang}';
    return repo.getCourseNote(courseId);
  });
}

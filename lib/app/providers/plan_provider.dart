import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../entities/plan/level_tier.dart';
import '../../shared/repositories/plan_repository.dart';
import 'dictionary_provider.dart';
import 'language_settings_provider.dart';

final planRepositoryProvider = Provider<PlanRepository>((ref) {
  return PlanRepository();
});

/// Map of levelId → [LevelTier] for the current course (target→native).
///
/// Reloads whenever language settings change.
final levelTiersProvider = FutureProvider<Map<String, LevelTier>>((ref) async {
  final repo = ref.watch(planRepositoryProvider);
  final settings = ref.watch(languageSettingsProvider);
  final dictionary = await ref.watch(dictionaryProvider.future);
  final courseId = '${settings.targetLang}\u2192${settings.nativeLang}';
  final levelIds = dictionary.levels.map((l) => l.id).toList();
  return repo.getTiers(courseId, levelIds);
});

/// Optional note for the current course pair (target→native).
final courseNoteProvider = FutureProvider<String?>((ref) async {
  final repo = ref.watch(planRepositoryProvider);
  final settings = ref.watch(languageSettingsProvider);
  final courseId = '${settings.targetLang}\u2192${settings.nativeLang}';
  return repo.getCourseNote(courseId);
});

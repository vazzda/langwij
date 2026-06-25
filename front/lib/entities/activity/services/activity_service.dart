import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:langwij/shared/app/config/config.dart';
import '../model/daily_activity_stats.dart';
import 'activity_internal_service.dart';

class ActivityService {
  ActivityService(this._ref);
  final Ref _ref;

  static final instance = Provider((ref) => ActivityService(ref));

  static final todayStats = FutureProvider<DailyActivityStats>((ref) async {
    ref.watch(ActivityInternalService.revision);
    final langSettings = await ref.watch(ConfigService.languageSettings.future);
    final repo = await ref.watch(ActivityInternalService.dailyActivityRepository.future);
    return repo.readToday(langSettings.targetLang);
  });

  Future<DailyActivityStats> addRound({
    required int correct,
    required int wrong,
    required Set<String> wordIds,
  }) async {
    final langSettings = await _ref.read(ConfigService.languageSettings.future);
    final repo = await _ref.read(ActivityInternalService.dailyActivityRepository.future);
    final stats = await repo.addRound(
      targetLang: langSettings.targetLang,
      correct: correct,
      wrong: wrong,
      wordIds: wordIds,
    );
    _ref.read(ActivityInternalService.revision.notifier).state++;
    return stats;
  }

  Future<void> deleteForLanguage(String targetLang) async {
    final repo = await _ref.read(ActivityInternalService.dailyActivityRepository.future);
    await repo.deleteForLanguage(targetLang);
    _ref.read(ActivityInternalService.revision.notifier).state++;
  }
}

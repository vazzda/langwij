import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:langwij/entities/dictionary/@x/progress.dart';
import 'package:langwij/shared/app/config/config.dart';
import '../model/card_result.dart';
import '../model/quiz_mode.dart';
import '../model/deck_progress.dart';
import 'progress_internal_service.dart';

class ProgressService {
  ProgressService(this._ref);
  final Ref _ref;

  static final instance = Provider((ref) => ProgressService(ref));

  static final allDeckProgress = FutureProvider<Map<String, DeckProgress>>((ref) async {
    ref.watch(ProgressInternalService.revision);
    final langSettings = await ref.watch(ConfigService.languageSettings.future);
    final repo = await ref.watch(ProgressInternalService.deckProgressRepository.future);
    return repo.getAllProgress(langSettings.targetLang);
  });

  static final levelProgress = Provider.family<double, String>((ref, levelId) {
    final dict = ref.watch(DictionaryService.dictionary).valueOrNull;
    if (dict == null) return 0.0;

    Level? level;
    for (final l in dict.levels) {
      if (l.id == levelId) {
        level = l;
        break;
      }
    }
    if (level == null || level.deckIds.isEmpty) return 0.0;

    final allProgress = ref.watch(allDeckProgress).valueOrNull ?? {};
    final total = level.deckIds.fold(
      0.0,
      (sum, gid) => sum + (allProgress[gid]?.totalProgress ?? 0.0),
    );
    return total / level.deckIds.length;
  });

  static final allLanguagesProgress = FutureProvider<Map<String, double>>((ref) async {
    ref.watch(ProgressInternalService.revision);
    final repo = await ref.watch(ProgressInternalService.deckProgressRepository.future);
    final dict = ref.watch(DictionaryService.dictionary).valueOrNull;
    final totalDecks = dict?.decks.length ?? 0;
    if (totalDecks == 0) return {};

    final sumByLang = await repo.getSumProgressAllLanguages();
    return {
      for (final entry in sumByLang.entries)
        entry.key: (entry.value / (totalDecks * 100.0)).clamp(0.0, 1.0),
    };
  });

  static final termsTouched = FutureProvider<Set<String>>((ref) async {
    ref.watch(ProgressInternalService.revision);
    final langSettings = await ref.watch(ConfigService.languageSettings.future);
    final repo = await ref.watch(ProgressInternalService.languageStatsRepository.future);
    return repo.getTermsTouched(langSettings.targetLang);
  });

  Future<void> recordVocabRound({
    required String deckId,
    required QuizMode mode,
    required List<CardResult> cardResults,
    required int totalDeckTerms,
  }) async {
    final langSettings = await _ref.read(ConfigService.languageSettings.future);
    final repo = await _ref.read(ProgressInternalService.deckProgressRepository.future);
    await repo.recordVocabRound(
      targetLang: langSettings.targetLang,
      deckId: deckId,
      mode: mode,
      cardResults: cardResults,
      totalDeckTerms: totalDeckTerms,
    );
    _ref.read(ProgressInternalService.revision.notifier).state++;
  }

  Future<bool> recordRound({
    required String deckId,
    required double score,
    required QuizMode mode,
    required double modeCap,
    required double coverage,
    required double accuracy,
  }) async {
    final langSettings = await _ref.read(ConfigService.languageSettings.future);
    final repo = await _ref.read(ProgressInternalService.deckProgressRepository.future);
    final result = await repo.recordRound(
      targetLang: langSettings.targetLang,
      deckId: deckId,
      score: score,
      mode: mode,
      modeCap: modeCap,
      coverage: coverage,
      accuracy: accuracy,
    );
    _ref.read(ProgressInternalService.revision.notifier).state++;
    return result;
  }

  Future<void> recordTestResult({
    required String deckId,
    required double testCoverage,
  }) async {
    final langSettings = await _ref.read(ConfigService.languageSettings.future);
    final repo = await _ref.read(ProgressInternalService.deckProgressRepository.future);
    await repo.recordTestResult(
      targetLang: langSettings.targetLang,
      deckId: deckId,
      testCoverage: testCoverage,
    );
    _ref.read(ProgressInternalService.revision.notifier).state++;
  }

  Future<int> addTermsTouched(Set<String> termIds) async {
    final langSettings = await _ref.read(ConfigService.languageSettings.future);
    final repo = await _ref.read(ProgressInternalService.languageStatsRepository.future);
    final count = await repo.addTermsTouched(langSettings.targetLang, termIds);
    _ref.read(ProgressInternalService.revision.notifier).state++;
    return count;
  }

  Future<void> deleteForLanguage(String targetLang) async {
    final deckRepo = await _ref.read(ProgressInternalService.deckProgressRepository.future);
    final statsRepo = await _ref.read(ProgressInternalService.languageStatsRepository.future);
    await deckRepo.deleteForLanguage(targetLang);
    await statsRepo.deleteForLanguage(targetLang);
    _ref.read(ProgressInternalService.revision.notifier).state++;
  }
}

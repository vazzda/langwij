import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_settings_provider.dart';
import '../../../app/providers/daily_activity_provider.dart';
import '../../../app/providers/deck_progress_provider.dart';
import '../../../app/providers/groups_provider.dart';
import '../../../app/providers/language_settings_provider.dart';
import '../../../app/providers/language_stats_provider.dart';
import '../../../app/router/app_router.dart';
import 'package:langwij/shared/lib/progress_calculator.dart';
import 'package:langwij/shared/lib/progress_constants.dart';
import '../quiz_mode.dart';
import '../round_notifier.dart';

/// Service for round lifecycle operations.
/// Handles persistence, provider cleanup, and invalidation sequences.
class QuizRoundService {
  QuizRoundService(this._ref);

  final Ref _ref;

  /// Whether the last persisted round actually contributed to progress.
  /// `false` when round mode cap was already exceeded.
  bool lastRoundContributed = true;

  /// Persists the current round into today's daily activity and deck progress.
  /// Updates all relevant providers with the new stats.
  Future<void> persistRound() async {
    try {
      final round = _ref.read(roundProvider);
      if (round == null) {
        debugPrint('QuizRoundService.persistRound: round is null');
        return;
      }
      final targetLang = _ref.read(languageSettingsProvider).targetLang;
      final stats = await _ref.read(dailyActivityRepositoryProvider).addRound(
            targetLang: targetLang,
            correct: round.correctCount,
            wrong: round.wrongCount,
            wordIds: round.roundWordIds,
          );
      _ref.read(dailyActivityProvider.notifier).setStats(stats);

      // Calculate round score (all attempts)
      final total = round.correctCount + round.wrongCount;
      final score = total > 0 ? (round.correctCount * 100.0 / total) : 0.0;

      if (round.isTest) {
        await _persistTestRound(round, targetLang, score);
      } else {
        await _persistTrainingRound(round, targetLang, score);
      }

      // Update peak retention if needed
      final settings = _ref.read(appSettingsProvider);
      final progress =
          _ref.read(deckProgressProvider.notifier).getProgress(round.deckId);
      final retention =
          ProgressCalculator.calculateRetention(progress, settings.decayFormula);
      if (ProgressCalculator.shouldUpdatePeak(progress, retention)) {
        await _ref
            .read(deckProgressProvider.notifier)
            .updatePeakRetention(round.deckId, retention);
      }

      // Record terms touched for vocab rounds (language-level progress)
      if (round.allCards != null) {
        final termIds = round.roundWordIds
            .map((wid) => wid.split(':').first)
            .toSet();
        await _ref
            .read(languageStatsRepositoryProvider)
            .addTermsTouched(targetLang, termIds);
      }
    } catch (e, st) {
      debugPrint('QuizRoundService.persistRound error: $e\n$st');
    }
  }

  Future<void> _persistTestRound(
    dynamic round,
    String targetLang,
    double roundScore,
  ) async {
    // First-pass score: cards correct on first attempt / total deck terms
    final totalTerms = round.totalDeckTerms;
    final firstPassScore = totalTerms > 0
        ? (round.firstPassCorrect * 100.0 / totalTerms)
        : 0.0;

    lastRoundContributed =
        await _ref.read(deckProgressProvider.notifier).recordTestResult(
              deckId: round.deckId,
              firstPassScore: firstPassScore,
              roundScore: roundScore,
              mode: round.mode,
            );
  }

  Future<void> _persistTrainingRound(
    dynamic round,
    String targetLang,
    double roundScore,
  ) async {
    final modeCap = _modeCap(round.mode);
    final totalTerms = round.totalDeckTerms;
    final coverage = totalTerms > 0
        ? round.roundTermCount / totalTerms
        : 0.0;
    final total = round.correctCount + round.wrongCount;
    final accuracy = total > 0 ? round.correctCount / total : 0.0;

    lastRoundContributed =
        await _ref.read(deckProgressProvider.notifier).recordRound(
              deckId: round.deckId,
              score: roundScore,
              mode: round.mode,
              modeCap: modeCap,
              coverage: coverage,
              accuracy: accuracy,
            );
  }

  /// Resolves the progress cap for a given quiz mode (non-test).
  static double _modeCap(QuizMode mode) {
    return switch (mode) {
      QuizMode.nativeShown => ProgressConstants.capNativeShown,
      QuizMode.targetShown => ProgressConstants.capTargetShown,
      QuizMode.write => ProgressConstants.capWrite,
    };
  }

  /// Cleans up round state and returns the origin route for navigation.
  String endRound() {
    final round = _ref.read(roundProvider);
    final originRoute = round?.originRoute ?? AppRoutes.home;
    final scrollOffset = round?.originScrollOffset ?? 0.0;
    _ref.read(scrollOffsetToRestoreProvider.notifier).state = scrollOffset;
    _ref.read(roundProvider.notifier).endRound();
    _ref.read(selectedGroupProvider.notifier).state = null;
    return originRoute;
  }
}

final quizRoundServiceProvider = Provider<QuizRoundService>((ref) {
  return QuizRoundService(ref);
});

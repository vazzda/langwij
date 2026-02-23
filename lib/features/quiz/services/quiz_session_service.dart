import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_settings_provider.dart';
import '../../../app/providers/daily_activity_provider.dart';
import '../../../app/providers/group_progress_provider.dart';
import '../../../app/providers/groups_provider.dart';
import '../../../app/router/app_router.dart';
import '../../../shared/lib/progress_calculator.dart';
import '../session_notifier.dart';

/// Service for session lifecycle operations.
/// Handles persistence, provider cleanup, and invalidation sequences.
class QuizSessionService {
  QuizSessionService(this._ref);

  final Ref _ref;

  /// Persists the current session into today's daily activity and group progress.
  /// Updates all relevant providers with the new stats.
  Future<void> persistSession() async {
    try {
      final session = _ref.read(sessionProvider);
      if (session == null) {
        debugPrint('QuizSessionService.persistSession: session is null');
        return;
      }
      final stats = await _ref.read(dailyActivityRepositoryProvider).addSession(
            correct: session.correctCount,
            wrong: session.wrongCount,
            wordIds: session.sessionWordIds,
          );
      _ref.read(dailyActivityProvider.notifier).setStats(stats);

      // Calculate session score and record group progress
      final total = session.correctCount + session.wrongCount;
      final score = total > 0 ? (session.correctCount * 100.0 / total) : 0.0;

      await _ref.read(groupProgressProvider.notifier).recordSession(
            groupId: session.groupId,
            score: score,
            mode: session.mode,
          );

      // Update peak retention if needed
      final settings = _ref.read(appSettingsProvider);
      final progress =
          _ref.read(groupProgressProvider.notifier).getProgress(session.groupId);
      final retention =
          ProgressCalculator.calculateRetention(progress, settings.decayFormula);
      if (ProgressCalculator.shouldUpdatePeak(progress, retention)) {
        await _ref
            .read(groupProgressProvider.notifier)
            .updatePeakRetention(session.groupId, retention);
      }
    } catch (e, st) {
      debugPrint('QuizSessionService.persistSession error: $e\n$st');
    }
  }

  /// Cleans up session state and returns the origin route for navigation.
  String endSession() {
    final session = _ref.read(sessionProvider);
    final originRoute = session?.originRoute ?? AppRoutes.home;
    final scrollOffset = session?.originScrollOffset ?? 0.0;
    _ref.read(scrollOffsetToRestoreProvider.notifier).state = scrollOffset;
    _ref.read(sessionProvider.notifier).endSession();
    _ref.read(selectedGroupProvider.notifier).state = null;
    return originRoute;
  }
}

final quizSessionServiceProvider = Provider<QuizSessionService>((ref) {
  return QuizSessionService(ref);
});

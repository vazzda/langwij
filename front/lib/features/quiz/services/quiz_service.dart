import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:langwij/entities/activity/activity.dart';
import 'package:langwij/entities/group/group.dart';
import 'package:langwij/entities/progress/progress.dart';
import 'package:langwij/shared/app/config/config.dart';
import 'package:langwij/shared/app/routing/routing.dart';

import '../model/round_state.dart';
import 'quiz_round_state_notifier_service.dart';

class QuizService {
  QuizService(this._ref);
  final Ref _ref;

  static final instance = Provider((ref) => QuizService(ref));

  static final round = NotifierProvider<QuizRoundStateNotifierService, RoundState?>(
    QuizRoundStateNotifierService.new,
  );

  static final lastRoundContributed = StateProvider<bool>((ref) => true);

  static final selectedGroup = StateProvider<GroupModel?>((ref) => null);

  static final scrollOffsetToRestore = StateProvider<double?>((ref) => null);

  void selectGroup(GroupModel group) {
    _ref.read(selectedGroup.notifier).state = group;
  }

  void clearSelectedGroup() {
    _ref.read(selectedGroup.notifier).state = null;
  }

  void setScrollOffset(double offset) {
    _ref.read(scrollOffsetToRestore.notifier).state = offset;
  }

  void clearScrollOffset() {
    _ref.read(scrollOffsetToRestore.notifier).state = null;
  }

  Future<void> persistRound() async {
    try {
      final roundState = _ref.read(round);
      if (roundState == null) {
        debugPrint('QuizService.persistRound: round is null');
        return;
      }
      await _ref.read(ActivityService.instance).addRound(
        correct: roundState.correctCount,
        wrong: roundState.wrongCount,
        wordIds: roundState.roundWordIds,
      );

      final total = roundState.correctCount + roundState.wrongCount;
      final score = total > 0 ? (roundState.correctCount * 100.0 / total) : 0.0;

      if (roundState.isTest) {
        await _persistTestRound(roundState, score);
      } else {
        await _persistTrainingRound(roundState, score);
      }

      final settings = await _ref.read(ConfigService.appSettings.future);
      final allProgress = await _ref.read(ProgressService.allDeckProgress.future);
      final progress = allProgress[roundState.deckId] ?? DeckProgress(deckId: roundState.deckId);
      final retention = ProgressCalculator.calculateRetention(progress, settings.decayFormula);
      if (ProgressCalculator.shouldUpdatePeak(progress, retention)) {
        await _ref.read(ProgressService.instance).updatePeakRetention(roundState.deckId, retention);
      }

      if (roundState.allCards != null) {
        final termIds = roundState.roundWordIds
            .map((wid) => wid.split(':').first)
            .toSet();
        await _ref.read(ProgressService.instance).addTermsTouched(termIds);
      }
    } catch (e, st) {
      debugPrint('QuizService.persistRound error: $e\n$st');
    }
  }

  Future<void> _persistTestRound(RoundState roundState, double roundScore) async {
    final totalTerms = roundState.totalDeckTerms;
    final firstPassScore = totalTerms > 0
        ? (roundState.firstPassCorrect * 100.0 / totalTerms)
        : 0.0;

    _ref.read(lastRoundContributed.notifier).state = await _ref.read(ProgressService.instance).recordTestResult(
      deckId: roundState.deckId,
      firstPassScore: firstPassScore,
      roundScore: roundScore,
      mode: roundState.mode,
    );
  }

  Future<void> _persistTrainingRound(RoundState roundState, double roundScore) async {
    final modeCap = _modeCap(roundState.mode);
    final totalTerms = roundState.totalDeckTerms;
    final coverage = totalTerms > 0
        ? roundState.roundTermCount / totalTerms
        : 0.0;
    final total = roundState.correctCount + roundState.wrongCount;
    final accuracy = total > 0 ? roundState.correctCount / total : 0.0;

    _ref.read(lastRoundContributed.notifier).state = await _ref.read(ProgressService.instance).recordRound(
      deckId: roundState.deckId,
      score: roundScore,
      mode: roundState.mode,
      modeCap: modeCap,
      coverage: coverage,
      accuracy: accuracy,
    );
  }

  static double _modeCap(QuizMode mode) {
    return switch (mode) {
      QuizMode.nativeShown => ProgressConstants.capNativeShown,
      QuizMode.targetShown => ProgressConstants.capTargetShown,
      QuizMode.write => ProgressConstants.capWrite,
    };
  }

  String endRound() {
    final roundState = _ref.read(round);
    final originRoute = roundState?.originRoute ?? AppRoutes.home;
    final scrollOffset = roundState?.originScrollOffset ?? 0.0;
    setScrollOffset(scrollOffset);
    _ref.read(round.notifier).endRound();
    clearSelectedGroup();
    return originRoute;
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:langwij/entities/activity/activity.dart';
import 'package:langwij/entities/group/group.dart';
import 'package:langwij/entities/progress/progress.dart';
import 'package:langwij/shared/app/routing/routing.dart';

import '../model/round_state.dart';
import '../model/round_type.dart';
import '../model/vocab_card.dart';
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

      if (roundState.roundType == RoundType.vocabulary) {
        await _persistVocabRound(roundState, score);
      } else {
        await _persistNonVocabRound(roundState, score);
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

  Future<void> _persistVocabRound(RoundState roundState, double roundScore) async {
    if (roundState.isTest) {
      await _persistTestRound(roundState);
      return;
    }

    if (roundState.isLevelTraining) {
      await _persistLevelTrainingRound(roundState, roundScore);
      return;
    }

    final missedTermIds = <String>{};
    for (final entry in roundState.missedEntries) {
      if (entry.card is VocabCard) {
        missedTermIds.add((entry.card as VocabCard).wordId);
      }
    }

    final cardResults = roundState.roundWordIds.map((termId) => CardResult(
      termId: termId,
      hadWrongAttempt: missedTermIds.contains(termId),
    )).toList();

    await _ref.read(ProgressService.instance).recordVocabRound(
      deckId: roundState.deckId,
      mode: roundState.mode,
      cardResults: cardResults,
      totalDeckTerms: roundState.totalDeckTerms,
    );

    _ref.read(lastRoundContributed.notifier).state = true;
  }

  Future<void> _persistTestRound(RoundState roundState) async {
    final testCoverage = roundState.totalDeckTerms > 0
        ? (roundState.firstPassCorrect / roundState.totalDeckTerms) * 100.0
        : 0.0;

    await _ref.read(ProgressService.instance).recordTestResult(
      deckId: roundState.deckId,
      testCoverage: testCoverage,
    );

    _ref.read(lastRoundContributed.notifier).state = true;
  }

  Future<void> _persistLevelTrainingRound(RoundState roundState, double roundScore) async {
    if (roundState.mode != QuizMode.write) {
      _ref.read(lastRoundContributed.notifier).state = false;
      return;
    }

    final termDeckMap = roundState.termDeckMap!;
    final deckTermCounts = roundState.deckTermCounts!;

    final missedTermIds = <String>{};
    for (final entry in roundState.missedEntries) {
      if (entry.card is VocabCard) {
        missedTermIds.add((entry.card as VocabCard).wordId);
      }
    }

    final resultsByDeck = <String, List<CardResult>>{};
    for (final termId in roundState.roundWordIds) {
      final deckId = termDeckMap[termId];
      if (deckId == null) continue;
      resultsByDeck.putIfAbsent(deckId, () => []).add(
        CardResult(
          termId: termId,
          hadWrongAttempt: missedTermIds.contains(termId),
        ),
      );
    }

    for (final entry in resultsByDeck.entries) {
      final deckId = entry.key;
      final cardResults = entry.value;
      await _ref.read(ProgressService.instance).recordVocabRound(
        deckId: deckId,
        mode: roundState.mode,
        cardResults: cardResults,
        totalDeckTerms: deckTermCounts[deckId] ?? 0,
      );
    }

    _ref.read(lastRoundContributed.notifier).state = true;
  }

  Future<void> _persistNonVocabRound(RoundState roundState, double roundScore) async {
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

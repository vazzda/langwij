import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:langwij/entities/activity/activity.dart';
import 'package:langwij/entities/dictionary/dictionary.dart';
import 'package:langwij/entities/group/group.dart';
import 'package:langwij/entities/progress/progress.dart';
import 'package:langwij/shared/app/config/config.dart';
import 'package:langwij/shared/app/routing/routing.dart';

import '../model/missed_entry.dart';
import '../model/round_state.dart';
import '../model/round_type.dart';
import '../model/vocab_card.dart';
import 'agreement_round_builder.dart';
import 'card_generation_service.dart';

class QuizService {
  QuizService(this._ref);
  final Ref _ref;

  static final instance = Provider((ref) => QuizService(ref));

  static final round = NotifierProvider<RoundNotifier, RoundState?>(
    RoundNotifier.new,
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

class RoundNotifier extends Notifier<RoundState?> {
  static ({List<CardModel> queue, Set<String> wordIds}) _buildQueueAndWordIds(
    GroupModel group,
    int count,
  ) {
    if (group.cards.isEmpty) return (queue: [], wordIds: {});
    final indices = List.generate(group.cards.length, (i) => i)..shuffle(Random());
    final take = count.clamp(1, indices.length);
    final selected = indices.take(take).toList();
    final queue = selected.map((i) => group.cards[i]).toList();
    final wordIds = <String>{};
    for (final i in selected) {
      if (group.type == GroupType.words) {
        wordIds.add('${group.id}:${group.cards[i].targetText}');
      } else {
        wordIds.add('${group.id}:${i ~/ 6}');
      }
    }
    return (queue: queue, wordIds: wordIds);
  }

  @override
  RoundState? build() => null;

  void startVocab({
    required VocabDeckModel deck,
    required LanguagePack targetPack,
    required LanguagePack nativePack,
    required QuizMode mode,
    required int questionCount,
    required String originRoute,
    double originScrollOffset = 0.0,
    bool isTest = false,
  }) {
    final service = CardGenerationService();
    final allCards = service.buildCards(
      deck: deck,
      targetPack: targetPack,
      nativePack: nativePack,
    );
    if (allCards.isEmpty) return;

    final indices = List.generate(allCards.length, (i) => i)..shuffle(Random());
    final take = questionCount.clamp(1, indices.length);
    final selected = indices.take(take).toList();
    final queue = selected.map((i) => allCards[i]).toList();
    final wordIds = selected.map((i) => allCards[i].wordId).toSet();

    final resolvedName = nativePack.deckMeta[deck.id]?.name ?? deck.id;

    state = RoundState(
      deckId: deck.id,
      deckName: resolvedName,
      mode: mode,
      requestedCount: questionCount,
      roundType: RoundType.vocabulary,
      originRoute: originRoute,
      originScrollOffset: originScrollOffset,
      isTest: isTest,
      totalDeckTerms: deck.termIds.length,
      queue: queue,
      allCards: allCards,
      roundWordIds: wordIds,
    );
  }

  void start({
    required GroupModel group,
    required QuizMode mode,
    required int questionCount,
    required String originRoute,
    double originScrollOffset = 0.0,
  }) {
    final result = _buildQueueAndWordIds(group, questionCount);
    final roundType = group.type == GroupType.endings
        ? RoundType.conjugations
        : RoundType.vocabulary;
    state = RoundState(
      deckId: group.id,
      mode: mode,
      requestedCount: questionCount,
      roundType: roundType,
      originRoute: originRoute,
      originScrollOffset: originScrollOffset,
      queue: result.queue,
      roundWordIds: result.wordIds,
    );
  }

  void startAgreement({
    required GroupModel adjectiveGroup,
    required List<GroupModel> allGroups,
    required QuizMode mode,
    required int questionCount,
    required String originRoute,
    double originScrollOffset = 0.0,
  }) {
    final nounGroups = allGroups
        .where((g) => g.category == GroupCategory.noun)
        .toList();
    final result = buildAgreementQueue(
      adjectiveGroup: adjectiveGroup,
      nounGroups: nounGroups,
      count: questionCount,
      random: Random(),
    );
    state = RoundState(
      deckId: 'agreement:${adjectiveGroup.id}',
      mode: mode,
      requestedCount: questionCount,
      roundType: RoundType.agreement,
      originRoute: originRoute,
      originScrollOffset: originScrollOffset,
      adjectiveGroupId: adjectiveGroup.id,
      queue: result.queue,
      roundWordIds: result.wordIds,
    );
  }

  void answerCorrect() {
    if (state == null || state!.queue.isEmpty) return;
    final card = state!.queue.first;
    final cardId = card is VocabCard ? card.wordId : card.targetAnswer;
    final isFirstAttempt = !state!.attemptedCardIds.contains(cardId);
    final rest = state!.queue.skip(1).toList();
    state = state!.copyWith(
      queue: rest,
      correctCount: state!.correctCount + 1,
      firstPassCorrect:
          isFirstAttempt ? state!.firstPassCorrect + 1 : state!.firstPassCorrect,
      attemptedCardIds: {...state!.attemptedCardIds, cardId},
      correctEntries: isFirstAttempt
          ? [...state!.correctEntries, card]
          : null,
    );
  }

  void answerWrong({String? userTypedAnswer}) {
    if (state == null || state!.queue.isEmpty) return;
    final card = state!.queue.first;
    final cardId = card is VocabCard ? card.wordId : card.targetAnswer;
    final rest = state!.queue.skip(1).toList();
    final entry = MissedEntry(card: card, userTypedAnswer: userTypedAnswer);
    state = state!.copyWith(
      queue: [...rest, card],
      wrongCount: state!.wrongCount + 1,
      attemptedCardIds: {...state!.attemptedCardIds, cardId},
      missedEntries: [...state!.missedEntries, entry],
    );
  }

  void restartFromAllCards() {
    if (state == null || state!.allCards == null) return;
    final allCards = state!.allCards!;
    final indices = List.generate(allCards.length, (i) => i)..shuffle(Random());
    final take = state!.requestedCount.clamp(1, indices.length);
    final selected = indices.take(take).toList();
    final queue = selected.map((i) => allCards[i]).toList();
    final wordIds = selected.map((i) {
      final c = allCards[i];
      return c is VocabCard ? c.wordId : '${state!.deckId}:${c.targetText}';
    }).toSet();
    state = RoundState(
      deckId: state!.deckId,
      deckName: state!.deckName,
      mode: state!.mode,
      requestedCount: state!.requestedCount,
      roundType: state!.roundType,
      originRoute: state!.originRoute,
      originScrollOffset: state!.originScrollOffset,
      isTest: state!.isTest,
      totalDeckTerms: state!.totalDeckTerms,
      queue: queue,
      allCards: allCards,
      roundWordIds: wordIds,
    );
  }

  void endRound() {
    state = null;
  }
}

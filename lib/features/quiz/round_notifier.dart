import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../entities/card/card_model.dart';
import '../../entities/card/vocab_card.dart';
import '../../entities/group/group_model.dart';
import '../../entities/deck/vocab_deck_model.dart';
import '../../entities/language/language_pack.dart';
import 'agreement_round_builder.dart';
import 'quiz_mode.dart';
import 'services/card_generation_service.dart';
import 'round_state.dart';

/// Builds initial queue and set of distinct word IDs for a legacy group (endings/tools).
({List<CardModel> queue, Set<String> wordIds}) _buildQueueAndWordIds(
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

/// Notifier that holds round state and applies answer (correct → remove from queue; wrong → move to end, add to missed).
class RoundNotifier extends StateNotifier<RoundState?> {
  RoundNotifier(Ref ref) : super(null);

  /// Start a vocabulary round from the new dictionary system.
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

    final resolvedName =
        nativePack.deckMeta[deck.id]?.name ?? deck.id;

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

  /// Start a legacy round (endings, tools) from the old GroupModel.
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

  /// [userTypedAnswer] optional; pass in Write mode to show "you wrote" on result screen.
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

  /// Restart the current round with reshuffled cards from allCards.
  /// Used by "Again" button for vocab rounds.
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

final roundProvider =
    StateNotifierProvider<RoundNotifier, RoundState?>((ref) {
  return RoundNotifier(ref);
});

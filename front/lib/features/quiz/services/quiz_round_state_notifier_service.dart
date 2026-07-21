import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:langwij/entities/dictionary/dictionary.dart';
import 'package:langwij/entities/group/group.dart';
import 'package:langwij/entities/progress/progress.dart';

import '../model/missed_entry.dart';
import '../model/round_state.dart';
import '../model/round_type.dart';
import '../model/vocab_card.dart';
import 'agreement_round_builder_service.dart';
import 'card_generation_service.dart';

class QuizRoundStateNotifierService extends Notifier<RoundState?> {
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
    required Map<String, Term> terms,
    double originScrollOffset = 0.0,
    bool isTest = false,
  }) {
    final service = CardGenerationService();
    final allCards = service.buildCards(
      deck: deck,
      targetPack: targetPack,
      nativePack: nativePack,
      terms: terms,
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

  void startLevelTraining({
    required List<({VocabDeckModel deck, double practice})> deckPool,
    required LanguagePack targetPack,
    required LanguagePack nativePack,
    required QuizMode mode,
    required int questionCount,
    required String levelId,
    required String levelName,
    required String originRoute,
    required Map<String, Term> terms,
    double originScrollOffset = 0.0,
  }) {
    if (deckPool.isEmpty) return;

    final service = CardGenerationService();
    final deckCards = <String, List<VocabCard>>{};
    final deckTermCounts = <String, int>{};
    for (final entry in deckPool) {
      final cards = service.buildCards(
        deck: entry.deck,
        targetPack: targetPack,
        nativePack: nativePack,
        terms: terms,
      );
      deckCards[entry.deck.id] = cards;
      deckTermCounts[entry.deck.id] = entry.deck.termIds.length;
    }

    final cardToDeck = <VocabCard, String>{};
    for (final entry in deckCards.entries) {
      for (final card in entry.value) {
        cardToDeck[card] = entry.key;
      }
    }

    final allCards = deckCards.values.expand((c) => c).toList();
    final pool = [...allCards]..shuffle(Random());
    final take = questionCount.clamp(1, pool.length);
    final selected = pool.take(take).toList();

    final termDeckMap = <String, String>{};
    for (final card in selected) {
      termDeckMap[card.termId] = cardToDeck[card]!;
    }

    if (selected.isEmpty) return;

    final wordIds = selected.map((c) => c.wordId).toSet();

    state = RoundState(
      deckId: levelId,
      deckName: levelName,
      mode: mode,
      requestedCount: questionCount,
      roundType: RoundType.vocabulary,
      originRoute: originRoute,
      originScrollOffset: originScrollOffset,
      isLevelTraining: true,
      totalDeckTerms: deckTermCounts.values.fold(0, (s, v) => s + v),
      termDeckMap: termDeckMap,
      deckTermCounts: deckTermCounts,
      queue: selected,
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
      allCards: group.cards,
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
    final result = AgreementRoundBuilderService.buildAgreementQueue(
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
      allCards: result.queue,
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
      queue: state!.isTest ? rest : [...rest, card],
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

import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../entities/card/card_model.dart';
import '../../entities/card/vocab_card.dart';
import '../../entities/group/group_model.dart';
import '../../entities/group/vocab_group_model.dart';
import '../../entities/language/language_pack.dart';
import 'agreement_session_builder.dart';
import 'quiz_mode.dart';
import 'services/card_generation_service.dart';
import 'session_state.dart';

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

/// Notifier that holds session state and applies answer (correct → remove from queue; wrong → move to end, add to missed).
class SessionNotifier extends StateNotifier<SessionState?> {
  SessionNotifier(Ref ref) : super(null);

  /// Start a vocabulary session from the new dictionary system.
  void startVocab({
    required VocabGroupModel group,
    required LanguagePack targetPack,
    required LanguagePack nativePack,
    required QuizMode mode,
    required int questionCount,
    required String originRoute,
    double originScrollOffset = 0.0,
  }) {
    final service = CardGenerationService();
    final allCards = service.buildCards(
      group: group,
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
        nativePack.groupMeta[group.id]?.name ?? group.id;

    state = SessionState(
      groupId: group.id,
      groupName: resolvedName,
      mode: mode,
      requestedCount: questionCount,
      sessionType: SessionType.vocabulary,
      originRoute: originRoute,
      originScrollOffset: originScrollOffset,
      queue: queue,
      allCards: allCards,
      sessionWordIds: wordIds,
    );
  }

  /// Start a legacy session (endings, tools) from the old GroupModel.
  void start({
    required GroupModel group,
    required QuizMode mode,
    required int questionCount,
    required String originRoute,
    double originScrollOffset = 0.0,
  }) {
    final result = _buildQueueAndWordIds(group, questionCount);
    final sessionType = group.type == GroupType.endings
        ? SessionType.conjugations
        : SessionType.vocabulary;
    state = SessionState(
      groupId: group.id,
      mode: mode,
      requestedCount: questionCount,
      sessionType: sessionType,
      originRoute: originRoute,
      originScrollOffset: originScrollOffset,
      queue: result.queue,
      sessionWordIds: result.wordIds,
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
    state = SessionState(
      groupId: 'agreement:${adjectiveGroup.id}',
      mode: mode,
      requestedCount: questionCount,
      sessionType: SessionType.agreement,
      originRoute: originRoute,
      originScrollOffset: originScrollOffset,
      adjectiveGroupId: adjectiveGroup.id,
      queue: result.queue,
      sessionWordIds: result.wordIds,
    );
  }

  void answerCorrect() {
    if (state == null || state!.queue.isEmpty) return;
    final rest = state!.queue.skip(1).toList();
    state = state!.copyWith(
      queue: rest,
      correctCount: state!.correctCount + 1,
    );
  }

  /// [userTypedAnswer] optional; pass in Write mode to show "you wrote" on result screen.
  void answerWrong({String? userTypedAnswer}) {
    if (state == null || state!.queue.isEmpty) return;
    final card = state!.queue.first;
    final rest = state!.queue.skip(1).toList();
    final entry = MissedEntry(card: card, userTypedAnswer: userTypedAnswer);
    state = state!.copyWith(
      queue: [...rest, card],
      wrongCount: state!.wrongCount + 1,
      missedEntries: [...state!.missedEntries, entry],
    );
  }

  /// Restart the current session with reshuffled cards from allCards.
  /// Used by "Again" button for vocab sessions.
  void restartFromAllCards() {
    if (state == null || state!.allCards == null) return;
    final allCards = state!.allCards!;
    final indices = List.generate(allCards.length, (i) => i)..shuffle(Random());
    final take = state!.requestedCount.clamp(1, indices.length);
    final selected = indices.take(take).toList();
    final queue = selected.map((i) => allCards[i]).toList();
    final wordIds = selected.map((i) {
      final c = allCards[i];
      return c is VocabCard ? c.wordId : '${state!.groupId}:${c.targetText}';
    }).toSet();
    state = SessionState(
      groupId: state!.groupId,
      groupName: state!.groupName,
      mode: state!.mode,
      requestedCount: state!.requestedCount,
      sessionType: state!.sessionType,
      originRoute: state!.originRoute,
      originScrollOffset: state!.originScrollOffset,
      queue: queue,
      allCards: allCards,
      sessionWordIds: wordIds,
    );
  }

  void endSession() {
    state = null;
  }
}

final sessionProvider =
    StateNotifierProvider<SessionNotifier, SessionState?>((ref) {
  return SessionNotifier(ref);
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../app/providers/groups_provider.dart';
import '../entities/card/card_model.dart';
import '../features/quiz/display_english.dart' show displayNativeForCard;
import '../features/quiz/services/quiz_round_service.dart';
import '../features/quiz/quiz_mode.dart';
import '../features/quiz/round_notifier.dart';
import '../features/quiz/round_state.dart';
import '../app/router/app_router.dart';
import '../shared/ui/bottom_sheet/langwij_bug_report_sheet.dart';
import 'package:flessel/flessel.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = FlesselThemes.of(context);
    final round = ref.watch(roundProvider);

    if (round == null) {
      // Round ended - navigation should already be handled by Back/Again button
      return const Scaffold(body: Center(child: FlesselSpinner()));
    }

    return FlesselScaffold(
      title: l10n.resultTitle,
      uppercaseTitle: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(FlesselLayout.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FlesselCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.correctCount(round.correctCount),
                    style: FlesselFonts.contentXxxlAccent.copyWith(color: t.accentColor),
                  ),
                  const FlesselGap.s(),
                  Text(
                    l10n.wrongCount(round.wrongCount),
                    style: FlesselFonts.contentXxxlAccent.copyWith(color: t.dangerColor),
                  ),
                ],
              ),
            ),
            const FlesselGap.xl(),
            Row(
              children: [
                Expanded(
                  child: FlesselAccentButton(
                    label: l10n.again,
                    onPressed: () {
                      final round = ref.read(roundProvider);
                      if (round == null) return;

                      // Vocab rounds: restart from allCards
                      if (round.allCards != null) {
                        ref.read(roundProvider.notifier).restartFromAllCards();
                        if (context.mounted) {
                          context.go(AppRoutes.round);
                        }
                        return;
                      }

                      // Agreement rounds
                      final groups = ref.read(groupsProvider).valueOrNull;
                      if (groups == null) return;
                      if (round.roundType == RoundType.agreement) {
                        final adjId = round.adjectiveGroupId;
                        if (adjId == null) return;
                        try {
                          final adjGroup = groups.firstWhere(
                            (g) => g.id == adjId,
                          );
                          ref.read(roundProvider.notifier).startAgreement(
                                adjectiveGroup: adjGroup,
                                allGroups: groups,
                                mode: round.mode,
                                questionCount: round.requestedCount,
                                originRoute: round.originRoute,
                              );
                          if (context.mounted) {
                            context.go(AppRoutes.round);
                          }
                        } catch (_) {}
                        return;
                      }

                      // Legacy tool rounds (conjugations)
                      try {
                        final group = groups.firstWhere(
                          (g) => g.id == round.deckId,
                        );
                        ref.read(roundProvider.notifier).start(
                              group: group,
                              mode: round.mode,
                              questionCount: round.requestedCount,
                              originRoute: round.originRoute,
                            );
                        if (context.mounted) {
                          context.go(AppRoutes.round);
                        }
                      } catch (_) {}
                    },
                  ),
                ),
                const FlesselGap.m(),
                Expanded(
                  child: FlesselButton(
                    label: l10n.back,
                    onPressed: () {
                      final originRoute =
                          ref.read(quizRoundServiceProvider).endRound();
                      if (context.mounted) {
                        context.go(originRoute);
                      }
                    },
                  ),
                ),
              ],
            ),
            if (!ref.read(quizRoundServiceProvider).lastRoundContributed) ...[
              const FlesselGap.l(),
              FlesselNote(text: l10n.result_techWork),
            ],
            if (round.missedEntries.isNotEmpty) ...[
              const FlesselGap.xl(),
              Text(
                l10n.reviewWrongTitle,
                style: FlesselFonts.contentXxxlAccent.copyWith(color: t.textPrimary),
              ),
              const FlesselGap.xs(),
              Text(
                l10n.reviewWrongSubtitle,
                style: FlesselFonts.contentM.copyWith(color: t.textPrimary),
              ),
              const FlesselGap.m(),
              ...round.missedEntries.map(
                (entry) => _ResultEntryTile(
                  card: entry.card,
                  mode: round.mode,
                  userTypedAnswer: entry.userTypedAnswer,
                ),
              ),
            ],
            if (round.correctEntries.isNotEmpty) ...[
              const FlesselGap.xl(),
              Text(
                l10n.result_correctTitle,
                style: FlesselFonts.contentXxxlAccent.copyWith(color: t.textPrimary),
              ),
              const FlesselGap.xs(),
              Text(
                l10n.result_correctSubtitle,
                style: FlesselFonts.contentM.copyWith(color: t.textPrimary),
              ),
              const FlesselGap.m(),
              ...round.correctEntries.map(
                (card) => _ResultEntryTile(card: card, mode: round.mode),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultEntryTile extends StatelessWidget {
  const _ResultEntryTile({
    required this.card,
    required this.mode,
    this.userTypedAnswer,
  });

  final CardModel card;
  final QuizMode mode;
  /// Non-null only for missed entries in write mode.
  final String? userTypedAnswer;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final l10n = AppLocalizations.of(context)!;

    final isWriteWithTyped = mode == QuizMode.write && userTypedAnswer != null;

    return FlesselCard(
      margin: FlesselSize.xs,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: isWriteWithTyped
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${l10n.youWrote} ${userTypedAnswer!.isEmpty ? l10n.emptyAnswer : userTypedAnswer}',
                        style: FlesselFonts.contentL.copyWith(color: t.textPrimary),
                      ),
                      const FlesselGap.xs(),
                      Text(
                        '${l10n.correctAnswerLabel} ${card.targetAnswer} → ${displayNativeForCard(card, l10n)}',
                        style: FlesselFonts.contentLAccent.copyWith(color: t.textPrimary),
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          card.targetAnswer,
                          style: FlesselFonts.contentLAccent.copyWith(
                            color: t.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        ' → ',
                        style: FlesselFonts.contentL.copyWith(color: t.textPrimary),
                      ),
                      Expanded(
                        child: Text(
                          displayNativeForCard(card, l10n),
                          style: FlesselFonts.contentL.copyWith(color: t.textPrimary),
                        ),
                      ),
                    ],
                  ),
          ),
          const FlesselGap.s(),
          FlesselDangerButton(
            icon: PhosphorIconsBold.bug,
            size: FlesselSize.s,
            margin: EdgeInsets.zero,
            onPressed: () => showLangwijBugReportSheet(context, card: card),
          ),
        ],
      ),
    );
  }
}

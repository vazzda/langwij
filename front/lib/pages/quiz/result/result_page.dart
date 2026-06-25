import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/entities/group/group.dart';
import 'package:langwij/entities/progress/progress.dart';
import 'package:langwij/features/quiz/quiz.dart';
import 'package:langwij/shared/app/routing/routing.dart';
import 'package:langwij/shared/bug_report/bug_report.dart';

class ResultPage extends ConsumerWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = FlesselThemes.of(context);
    final round = ref.watch(QuizService.round);

    if (round == null) {
      return const Scaffold(body: Center(child: FlesselSpinner()));
    }

    return FlesselScaffold(
      title: l10n.resultTitle,
      uppercaseTitle: true,
      child: SingleChildScrollView(
        padding: FlesselLayout.screenPaddingInsets(context),
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
                  child: FlesselButton(
                    variant: FlesselVariant.accent,
                    label: l10n.again,
                    onPressed: () {
                      final round = ref.read(QuizService.round);
                      if (round == null) return;

                      if (round.allCards != null) {
                        ref.read(QuizService.round.notifier).restartFromAllCards();
                        if (context.mounted) {
                          context.go(AppRoutes.round);
                        }
                        return;
                      }

                      final groups = ref.read(GroupService.groups).valueOrNull;
                      if (groups == null) return;
                      if (round.roundType == RoundType.agreement) {
                        final adjId = round.adjectiveGroupId;
                        if (adjId == null) return;
                        try {
                          final adjGroup = groups.firstWhere(
                            (g) => g.id == adjId,
                          );
                          ref.read(QuizService.round.notifier).startAgreement(
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

                      try {
                        final group = groups.firstWhere(
                          (g) => g.id == round.deckId,
                        );
                        ref.read(QuizService.round.notifier).start(
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
                      final originRoute = ref.read(QuizService.instance).endRound();
                      if (context.mounted) {
                        context.go(originRoute);
                      }
                    },
                  ),
                ),
              ],
            ),
            if (!ref.watch(QuizService.lastRoundContributed)) ...[
              const FlesselGap.l(),
              FlesselNote(text: l10n.result_techWork),
            ],
            if (round.missedEntries.isNotEmpty) ...[
              const FlesselGap.xl(),
              Text(
                l10n.reviewWrongTitle,
                style: FlesselFonts.contentXxxlAccent.copyWith(color: t.fg),
              ),
              const FlesselGap.xs(),
              Text(
                l10n.reviewWrongSubtitle,
                style: FlesselFonts.contentM.copyWith(color: t.fg),
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
                style: FlesselFonts.contentXxxlAccent.copyWith(color: t.fg),
              ),
              const FlesselGap.xs(),
              Text(
                l10n.result_correctSubtitle,
                style: FlesselFonts.contentM.copyWith(color: t.fg),
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
                        style: FlesselFonts.contentL.copyWith(color: t.fg),
                      ),
                      const FlesselGap.xs(),
                      Text(
                        '${l10n.correctAnswerLabel} ${card.targetAnswer} → ${displayNativeForCard(card, l10n)}',
                        style: FlesselFonts.contentLAccent.copyWith(color: t.fg),
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
                            color: t.fg,
                          ),
                        ),
                      ),
                      Text(
                        ' → ',
                        style: FlesselFonts.contentL.copyWith(color: t.fg),
                      ),
                      Expanded(
                        child: Text(
                          displayNativeForCard(card, l10n),
                          style: FlesselFonts.contentL.copyWith(color: t.fg),
                        ),
                      ),
                    ],
                  ),
          ),
          const FlesselGap.s(),
          FlesselButton(
            variant: FlesselVariant.danger,
            icon: PhosphorIconsBold.bug,
            size: FlesselSize.s,
            onPressed: () => showLangwijBugReportSheet(
              context,
              targetText: card.targetAnswer,
              nativeText: card.nativeText,
            ),
          ),
        ],
      ),
    );
  }
}

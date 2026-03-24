import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../l10n/app_localizations.dart';
import '../app/providers/groups_provider.dart';
import '../entities/card/card_model.dart';
import '../features/quiz/display_english.dart' show displayNativeForCard;
import '../features/quiz/services/quiz_round_service.dart';
import '../features/quiz/quiz_mode.dart';
import '../features/quiz/round_notifier.dart';
import '../features/quiz/round_state.dart';
import '../app/router/app_router.dart';
import '../app/theme/vessel_themes.dart';
import '../shared/ui/buttons/vessel_buttons.dart';
import '../shared/ui/bottom_sheet/bug_report_sheet.dart';
import '../shared/ui/card/vessel_card.dart';
import '../shared/ui/screen_layout/vessel_scaffold.dart';
import '../shared/ui/gap/vessel_gap.dart';
import '../shared/ui/note/vessel_note.dart';
import '../app/layout/vessel_layout.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = VesselThemes.of(context);
    final round = ref.watch(roundProvider);

    if (round == null) {
      // Round ended - navigation should already be handled by Back/Again button
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return VesselScaffold(
      title: l10n.resultTitle,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(VesselLayout.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VesselCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.correctCount(round.correctCount),
                    style: VesselFonts.textContentHeader.copyWith(color: t.accentColor),
                  ),
                  const VesselGap.s(),
                  Text(
                    l10n.wrongCount(round.wrongCount),
                    style: VesselFonts.textContentHeader.copyWith(color: t.dangerColor),
                  ),
                ],
              ),
            ),
            const VesselGap.xl(),
            Row(
              children: [
                Expanded(
                  child: VesselAccentButton(
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
                const VesselGap.hm(),
                Expanded(
                  child: VesselButton(
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
              const VesselGap.l(),
              VesselNote(text: l10n.result_techWork),
            ],
            if (round.missedEntries.isNotEmpty) ...[
              const VesselGap.xl(),
              Text(
                l10n.reviewWrongTitle,
                style: VesselFonts.textContentHeader.copyWith(color: t.textPrimary),
              ),
              const VesselGap.xs(),
              Text(
                l10n.reviewWrongSubtitle,
                style: VesselFonts.textBody.copyWith(color: t.textPrimary),
              ),
              const VesselGap.m(),
              ...round.missedEntries.map(
                (entry) => _ResultEntryTile(
                  card: entry.card,
                  mode: round.mode,
                  userTypedAnswer: entry.userTypedAnswer,
                ),
              ),
            ],
            if (round.correctEntries.isNotEmpty) ...[
              const VesselGap.xl(),
              Text(
                l10n.result_correctTitle,
                style: VesselFonts.textContentHeader.copyWith(color: t.textPrimary),
              ),
              const VesselGap.xs(),
              Text(
                l10n.result_correctSubtitle,
                style: VesselFonts.textBody.copyWith(color: t.textPrimary),
              ),
              const VesselGap.m(),
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
    final t = VesselThemes.of(context);
    final l10n = AppLocalizations.of(context)!;

    final isWriteWithTyped = mode == QuizMode.write && userTypedAnswer != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: VesselLayout.listItemGapSmall),
      child: VesselCard(
        padding: const EdgeInsets.symmetric(vertical: VesselLayout.resultEntryPaddingV, horizontal: VesselLayout.resultEntryPaddingH),
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
                          style: VesselFonts.textBodyLarge.copyWith(color: t.textPrimary),
                        ),
                        const VesselGap.xs(),
                        Text(
                          '${l10n.correctAnswerLabel} ${card.targetAnswer} → ${displayNativeForCard(card, l10n)}',
                          style: VesselFonts.textBodyLargeAccented.copyWith(color: t.textPrimary),
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            card.targetAnswer,
                            style: VesselFonts.textBodyLargeAccented.copyWith(
                              color: t.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          ' → ',
                          style: VesselFonts.textBodyLarge.copyWith(color: t.textPrimary),
                        ),
                        Expanded(
                          child: Text(
                            displayNativeForCard(card, l10n),
                            style: VesselFonts.textBodyLarge.copyWith(color: t.textPrimary),
                          ),
                        ),
                      ],
                    ),
            ),
            const VesselGap.hs(),
            VesselDangerButton(
              icon: PhosphorIconsBold.bug,
              size: VesselButtonSize.small,
              margin: EdgeInsets.zero,
              onPressed: () => showBugReportSheet(context, card: card),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/entities/dictionary/dictionary.dart';
import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/shared/app/layout/layout.dart';
import '../../deck_card/ui/vocab_deck_card.dart';
import '../../deck_card/model/vocab_level_data.dart';

class LangwijVocabLevelCard extends StatelessWidget {
  const LangwijVocabLevelCard({
    super.key,
    required this.item,
    required this.l10n,
    required this.isExpanded,
    required this.onToggle,
    required this.onDeckTap,
    this.onTrainTap,
  });

  final VocabLevelData item;
  final AppLocalizations l10n;
  final bool isExpanded;
  final VoidCallback onToggle;
  final void Function(VocabDeckModel deck, int cardCount) onDeckTap;
  final VoidCallback? onTrainTap;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final counterStyle =
        FlesselFonts.contentBodyAccent.copyWith(color: t.fg);
    final labelStyle =
        FlesselFonts.contentBody.copyWith(color: t.fg);
    final allInPractice = item.decks.isNotEmpty &&
        item.decks.every((d) => d.coverage != null && d.coverage! >= 100);
    final levelMastery = item.decks.isNotEmpty
        ? item.decks.map((d) => d.mastery).reduce((a, b) => a < b ? a : b)
        : 0;
    final avgPractice = allInPractice
        ? item.decks.map((d) => d.practice).reduce((a, b) => a + b) /
            item.decks.length /
            100.0
        : 0.0;

    return FlesselCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: FlesselFonts.displayXl
                            .copyWith(color: t.fg),
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? PhosphorIconsRegular.caretDown
                          : PhosphorIconsRegular.caretRight,
                      size: FlesselLayout.iconS,
                      color: t.fgSecondary,
                    ),
                  ],
                ),
                const FlesselGap.s(),
                Row(
                  children: [
                    SizedBox(
                      width: LangwijLayout.vocabProgressWordsWidth,
                      child: Row(
                        children: [
                          Text(l10n.vocab_termsLabel, style: labelStyle),
                          const Spacer(),
                          Text('${item.totalCardCount}', style: counterStyle),
                        ],
                      ),
                    ),
                    const FlesselGap.m(),
                    Expanded(
                      child: FlesselProgressBar(
                        value: (item.levelProgress / 100.0).clamp(0.0, 1.0),
                        mode: FlesselProgressBarMode.detailed,
                        variant: FlesselProgressBarVariant.accent,
                      ),
                    ),
                    const FlesselGap.xs(),
                    SizedBox(
                      width: LangwijLayout.vocabProgressPercentWidth,
                      child: Text(
                        '${item.levelProgress.round()}%',
                        textAlign: TextAlign.end,
                        style: counterStyle,
                      ),
                    ),
                  ],
                ),
                if (allInPractice) ...[
                  const FlesselGap.xs(),
                  Row(
                    children: [
                      SizedBox(
                        width: LangwijLayout.vocabProgressWordsWidth,
                        child: Row(
                          children: [
                            Text(l10n.vocab_masteryLabel, style: labelStyle),
                            const Spacer(),
                            Text('$levelMastery', style: counterStyle),
                          ],
                        ),
                      ),
                      const FlesselGap.m(),
                      Expanded(
                        child: FlesselProgressBar(
                          value: avgPractice.clamp(0.0, 1.0),
                          mode: FlesselProgressBarMode.detailed,
                          variant: FlesselProgressBarVariant.accent,
                        ),
                      ),
                      const FlesselGap.xs(),
                      SizedBox(
                        width: LangwijLayout.vocabProgressPercentWidth,
                        child: Text(
                          '${(avgPractice * 100).round()}%',
                          textAlign: TextAlign.end,
                          style: counterStyle,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(
              height: LangwijLayout.vocabProgressSpacingAfter,
            ),
            if (item.description != null) ...[
              Text(
                item.description!,
                style: FlesselFonts.contentCaption
                    .copyWith(color: t.fgSecondary),
              ),
              const FlesselGap.s(),
            ],
            ...item.decks.map(
              (g) => LangwijVocabDeckCard(
                item: g,
                l10n: l10n,
                onTap: () => onDeckTap(g.deck, g.cardCount),
              ),
            ),
          ],
          if (allInPractice) ...[
            const FlesselGap.s(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FlesselButton(
                  surface: FlesselSurface.s21,
                  label: l10n.vocab_train,
                  onPressed: onTrainTap,
                  size: FlesselSize.s,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

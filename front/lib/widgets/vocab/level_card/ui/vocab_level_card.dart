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
  });

  final VocabLevelData item;
  final AppLocalizations l10n;
  final bool isExpanded;
  final VoidCallback onToggle;
  final void Function(VocabDeckModel deck, int cardCount) onDeckTap;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final isPremium = item.tier == LevelTier.premium;
    final counterStyle =
        FlesselFonts.contentBodyAccent.copyWith(color: t.fg);

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
                    if (isPremium)
                      Icon(
                        PhosphorIconsRegular.lock,
                        size: FlesselLayout.iconS,
                        color: t.fgSecondary,
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
                      child: Text(
                        '${item.totalCardCount}',
                        textAlign: TextAlign.start,
                        style: counterStyle,
                      ),
                    ),
                    const FlesselGap.xs(),
                    Expanded(
                      child: FlesselProgressBar(
                        value: (item.levelProgress / 100.0).clamp(0.0, 1.0),
                        mode: FlesselProgressBarMode.detailed,
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
                    const FlesselGap.xs(),
                    FlesselButton(
                      variant: FlesselVariant.accent,
                      label: l10n.vocab_train,
                      onPressed: item.levelProgress >= 100.0 ? () {} : null,
                      size: FlesselSize.s,
                    ),
                  ],
                ),
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
        ],
      ),
    );
  }
}

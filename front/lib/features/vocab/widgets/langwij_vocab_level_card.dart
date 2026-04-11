import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';

import '../../../entities/deck/vocab_deck_model.dart';
import '../../../entities/plan/level_tier.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/layout/langwij_layout.dart';
import 'langwij_vocab_deck_tile.dart';
import 'langwij_vocab_level_stats_row.dart';
import 'vocab_deck_tile_data.dart';

/// Langwij composite: a single level card on the vocab list screen.
///
/// The header (level name + progress row) is tappable and toggles
/// [isExpanded] via [onToggle]. When expanded, the body shows an optional
/// description, a [Wrap] of [LangwijVocabDeckTile] children sized via
/// [LayoutBuilder], and a closing [LangwijVocabLevelStatsRow].
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
        FlesselFonts.contentBodyAccent.copyWith(color: t.textPrimary);

    return FlesselCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tappable header: name row + progress bar row
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
                            .copyWith(color: t.textPrimary),
                      ),
                    ),
                    if (isPremium)
                      Icon(
                        PhosphorIconsRegular.lock,
                        size: FlesselLayout.iconS,
                        color: t.textSecondary,
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
                  ],
                ),
              ],
            ),
          ),
          // Body: visible only when expanded
          if (isExpanded) ...[
            const SizedBox(
              height: LangwijLayout.vocabProgressSpacingAfter,
            ),
            if (item.description != null) ...[
              Text(
                item.description!,
                style: FlesselFonts.contentCaption
                    .copyWith(color: t.textSecondary),
              ),
              const FlesselGap.s(),
            ],
            LayoutBuilder(
              builder: (context, constraints) {
                final n = ((constraints.maxWidth + FlesselLayout.gapM) /
                        (LangwijLayout.vocabTileMinWidth + FlesselLayout.gapM))
                    .floor()
                    .clamp(1, 100);
                final tileWidth =
                    (constraints.maxWidth - FlesselLayout.gapM * (n - 1)) / n;
                return Wrap(
                  spacing: FlesselLayout.gapM,
                  runSpacing: FlesselLayout.gapM,
                  children: item.decks
                      .map(
                        (g) => LangwijVocabDeckTile(
                          item: g,
                          l10n: l10n,
                          width: tileWidth,
                          onTap: () => onDeckTap(g.deck, g.cardCount),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const FlesselGap.l(),
            LangwijVocabLevelStatsRow(item: item, l10n: l10n),
          ],
        ],
      ),
    );
  }
}

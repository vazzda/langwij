import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/shared/lib/deck_icons.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/layout/langwij_layout.dart';
import 'vocab_deck_tile_data.dart';

/// Langwij composite: a single deck tile inside a vocab level card.
///
/// Wraps [FlesselTile] with a fixed [LangwijLayout.vocabTileHeight] envelope.
/// `onTap` is gated to null when the deck has no cards. The internal layout
/// is a stack of three [Positioned] children: header (icon + counter +
/// progress bar), title, and word preview.
class LangwijVocabDeckTile extends StatelessWidget {
  const LangwijVocabDeckTile({
    super.key,
    required this.item,
    required this.l10n,
    required this.width,
    required this.onTap,
  });

  final VocabDeckTileData item;
  final AppLocalizations l10n;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final barValue = item.percentage != null ? item.percentage! / 100.0 : 0.0;
    final iconData = item.icon != null
        ? DeckIcons.fromString(item.icon!)
        : DeckIcons.fallback;
    final dimmedTextColor = t.textPrimary.withValues(alpha: t.disabledOpacity);

    return SizedBox(
      width: width,
      height: LangwijLayout.vocabTileHeight,
      child: FlesselTile(
        onTap: item.cardCount > 0 ? onTap : null,
        child: Stack(
          children: [
            // Header: icon (left) + stats column (right)
            Positioned(
              top: LangwijLayout.vocabTileHeaderTop,
              left: LangwijLayout.vocabTileHeaderLeft,
              right: LangwijLayout.vocabTileHeaderRight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Transform.translate(
                    offset: const Offset(0, LangwijLayout.vocabTileIconTopOffset),
                    child: FlesselIconContainer(
                      icon: iconData,
                      iconSize: LangwijLayout.vocabTileIconSize,
                    ),
                  ),
                  const SizedBox(width: LangwijLayout.vocabTileHeaderGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.vocab_termsCount(item.cardCount),
                          textAlign: TextAlign.start,
                          style: FlesselFonts.contentSAccent.copyWith(
                            color: t.textPrimary,
                          ),
                        ),
                        const SizedBox(
                          height: LangwijLayout.vocabTileHeaderRowGap,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: FlesselProgressBar(
                                value: barValue,
                                mode: FlesselProgressBarMode.compact,
                              ),
                            ),
                            const SizedBox(
                              width: LangwijLayout.vocabTileProgressPercentGap,
                            ),
                            SizedBox(
                              width:
                                  LangwijLayout.vocabTileProgressPercentWidth,
                              child: Text(
                                '${item.percentage ?? 0}%',
                                textAlign: TextAlign.start,
                                style: FlesselFonts.contentXsAccent.copyWith(
                                  color: item.percentage != null
                                      ? t.textPrimary
                                      : dimmedTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Title
            Positioned(
              top: LangwijLayout.vocabTileNameTop,
              left: LangwijLayout.vocabTileNameLeft,
              right: LangwijLayout.vocabTileNameRight,
              child: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FlesselFonts.displayM.copyWith(color: t.textPrimary),
              ),
            ),
            // Word list
            Positioned(
              top: LangwijLayout.vocabTileWordsTop,
              left: LangwijLayout.vocabTileWordsLeft,
              right: LangwijLayout.vocabTileWordsRight,
              child: Text(
                item.words.join(', '),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: FlesselFonts.contentCaption.copyWith(
                  color: t.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

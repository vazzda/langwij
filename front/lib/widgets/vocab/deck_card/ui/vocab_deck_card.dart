import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/shared/date_format/date_format.dart';
import 'package:langwij/shared/deck_icons/deck_icons.dart';
import 'package:langwij/shared/app/layout/layout.dart';
import '../model/vocab_deck_card_data.dart';

enum _DeckCardPhase { idle, studying, training }

class LangwijVocabDeckCard extends StatelessWidget {
  const LangwijVocabDeckCard({
    super.key,
    required this.item,
    required this.l10n,
    required this.onTap,
  });

  final VocabDeckCardData item;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final phase = item.percentage == null || item.percentage! <= 0
        ? _DeckCardPhase.idle
        : item.percentage! >= 100
            ? _DeckCardPhase.training
            : _DeckCardPhase.studying;
    final barValue = item.percentage != null ? item.percentage! / 100.0 : 0.0;
    final iconData = item.icon != null
        ? DeckIcons.fromString(item.icon!)
        : DeckIcons.fallback;

    return FlesselCard(
      variant: FlesselCardVariant.transparent,
      margin: FlesselSize.l,
      onTap: item.cardCount > 0 ? onTap : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: FlesselFonts.displayL.copyWith(color: t.fg),
          ),
          const FlesselGap.s(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FlesselIconContainer(
                icon: iconData,
                iconSize: LangwijLayout.vocabTileIconSize,
              ),
              const FlesselGap.s(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${l10n.vocab_termsCount(item.cardCount)}: ',
                            style: FlesselFonts.contentSAccent.copyWith(
                              color: t.fg,
                            ),
                          ),
                          TextSpan(
                            text: item.words.join(', '),
                            style: FlesselFonts.contentCaption.copyWith(
                              color: t.fg,
                            ),
                          ),
                        ],
                      ),
                      maxLines: phase == _DeckCardPhase.idle ? 4 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (phase != _DeckCardPhase.idle) ...[
                      const FlesselGap.s(),
                      Row(
                        children: [
                          SizedBox(
                            width: LangwijLayout.vocabProgressLabelWidth,
                            child: Text(
                              l10n.vocab_studied,
                              style: FlesselFonts.contentXsAccent.copyWith(
                                color: t.fg,
                              ),
                            ),
                          ),
                          const FlesselGap.xxs(),
                          Expanded(
                            child: FlesselProgressBar(
                              value: barValue,
                              mode: FlesselProgressBarMode.compact,
                            ),
                          ),
                          const FlesselGap.xxs(),
                          SizedBox(
                            width: LangwijLayout.vocabTileProgressPercentWidth,
                            child: Text(
                              '${item.percentage ?? 0}%',
                              textAlign: TextAlign.end,
                              style: FlesselFonts.contentXsAccent.copyWith(
                                color: t.fg,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (phase == _DeckCardPhase.training) ...[
                      const FlesselGap.xxs(),
                      Row(
                        children: [
                          SizedBox(
                            width: LangwijLayout.vocabProgressLabelWidth,
                            child: Text(
                              l10n.vocab_trained,
                              style: FlesselFonts.contentXsAccent.copyWith(
                                color: t.fg,
                              ),
                            ),
                          ),
                          const FlesselGap.xxs(),
                          Expanded(
                            child: FlesselProgressBar(
                              value: (item.retention / 100.0).clamp(0.0, 1.0),
                              mode: FlesselProgressBarMode.compact,
                            ),
                          ),
                          const FlesselGap.xxs(),
                          SizedBox(
                            width: LangwijLayout.vocabTileProgressPercentWidth,
                            child: Text(
                              '${item.retention.round()}%',
                              textAlign: TextAlign.end,
                              style: FlesselFonts.contentXsAccent.copyWith(
                                color: t.fg,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (item.progress?.lastRoundDate != null) ...[
                      const FlesselGap.xxs(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            l10n.vocab_lastTrained,
                            style: FlesselFonts.contentXsAccent.copyWith(
                              color: t.fgSecondary,
                            ),
                          ),
                          const FlesselGap.xxs(),
                          Text(
                            RelativeDateFormat.format(
                              item.progress!.lastRoundDate!,
                              l10n,
                            ).toUpperCase(),
                            style: FlesselFonts.contentXsAccent.copyWith(
                              color: t.fg,
                            ),
                          ),
                          const FlesselGap.xxs(),
                          Icon(
                            PhosphorIconsFill.circle,
                            size: FlesselLayout.iconXxxs,
                            color: t.fgSecondary,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/shared/date_format/date_format.dart';
import 'package:langwij/shared/deck_icons/deck_icons.dart';
import 'package:langwij/shared/app/layout/layout.dart';
import '../model/vocab_deck_card_data.dart';

enum _DeckCardPhase { idle, studying, training, trainingLost }

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

    final _DeckCardPhase phase;
    if (item.coverage == null || item.coverage! <= 0) {
      phase = _DeckCardPhase.idle;
    } else if (item.coverage! < 100) {
      phase = _DeckCardPhase.studying;
    } else if (item.mastery >= 1 && item.practice < 50) {
      phase = _DeckCardPhase.trainingLost;
    } else {
      phase = _DeckCardPhase.training;
    }

    final iconVariant = phase == _DeckCardPhase.trainingLost
        ? FlesselVariant.danger
        : FlesselVariant.regular;

    final coverageBar = item.coverage != null ? item.coverage! / 100.0 : 0.0;
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
              Stack(
                clipBehavior: Clip.none,
                children: [
                  FlesselCard(
                    surface: FlesselSurface.s21,
                    colorVariant: iconVariant,
                    padding: FlesselSize.xs,
                    margin: FlesselSize.none,
                    child: Icon(
                      iconData,
                      size: LangwijLayout.vocabTileIconSize,
                      color: t.surface21.resolve(iconVariant).fg,
                    ),
                  ),
                  if (item.mastery > 0)
                    Positioned(
                      bottom: -FlesselLayout.gapS,
                      right: -FlesselLayout.gapXs,
                      child: FlesselTag(
                        label: l10n.vocab_masteryCount(item.mastery),
                        size: FlesselSize.xxs,
                      ),
                    ),
                ],
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
                              value: coverageBar,
                              mode: FlesselProgressBarMode.compact,
                              variant: FlesselProgressBarVariant.accent,
                            ),
                          ),
                          const FlesselGap.xxs(),
                          SizedBox(
                            width: LangwijLayout.vocabTileProgressPercentWidth,
                            child: Text(
                              '${item.coverage ?? 0}%',
                              textAlign: TextAlign.end,
                              style: FlesselFonts.contentXsAccent.copyWith(
                                color: t.fg,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (phase == _DeckCardPhase.training ||
                        phase == _DeckCardPhase.trainingLost) ...[
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
                              value: (item.practice / 100.0).clamp(0.0, 1.0),
                              mode: FlesselProgressBarMode.compact,
                              variant: FlesselProgressBarVariant.accent,
                            ),
                          ),
                          const FlesselGap.xxs(),
                          SizedBox(
                            width: LangwijLayout.vocabTileProgressPercentWidth,
                            child: Text(
                              '${item.practice.round()}%',
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
                      Builder(builder: (context) {
                        final now = DateTime.now();
                        final last = item.progress!.lastRoundDate!;
                        final daysDiff = DateTime(now.year, now.month, now.day)
                            .difference(DateTime(last.year, last.month, last.day))
                            .inDays;
                        final indicatorColor = daysDiff <= 0
                            ? t.surface21.regular.bg.colorValue
                            : daysDiff == 1
                                ? t.surface21.accent.bg.colorValue
                                : t.surface21.danger.bg.colorValue;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              l10n.vocab_lastTrained,
                              style: FlesselFonts.contentXs.copyWith(
                                color: t.fgSecondary,
                              ),
                            ),
                            const FlesselGap.xxs(),
                            Icon(
                              PhosphorIconsFill.circle,
                              size: FlesselLayout.iconXxxs,
                              color: indicatorColor,
                            ),
                            const FlesselGap.xxs(),
                            Text(
                              RelativeDateFormat.format(
                                last,
                                l10n,
                              ).toUpperCase(),
                              style: FlesselFonts.contentXsAccent.copyWith(
                                color: t.fg,
                              ),
                            ),
                          ],
                        );
                      }),
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

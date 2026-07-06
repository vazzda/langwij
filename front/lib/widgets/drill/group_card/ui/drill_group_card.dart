import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/shared/date_format/date_format.dart';
import 'package:langwij/shared/app/layout/layout.dart';
import '../model/drill_group_card_data.dart';

class LangwijDrillGroupCard extends StatelessWidget {
  const LangwijDrillGroupCard({
    super.key,
    required this.item,
    required this.l10n,
    required this.onTap,
  });

  final DrillGroupCardData item;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final hasCoverage = item.coverage != null && item.coverage! > 0;
    final coverageBar = item.coverage != null ? item.coverage! / 100.0 : 0.0;

    return FlesselCard(
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
              // TODO: icon card placeholder — hidden for comparison
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${l10n.wordsCount(item.cardCount)}: ',
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
                      maxLines: hasCoverage ? 2 : 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasCoverage) ...[
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
                    if (item.progress?.lastRoundDate != null) ...[
                      const FlesselGap.xxs(),
                      Builder(builder: (context) {
                        final now = DateTime.now();
                        final last = item.progress!.lastRoundDate!;
                        final daysDiff =
                            DateTime(now.year, now.month, now.day)
                                .difference(
                                    DateTime(last.year, last.month, last.day))
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
                              RelativeDateFormat.format(last, l10n)
                                  .toUpperCase(),
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

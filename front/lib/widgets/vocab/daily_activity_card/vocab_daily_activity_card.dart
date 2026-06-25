import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/entities/activity/activity.dart';
import 'package:langwij/l10n/app_localizations.dart';

class LangwijVocabDailyActivityCard extends StatelessWidget {
  const LangwijVocabDailyActivityCard({
    super.key,
    required this.asyncStats,
    required this.l10n,
  });

  final AsyncValue<DailyActivityStats> asyncStats;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final captionStyle = FlesselFonts.contentCaption.copyWith(
      color: t.fgSecondary,
    );

    return FlesselCard(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.dailyActivityTitle,
              style: FlesselFonts.contentBody.copyWith(color: t.fg),
            ),
            const FlesselGap.xs(),
            asyncStats.when(
              data: (stats) {
                final isEmpty = stats.correct == 0 &&
                    stats.wrong == 0 &&
                    stats.wordsTouched == 0;
                return Text(
                  isEmpty
                      ? l10n.dailyActivityEmpty
                      : '${l10n.correctCount(stats.correct)} · ${l10n.wrongCount(stats.wrong)} · ${l10n.wordsCount(stats.wordsTouched)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: captionStyle,
                );
              },
              loading: () => Text(l10n.dailyActivityEmpty, style: captionStyle),
              error: (_, _) =>
                  Text(l10n.dailyActivityEmpty, style: captionStyle),
            ),
          ],
        ),
      ),
    );
  }
}

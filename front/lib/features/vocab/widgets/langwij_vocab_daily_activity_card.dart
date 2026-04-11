import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flessel/flessel.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/repositories/daily_activity_repository.dart';

/// Langwij composite: daily activity summary card for the vocab list screen.
///
/// Renders a [FlesselCard] containing the daily activity title plus a single
/// summary line derived from [asyncStats]. Empty/loading/error states all
/// fall back to [AppLocalizations.dailyActivityEmpty].
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
      color: t.textSecondary,
    );

    return FlesselCard(
      // Accepted escape hatch: FlesselCard's headerless path does not stretch
      // its child to the parent ListView's max cross-axis extent. Tracked for
      // a future FlesselCard stretch fix.
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.dailyActivityTitle,
              style: FlesselFonts.contentBody.copyWith(color: t.textPrimary),
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

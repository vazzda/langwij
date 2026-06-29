import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/entities/progress/progress.dart';
import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/shared/date_format/date_format.dart';
import '../../deck_card/model/vocab_level_data.dart';

class LangwijVocabLevelStatsRow extends StatelessWidget {
  const LangwijVocabLevelStatsRow({
    super.key,
    required this.item,
    required this.l10n,
  });

  final VocabLevelData item;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final dateText = item.latestDate != null
        ? RelativeDateFormat.format(item.latestDate!, l10n)
        : '-';
    final levelLabel = _retentionLabel(item.strengthLevel, l10n);

    return Row(
      children: [
        FlesselTag(label: dateText),
        const FlesselGap.xs(),
        FlesselTag(label: levelLabel),
        const Spacer(),
        FlesselButton(
          variant: FlesselVariant.accent,
          label: l10n.vocab_train,
          onPressed: null,
          size: FlesselSize.s,
        ),
      ],
    );
  }

  static String _retentionLabel(RetentionLevel level, AppLocalizations l10n) {
    switch (level) {
      case RetentionLevel.none:
        return l10n.retentionNone;
      case RetentionLevel.weak:
        return l10n.retentionWeak;
      case RetentionLevel.good:
        return l10n.retentionGood;
      case RetentionLevel.strong:
        return l10n.retentionStrong;
      case RetentionLevel.super_:
        return l10n.retentionSuper;
    }
  }
}

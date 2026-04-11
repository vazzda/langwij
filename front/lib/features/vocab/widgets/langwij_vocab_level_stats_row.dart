import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';

import '../../../l10n/app_localizations.dart';
import '../../../pages/group_list_screen.dart' show formatRelativeDate;
import '../../../shared/repositories/models/retention_level.dart';
import 'vocab_deck_tile_data.dart';

/// Langwij composite: stats row at the bottom of an expanded
/// [LangwijVocabLevelCard]. Shows last-round date + retention label as plain
/// neutral [FlesselTag]s, plus a disabled "train" call-to-action button.
///
/// Retention color coding is intentionally deferred — the badges render as
/// neutral tags until retention color fields land in [FlesselThemeData].
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
        ? formatRelativeDate(item.latestDate!, l10n)
        : '-';
    final levelLabel = _retentionLabel(item.strengthLevel, l10n);

    return Row(
      children: [
        FlesselTag(label: dateText),
        const FlesselGap.xs(),
        FlesselTag(label: levelLabel),
        const Spacer(),
        FlesselAccentButton(
          label: l10n.vocab_train,
          onPressed: null,
          size: FlesselSize.s,
          margin: EdgeInsets.zero,
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

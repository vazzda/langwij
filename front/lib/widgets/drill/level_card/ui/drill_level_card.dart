import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/l10n/app_localizations.dart';
import '../../group_card/model/drill_group_card_data.dart';
import '../../group_card/model/drill_level_data.dart';
import '../../group_card/ui/drill_group_card.dart';

class LangwijDrillLevelCard extends StatelessWidget {
  const LangwijDrillLevelCard({
    super.key,
    required this.item,
    required this.l10n,
    required this.isExpanded,
    required this.onToggle,
    required this.onGroupTap,
  });

  final DrillLevelData item;
  final AppLocalizations l10n;
  final bool isExpanded;
  final VoidCallback onToggle;
  final void Function(DrillGroupCardData group) onGroupTap;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);

    return FlesselCard(
      variant: FlesselCardVariant.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FlesselCard(
            padding: FlesselSize.s,
            onTap: onToggle,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: FlesselFonts.displayXl.copyWith(color: t.fg),
                  ),
                ),
                Icon(
                  isExpanded
                      ? PhosphorIconsRegular.caretDown
                      : PhosphorIconsRegular.caretRight,
                  size: FlesselLayout.iconS,
                  color: t.fg,
                ),
              ],
            ),
          ),
          if (isExpanded)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: item.groups.map(
                (g) => LangwijDrillGroupCard(
                  item: g,
                  l10n: l10n,
                  onTap: () => onGroupTap(g),
                ),
              ).toList(),
            ),
        ],
      ),
    );
  }
}

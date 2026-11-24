import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/l10n/app_localizations.dart';
import '../../deck_card/model/vocab_deck_card_data.dart';
import '../../deck_card/model/vocab_level_data.dart';
import 'vocab_level_accordion_item.dart';

/// The levels of one vocabulary segment as a single block: one border and
/// one background around all levels, rounded only at the top of the first
/// level and at the bottom of the last one, with a line between levels.
/// At most one level is expanded.
class LangwijVocabLevelAccordion extends StatelessWidget {
  const LangwijVocabLevelAccordion({
    super.key,
    required this.levels,
    required this.unfoldedLevelId,
    required this.l10n,
    required this.onLevelHeaderTap,
    required this.onDeckTap,
    required this.onLevelTrainTap,
  });

  final List<VocabLevelData> levels;
  final String? unfoldedLevelId;
  final AppLocalizations l10n;
  final void Function(VocabLevelData level) onLevelHeaderTap;
  final void Function(VocabDeckCardData deckCard) onDeckTap;
  final void Function(VocabLevelData level) onLevelTrainTap;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final blockColors = t.surface01.regular;
    final blockBorderRadius = BorderRadius.circular(t.cardBorderRadius);
    final contentBorderRadius = BorderRadius.circular(
      (t.cardBorderRadius - t.cardBorderWidth).clamp(0.0, double.infinity),
    );

    return Container(
      margin: EdgeInsets.only(
        bottom: FlesselLayout.cardMargin(FlesselSize.m),
      ),
      decoration: BoxDecoration(
        color: blockColors.bg.color,
        gradient: blockColors.bg.gradient,
        borderRadius: blockBorderRadius,
        border: Border.all(
          color: blockColors.border,
          width: t.cardBorderWidth,
        ),
        boxShadow: t.componentShadow,
      ),
      child: ClipRRect(
        borderRadius: contentBorderRadius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (levelIndex, level) in levels.indexed) ...[
              if (levelIndex > 0)
                _buildLineBetweenLevels(
                  color: blockColors.border,
                  thickness: t.cardBorderWidth,
                ),
              _buildLevelItem(level),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLineBetweenLevels({
    required Color color,
    required double thickness,
  }) {
    return Container(height: thickness, color: color);
  }

  Widget _buildLevelItem(VocabLevelData level) {
    return LangwijVocabLevelAccordionItem(
      item: level,
      l10n: l10n,
      isExpanded: level.level.id == unfoldedLevelId,
      onHeaderTap: () => onLevelHeaderTap(level),
      onDeckTap: onDeckTap,
      onTrainTap: () => onLevelTrainTap(level),
    );
  }
}

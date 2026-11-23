import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/entities/dictionary/dictionary.dart';
import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/shared/app/layout/layout.dart';
import 'package:langwij/shared/keep_in_view/ui/keep_unfolded_in_view.dart';
import '../../deck_card/model/vocab_level_data.dart';
import '../../deck_card/ui/vocab_deck_card.dart';

/// One level of the level accordion: a header with the level name and its
/// progress, the decks of the level while expanded, and the level training
/// button once every deck is fully studied.
class LangwijVocabLevelAccordionItem extends StatelessWidget {
  const LangwijVocabLevelAccordionItem({
    super.key,
    required this.item,
    required this.l10n,
    required this.isExpanded,
    required this.onHeaderTap,
    required this.onDeckTap,
    required this.onTrainTap,
  });

  static const double _fullProgressPercent = 100.0;

  final VocabLevelData item;
  final AppLocalizations l10n;
  final bool isExpanded;
  final VoidCallback onHeaderTap;
  final void Function(VocabDeckModel deck, int cardCount) onDeckTap;
  final VoidCallback onTrainTap;

  @override
  Widget build(BuildContext context) {
    return LangwijKeepUnfoldedInView(
      isUnfolded: isExpanded,
      child: Padding(
        padding: EdgeInsets.all(FlesselLayout.cardPadding(FlesselSize.m)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            if (isExpanded) _buildExpandedContent(context),
            if (item.isEveryDeckFullyStudied) ...[
              const FlesselGap.s(),
              _buildTrainButtonRow(),
            ],
          ],
        ),
      ),
    );
  }

  /// The level's name, its studied share as a bar and the fold caret, on
  /// one line. A tap anywhere on the line folds or unfolds the level.
  Widget _buildHeader(BuildContext context) {
    final t = FlesselThemes.of(context);

    return GestureDetector(
      onTap: onHeaderTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Text(
            item.name,
            style: FlesselFonts.displayXl.copyWith(color: t.fg),
          ),
          const FlesselGap.m(),
          Expanded(
            child: FlesselProgressBar(
              value:
                  (item.levelProgress / _fullProgressPercent).clamp(0.0, 1.0),
              mode: FlesselProgressBarMode.detailed,
              variant: FlesselProgressBarVariant.accent,
            ),
          ),
          const FlesselGap.m(),
          Icon(
            isExpanded
                ? PhosphorIconsRegular.caretDown
                : PhosphorIconsRegular.caretRight,
            size: FlesselLayout.iconS,
            color: t.fgSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
    final t = FlesselThemes.of(context);
    final description = item.description;

    return Padding(
      padding: const EdgeInsets.only(top: FlesselLayout.gapXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (description != null) ...[
            Text(
              description,
              style: FlesselFonts.contentCaption.copyWith(
                color: t.fgSecondary,
              ),
            ),
            const FlesselGap.s(),
          ],
          _buildIndentedDeckList(),
        ],
      ),
    );
  }

  /// The decks sit indented from the left, to read as nested in the level.
  Widget _buildIndentedDeckList() {
    return Padding(
      padding: const EdgeInsets.only(left: LangwijLayout.vocabDeckIndentLeft),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final deckCard in item.decks)
            LangwijVocabDeckCard(
              item: deckCard,
              l10n: l10n,
              onTap: () => onDeckTap(deckCard.deck, deckCard.cardCount),
            ),
        ],
      ),
    );
  }

  Widget _buildTrainButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FlesselButton(
          surface: FlesselSurface.s21,
          label: l10n.vocab_train,
          onPressed: onTrainTap,
          size: FlesselSize.s,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/shared/app/layout/layout.dart';
import 'package:langwij/shared/keep_in_view/ui/keep_unfolded_in_view.dart';
import '../model/vocab_segment_section_data.dart';

/// A vocabulary segment: a header card with the segment name and the studied
/// share of its levels as a percent and, while expanded, the segment's intro
/// in the card and the content of the segment (its levels) under it.
class LangwijVocabSegmentSection extends StatelessWidget {
  const LangwijVocabSegmentSection({
    super.key,
    required this.item,
    required this.isExpanded,
    required this.onHeaderTap,
    required this.expandedContent,
  });

  final VocabSegmentSectionData item;
  final bool isExpanded;
  final VoidCallback onHeaderTap;

  /// Shown under the header while the segment is expanded.
  final Widget expandedContent;

  @override
  Widget build(BuildContext context) {
    return LangwijKeepUnfoldedInView(
      isUnfolded: isExpanded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          if (isExpanded) expandedContent,
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final t = FlesselThemes.of(context);
    final cardPadding = FlesselLayout.cardPadding(FlesselSize.m);

    // The card's own padding is taken off and given here instead, so that
    // the unfolded card can end close under its last row, with only the
    // smallest padding beneath it; the folded card keeps the same padding on
    // all four sides.
    return GestureDetector(
      onTap: onHeaderTap,
      behavior: HitTestBehavior.opaque,
      child: FlesselCard(
        surface: FlesselSurface.s21,
        padding: FlesselSize.none,
        margin: FlesselSize.xs,
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: cardPadding,
            top: cardPadding,
            end: cardPadding,
            bottom: isExpanded
                ? FlesselLayout.cardPadding(FlesselSize.xxs)
                : cardPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: FlesselFonts.displayXl.copyWith(color: t.fg),
                    ),
                  ),
                  Text(
                    '${item.studiedPercent.round()}%',
                    style: FlesselFonts.displayXl.copyWith(color: t.fg),
                  ),
                  const FlesselGap.m(),
                  Icon(
                    isExpanded
                        ? PhosphorIconsRegular.caretDown
                        : PhosphorIconsRegular.caretRight,
                    size: FlesselLayout.iconM,
                    color: t.fgSecondary,
                  ),
                ],
              ),
              if (isExpanded) ...[
                ..._buildIntro(t),
                ..._buildMockOfCountsAndButtons(t),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// The quote icon turned by this many quarter turns, a half turn, serves
  /// as the closing mark; the icon set has no closing one of its own.
  static const int _quarterTurnsOfClosingQuote = 2;

  /// The points of the card's background gradient the two quote icons take
  /// their colours from: where the gradient starts and where it ends.
  static const double _startOfCardGradient = 0.0;
  static const double _endOfCardGradient = 1.0;

  /// How much of a quote icon's colour is seen over the card.
  static const double _quoteIconOpacity = 0.5;

  /// The intro of the segment under a gap: the phrase centred between two
  /// empty boxes, and the two quote icons drawn as decoration under it.
  /// Nothing when the language the learner speaks gives no intro.
  ///
  /// The boxes set the intro's least height and the space beside the
  /// phrase; the icons take no part in the layout. The opening icon hangs
  /// from the intro's top-start corner and the closing one from its
  /// bottom-end corner, each moved outward by its own shift. The opening
  /// icon takes the colour the card's gradient ends with, the closing one
  /// the colour it starts with.
  List<Widget> _buildIntro(FlesselThemeData t) {
    final intro = item.intro;
    if (intro == null) return const [];

    final cardFill = t.surface21.regular.bg;
    const quoteBox = SizedBox(
      width: LangwijLayout.vocabSegmentQuoteBoxWidth,
      height: LangwijLayout.vocabSegmentQuoteBoxHeight,
    );
    return [
      const FlesselGap.m(),
      Stack(
        clipBehavior: Clip.none,
        children: [
          PositionedDirectional(
            start: -LangwijLayout.vocabSegmentOpeningQuoteShiftHorizontal,
            top: -LangwijLayout.vocabSegmentOpeningQuoteShiftVertical,
            child: _buildQuoteIcon(cardFill.colorAt(_endOfCardGradient)),
          ),
          PositionedDirectional(
            end: -LangwijLayout.vocabSegmentClosingQuoteShiftHorizontal,
            bottom: -LangwijLayout.vocabSegmentClosingQuoteShiftVertical,
            child: RotatedBox(
              quarterTurns: _quarterTurnsOfClosingQuote,
              child: _buildQuoteIcon(cardFill.colorAt(_startOfCardGradient)),
            ),
          ),
          Row(
            children: [
              quoteBox,
              Expanded(
                child: Text(
                  intro,
                  textAlign: TextAlign.center,
                  style: FlesselFonts.contentBodyAccentItalic.copyWith(
                    color: t.fg,
                  ),
                ),
              ),
              quoteBox,
            ],
          ),
        ],
      ),
    ];
  }

  /// One quote icon of the intro, in the given colour, half seen through.
  /// Both icons are built here, so that they cannot drift apart in size,
  /// weight or opacity.
  static Widget _buildQuoteIcon(Color color) {
    return Opacity(
      opacity: _quoteIconOpacity,
      child: Icon(
        PhosphorIconsRegular.quotes,
        size: LangwijLayout.vocabSegmentQuoteIconSize,
        color: color,
      ),
    );
  }

  // PLACEHOLDER, look only. The texts below are English samples, the same
  // for every segment and outside the translation files, and the buttons
  // have no action. They serve to judge the layout of the unfolded card and
  // are to be replaced by real content and translated texts.
  static const String _mockTermsCount = 'Terms 312/1000';
  static const String _mockDecksCount = 'Decks 9/34';
  static const String _mockLevelsCount = 'Levels 2/7';
  static const String _mockContinueLabel = 'Continue';
  static const String _mockRefreshLabel = 'Refresh · 4';

  List<Widget> _buildMockOfCountsAndButtons(FlesselThemeData t) {
    final countStyle = FlesselFonts.controlS.copyWith(color: t.fg);

    return [
      const FlesselGap.m(),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FlesselButton(
            label: _mockContinueLabel,
            variant: FlesselVariant.accent,
            size: FlesselSize.s,
            onPressed: () {},
          ),
          const FlesselGap.s(),
          FlesselButton(
            label: _mockRefreshLabel,
            variant: FlesselVariant.accent,
            size: FlesselSize.s,
            onPressed: () {},
          ),
        ],
      ),
      const FlesselGap.s(),
      Row(
        children: [
          Expanded(
            child: Text(
              _mockTermsCount,
              style: countStyle,
              textAlign: TextAlign.start,
            ),
          ),
          Expanded(
            child: Text(
              _mockDecksCount,
              style: countStyle,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              _mockLevelsCount,
              style: countStyle,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    ];
  }
}

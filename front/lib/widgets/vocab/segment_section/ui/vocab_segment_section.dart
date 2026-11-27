import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/shared/keep_in_view/ui/keep_unfolded_in_view.dart';
import '../model/vocab_segment_section_data.dart';

/// A vocabulary segment: a header card with the segment name and the studied
/// share of its levels as a percent and, while expanded, the content of the
/// segment (its levels) under it.
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

    return GestureDetector(
      onTap: onHeaderTap,
      behavior: HitTestBehavior.opaque,
      child: FlesselCard(
        surface: FlesselSurface.s21,
        margin: FlesselSize.xs,
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
            if (isExpanded) ..._buildMockOfUnfoldedContent(t),
          ],
        ),
      ),
    );
  }

  // PLACEHOLDER, look only. The texts below are English samples, the same
  // for every segment and outside the translation files, and the buttons
  // have no action. They serve to judge the layout of the unfolded card and
  // are to be replaced by real content and translated texts.
  static const String _mockSegmentSentence =
      'Placeholder: one sentence on what this segment gives the learner.';
  static const String _mockCounts = 'Terms 312/1000 · Decks 9/34 · Levels 2/7';
  static const String _mockContinueLabel = 'Continue';
  static const String _mockRefreshLabel = 'Refresh · 4';

  List<Widget> _buildMockOfUnfoldedContent(FlesselThemeData t) {
    return [
      const FlesselGap.s(),
      Text(
        _mockSegmentSentence,
        style: FlesselFonts.contentCaption.copyWith(color: t.fgSecondary),
      ),
      const FlesselGap.s(),
      Text(
        _mockCounts,
        style: FlesselFonts.contentBodyAccent.copyWith(color: t.fg),
      ),
      const FlesselGap.s(),
      Row(
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
            size: FlesselSize.s,
            onPressed: () {},
          ),
        ],
      ),
    ];
  }
}

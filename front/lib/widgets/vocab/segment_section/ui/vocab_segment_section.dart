import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/shared/keep_in_view/ui/keep_unfolded_in_view.dart';
import '../model/vocab_segment_section_data.dart';

/// A vocabulary segment: a header with the segment name and, while expanded,
/// the content of the segment (its levels) under it.
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
        variant: FlesselCardVariant.transparent,
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.name,
                style: FlesselFonts.displayXxl.copyWith(color: t.fg),
              ),
            ),
            Icon(
              isExpanded
                  ? PhosphorIconsRegular.caretDown
                  : PhosphorIconsRegular.caretRight,
              size: FlesselLayout.iconS,
              color: t.fgSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

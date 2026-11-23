import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/shared/app/layout/layout.dart';

/// The icon box of a vocabulary deck: the deck's glyph on the surface that
/// controls are drawn on, as buttons are.
class LangwijVocabDeckIcon extends StatelessWidget {
  const LangwijVocabDeckIcon({super.key, required this.icon});

  static const FlesselSize _paddingAroundGlyph = FlesselSize.xxs;

  final IconData icon;

  /// The outer side of the box in the given theme: the glyph, the padding
  /// around it and the border, the same parts the box is drawn with.
  static double outerSideIn(FlesselThemeData t) {
    return LangwijLayout.vocabTileIconSize +
        2 * (FlesselLayout.cardPadding(_paddingAroundGlyph) + t.cardBorderWidth);
  }

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final boxColors = t.surface12.regular;

    return Container(
      padding: EdgeInsets.all(FlesselLayout.cardPadding(_paddingAroundGlyph)),
      decoration: BoxDecoration(
        color: boxColors.bg.color,
        gradient: boxColors.bg.gradient,
        borderRadius: BorderRadius.circular(t.cardBorderRadius),
        border: Border.all(color: boxColors.border, width: t.cardBorderWidth),
        boxShadow: t.componentShadow,
      ),
      child: Icon(
        icon,
        size: LangwijLayout.vocabTileIconSize,
        color: boxColors.fg,
      ),
    );
  }
}

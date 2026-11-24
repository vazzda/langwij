import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';

/// What a star of the practice box stands for.
enum VocabMasteryStarKind {
  /// A finished practice.
  earned,

  /// A practice not finished yet, on the exact scale.
  unearned,

  /// The larger star painted behind a stacked star, in the box's colour;
  /// its edge shows as a rim that keeps the covered star apart.
  rim,

  /// A star standing in a text, outside the practice box, in the text's
  /// colour.
  inText,
}

/// One mastery star. Its size and its colour follow from its kind: a star
/// of the practice box takes the colours of [surface], a star in a text
/// takes the text's colour.
class LangwijVocabMasteryStar extends StatelessWidget {
  const LangwijVocabMasteryStar({super.key, required this.kind});

  /// The surface the practice box is drawn on.
  static const FlesselSurface surface = FlesselSurface.s21;

  /// The side of every star but a rim star.
  static const double side = FlesselLayout.iconXxxs;

  /// The side of a rim star.
  static const double rimSide = FlesselLayout.iconXs;

  /// Where along the box's background the rim colour is taken: its middle,
  /// which is where the stacked stars sit.
  static const double _placeOfRimColorAlongBackground = 0.5;

  final VocabMasteryStarKind kind;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final surfaceColors = t.surfaceOf(surface).regular;

    return Icon(
      PhosphorIconsFill.star,
      size: switch (kind) {
        VocabMasteryStarKind.earned ||
        VocabMasteryStarKind.unearned ||
        VocabMasteryStarKind.inText =>
          side,
        VocabMasteryStarKind.rim => rimSide,
      },
      color: switch (kind) {
        VocabMasteryStarKind.earned => surfaceColors.fg,
        VocabMasteryStarKind.unearned => surfaceColors.fgSecondary,
        VocabMasteryStarKind.rim =>
          surfaceColors.bg.colorAt(_placeOfRimColorAlongBackground),
        VocabMasteryStarKind.inText => t.fg,
      },
    );
  }
}

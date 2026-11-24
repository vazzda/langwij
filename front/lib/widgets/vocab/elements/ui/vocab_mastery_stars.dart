import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';

import '../../deck_card/ui/vocab_deck_icon.dart';
import 'vocab_mastery_star.dart';

/// The two forms of the practice box.
enum VocabMasteryStarsForm {
  /// As wide as a deck icon, whatever it holds. Up to three finished
  /// practices the stars count them exactly: one earned star each, the
  /// rest unearned. Above that the number leads and a stack of earned
  /// stars follows as an ornament that no longer counts anything.
  collapsed,

  /// As wide as its stars: one earned star for every finished practice.
  expanded,
}

/// The practice box: how many times a practice was finished, shown as
/// stars in a small box on the surface of [LangwijVocabMasteryStar].
class LangwijVocabMasteryStars extends StatelessWidget {
  const LangwijVocabMasteryStars({
    super.key,
    required this.finishedPracticeCount,
    required this.form,
  });

  static const int _starCountOfExactScale = 3;
  static const int _starCountOfOrnamentStack = 4;

  /// The share of a star's width by which each star of the ornament stack
  /// covers the star before it.
  static const double _shareOfStarCoveredByNextStar = 0.5;

  static const double _starSide = LangwijVocabMasteryStar.side;
  static const double _starRimOverhang =
      (LangwijVocabMasteryStar.rimSide - _starSide) / 2;

  static const double _distanceBetweenStackedStarStarts =
      _starSide * (1 - _shareOfStarCoveredByNextStar);
  static const double _ornamentStackWidth = _starSide +
      _distanceBetweenStackedStarStarts * (_starCountOfOrnamentStack - 1);

  static const FlesselSize _paddingOfBox = FlesselSize.xxs;

  final int finishedPracticeCount;
  final VocabMasteryStarsForm form;

  @override
  Widget build(BuildContext context) {
    return switch (form) {
      VocabMasteryStarsForm.collapsed => _buildCollapsedBox(context),
      VocabMasteryStarsForm.expanded => _buildExpandedBox(),
    };
  }

  /// The box pads its content above and below only. Its content is centred
  /// across the whole width, so the room at the sides is the content's to
  /// use.
  Widget _buildCollapsedBox(BuildContext context) {
    final t = FlesselThemes.of(context);

    return SizedBox(
      width: LangwijVocabDeckIcon.outerSideIn(t),
      child: FlesselCard(
        surface: LangwijVocabMasteryStar.surface,
        padding: FlesselSize.none,
        margin: FlesselSize.none,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: FlesselLayout.cardPadding(_paddingOfBox),
          ),
          child: finishedPracticeCount > _starCountOfExactScale
              ? _buildCountWithOrnamentStack(t)
              : _buildExactScale(),
        ),
      ),
    );
  }

  /// The box fits its stars and stands at the start of the line; stars
  /// that do not fit the width go on to further lines.
  Widget _buildExpandedBox() {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: FlesselCard(
        surface: LangwijVocabMasteryStar.surface,
        padding: _paddingOfBox,
        margin: FlesselSize.none,
        child: Wrap(
          children: [
            for (var starIndex = 0;
                starIndex < finishedPracticeCount;
                starIndex++)
              const LangwijVocabMasteryStar(kind: VocabMasteryStarKind.earned),
          ],
        ),
      ),
    );
  }

  Widget _buildExactScale() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var starIndex = 0; starIndex < _starCountOfExactScale; starIndex++)
          LangwijVocabMasteryStar(
            kind: starIndex < finishedPracticeCount
                ? VocabMasteryStarKind.earned
                : VocabMasteryStarKind.unearned,
          ),
      ],
    );
  }

  /// The number of finished practices, then the ornament stack.
  Widget _buildCountWithOrnamentStack(FlesselThemeData t) {
    final surfaceColors = t.surfaceOf(LangwijVocabMasteryStar.surface).regular;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$finishedPracticeCount',
          style: FlesselFonts.displayS.copyWith(color: surfaceColors.fg),
        ),
        const FlesselGap.xxs(),
        _buildOrnamentStack(),
      ],
    );
  }

  /// Earned stars laid left to right, each covering a share of the one
  /// before. The first star covers nothing, so it has no rim.
  Widget _buildOrnamentStack() {
    return SizedBox(
      width: _ornamentStackWidth,
      height: _starSide,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var starIndex = 0;
              starIndex < _starCountOfOrnamentStack;
              starIndex++) ...[
            if (starIndex > 0)
              Positioned(
                left: _distanceBetweenStackedStarStarts * starIndex -
                    _starRimOverhang,
                top: -_starRimOverhang,
                child: const LangwijVocabMasteryStar(
                  kind: VocabMasteryStarKind.rim,
                ),
              ),
            Positioned(
              left: _distanceBetweenStackedStarStarts * starIndex,
              top: 0,
              child: const LangwijVocabMasteryStar(
                kind: VocabMasteryStarKind.earned,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

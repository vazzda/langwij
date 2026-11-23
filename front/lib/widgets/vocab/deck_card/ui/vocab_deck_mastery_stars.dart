import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';

/// How many times the practice of a vocabulary deck was finished, shown as
/// stars in a small container of a fixed width. Up to
/// [_starCountOfExactScale] finished practices the stars count them
/// exactly: one earned star each, the rest unearned. Above that the number
/// leads and a stack of earned stars follows as an ornament that no longer
/// counts anything.
class LangwijVocabDeckMasteryStars extends StatelessWidget {
  const LangwijVocabDeckMasteryStars({
    super.key,
    required this.finishedPracticeCount,
    required this.surface,
    required this.width,
  });

  static const int _starCountOfExactScale = 3;
  static const int _starCountOfOrnamentStack = 4;

  /// The share of a star's width by which each star of the ornament stack
  /// covers the star before it.
  static const double _shareOfStarCoveredByNextStar = 0.5;

  static const double _starSize = FlesselLayout.iconXxxs;

  /// A larger star in the container's colour, painted behind a stacked
  /// star; its edge shows as a rim that keeps the covered star apart.
  static const double _starRimSize = FlesselLayout.iconXs;
  static const double _starRimOverhang = (_starRimSize - _starSize) / 2;

  static const double _distanceBetweenStackedStarStarts =
      _starSize * (1 - _shareOfStarCoveredByNextStar);
  static const double _ornamentStackWidth = _starSize +
      _distanceBetweenStackedStarStarts * (_starCountOfOrnamentStack - 1);

  /// Where along the container's background the rim colour is taken: its
  /// middle, which is where the stacked stars sit.
  static const double _placeOfRimColorAlongBackground = 0.5;

  final int finishedPracticeCount;

  /// The surface the stars sit on. Its background fills their container,
  /// its foreground colours an earned star and the number, and its
  /// secondary foreground colours an unearned star.
  final FlesselSurface surface;

  /// The outer width of the container, whatever it holds.
  final double width;

  /// The container pads its content above and below only. Its content is
  /// centred across the whole width, so the room at the sides is the
  /// content's to use.
  @override
  Widget build(BuildContext context) {
    final surfaceColors = FlesselThemes.of(context).surfaceOf(surface).regular;

    return SizedBox(
      width: width,
      child: FlesselCard(
        surface: surface,
        padding: FlesselSize.none,
        margin: FlesselSize.none,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: FlesselLayout.cardPadding(FlesselSize.xxs),
          ),
          child: finishedPracticeCount > _starCountOfExactScale
              ? _buildCountWithOrnamentStack(surfaceColors)
              : _buildExactScale(surfaceColors),
        ),
      ),
    );
  }

  Widget _buildExactScale(FlesselSurfaceColors surfaceColors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var starIndex = 0; starIndex < _starCountOfExactScale; starIndex++)
          _buildStar(
            starIndex < finishedPracticeCount
                ? surfaceColors.fg
                : surfaceColors.fgSecondary,
          ),
      ],
    );
  }

  /// The number of finished practices, then the ornament stack.
  Widget _buildCountWithOrnamentStack(FlesselSurfaceColors surfaceColors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$finishedPracticeCount',
          style: FlesselFonts.displayS.copyWith(color: surfaceColors.fg),
        ),
        const FlesselGap.xxs(),
        _buildOrnamentStack(surfaceColors),
      ],
    );
  }

  /// Earned stars laid left to right, each covering a share of the one
  /// before. The first star covers nothing, so it has no rim.
  Widget _buildOrnamentStack(FlesselSurfaceColors surfaceColors) {
    final rimColor = surfaceColors.bg.colorAt(_placeOfRimColorAlongBackground);

    return SizedBox(
      width: _ornamentStackWidth,
      height: _starSize,
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
                child: Icon(
                  PhosphorIconsFill.star,
                  size: _starRimSize,
                  color: rimColor,
                ),
              ),
            Positioned(
              left: _distanceBetweenStackedStarStarts * starIndex,
              top: 0,
              child: _buildStar(surfaceColors.fg),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStar(Color color) {
    return Icon(PhosphorIconsFill.star, size: _starSize, color: color);
  }
}

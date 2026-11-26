import 'package:country_flags/country_flags.dart';
import 'package:flessel/flessel.dart';
import 'package:flutter/material.dart';

import 'package:langwij/shared/app/layout/layout.dart';

/// The sizes a flag is drawn at.
enum LangwijFlagSize {
  /// In a line of the progression list.
  small(
    width: LangwijLayout.langProgressionFlagWidth,
    height: LangwijLayout.langProgressionFlagHeight,
    cornerRadius: LangwijLayout.langProgressionFlagBorderRadius,
  ),

  /// In a block of the mode sheet.
  medium(
    width: LangwijLayout.modeTileFlagWidth,
    height: LangwijLayout.modeTileFlagHeight,
    cornerRadius: LangwijLayout.modeTileFlagBorderRadius,
  ),

  /// In the card of a chosen language and in a line of the language picker.
  large(
    width: LangwijLayout.langFlagWidth,
    height: LangwijLayout.langFlagHeight,
    cornerRadius: LangwijLayout.langFlagBorderRadius,
  );

  const LangwijFlagSize({
    required this.width,
    required this.height,
    required this.cornerRadius,
  });

  /// The outer width, border included.
  final double width;

  /// The outer height, border included.
  final double height;

  /// The radius of the outer corners.
  final double cornerRadius;
}

/// The flag of a country in a border. The border lies inside the size, so
/// the flag takes exactly the room its [size] names, and its picture fills
/// what the border leaves.
class LangwijFlag extends StatelessWidget {
  const LangwijFlag({
    super.key,
    required this.countryCode,
    required this.size,
  });

  /// The two-letter code of the country whose flag is shown.
  final String countryCode;

  final LangwijFlagSize size;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final borderWidth = t.badgeBorderWidth;
    final cornerRadiusInsideBorder =
        (size.cornerRadius - borderWidth).clamp(0.0, double.infinity);

    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        border: Border.all(color: t.fg, width: borderWidth),
        borderRadius: BorderRadius.circular(size.cornerRadius),
      ),
      child: CountryFlag.fromCountryCode(
        countryCode,
        theme: ImageTheme(
          width: size.width - 2 * borderWidth,
          height: size.height - 2 * borderWidth,
          shape: RoundedRectangle(cornerRadiusInsideBorder),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../app/layout/vessel_layout.dart';
import '../../../app/theme/vessel_themes.dart';

/// Standalone tappable tile for quiz answer options.
///
/// Reads appearance from `roundAnswerTile*` theme properties.
/// Border radius is shared with standard tiles (`tileBorderRadius`).
class VesselAnswerTile extends StatelessWidget {
  const VesselAnswerTile({
    super.key,
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = VesselThemes.of(context);
    final radius = BorderRadius.circular(t.tileBorderRadius);

    return Material(
      color: t.roundAnswerTileBackground,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        borderRadius: radius,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: t.roundAnswerTileBorderColor,
              width: t.roundAnswerTileBorderWidth,
            ),
            borderRadius: radius,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(VesselLayout.gapS),
              child: Text(
                label,
                style: VesselFonts.textRoundAnswer.copyWith(
                  color: t.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../app/theme/app_themes.dart';

/// Tappable themed tile for use inside cards or grids.
///
/// Uses [Ink] + [InkWell] — no Card widget, no outer margin, no inner padding.
/// All sizing and appearance driven by theme tile properties.
/// Content should be fully positioned using [Stack] + [Positioned].
class ProjectTile extends StatelessWidget {
  const ProjectTile({
    super.key,
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppThemes.of(context);
    final radius = BorderRadius.circular(t.tileBorderRadius);

    return Ink(
      decoration: BoxDecoration(
        color: t.tileBackground,
        border: Border.all(
          color: t.tileBorderColor,
          width: t.tileBorderWidth,
        ),
        borderRadius: radius,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: child,
      ),
    );
  }
}

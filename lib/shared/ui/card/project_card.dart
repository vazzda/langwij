import 'package:flutter/material.dart';

import '../../../app/theme/app_themes.dart';

/// Content card using theme card style. No direct colors.
class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final t = AppThemes.of(context);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(t.cardBorderRadius),
      side: BorderSide(color: t.cardBorderColor, width: t.cardBorderWidth),
    );
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
    if (onTap != null) {
      return Card(
        color: t.cardBackground,
        shape: shape,
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(t.cardBorderRadius),
          child: content,
        ),
      );
    }
    return Card(color: t.cardBackground, shape: shape, elevation: 0, child: content);
  }
}

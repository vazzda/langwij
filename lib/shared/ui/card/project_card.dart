import 'package:flutter/material.dart';

import '../../../app/theme/app_themes.dart';

/// Content card using theme card style.
class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.transparent = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final bool transparent;

  @override
  Widget build(BuildContext context) {
    final t = AppThemes.of(context);

    if (transparent) {
      return Padding(
        padding: padding ?? const EdgeInsets.only(bottom: 16),
        child: child,
      );
    }

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(t.cardBorderRadius),
      side: BorderSide(color: t.cardBorderColor, width: t.cardBorderWidth),
    );
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );

    Widget card;
    if (onTap != null) {
      card = Card(
        color: t.cardBackground,
        shape: shape,
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(t.cardBorderRadius),
          child: content,
        ),
      );
    } else {
      card = Card(color: t.cardBackground, shape: shape, elevation: 0, child: content);
    }

    if (t.componentShadow != null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(t.cardBorderRadius),
          boxShadow: t.componentShadow,
        ),
        child: card,
      );
    }

    return card;
  }
}

/// Attention card with danger-tinted background.
class ProjectAttentionCard extends StatelessWidget {
  final Widget child;

  const ProjectAttentionCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final t = AppThemes.of(context);

    return Card(
      color: t.controlDangerBackground.withValues(alpha: 0.15),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

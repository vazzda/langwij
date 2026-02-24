import 'package:flutter/material.dart';
import 'package:srpski_card/app/theme/app_themes.dart';

/// Themed divider control
class ProjectDivider extends StatelessWidget {
  const ProjectDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemes.of(context);
    return Divider(
      height: 1,
      thickness: theme.dividerWidth,
      color: theme.dividerColor,
    );
  }
}

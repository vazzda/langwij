import 'package:flutter/material.dart';
import 'package:srpski_card/app/theme/app_themes.dart';

/// Project-wide header component for section titles
class ProjectHeader extends StatelessWidget {
  final String text;

  const ProjectHeader({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemes.of(context);

    return Text(
      text,
      style: AppFontStyles.textSubtitle.copyWith(color: theme.textPrimary),
    );
  }
}

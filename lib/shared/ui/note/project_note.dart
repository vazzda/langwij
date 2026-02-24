import 'package:flutter/material.dart';
import 'package:srpski_card/app/theme/app_themes.dart';

/// Informational note widget with themed background, border, and text.
class ProjectNote extends StatelessWidget {
  final String text;

  const ProjectNote({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemes.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.noteBackground,
        borderRadius: BorderRadius.circular(theme.noteBorderRadius),
        border: Border.all(
          color: theme.noteBorderColor,
          width: theme.noteBorderWidth,
        ),
      ),
      child: Text(
        text,
        style: AppFontStyles.textNote.copyWith(color: theme.noteTextColor),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:srpski_card/app/theme/app_themes.dart';

/// Themed SnackBar — replaces raw SnackBar throughout the app.
/// Applies snackbar colors, border radius, and font style from the current theme.
class ProjectSnackBar {
  ProjectSnackBar._();

  /// Create a themed [SnackBar] widget.
  static SnackBar of(BuildContext context, String message) {
    final theme = AppThemes.of(context);
    return SnackBar(
      backgroundColor: theme.snackbarBackground,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(theme.snackbarBorderRadius),
      ),
      content: Text(
        message,
        style: AppFontStyles.textSnackbar.copyWith(color: theme.snackbarTextColor),
      ),
    );
  }

  /// Show a themed SnackBar immediately via [ScaffoldMessenger].
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(of(context, message));
  }
}

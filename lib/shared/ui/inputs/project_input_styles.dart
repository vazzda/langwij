import 'package:flutter/material.dart';
import 'package:srpski_card/app/theme/app_themes.dart';

class ProjectInputStyles {
  static OutlineInputBorder _border(BuildContext context) {
    final theme = AppThemes.of(context);
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(theme.controlBorderRadius),
      borderSide: BorderSide(
        color: theme.controlBorder,
        width: theme.controlBorderWidth,
      ),
    );
  }

  static InputDecoration decoration({
    required BuildContext context,
    String? label,
    String? hint,
  }) {
    final theme = AppThemes.of(context);
    final border = _border(context);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: AppFontStyles.textControlInput.copyWith(
        color: theme.controlForeground,
      ),
      hintStyle: AppFontStyles.textControlHint.copyWith(color: theme.textSecondary),
      filled: true,
      fillColor: theme.controlBackground,
      isDense: true,
      enabledBorder: border,
      focusedBorder: border,
      border: border,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  static TextStyle textStyle(BuildContext context) {
    final theme = AppThemes.of(context);
    return AppFontStyles.textControlInput.copyWith(color: theme.controlForeground);
  }
}

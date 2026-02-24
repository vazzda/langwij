import 'package:flutter/material.dart';
import 'package:srpski_card/app/theme/app_themes.dart';

/// Button size variants
enum ButtonSize { small, medium, large }

/// Resolved colors for project buttons based on the current theme.
class ProjectButtonColors {
  final Color background;
  final Color foreground;
  final Color border;
  final Color disabledBackground;
  final Color disabledForeground;
  final Color disabledBorder;

  const ProjectButtonColors({
    required this.background,
    required this.foreground,
    required this.border,
    required this.disabledBackground,
    required this.disabledForeground,
    required this.disabledBorder,
  });
}

class ProjectButtonStyleResolver {
  static const _smallMinHeight = 32.0;
  static const _mediumMinHeight = 44.0;
  static const _largeMinHeight = 56.0;

  static const _smallHPadding = 10.0;
  static const _mediumHPadding = 16.0;
  static const _largeHPadding = 24.0;

  static bool _isTextVariant(ButtonVariant variant) =>
      variant == ButtonVariant.text ||
      variant == ButtonVariant.textAccent ||
      variant == ButtonVariant.textDanger;

  static const _smallIconOnlyPadding = 4.0;
  static const _mediumIconOnlyPadding = 8.0;
  static const _largeIconOnlyPadding = 10.0;

  static double getIconOnlySize(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return 20.0;
      case ButtonSize.medium:
        return 28.0;
      case ButtonSize.large:
        return 32.0;
    }
  }

  static double getIconWithTextSize(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return 18.0;
      case ButtonSize.medium:
        return 24.0;
      case ButtonSize.large:
        return 28.0;
    }
  }

  static ButtonStyle style({
    required BuildContext context,
    required ProjectButtonColors colors,
    required bool iconOnly,
    bool hasIconAndText = false,
    ButtonSize size = ButtonSize.medium,
    bool condensed = false,
    ButtonVariant variant = ButtonVariant.base,
  }) {
    final theme = AppThemes.of(context);

    double minHeight;
    double hPadding;
    double iconOnlyPadding;
    final TextStyle textStyle;
    final double borderWidth;

    switch (size) {
      case ButtonSize.small:
        minHeight = _smallMinHeight;
        hPadding = _smallHPadding;
        iconOnlyPadding = _smallIconOnlyPadding;
        textStyle = AppFontStyles.textButtonSmall;
        borderWidth = theme.buttonBorderWidth;
        break;
      case ButtonSize.medium:
        minHeight = _mediumMinHeight;
        hPadding = _mediumHPadding;
        iconOnlyPadding = _mediumIconOnlyPadding;
        textStyle = AppFontStyles.textButton;
        borderWidth = theme.buttonBorderWidth;
        break;
      case ButtonSize.large:
        minHeight = _largeMinHeight;
        hPadding = _largeHPadding;
        iconOnlyPadding = _largeIconOnlyPadding;
        textStyle = AppFontStyles.textButtonLarge;
        borderWidth = theme.buttonBorderWidth * 2;
        break;
    }

    if (_isTextVariant(variant)) {
      hPadding = _smallHPadding;
    }

    if (condensed) {
      minHeight = (minHeight / 2).ceilToDouble();
      hPadding = (hPadding / 2).ceilToDouble();
      iconOnlyPadding = 0.0;
    }

    final padding = iconOnly
        ? EdgeInsets.all(iconOnlyPadding)
        : hasIconAndText
            ? EdgeInsets.fromLTRB(iconOnlyPadding + 2, iconOnlyPadding, hPadding, iconOnlyPadding)
            : EdgeInsets.symmetric(horizontal: hPadding, vertical: iconOnlyPadding);
    final minSize = iconOnly
        ? Size(minHeight, minHeight)
        : Size(0, minHeight);

    final themeData = AppThemes.of(context);
    final borderRadius = BorderRadius.circular(themeData.buttonBorderRadius);

    return OutlinedButton.styleFrom(
      padding: padding,
      minimumSize: minSize,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: textStyle,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      side: BorderSide(color: colors.border, width: borderWidth),
      foregroundColor: colors.foreground,
      backgroundColor: colors.background,
      disabledForegroundColor: colors.disabledForeground,
      disabledBackgroundColor: colors.disabledBackground,
      disabledMouseCursor: SystemMouseCursors.forbidden,
      splashFactory: NoSplash.splashFactory,
    ).copyWith(
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(color: colors.disabledBorder, width: borderWidth);
        }
        return BorderSide(color: colors.border, width: borderWidth);
      }),
    );
  }

  static ProjectButtonColors resolveColors(
    BuildContext context, {
    required AppTheme theme,
    required ButtonVariant variant,
  }) {
    final themeData = AppThemes.getThemeData(theme);

    switch (variant) {
      case ButtonVariant.base:
        return ProjectButtonColors(
          background: themeData.controlBackground,
          foreground: themeData.controlForeground,
          border: themeData.controlBorder,
          disabledBackground: themeData.controlBackground.withValues(alpha: 0.6),
          disabledForeground: themeData.controlForeground.withValues(alpha: 0.6),
          disabledBorder: themeData.controlBorder.withValues(alpha: 0.6),
        );
      case ButtonVariant.accent:
        return ProjectButtonColors(
          background: themeData.controlAccentBackground,
          foreground: themeData.controlAccentForeground,
          border: themeData.controlAccentBackground,
          disabledBackground: themeData.controlAccentBackground.withValues(alpha: 0.6),
          disabledForeground: themeData.controlAccentForeground.withValues(alpha: 0.6),
          disabledBorder: themeData.controlAccentBackground.withValues(alpha: 0.6),
        );
      case ButtonVariant.danger:
        return ProjectButtonColors(
          background: themeData.controlDangerBackground,
          foreground: themeData.controlDangerForeground,
          border: themeData.controlDangerBackground,
          disabledBackground: themeData.controlDangerBackground.withValues(alpha: 0.6),
          disabledForeground: themeData.controlDangerForeground.withValues(alpha: 0.6),
          disabledBorder: themeData.controlDangerBackground.withValues(alpha: 0.6),
        );
      case ButtonVariant.text:
        return ProjectButtonColors(
          background: Colors.transparent,
          foreground: themeData.textPrimary,
          border: Colors.transparent,
          disabledBackground: Colors.transparent,
          disabledForeground: themeData.textSecondary.withValues(alpha: 0.6),
          disabledBorder: Colors.transparent,
        );
      case ButtonVariant.textAccent:
        return ProjectButtonColors(
          background: Colors.transparent,
          foreground: themeData.controlAccentBackground,
          border: Colors.transparent,
          disabledBackground: Colors.transparent,
          disabledForeground: themeData.controlAccentBackground.withValues(alpha: 0.4),
          disabledBorder: Colors.transparent,
        );
      case ButtonVariant.textDanger:
        return ProjectButtonColors(
          background: Colors.transparent,
          foreground: themeData.controlDangerBackground,
          border: Colors.transparent,
          disabledBackground: Colors.transparent,
          disabledForeground: themeData.controlDangerBackground.withValues(alpha: 0.4),
          disabledBorder: Colors.transparent,
        );
    }
  }
}

enum ButtonVariant { base, accent, danger, text, textAccent, textDanger }

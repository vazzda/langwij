import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'themes/candidate01_theme.dart';
import 'themes/candidate02_theme.dart';
import 'themes/candidate05_theme.dart';
import 'themes/candidate07_theme.dart';
import 'themes/candidate08_theme.dart';
import 'app_font_styles.dart';

export 'themes/candidate01_theme.dart';
export 'themes/candidate02_theme.dart';
export 'themes/candidate05_theme.dart';
export 'themes/candidate07_theme.dart';
export 'themes/candidate08_theme.dart';
export 'app_font_styles.dart';

// ============================================================================
// SECTION 1: THEME IDENTIFIERS
// ============================================================================

enum AppTheme {
  candidate05,
  candidate07,
  candidate08,
  candidate01,
  candidate02,
}

// ============================================================================
// SECTION 2: AppThemeData - Structure Definition
// ============================================================================

class AppThemeData {
  final AppTheme themeType;

  // Scaffold
  final Color scaffoldBackground;

  // AppBar
  final Color appBarBackground;
  final Color appBarBorderColor;
  final double appBarBorderWidth;
  final Color appBarForeground;
  final Color appBarTitleColor;

  // Navbar
  final Color navbarBackground;
  final Color navbarBorderColor;
  final double navbarBorderWidth;
  final Color navbarIconColor;
  final Color navbarDisabledIconColor;

  // Text
  final Color textPrimary;
  final Color textSecondary;

  // Accent
  final Color accentColor;
  final Color accentColorText;

  // Danger / Error
  final Color dangerColor;
  final Color dangerColorText;

  // Card
  final Color cardBackground;
  final Color cardBorderColor;
  final double cardBorderRadius;
  final double cardBorderWidth;

  // Control
  final Color controlAccentBackground;
  final Color controlAccentForeground;
  final Color controlBackground;
  final Color controlBorder;
  final double controlBorderRadius;
  final double controlBorderWidth;
  final Color controlForeground;

  // Button
  final double buttonBorderRadius;
  final double buttonBorderWidth;

  // Bottom Sheet
  final Color bottomSheetBackground;
  final Color bottomSheetBorderColor;
  final double bottomSheetBorderRadius;
  final double bottomSheetBorderWidth;
  final Color bottomSheetScrimColor;
  final double bottomSheetPadding;

  // Divider
  final Color dividerColor;
  final double dividerWidth;

  // Test badge
  final Color testBadgeBackground;
  final Color testBadgePercentage;
  final Color testBadgeDateRecent;
  final Color testBadgeDateStale;
  final Color testBadgeDateOld;

  // Choice chip
  final Color chipSelectedBackground;
  final Color chipSelectedForeground;

  // Retention badge
  final Color retentionNone;
  final Color retentionWeak;
  final Color retentionGood;
  final Color retentionStrong;
  final Color retentionSuper;
  final Color retentionText;

  // Disabled
  final double disabledOpacity;

  const AppThemeData({
    required this.themeType,
    required this.scaffoldBackground,
    required this.appBarBackground,
    required this.appBarBorderColor,
    required this.appBarBorderWidth,
    required this.appBarForeground,
    required this.appBarTitleColor,
    required this.navbarBackground,
    required this.navbarBorderColor,
    required this.navbarBorderWidth,
    required this.navbarIconColor,
    required this.navbarDisabledIconColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
    required this.accentColorText,
    required this.dangerColor,
    required this.dangerColorText,
    required this.cardBackground,
    required this.cardBorderColor,
    required this.cardBorderRadius,
    required this.cardBorderWidth,
    required this.controlAccentBackground,
    required this.controlAccentForeground,
    required this.controlBackground,
    required this.controlBorder,
    required this.controlBorderRadius,
    required this.controlBorderWidth,
    required this.controlForeground,
    required this.buttonBorderRadius,
    required this.buttonBorderWidth,
    required this.bottomSheetBackground,
    required this.bottomSheetBorderColor,
    required this.bottomSheetBorderRadius,
    required this.bottomSheetBorderWidth,
    required this.bottomSheetScrimColor,
    required this.bottomSheetPadding,
    required this.dividerColor,
    required this.dividerWidth,
    required this.testBadgeBackground,
    required this.testBadgePercentage,
    required this.testBadgeDateRecent,
    required this.testBadgeDateStale,
    required this.testBadgeDateOld,
    required this.chipSelectedBackground,
    required this.chipSelectedForeground,
    required this.retentionNone,
    required this.retentionWeak,
    required this.retentionGood,
    required this.retentionStrong,
    required this.retentionSuper,
    required this.retentionText,
    required this.disabledOpacity,
  });
}

// ============================================================================
// SECTION 3: AppTheme Extension - Helper Methods
// ============================================================================

extension AppThemeExtension on AppTheme {
  String getDisplayName() {
    switch (this) {
      case AppTheme.candidate05:
        return 'Clean';
      case AppTheme.candidate07:
        return 'Warm';
      case AppTheme.candidate08:
        return 'Dark';
      case AppTheme.candidate01:
        return 'Newspaper';
      case AppTheme.candidate02:
        return 'Ocean';
    }
  }

  static AppTheme fromString(String value) {
    switch (value) {
      case 'candidate05':
        return AppTheme.candidate05;
      case 'candidate07':
        return AppTheme.candidate07;
      case 'candidate08':
        return AppTheme.candidate08;
      case 'candidate01':
        return AppTheme.candidate01;
      case 'candidate02':
        return AppTheme.candidate02;
      default:
        return AppTheme.candidate05;
    }
  }
}

// ============================================================================
// SECTION 4: Flutter Theme Integration
// ============================================================================

class NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  const NoAnimationPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class AppThemeDataExtension extends ThemeExtension<AppThemeDataExtension> {
  final AppThemeData data;

  const AppThemeDataExtension(this.data);

  @override
  ThemeExtension<AppThemeDataExtension> copyWith({AppThemeData? data}) {
    return AppThemeDataExtension(data ?? this.data);
  }

  @override
  ThemeExtension<AppThemeDataExtension> lerp(
    covariant ThemeExtension<AppThemeDataExtension>? other,
    double t,
  ) {
    if (other is! AppThemeDataExtension) return this;
    return t < 0.5 ? this : other;
  }
}

// ============================================================================
// SECTION 5: AppThemes - Main Access Point
// ============================================================================

class AppThemes {
  AppThemes._();

  static AppThemeData getThemeData(AppTheme theme) {
    switch (theme) {
      case AppTheme.candidate05:
        return candidate05Theme;
      case AppTheme.candidate07:
        return candidate07Theme;
      case AppTheme.candidate08:
        return candidate08Theme;
      case AppTheme.candidate01:
        return candidate01Theme;
      case AppTheme.candidate02:
        return candidate02Theme;
    }
  }

  static ThemeData getFlutterThemeData(AppTheme theme) {
    final data = getThemeData(theme);
    final textTheme = _getTextTheme(data.textPrimary);

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: data.scaffoldBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: data.accentColor,
        primary: data.accentColor,
        onPrimary: data.accentColorText,
        surface: data.cardBackground,
        onSurface: data.textPrimary,
        error: data.dangerColor,
        onError: data.dangerColorText,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: data.appBarBackground,
        foregroundColor: data.appBarForeground,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppFontStyles.textTitle.copyWith(
          color: data.appBarTitleColor,
        ),
      ),
      iconTheme: IconThemeData(color: data.textPrimary),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: NoAnimationPageTransitionsBuilder(),
          TargetPlatform.iOS: NoAnimationPageTransitionsBuilder(),
          TargetPlatform.linux: NoAnimationPageTransitionsBuilder(),
          TargetPlatform.macOS: NoAnimationPageTransitionsBuilder(),
          TargetPlatform.windows: NoAnimationPageTransitionsBuilder(),
          TargetPlatform.fuchsia: NoAnimationPageTransitionsBuilder(),
        },
      ),
      extensions: <ThemeExtension<dynamic>>[AppThemeDataExtension(data)],
    );
  }

  static TextTheme _getTextTheme(Color color) {
    return TextTheme(
      headlineMedium: GoogleFonts.bigShouldersDisplay(fontSize: 24, fontWeight: FontWeight.w600, color: color),
      titleLarge: GoogleFonts.bigShouldersDisplay(fontSize: 20, fontWeight: FontWeight.w600, color: color),
      titleMedium: GoogleFonts.robotoMono(fontSize: 16, fontWeight: FontWeight.w500, color: color),
      bodyLarge: GoogleFonts.robotoMono(fontSize: 16, color: color),
      bodyMedium: GoogleFonts.robotoMono(fontSize: 14, color: color),
      bodySmall: GoogleFonts.robotoMono(fontSize: 12, color: color),
      labelLarge: GoogleFonts.robotoMono(fontSize: 14, fontWeight: FontWeight.w500, color: color),
    );
  }

  static AppThemeData of(BuildContext context) {
    return Theme.of(context).extension<AppThemeDataExtension>()!.data;
  }
}

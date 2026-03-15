import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import 'themes/theme01_theme.dart';
import 'themes/theme02_theme.dart';
import 'themes/theme03_theme.dart';
import 'themes/theme04_theme.dart';
import 'themes/theme05_theme.dart';
import 'vessel_fonts.dart';

export 'themes/theme01_theme.dart';
export 'themes/theme02_theme.dart';
export 'themes/theme03_theme.dart';
export 'themes/theme04_theme.dart';
export 'themes/theme05_theme.dart';
export 'vessel_fonts.dart';

// ============================================================================
// SECTION 1: THEME IDENTIFIERS
// ============================================================================

enum AppTheme {
  theme01,
  theme02,
  theme03,
  theme04,
  theme05,
}

// ============================================================================
// SECTION 2: VesselThemeData - Structure Definition
// ============================================================================

class VesselThemeData {
  // ==========================================================================
  // THEME IDENTIFIER
  // ==========================================================================
  final AppTheme themeType;

  // ==========================================================================
  // ACCENT
  // ==========================================================================
  final Color accentColor;
  final Color accentColorText;
  final Color dangerColor;
  final Color dangerColorText;

  // ==========================================================================
  // APPBAR
  // ==========================================================================
  final Color appBarBackground;
  final Color appBarBorderColor;
  final double appBarBorderWidth;
  final Color appBarForeground;
  final Color appBarIconColor;
  final Color appBarTitleColor;

  // ==========================================================================
  // BADGE
  // ==========================================================================
  final double badgeBorderRadius;
  final double badgeBorderWidth;

  // ==========================================================================
  // BOTTOM SHEET
  // ==========================================================================
  final Color bottomSheetBackground;
  final Color bottomSheetBorderColor;
  final double bottomSheetBorderRadius;
  final double bottomSheetBorderWidth;
  final double bottomSheetBlurSigma;
  final double bottomSheetPadding;
  final Color bottomSheetScrimColor;

  // ==========================================================================
  // BUTTON
  // ==========================================================================
  final double buttonBorderRadius;
  final double buttonBorderWidth;

  // ==========================================================================
  // CARD
  // ==========================================================================
  final Color cardBackground;
  final Color cardBorderColor;
  final double cardBorderRadius;
  final double cardBorderWidth;

  // ==========================================================================
  // TILE
  // ==========================================================================
  final Color tileBackground;
  final Color tileForeground;
  final Color tileBorderColor;
  final double tileBorderWidth;
  final double tileBorderRadius;

  // ==========================================================================
  // ROUND ANSWER TILE
  // ==========================================================================
  final Color roundAnswerTileBackground;
  final Color roundAnswerTileBorderColor;
  final double roundAnswerTileBorderWidth;
  final Color roundAnswerTileCorrectColor;
  final Color roundAnswerTileWrongColor;

  // ==========================================================================
  // DECK ICON
  // ==========================================================================
  final Color deckIconColor;
  final Color deckIconBackground;
  final double deckIconBorderRadius;

  // ==========================================================================
  // DASH
  // ==========================================================================
  final Color dashCardBackground;
  final Color dashCardBorderColor;
  final double dashCardBorderRadius;
  final double dashCardBorderWidth;

  // ==========================================================================
  // CONTROL
  // ==========================================================================
  final Color controlAccentBackground;
  final Color controlAccentForeground;
  final Color controlBackground;
  final Color controlBorder;
  final double controlBorderRadius;
  final double controlBorderWidth;
  final Color controlDangerBackground;
  final Color controlDangerForeground;
  final Color controlForeground;

  // ==========================================================================
  // DISPLAY
  // ==========================================================================
  final Color displayBackground;
  final double displayBorderRadius;

  // ==========================================================================
  // DIVIDER
  // ==========================================================================
  final double dividerWidth;
  final Color dividerColor;

  // ==========================================================================
  // FAB
  // ==========================================================================
  final Color fabBackground;
  final Color fabBorderColor;
  final double fabBorderWidth;
  final Color fabTextColor;

  // ==========================================================================
  // CONFIRM FAB
  // ==========================================================================
  final Color confirmFabBackground;
  final Color confirmFabBorderColor;
  final Color confirmFabForeground;

  // ==========================================================================
  // LIST ITEM
  // ==========================================================================
  final Color listItemBorderColor;
  final double listItemBorderRadius;
  final double listItemBorderWidth;

  // ==========================================================================
  // MODAL
  // ==========================================================================
  final double modalBorderRadius;

  // ==========================================================================
  // NAVBAR
  // ==========================================================================
  final Color navbarBackground;
  final Color navbarBorderColor;
  final double navbarBorderWidth;
  final Color navbarDisabledIconColor;
  final Color navbarIconColor;

  // ==========================================================================
  // NOTE
  // ==========================================================================
  final Color noteBackground;
  final Color noteBorderColor;
  final double noteBorderRadius;
  final double noteBorderWidth;
  final Color noteTextColor;

  // ==========================================================================
  // SCAFFOLD
  // ==========================================================================
  final Color scaffoldBackground;

  // ==========================================================================
  // SNACKBAR
  // ==========================================================================
  final Color snackbarBackground;
  final Color snackbarTextColor;
  final double snackbarBorderRadius;

  // ==========================================================================
  // TAG
  // ==========================================================================
  final Color tag1Bg;
  final Color tag1BorderColor;
  final Color tag1TextColor;
  final Color tag2Bg;
  final Color tag2BorderColor;
  final Color tag2TextColor;
  final Color tag3Bg;
  final Color tag3BorderColor;
  final Color tag3TextColor;
  final Color tag4Bg;
  final Color tag4BorderColor;
  final Color tag4TextColor;
  final Color tag5Bg;
  final Color tag5BorderColor;
  final Color tag5TextColor;
  final double tagBorderRadius;
  final double tagBorderWidth;
  final Color tagChipBorder;
  final Color tagColor1;
  final Color tagColor2;
  final Color tagColor3;
  final Color tagColor4;
  final Color tagColor5;
  final Color tagNoneBg;
  final Color tagNoneBorderColor;
  final Color tagNoneTextColor;

  // ==========================================================================
  // TEXT
  // ==========================================================================
  final Color textPrimary;
  final Color textSecondary;

  // ==========================================================================
  // TEST BADGE (srpski-specific)
  // ==========================================================================
  final Color testBadgeBackground;
  final Color testBadgePercentage;
  final Color testBadgeDateRecent;
  final Color testBadgeDateStale;
  final Color testBadgeDateOld;

  // ==========================================================================
  // RETENTION (srpski-specific)
  // ==========================================================================
  final Color retentionNone;
  final Color retentionWeak;
  final Color retentionGood;
  final Color retentionStrong;
  final Color retentionSuper;
  final Color retentionText;

  // ==========================================================================
  // SHADOW
  // ==========================================================================
  final List<BoxShadow>? componentShadow;
  final List<BoxShadow>? appBarShadow;
  final List<BoxShadow>? navbarShadow;

  // ==========================================================================
  // PROGRESS BAR
  // ==========================================================================
  final Color progressBarFilled;
  final Color progressBarUnfilled;
  final double progressBarBorderRadius;
  final double progressBarCompactHeight;
  final double progressBarDetailedHeight;

  // ==========================================================================
  // TOGGLE
  // ==========================================================================
  final double toggleBorderRadius;

  // ==========================================================================
  // DISABLED
  // ==========================================================================
  final double disabledOpacity;

  // ==========================================================================
  // NOTE ACCENT
  // ==========================================================================
  final Color noteAccentBackground;
  final Color noteAccentBorderColor;
  final Color noteAccentTextColor;

  // ==========================================================================
  // MODE TILE (quiz mode selection bottom sheet)
  // ==========================================================================
  final Color modeTileBackground;
  final Color modeTileForeground;
  final Color modeTileBorderColor;
  final Color modeTileAccentBackground;
  final Color modeTileAccentForeground;
  final Color modeTileAccentBorderColor;

  const VesselThemeData({
    required this.themeType,
    // Accent
    required this.accentColor,
    required this.accentColorText,
    required this.dangerColor,
    required this.dangerColorText,
    // AppBar
    required this.appBarBackground,
    required this.appBarBorderColor,
    required this.appBarBorderWidth,
    required this.appBarForeground,
    required this.appBarIconColor,
    required this.appBarTitleColor,
    // Badge
    required this.badgeBorderRadius,
    required this.badgeBorderWidth,
    // BottomSheet
    required this.bottomSheetBackground,
    required this.bottomSheetBorderColor,
    required this.bottomSheetBorderRadius,
    required this.bottomSheetBorderWidth,
    required this.bottomSheetBlurSigma,
    required this.bottomSheetPadding,
    required this.bottomSheetScrimColor,
    // Button
    required this.buttonBorderRadius,
    required this.buttonBorderWidth,
    // Card
    required this.cardBackground,
    required this.cardBorderColor,
    required this.cardBorderRadius,
    required this.cardBorderWidth,
    // Tile
    required this.tileBackground,
    required this.tileForeground,
    required this.tileBorderColor,
    required this.tileBorderWidth,
    required this.tileBorderRadius,
    // Round answer tile
    required this.roundAnswerTileBackground,
    required this.roundAnswerTileBorderColor,
    required this.roundAnswerTileBorderWidth,
    required this.roundAnswerTileCorrectColor,
    required this.roundAnswerTileWrongColor,
    // Deck icon
    required this.deckIconColor,
    required this.deckIconBackground,
    required this.deckIconBorderRadius,
    // Dash
    required this.dashCardBackground,
    required this.dashCardBorderColor,
    required this.dashCardBorderRadius,
    required this.dashCardBorderWidth,
    // Control
    required this.controlAccentBackground,
    required this.controlAccentForeground,
    required this.controlBackground,
    required this.controlBorder,
    required this.controlBorderRadius,
    required this.controlBorderWidth,
    required this.controlDangerBackground,
    required this.controlDangerForeground,
    required this.controlForeground,
    // Display
    required this.displayBackground,
    required this.displayBorderRadius,
    // Divider
    required this.dividerWidth,
    required this.dividerColor,
    // Progress bar
    required this.progressBarFilled,
    required this.progressBarUnfilled,
    required this.progressBarBorderRadius,
    required this.progressBarCompactHeight,
    required this.progressBarDetailedHeight,
    // Fab
    required this.fabBackground,
    required this.fabBorderColor,
    required this.fabBorderWidth,
    required this.fabTextColor,
    // Confirm Fab
    required this.confirmFabBackground,
    required this.confirmFabBorderColor,
    required this.confirmFabForeground,
    // ListItem
    required this.listItemBorderColor,
    required this.listItemBorderRadius,
    required this.listItemBorderWidth,
    // Modal
    required this.modalBorderRadius,
    // Navbar
    required this.navbarBackground,
    required this.navbarBorderColor,
    required this.navbarBorderWidth,
    required this.navbarDisabledIconColor,
    required this.navbarIconColor,
    // Note
    required this.noteBackground,
    required this.noteBorderColor,
    required this.noteBorderRadius,
    required this.noteBorderWidth,
    required this.noteTextColor,
    // Scaffold
    required this.scaffoldBackground,
    // Snackbar
    required this.snackbarBackground,
    required this.snackbarTextColor,
    required this.snackbarBorderRadius,
    // Tag
    required this.tag1Bg,
    required this.tag1BorderColor,
    required this.tag1TextColor,
    required this.tag2Bg,
    required this.tag2BorderColor,
    required this.tag2TextColor,
    required this.tag3Bg,
    required this.tag3BorderColor,
    required this.tag3TextColor,
    required this.tag4Bg,
    required this.tag4BorderColor,
    required this.tag4TextColor,
    required this.tag5Bg,
    required this.tag5BorderColor,
    required this.tag5TextColor,
    required this.tagBorderRadius,
    required this.tagBorderWidth,
    required this.tagChipBorder,
    required this.tagColor1,
    required this.tagColor2,
    required this.tagColor3,
    required this.tagColor4,
    required this.tagColor5,
    required this.tagNoneBg,
    required this.tagNoneBorderColor,
    required this.tagNoneTextColor,
    // Text
    required this.textPrimary,
    required this.textSecondary,
    // Test badge
    required this.testBadgeBackground,
    required this.testBadgePercentage,
    required this.testBadgeDateRecent,
    required this.testBadgeDateStale,
    required this.testBadgeDateOld,
    // Retention
    required this.retentionNone,
    required this.retentionWeak,
    required this.retentionGood,
    required this.retentionStrong,
    required this.retentionSuper,
    required this.retentionText,
    // Shadow
    required this.componentShadow,
    required this.appBarShadow,
    required this.navbarShadow,
    // Toggle
    required this.toggleBorderRadius,
    // Disabled
    required this.disabledOpacity,
    // Note accent
    required this.noteAccentBackground,
    required this.noteAccentBorderColor,
    required this.noteAccentTextColor,
    // Mode tile
    required this.modeTileBackground,
    required this.modeTileForeground,
    required this.modeTileBorderColor,
    required this.modeTileAccentBackground,
    required this.modeTileAccentForeground,
    required this.modeTileAccentBorderColor,
  });

  // Computed — derived from existing fields, no constructor param needed
  Color get textPrimaryDimmed => textPrimary.withValues(alpha: disabledOpacity);
  Color get textSecondaryDimmed =>
      textSecondary.withValues(alpha: disabledOpacity);
}

// ============================================================================
// SECTION 3: AppTheme Extension - Helper Methods
// ============================================================================

extension AppThemeExtension on AppTheme {
  String getDisplayName(AppLocalizations l10n) {
    switch (this) {
      case AppTheme.theme01:
        return l10n.theme_01;
      case AppTheme.theme02:
        return l10n.theme_02;
      case AppTheme.theme03:
        return l10n.theme_03;
      case AppTheme.theme04:
        return l10n.theme_04;
      case AppTheme.theme05:
        return l10n.theme_05;
    }
  }

  static AppTheme fromString(String value) {
    switch (value) {
      case 'theme01':
        return AppTheme.theme01;
      case 'theme02':
        return AppTheme.theme02;
      case 'theme03':
        return AppTheme.theme03;
      case 'theme04':
        return AppTheme.theme04;
      case 'theme05':
        return AppTheme.theme05;
      default:
        return AppTheme.theme01;
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

class VesselThemeDataExtension extends ThemeExtension<VesselThemeDataExtension> {
  final VesselThemeData data;

  const VesselThemeDataExtension(this.data);

  @override
  ThemeExtension<VesselThemeDataExtension> copyWith({VesselThemeData? data}) {
    return VesselThemeDataExtension(data ?? this.data);
  }

  @override
  ThemeExtension<VesselThemeDataExtension> lerp(
    covariant ThemeExtension<VesselThemeDataExtension>? other,
    double t,
  ) {
    if (other is! VesselThemeDataExtension) return this;
    return t < 0.5 ? this : other;
  }
}

// ============================================================================
// SECTION 5: VesselThemes - Main Access Point
// ============================================================================

class VesselThemes {
  VesselThemes._();

  static VesselThemeData getThemeData(AppTheme theme) {
    switch (theme) {
      case AppTheme.theme01:
        return theme01Theme;
      case AppTheme.theme02:
        return theme02Theme;
      case AppTheme.theme03:
        return theme03Theme;
      case AppTheme.theme04:
        return theme04Theme;
      case AppTheme.theme05:
        return theme05Theme;
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
        titleTextStyle: VesselFonts.textAppBarTitle.copyWith(
          color: data.appBarTitleColor,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          systemNavigationBarColor: data.navbarBackground,
          systemNavigationBarIconBrightness:
              data.navbarBackground.computeLuminance() > 0.5
                  ? Brightness.dark
                  : Brightness.light,
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
      extensions: <ThemeExtension<dynamic>>[VesselThemeDataExtension(data)],
    );
  }

  static TextTheme _getTextTheme(Color color) {
    return TextTheme(
      headlineMedium: TextStyle(
        fontFamily: VesselFonts.headerFontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleLarge: TextStyle(
        fontFamily: VesselFonts.headerFontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleMedium: GoogleFonts.robotoMono(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      bodyLarge: GoogleFonts.robotoMono(fontSize: 16, color: color),
      bodyMedium: GoogleFonts.robotoMono(fontSize: 14, color: color),
      bodySmall: GoogleFonts.robotoMono(fontSize: 12, color: color),
      labelLarge: GoogleFonts.robotoMono(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    );
  }

  static VesselThemeData of(BuildContext context) {
    return Theme.of(context).extension<VesselThemeDataExtension>()!.data;
  }
}

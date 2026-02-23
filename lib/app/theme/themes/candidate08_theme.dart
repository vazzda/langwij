import 'package:flutter/material.dart';
import '../app_themes.dart';

// ==========================================================================
// RAW PALETTE
// ==========================================================================
class Candidate08Palette {
  Candidate08Palette._();

  static const Color porcleain = Color(0xFFFCFBF7);
  static const Color oldlace = Color(0xFFEBE9E6);
  static const Color dustyGrape = Color(0xFF5A5F87);
  static const Color twilightIndigo = Color(0xFF3D405B);
  static const Color spaceIndigo = Color(0xFF292B3D);
  static const Color deepWalnut = Color(0xFFFFFFFF);
  static const Color deepWalnutA40 = Color(0x40FFFFFF);
  static const Color deepWalnutA80 = Color(0x80FFFFFF);
  static const Color deepWalnutA12 = Color(0x10FFFFFF);
  static const Color burntPeach = Color(0xFFE07A5F);
  static const Color black = Color(0xFF101118);
  static const Color greyLight = Color(0xFF9E9E9E);
}

const AppThemeData candidate08Theme = AppThemeData(
  themeType: AppTheme.candidate08,
  // Scaffold
  scaffoldBackground: Candidate08Palette.twilightIndigo,
  // AppBar
  appBarBackground: Candidate08Palette.spaceIndigo,
  appBarBorderColor: Candidate08Palette.black,
  appBarBorderWidth: 2.0,
  appBarForeground: Candidate08Palette.deepWalnut,
  appBarTitleColor: Candidate08Palette.deepWalnut,
  // Navbar
  navbarBackground: Candidate08Palette.spaceIndigo,
  navbarBorderColor: Candidate08Palette.black,
  navbarBorderWidth: 2.0,
  navbarIconColor: Candidate08Palette.deepWalnut,
  navbarDisabledIconColor: Candidate08Palette.deepWalnutA40,
  // Text
  textPrimary: Candidate08Palette.deepWalnut,
  textSecondary: Candidate08Palette.deepWalnutA80,
  // Accent
  accentColor: Candidate08Palette.deepWalnut,
  accentColorText: Candidate08Palette.oldlace,
  // Danger
  dangerColor: Candidate08Palette.burntPeach,
  dangerColorText: Candidate08Palette.oldlace,
  // Card
  cardBackground: Candidate08Palette.dustyGrape,
  cardBorderColor: Candidate08Palette.dustyGrape,
  cardBorderRadius: 8.0,
  cardBorderWidth: 2.0,
  // Control
  controlAccentBackground: Candidate08Palette.deepWalnut,
  controlAccentForeground: Candidate08Palette.spaceIndigo,
  controlBackground: Candidate08Palette.spaceIndigo,
  controlBorder: Candidate08Palette.spaceIndigo,
  controlBorderRadius: 8.0,
  controlBorderWidth: 2.0,
  controlForeground: Candidate08Palette.deepWalnut,
  // Button
  buttonBorderRadius: 8.0,
  buttonBorderWidth: 2.0,
  // Bottom Sheet
  bottomSheetBackground: Candidate08Palette.spaceIndigo,
  bottomSheetBorderColor: Candidate08Palette.dustyGrape,
  bottomSheetBorderRadius: 12.0,
  bottomSheetBorderWidth: 2.0,
  bottomSheetScrimColor: Candidate08Palette.deepWalnutA40,
  bottomSheetPadding: 16.0,
  // Divider
  dividerColor: Candidate08Palette.deepWalnutA40,
  dividerWidth: 1.0,
  // Test badge
  testBadgeBackground: Candidate08Palette.deepWalnut,
  testBadgePercentage: Candidate08Palette.spaceIndigo,
  testBadgeDateRecent: Candidate08Palette.greyLight,
  testBadgeDateStale: Candidate08Palette.spaceIndigo,
  testBadgeDateOld: Candidate08Palette.burntPeach,
  // Choice chip
  chipSelectedBackground: Candidate08Palette.deepWalnutA12,
  chipSelectedForeground: Candidate08Palette.deepWalnut,
  // Retention
  retentionNone: Color(0xFF78909C),
  retentionWeak: Color(0xFFFFCC80),
  retentionGood: Color(0xFFA5D6A7),
  retentionStrong: Color(0xFF81C784),
  retentionSuper: Color(0xFF66BB6A),
  retentionText: Candidate08Palette.spaceIndigo,
  // Disabled
  disabledOpacity: 0.4,
);

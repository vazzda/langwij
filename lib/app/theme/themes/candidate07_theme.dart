import 'package:flutter/material.dart';
import '../app_themes.dart';

// ==========================================================================
// RAW PALETTE
// ==========================================================================
class Candidate07Palette {
  Candidate07Palette._();

  static const Color porcleain = Color(0xFFFCFBF7);
  static const Color oldlace = Color(0xFFEBE9E6);
  static const Color deepWalnut = Color(0xFF3D405D);
  static const Color deepWalnutA40 = Color(0x403D405D);
  static const Color deepWalnutA80 = Color(0x803D405D);
  static const Color deepWalnutA12 = Color(0x103D405D);
  static const Color lightCoral = Color(0xFFE07A5F);
  static const Color greyLight = Color(0xFF9E9E9E);
}

const AppThemeData candidate07Theme = AppThemeData(
  themeType: AppTheme.candidate07,
  // Scaffold
  scaffoldBackground: Candidate07Palette.porcleain,
  // AppBar
  appBarBackground: Candidate07Palette.porcleain,
  appBarBorderColor: Candidate07Palette.deepWalnut,
  appBarBorderWidth: 2.0,
  appBarForeground: Candidate07Palette.deepWalnut,
  appBarTitleColor: Candidate07Palette.deepWalnut,
  // Navbar
  navbarBackground: Candidate07Palette.porcleain,
  navbarBorderColor: Candidate07Palette.deepWalnut,
  navbarBorderWidth: 2.0,
  navbarIconColor: Candidate07Palette.deepWalnut,
  navbarDisabledIconColor: Candidate07Palette.deepWalnutA40,
  // Text
  textPrimary: Candidate07Palette.deepWalnut,
  textSecondary: Candidate07Palette.deepWalnutA80,
  // Accent
  accentColor: Candidate07Palette.deepWalnut,
  accentColorText: Candidate07Palette.oldlace,
  // Danger
  dangerColor: Candidate07Palette.lightCoral,
  dangerColorText: Candidate07Palette.oldlace,
  // Card
  cardBackground: Candidate07Palette.oldlace,
  cardBorderColor: Candidate07Palette.oldlace,
  cardBorderRadius: 8.0,
  cardBorderWidth: 2.0,
  // Control
  controlAccentBackground: Candidate07Palette.deepWalnut,
  controlAccentForeground: Candidate07Palette.oldlace,
  controlBackground: Candidate07Palette.oldlace,
  controlBorder: Candidate07Palette.oldlace,
  controlBorderRadius: 8.0,
  controlBorderWidth: 2.0,
  controlForeground: Candidate07Palette.deepWalnut,
  // Button
  buttonBorderRadius: 8.0,
  buttonBorderWidth: 2.0,
  // Bottom Sheet
  bottomSheetBackground: Candidate07Palette.porcleain,
  bottomSheetBorderColor: Candidate07Palette.deepWalnut,
  bottomSheetBorderRadius: 12.0,
  bottomSheetBorderWidth: 2.0,
  bottomSheetScrimColor: Candidate07Palette.deepWalnutA40,
  bottomSheetPadding: 16.0,
  // Divider
  dividerColor: Candidate07Palette.deepWalnutA40,
  dividerWidth: 1.0,
  // Test badge
  testBadgeBackground: Candidate07Palette.deepWalnut,
  testBadgePercentage: Candidate07Palette.oldlace,
  testBadgeDateRecent: Candidate07Palette.greyLight,
  testBadgeDateStale: Candidate07Palette.oldlace,
  testBadgeDateOld: Candidate07Palette.lightCoral,
  // Choice chip
  chipSelectedBackground: Candidate07Palette.deepWalnutA12,
  chipSelectedForeground: Candidate07Palette.deepWalnut,
  // Retention
  retentionNone: Color(0xFFBDBDBD),
  retentionWeak: Color(0xFFFFCC80),
  retentionGood: Color(0xFFA5D6A7),
  retentionStrong: Color(0xFF81C784),
  retentionSuper: Color(0xFF66BB6A),
  retentionText: Candidate07Palette.porcleain,
  // Disabled
  disabledOpacity: 0.4,
);

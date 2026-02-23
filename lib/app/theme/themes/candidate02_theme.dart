import 'package:flutter/material.dart';
import '../app_themes.dart';

// ==========================================================================
// RAW PALETTE
// ==========================================================================
class Candidate02Palette {
  Candidate02Palette._();

  static const Color mintCream = Color(0xFFF1FAEE);
  static const Color darkNavy = Color(0xFF0F1C2E);
  static const Color crimsonRed = Color(0xFFE63946);
  static const Color powderTeal = Color(0xFFa8dadc);
  static const Color darkNavyA67 = Color(0xAA0F1C2E);
  static const Color darkNavyA40 = Color(0x660F1C2E);
  static const Color darkNavyA12 = Color(0x200F1C2E);
  static const Color greyLight = Color(0xFF9E9E9E);
}

const AppThemeData candidate02Theme = AppThemeData(
  themeType: AppTheme.candidate02,
  // Scaffold
  scaffoldBackground: Candidate02Palette.powderTeal,
  // AppBar
  appBarBackground: Candidate02Palette.mintCream,
  appBarBorderColor: Candidate02Palette.darkNavy,
  appBarBorderWidth: 2.0,
  appBarForeground: Candidate02Palette.darkNavy,
  appBarTitleColor: Candidate02Palette.darkNavy,
  // Navbar
  navbarBackground: Candidate02Palette.mintCream,
  navbarBorderColor: Candidate02Palette.darkNavy,
  navbarBorderWidth: 2.0,
  navbarIconColor: Candidate02Palette.darkNavy,
  navbarDisabledIconColor: Candidate02Palette.darkNavyA40,
  // Text
  textPrimary: Candidate02Palette.darkNavy,
  textSecondary: Candidate02Palette.darkNavyA67,
  // Accent
  accentColor: Candidate02Palette.darkNavy,
  accentColorText: Candidate02Palette.mintCream,
  // Danger
  dangerColor: Candidate02Palette.crimsonRed,
  dangerColorText: Candidate02Palette.mintCream,
  // Card
  cardBackground: Candidate02Palette.mintCream,
  cardBorderColor: Candidate02Palette.darkNavy,
  cardBorderRadius: 8.0,
  cardBorderWidth: 2.0,
  // Control
  controlAccentBackground: Candidate02Palette.darkNavy,
  controlAccentForeground: Candidate02Palette.mintCream,
  controlBackground: Candidate02Palette.mintCream,
  controlBorder: Candidate02Palette.darkNavy,
  controlBorderRadius: 8.0,
  controlBorderWidth: 2.0,
  controlForeground: Candidate02Palette.darkNavy,
  // Button
  buttonBorderRadius: 8.0,
  buttonBorderWidth: 2.0,
  // Bottom Sheet
  bottomSheetBackground: Candidate02Palette.mintCream,
  bottomSheetBorderColor: Candidate02Palette.darkNavy,
  bottomSheetBorderRadius: 12.0,
  bottomSheetBorderWidth: 2.0,
  bottomSheetScrimColor: Candidate02Palette.darkNavyA40,
  bottomSheetPadding: 16.0,
  // Divider
  dividerColor: Candidate02Palette.darkNavyA12,
  dividerWidth: 1.0,
  // Test badge
  testBadgeBackground: Candidate02Palette.darkNavy,
  testBadgePercentage: Candidate02Palette.mintCream,
  testBadgeDateRecent: Candidate02Palette.greyLight,
  testBadgeDateStale: Candidate02Palette.mintCream,
  testBadgeDateOld: Candidate02Palette.crimsonRed,
  // Choice chip
  chipSelectedBackground: Candidate02Palette.darkNavyA12,
  chipSelectedForeground: Candidate02Palette.darkNavy,
  // Retention
  retentionNone: Color(0xFFBDBDBD),
  retentionWeak: Color(0xFFFFCC80),
  retentionGood: Color(0xFFA5D6A7),
  retentionStrong: Color(0xFF81C784),
  retentionSuper: Color(0xFF66BB6A),
  retentionText: Candidate02Palette.mintCream,
  // Disabled
  disabledOpacity: 0.4,
);

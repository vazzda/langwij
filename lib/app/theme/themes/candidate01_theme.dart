import 'package:flutter/material.dart';
import '../app_themes.dart';

// ==========================================================================
// RAW PALETTE
// ==========================================================================
class Candidate01Palette {
  Candidate01Palette._();

  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color platinum = Color(0xFFF4F5F6);
  static const Color pureBlack = Color(0xFF000000);
  static const Color pureBlackA67 = Color(0xAA000000);
  static const Color pureBlackA50 = Color(0x80000000);
  static const Color pureBlackA40 = Color(0x66000000);
  static const Color pureBlackA12 = Color(0x20000000);
  static const Color gunMetal = Color(0xFF373D43);
  static const Color crimsonRed = Color(0xFFE63946);
  static const Color greyLight = Color(0xFF9E9E9E);
}

const AppThemeData candidate01Theme = AppThemeData(
  themeType: AppTheme.candidate01,
  // Scaffold
  scaffoldBackground: Candidate01Palette.platinum,
  // AppBar
  appBarBackground: Candidate01Palette.platinum,
  appBarBorderColor: Candidate01Palette.gunMetal,
  appBarBorderWidth: 2.0,
  appBarForeground: Candidate01Palette.gunMetal,
  appBarTitleColor: Candidate01Palette.gunMetal,
  // Navbar
  navbarBackground: Candidate01Palette.pureWhite,
  navbarBorderColor: Candidate01Palette.gunMetal,
  navbarBorderWidth: 2.0,
  navbarIconColor: Candidate01Palette.gunMetal,
  navbarDisabledIconColor: Candidate01Palette.pureBlackA40,
  // Text
  textPrimary: Candidate01Palette.gunMetal,
  textSecondary: Candidate01Palette.pureBlackA67,
  // Accent
  accentColor: Candidate01Palette.gunMetal,
  accentColorText: Candidate01Palette.platinum,
  // Danger
  dangerColor: Candidate01Palette.crimsonRed,
  dangerColorText: Candidate01Palette.platinum,
  // Card
  cardBackground: Candidate01Palette.pureWhite,
  cardBorderColor: Candidate01Palette.gunMetal,
  cardBorderRadius: 4.0,
  cardBorderWidth: 2.0,
  // Control
  controlAccentBackground: Candidate01Palette.gunMetal,
  controlAccentForeground: Candidate01Palette.platinum,
  controlBackground: Candidate01Palette.pureWhite,
  controlBorder: Candidate01Palette.gunMetal,
  controlBorderRadius: 4.0,
  controlBorderWidth: 2.0,
  controlForeground: Candidate01Palette.gunMetal,
  // Button
  buttonBorderRadius: 4.0,
  buttonBorderWidth: 2.0,
  // Bottom Sheet
  bottomSheetBackground: Candidate01Palette.platinum,
  bottomSheetBorderColor: Candidate01Palette.gunMetal,
  bottomSheetBorderRadius: 12.0,
  bottomSheetBorderWidth: 2.0,
  bottomSheetScrimColor: Candidate01Palette.pureBlackA50,
  bottomSheetPadding: 16.0,
  // Divider
  dividerColor: Candidate01Palette.pureBlackA12,
  dividerWidth: 1.0,
  // Test badge
  testBadgeBackground: Candidate01Palette.gunMetal,
  testBadgePercentage: Candidate01Palette.platinum,
  testBadgeDateRecent: Candidate01Palette.greyLight,
  testBadgeDateStale: Candidate01Palette.platinum,
  testBadgeDateOld: Candidate01Palette.crimsonRed,
  // Choice chip
  chipSelectedBackground: Candidate01Palette.pureBlackA12,
  chipSelectedForeground: Candidate01Palette.gunMetal,
  // Retention
  retentionNone: Color(0xFFBDBDBD),
  retentionWeak: Color(0xFFFFCC80),
  retentionGood: Color(0xFFA5D6A7),
  retentionStrong: Color(0xFF81C784),
  retentionSuper: Color(0xFF66BB6A),
  retentionText: Candidate01Palette.pureWhite,
  // Disabled
  disabledOpacity: 0.4,
);

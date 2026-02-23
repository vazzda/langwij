import 'package:flutter/material.dart';
import '../app_themes.dart';

// ==========================================================================
// RAW PALETTE
// ==========================================================================
class Candidate05Palette {
  Candidate05Palette._();

  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color platinum = Color(0xFFE9EbEd);
  static const Color pureBlack = Color(0xFF000000);
  static const Color pureBlackA67 = Color(0xAA000000);
  static const Color pureBlackA50 = Color(0x80000000);
  static const Color pureBlackA40 = Color(0x66000000);
  static const Color pureBlackA12 = Color(0x20000000);
  static const Color gunMetal = Color(0xFF373D43);
  static const Color crimsonRed = Color(0xFFE63946);
  static const Color greyLight = Color(0xFF9E9E9E);
}

const AppThemeData candidate05Theme = AppThemeData(
  themeType: AppTheme.candidate05,
  // Scaffold
  scaffoldBackground: Candidate05Palette.pureWhite,
  // AppBar
  appBarBackground: Candidate05Palette.pureWhite,
  appBarBorderColor: Candidate05Palette.gunMetal,
  appBarBorderWidth: 2.0,
  appBarForeground: Candidate05Palette.gunMetal,
  appBarTitleColor: Candidate05Palette.gunMetal,
  // Navbar
  navbarBackground: Candidate05Palette.pureWhite,
  navbarBorderColor: Candidate05Palette.gunMetal,
  navbarBorderWidth: 2.0,
  navbarIconColor: Candidate05Palette.gunMetal,
  navbarDisabledIconColor: Candidate05Palette.pureBlackA40,
  // Text
  textPrimary: Candidate05Palette.gunMetal,
  textSecondary: Candidate05Palette.pureBlackA67,
  // Accent
  accentColor: Candidate05Palette.gunMetal,
  accentColorText: Candidate05Palette.platinum,
  // Danger
  dangerColor: Candidate05Palette.crimsonRed,
  dangerColorText: Candidate05Palette.platinum,
  // Card
  cardBackground: Candidate05Palette.platinum,
  cardBorderColor: Candidate05Palette.platinum,
  cardBorderRadius: 8.0,
  cardBorderWidth: 2.0,
  // Control
  controlAccentBackground: Candidate05Palette.gunMetal,
  controlAccentForeground: Candidate05Palette.platinum,
  controlBackground: Candidate05Palette.platinum,
  controlBorder: Candidate05Palette.platinum,
  controlBorderRadius: 8.0,
  controlBorderWidth: 2.0,
  controlForeground: Candidate05Palette.gunMetal,
  // Button
  buttonBorderRadius: 8.0,
  buttonBorderWidth: 2.0,
  // Bottom Sheet
  bottomSheetBackground: Candidate05Palette.pureWhite,
  bottomSheetBorderColor: Candidate05Palette.platinum,
  bottomSheetBorderRadius: 12.0,
  bottomSheetBorderWidth: 2.0,
  bottomSheetScrimColor: Candidate05Palette.pureBlackA50,
  bottomSheetPadding: 16.0,
  // Divider
  dividerColor: Candidate05Palette.pureBlackA12,
  dividerWidth: 1.0,
  // Test badge
  testBadgeBackground: Candidate05Palette.gunMetal,
  testBadgePercentage: Candidate05Palette.platinum,
  testBadgeDateRecent: Candidate05Palette.greyLight,
  testBadgeDateStale: Candidate05Palette.platinum,
  testBadgeDateOld: Candidate05Palette.crimsonRed,
  // Choice chip
  chipSelectedBackground: Candidate05Palette.pureBlackA12,
  chipSelectedForeground: Candidate05Palette.gunMetal,
  // Retention
  retentionNone: Color(0xFFBDBDBD),
  retentionWeak: Color(0xFFFFCC80),
  retentionGood: Color(0xFFA5D6A7),
  retentionStrong: Color(0xFF81C784),
  retentionSuper: Color(0xFF66BB6A),
  retentionText: Candidate05Palette.pureWhite,
  // Disabled
  disabledOpacity: 0.4,
);

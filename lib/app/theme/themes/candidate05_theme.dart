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
  static const Color pureBlackA06 = Color(0x10000000);

  static const Color gunMetal = Color(0xFF373D43);

  static const Color crimsonRed = Color(0xFFE63946);
  static const Color crimsonRedA53 = Color(0x88E63946);

  static const Color greyLight = Color(0xFF9E9E9E);

  static const Color coralRed = Color(0xFFff595e);
  static const Color goldenYellow = Color(0xFFffca3a);
  static const Color limeGreen = Color(0xFF8ac926);
  static const Color ceruleanBlue = Color(0xFF1982c4);
  static const Color deepPurple = Color(0xFF6a4c93);
}

// ==========================================================================
// FUNCTIONAL PALETTE
// ==========================================================================
class Candidate05Colors {
  Candidate05Colors._();

  static const Color danger = Candidate05Palette.crimsonRed;
  static const Color tag1 = Candidate05Palette.coralRed;
  static const Color tag2 = Candidate05Palette.goldenYellow;
  static const Color tag3 = Candidate05Palette.limeGreen;
  static const Color tag4 = Candidate05Palette.ceruleanBlue;
  static const Color tag5 = Candidate05Palette.deepPurple;
}

const AppThemeData candidate05Theme = AppThemeData(
  themeType: AppTheme.candidate05,
  // Scaffold
  scaffoldBackground: Candidate05Palette.pureWhite,
  // Display
  displayBackground: Candidate05Palette.pureWhite,
  displayBorderRadius: 12.0,
  // AppBar
  appBarBackground: Candidate05Palette.pureWhite,
  appBarForeground: Candidate05Palette.gunMetal,
  appBarBorderColor: Candidate05Palette.gunMetal,
  appBarBorderWidth: 2,
  appBarIconColor: Candidate05Palette.gunMetal,
  appBarTitleColor: Candidate05Palette.gunMetal,
  // Navbar
  navbarBackground: Candidate05Palette.pureWhite,
  navbarBorderColor: Candidate05Palette.gunMetal,
  navbarBorderWidth: 2.0,
  navbarIconColor: Candidate05Palette.gunMetal,
  navbarDisabledIconColor: Candidate05Palette.pureBlackA40,
  // Fab
  fabBackground: Candidate05Palette.pureWhite,
  fabBorderColor: Candidate05Palette.gunMetal,
  fabTextColor: Candidate05Palette.gunMetal,
  fabBorderWidth: 2,
  confirmFabBackground: Candidate05Palette.gunMetal,
  confirmFabForeground: Candidate05Palette.platinum,
  confirmFabBorderColor: Candidate05Palette.gunMetal,
  // Text
  textPrimary: Candidate05Palette.gunMetal,
  textSecondary: Candidate05Palette.pureBlackA67,
  // Accent
  accentColor: Candidate05Palette.gunMetal,
  accentColorText: Candidate05Palette.platinum,
  // Danger
  dangerColor: Candidate05Colors.danger,
  dangerColorText: Candidate05Palette.platinum,
  // BottomSheet
  bottomSheetBackground: Candidate05Palette.pureWhite,
  bottomSheetBorderColor: Candidate05Palette.platinum,
  bottomSheetScrimColor: Candidate05Palette.pureBlackA50,
  bottomSheetBorderRadius: 12.0,
  bottomSheetBorderWidth: 2.0,
  bottomSheetBlurSigma: 0.0,
  bottomSheetPadding: 16.0,
  // Modal
  modalBorderRadius: 8.0,
  // Control
  controlAccentBackground: Candidate05Palette.gunMetal,
  controlAccentForeground: Candidate05Palette.platinum,
  controlBackground: Candidate05Palette.platinum,
  controlBorder: Candidate05Palette.platinum,
  controlDangerBackground: Candidate05Colors.danger,
  controlDangerForeground: Candidate05Palette.platinum,
  controlForeground: Candidate05Palette.gunMetal,
  controlBorderRadius: 8.0,
  controlBorderWidth: 2.0,
  // Toggle
  toggleBorderRadius: 4.0,
  disabledOpacity: 0.4,
  // Divider
  dividerColor: Candidate05Palette.pureBlackA12,
  dividerWidth: 1.0,
  // Button
  buttonBorderRadius: 8.0,
  buttonBorderWidth: 2.0,
  // Note
  noteBackground: Candidate05Palette.platinum,
  noteBorderColor: Candidate05Palette.platinum,
  noteBorderRadius: 8.0,
  noteBorderWidth: 1.0,
  noteTextColor: Candidate05Palette.pureBlackA67,
  // Card
  cardBackground: Candidate05Palette.platinum,
  cardBorderColor: Candidate05Palette.platinum,
  cardBorderRadius: 8.0,
  cardBorderWidth: 2.0,
  // Dash
  dashCardBackground: Candidate05Palette.platinum,
  dashCardBorderColor: Candidate05Palette.platinum,
  dashCardBorderRadius: 8.0,
  dashCardBorderWidth: 2.0,
  // ListItem
  listItemBorderColor: Candidate05Palette.gunMetal,
  listItemBorderRadius: 8.0,
  listItemBorderWidth: 2.0,
  // Badge
  badgeBorderRadius: 4.0,
  badgeBorderWidth: 1.5,
  // Tag
  tag1Bg: Candidate05Palette.pureWhite,
  tag1BorderColor: Candidate05Colors.tag1,
  tag1TextColor: Candidate05Palette.pureBlack,
  tag2Bg: Candidate05Palette.pureWhite,
  tag2BorderColor: Candidate05Colors.tag2,
  tag2TextColor: Candidate05Palette.pureBlack,
  tag3Bg: Candidate05Palette.pureWhite,
  tag3BorderColor: Candidate05Colors.tag3,
  tag3TextColor: Candidate05Palette.pureBlack,
  tag4Bg: Candidate05Palette.pureWhite,
  tag4BorderColor: Candidate05Colors.tag4,
  tag4TextColor: Candidate05Palette.pureBlack,
  tag5Bg: Candidate05Palette.pureWhite,
  tag5BorderColor: Candidate05Colors.tag5,
  tag5TextColor: Candidate05Palette.pureWhite,
  tagBorderRadius: 4.0,
  tagBorderWidth: 1.0,
  tagChipBorder: Candidate05Palette.pureBlack,
  tagColor1: Candidate05Colors.tag1,
  tagColor2: Candidate05Colors.tag2,
  tagColor3: Candidate05Colors.tag3,
  tagColor4: Candidate05Colors.tag4,
  tagColor5: Candidate05Colors.tag5,
  tagNoneBg: Colors.transparent,
  tagNoneBorderColor: Candidate05Palette.pureBlack,
  tagNoneTextColor: Candidate05Palette.pureBlack,
  // Test badge
  testBadgeBackground: Candidate05Palette.gunMetal,
  testBadgePercentage: Candidate05Palette.platinum,
  testBadgeDateRecent: Candidate05Palette.greyLight,
  testBadgeDateStale: Candidate05Palette.platinum,
  testBadgeDateOld: Candidate05Palette.crimsonRed,
  // Retention
  retentionNone: Color(0xFFBDBDBD),
  retentionWeak: Color(0xFFFFCC80),
  retentionGood: Color(0xFFA5D6A7),
  retentionStrong: Color(0xFF81C784),
  retentionSuper: Color(0xFF66BB6A),
  retentionText: Candidate05Palette.pureWhite,
  // Shadow
  componentShadow: null,
  appBarShadow: null,
  navbarShadow: null,
  // Snackbar
  snackbarBackground: Candidate05Palette.pureBlack,
  snackbarTextColor: Candidate05Palette.pureWhite,
  snackbarBorderRadius: 8.0,
);

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
class Candidate01Colors {
  Candidate01Colors._();

  static const Color danger = Candidate01Palette.crimsonRed;
  static const Color tag1 = Candidate01Palette.coralRed;
  static const Color tag2 = Candidate01Palette.goldenYellow;
  static const Color tag3 = Candidate01Palette.limeGreen;
  static const Color tag4 = Candidate01Palette.ceruleanBlue;
  static const Color tag5 = Candidate01Palette.deepPurple;
}

const AppThemeData candidate01Theme = AppThemeData(
  themeType: AppTheme.candidate01,
  // Scaffold
  scaffoldBackground: Candidate01Palette.platinum,
  // Display
  displayBackground: Candidate01Palette.platinum,
  displayBorderRadius: 12.0,
  // AppBar
  appBarBackground: Candidate01Palette.platinum,
  appBarForeground: Candidate01Palette.gunMetal,
  appBarBorderColor: Candidate01Palette.gunMetal,
  appBarBorderWidth: 2,
  appBarIconColor: Candidate01Palette.gunMetal,
  appBarTitleColor: Candidate01Palette.gunMetal,
  // Navbar
  navbarBackground: Candidate01Palette.pureWhite,
  navbarBorderColor: Candidate01Palette.gunMetal,
  navbarBorderWidth: 2.0,
  navbarIconColor: Candidate01Palette.gunMetal,
  navbarDisabledIconColor: Candidate01Palette.pureBlackA40,
  // Fab
  fabBackground: Candidate01Palette.pureWhite,
  fabBorderColor: Candidate01Palette.gunMetal,
  fabTextColor: Candidate01Palette.gunMetal,
  fabBorderWidth: 2,
  confirmFabBackground: Candidate01Palette.gunMetal,
  confirmFabForeground: Candidate01Palette.platinum,
  confirmFabBorderColor: Candidate01Palette.gunMetal,
  // Text
  textPrimary: Candidate01Palette.gunMetal,
  textSecondary: Candidate01Palette.pureBlackA67,
  // Accent
  accentColor: Candidate01Palette.gunMetal,
  accentColorText: Candidate01Palette.platinum,
  // Danger
  dangerColor: Candidate01Colors.danger,
  dangerColorText: Candidate01Palette.platinum,
  // BottomSheet
  bottomSheetBackground: Candidate01Palette.platinum,
  bottomSheetBorderColor: Candidate01Palette.gunMetal,
  bottomSheetScrimColor: Candidate01Palette.pureBlackA50,
  bottomSheetBorderRadius: 12.0,
  bottomSheetBorderWidth: 2.0,
  bottomSheetBlurSigma: 0.0,
  bottomSheetPadding: 16.0,
  // Modal
  modalBorderRadius: 4.0,
  // Control
  controlAccentBackground: Candidate01Palette.gunMetal,
  controlAccentForeground: Candidate01Palette.platinum,
  controlBackground: Candidate01Palette.pureWhite,
  controlBorder: Candidate01Palette.gunMetal,
  controlDangerBackground: Candidate01Colors.danger,
  controlDangerForeground: Candidate01Palette.platinum,
  controlForeground: Candidate01Palette.gunMetal,
  controlBorderRadius: 4.0,
  controlBorderWidth: 2.0,
  // Toggle
  toggleBorderRadius: 4.0,
  disabledOpacity: 0.4,
  // Divider
  dividerColor: Candidate01Palette.pureBlackA12,
  dividerWidth: 1.0,
  // Button
  buttonBorderRadius: 4.0,
  buttonBorderWidth: 2.0,
  // Note
  noteBackground: Candidate01Palette.pureBlackA06,
  noteBorderColor: Candidate01Palette.pureBlackA40,
  noteBorderRadius: 4.0,
  noteBorderWidth: 1.0,
  noteTextColor: Candidate01Palette.pureBlackA67,
  // Card
  cardBackground: Candidate01Palette.pureWhite,
  cardBorderColor: Candidate01Palette.gunMetal,
  cardBorderRadius: 4.0,
  cardBorderWidth: 2.0,
  // Dash
  dashCardBackground: Candidate01Palette.pureWhite,
  dashCardBorderColor: Candidate01Palette.gunMetal,
  dashCardBorderRadius: 4.0,
  dashCardBorderWidth: 2.0,
  // Choice chip
  chipSelectedBackground: Candidate01Palette.pureBlackA12,
  chipSelectedForeground: Candidate01Palette.gunMetal,
  // ListItem
  listItemBorderColor: Candidate01Palette.gunMetal,
  listItemBorderRadius: 4.0,
  listItemBorderWidth: 2.0,
  // Badge
  badgeBorderRadius: 2.0,
  badgeBorderWidth: 1.5,
  // Tag
  tag1Bg: Candidate01Palette.pureWhite,
  tag1BorderColor: Candidate01Colors.tag1,
  tag1TextColor: Candidate01Palette.pureBlack,
  tag2Bg: Candidate01Palette.pureWhite,
  tag2BorderColor: Candidate01Colors.tag2,
  tag2TextColor: Candidate01Palette.pureBlack,
  tag3Bg: Candidate01Palette.pureWhite,
  tag3BorderColor: Candidate01Colors.tag3,
  tag3TextColor: Candidate01Palette.pureBlack,
  tag4Bg: Candidate01Palette.pureWhite,
  tag4BorderColor: Candidate01Colors.tag4,
  tag4TextColor: Candidate01Palette.pureBlack,
  tag5Bg: Candidate01Palette.pureWhite,
  tag5BorderColor: Candidate01Colors.tag5,
  tag5TextColor: Candidate01Palette.pureWhite,
  tagBorderRadius: 4.0,
  tagBorderWidth: 1.0,
  tagChipBorder: Candidate01Palette.pureBlack,
  tagColor1: Candidate01Colors.tag1,
  tagColor2: Candidate01Colors.tag2,
  tagColor3: Candidate01Colors.tag3,
  tagColor4: Candidate01Colors.tag4,
  tagColor5: Candidate01Colors.tag5,
  tagNoneBg: Colors.transparent,
  tagNoneBorderColor: Candidate01Palette.pureBlack,
  tagNoneTextColor: Candidate01Palette.pureBlack,
  // Test badge
  testBadgeBackground: Candidate01Palette.gunMetal,
  testBadgePercentage: Candidate01Palette.platinum,
  testBadgeDateRecent: Candidate01Palette.greyLight,
  testBadgeDateStale: Candidate01Palette.platinum,
  testBadgeDateOld: Candidate01Palette.crimsonRed,
  // Retention
  retentionNone: Color(0xFFBDBDBD),
  retentionWeak: Color(0xFFFFCC80),
  retentionGood: Color(0xFFA5D6A7),
  retentionStrong: Color(0xFF81C784),
  retentionSuper: Color(0xFF66BB6A),
  retentionText: Candidate01Palette.pureWhite,
  // Shadow
  componentShadow: null,
  appBarShadow: null,
  navbarShadow: null,
  // Snackbar
  snackbarBackground: Candidate01Palette.pureBlack,
  snackbarTextColor: Candidate01Palette.pureWhite,
  snackbarBorderRadius: 4.0,
);

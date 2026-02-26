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
  static const Color steelBlue = Color(0xFF457b9d);
  static const Color navyBlue = Color(0xFF1d3557);

  static const Color darkNavyA67 = Color(0xAA0F1C2E);
  static const Color darkNavyA40 = Color(0x660F1C2E);
  static const Color darkNavyA12 = Color(0x200F1C2E);
  static const Color darkNavyA06 = Color(0x100F1C2E);
  static const Color crimsonRedA67 = Color(0xAAE63946);
  static const Color mintCreamA67 = Color(0xAAF1FAEE);
  static const Color powderTealA67 = Color(0xAAa8dadc);
  static const Color powderTealA25 = Color(0x40a8dadc);
  static const Color powderTealA50 = Color(0x80a8dadc);
  static const Color steelBlueA67 = Color(0xAA457b9d);
  static const Color navyBlueA67 = Color(0xAA1d3557);

  static const Color greyLight = Color(0xFF9E9E9E);
}

// ==========================================================================
// FUNCTIONAL PALETTE
// ==========================================================================
class Candidate02Colors {
  Candidate02Colors._();

  static const Color glass = Candidate02Palette.powderTealA25;
  static const Color glassScrim = Candidate02Palette.powderTealA50;
  static const Color danger = Candidate02Palette.crimsonRed;
  static const Color tag1 = Candidate02Palette.crimsonRedA67;
  static const Color tag2 = Candidate02Palette.mintCreamA67;
  static const Color tag3 = Candidate02Palette.powderTealA67;
  static const Color tag4 = Candidate02Palette.steelBlueA67;
  static const Color tag5 = Candidate02Palette.navyBlueA67;
}

const AppThemeData candidate02Theme = AppThemeData(
  themeType: AppTheme.candidate02,
  // Scaffold
  scaffoldBackground: Candidate02Palette.powderTeal,
  // Display
  displayBackground: Candidate02Palette.powderTeal,
  displayBorderRadius: 12.0,
  // AppBar
  appBarBackground: Candidate02Palette.mintCream,
  appBarForeground: Candidate02Palette.darkNavy,
  appBarBorderColor: Candidate02Palette.darkNavy,
  appBarBorderWidth: 2,
  appBarIconColor: Candidate02Palette.darkNavy,
  appBarTitleColor: Candidate02Palette.darkNavy,
  // Navbar
  navbarBackground: Candidate02Palette.mintCream,
  navbarBorderColor: Candidate02Palette.darkNavy,
  navbarBorderWidth: 2.0,
  navbarIconColor: Candidate02Palette.darkNavy,
  navbarDisabledIconColor: Candidate02Palette.darkNavyA40,
  // Fab
  fabBackground: Candidate02Palette.mintCream,
  fabBorderColor: Candidate02Palette.darkNavy,
  fabTextColor: Candidate02Palette.darkNavy,
  fabBorderWidth: 2,
  confirmFabBackground: Candidate02Palette.darkNavy,
  confirmFabForeground: Candidate02Palette.mintCream,
  confirmFabBorderColor: Candidate02Palette.darkNavy,
  // Text
  textPrimary: Candidate02Palette.darkNavy,
  textSecondary: Candidate02Palette.darkNavyA67,
  // Accent
  accentColor: Candidate02Palette.darkNavy,
  accentColorText: Candidate02Palette.mintCream,
  // Danger
  dangerColor: Candidate02Colors.danger,
  dangerColorText: Candidate02Palette.mintCream,
  // BottomSheet
  bottomSheetBackground: Candidate02Colors.glass,
  bottomSheetBorderColor: Candidate02Palette.darkNavy,
  bottomSheetScrimColor: Candidate02Colors.glassScrim,
  bottomSheetBorderRadius: 12.0,
  bottomSheetBorderWidth: 2.0,
  bottomSheetBlurSigma: 10.0,
  bottomSheetPadding: 16.0,
  // Modal
  modalBorderRadius: 8.0,
  // Control
  controlAccentBackground: Candidate02Palette.darkNavy,
  controlAccentForeground: Candidate02Palette.mintCream,
  controlBackground: Candidate02Palette.mintCream,
  controlBorder: Candidate02Palette.darkNavy,
  controlDangerBackground: Candidate02Colors.danger,
  controlDangerForeground: Candidate02Palette.mintCream,
  controlForeground: Candidate02Palette.darkNavy,
  controlBorderRadius: 8.0,
  controlBorderWidth: 2.0,
  // Toggle
  toggleBorderRadius: 4.0,
  disabledOpacity: 0.4,
  // Divider
  dividerColor: Candidate02Palette.darkNavyA12,
  dividerWidth: 1.0,
  // Progress bar
  progressBarFilled: Candidate02Palette.darkNavy,
  progressBarUnfilled: Candidate02Palette.darkNavyA12,
  progressBarBorderRadius: 4.0,
  progressBarCompactHeight: 6.0,
  progressBarDetailedHeight: 8.0,
  // Button
  buttonBorderRadius: 8.0,
  buttonBorderWidth: 2.0,
  // Note
  noteBackground: Candidate02Palette.darkNavyA06,
  noteBorderColor: Candidate02Palette.darkNavyA40,
  noteBorderRadius: 8.0,
  noteBorderWidth: 1.0,
  noteTextColor: Candidate02Palette.darkNavyA67,
  // Card
  cardBackground: Candidate02Palette.mintCream,
  cardBorderColor: Candidate02Palette.darkNavy,
  cardBorderRadius: 8.0,
  cardBorderWidth: 2.0,
  // Tile
  tileBackground: Candidate02Palette.mintCream,
  tileForeground: Candidate02Palette.darkNavy,
  tileBorderColor: Candidate02Palette.darkNavy,
  tileBorderWidth: 2.0,
  tileBorderRadius: 8.0,
  // Dash
  dashCardBackground: Candidate02Palette.mintCream,
  dashCardBorderColor: Candidate02Palette.darkNavy,
  dashCardBorderRadius: 8.0,
  dashCardBorderWidth: 2.0,
  // ListItem
  listItemBorderColor: Candidate02Palette.darkNavy,
  listItemBorderRadius: 8.0,
  listItemBorderWidth: 2.0,
  // Badge
  badgeBorderRadius: 4.0,
  badgeBorderWidth: 1.5,
  // Tag
  tag1Bg: Candidate02Colors.tag1,
  tag1BorderColor: Candidate02Colors.tag1,
  tag1TextColor: Candidate02Palette.darkNavy,
  tag2Bg: Candidate02Colors.tag2,
  tag2BorderColor: Candidate02Colors.tag2,
  tag2TextColor: Candidate02Palette.darkNavy,
  tag3Bg: Candidate02Colors.tag3,
  tag3BorderColor: Candidate02Colors.tag3,
  tag3TextColor: Candidate02Palette.darkNavy,
  tag4Bg: Candidate02Colors.tag4,
  tag4BorderColor: Candidate02Colors.tag4,
  tag4TextColor: Candidate02Palette.darkNavy,
  tag5Bg: Candidate02Colors.tag5,
  tag5BorderColor: Candidate02Colors.tag5,
  tag5TextColor: Candidate02Palette.mintCream,
  tagBorderRadius: 8.0,
  tagBorderWidth: 1.0,
  tagChipBorder: Candidate02Palette.darkNavy,
  tagColor1: Candidate02Colors.tag1,
  tagColor2: Candidate02Colors.tag2,
  tagColor3: Candidate02Colors.tag3,
  tagColor4: Candidate02Colors.tag4,
  tagColor5: Candidate02Colors.tag5,
  tagNoneBg: Colors.transparent,
  tagNoneBorderColor: Candidate02Palette.darkNavy,
  tagNoneTextColor: Candidate02Palette.darkNavy,
  // Test badge
  testBadgeBackground: Candidate02Palette.darkNavy,
  testBadgePercentage: Candidate02Palette.mintCream,
  testBadgeDateRecent: Candidate02Palette.greyLight,
  testBadgeDateStale: Candidate02Palette.mintCream,
  testBadgeDateOld: Candidate02Palette.crimsonRed,
  // Retention
  retentionNone: Color(0xFFBDBDBD),
  retentionWeak: Color(0xFFFFCC80),
  retentionGood: Color(0xFFA5D6A7),
  retentionStrong: Color(0xFF81C784),
  retentionSuper: Color(0xFF66BB6A),
  retentionText: Candidate02Palette.mintCream,
  // Shadow
  componentShadow: null,
  appBarShadow: null,
  navbarShadow: null,
  // Snackbar
  snackbarBackground: Candidate02Palette.darkNavy,
  snackbarTextColor: Candidate02Palette.mintCream,
  snackbarBorderRadius: 8.0,
);

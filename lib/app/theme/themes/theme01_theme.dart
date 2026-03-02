import 'package:flutter/material.dart';
import '../vessel_themes.dart';

// ==========================================================================
// RAW PALETTE
// ==========================================================================
class Theme01Palette {
  Theme01Palette._();

  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color platinum = Color(0xFFE9EbEd);
  static const Color alabaster = Color(0xFFD3D6DA);
  static const Color pureBlack = Color(0xFF000000);
  static const Color pureBlackA67 = Color(0xAA000000);
  static const Color pureBlackA50 = Color(0x80000000);
  static const Color pureBlackA40 = Color(0x66000000);
  static const Color pureBlackA12 = Color(0x20000000);
  static const Color pureBlackA06 = Color(0x10000000);
  static const Color powderTealA25 = Color(0x40a8dadc);

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
class Theme01Colors {
  Theme01Colors._();

  static const Color danger = Theme01Palette.crimsonRed;
  static const Color tag1 = Theme01Palette.coralRed;
  static const Color tag2 = Theme01Palette.goldenYellow;
  static const Color tag3 = Theme01Palette.limeGreen;
  static const Color tag4 = Theme01Palette.ceruleanBlue;
  static const Color tag5 = Theme01Palette.deepPurple;
}

const VesselThemeData theme01Theme = VesselThemeData(
  themeType: AppTheme.theme01,
  // Scaffold
  scaffoldBackground: Theme01Palette.pureWhite,
  // Display
  displayBackground: Theme01Palette.pureWhite,
  displayBorderRadius: 12.0,
  // AppBar
  appBarBackground: Theme01Palette.platinum,
  appBarForeground: Theme01Palette.gunMetal,
  appBarBorderColor: Theme01Palette.pureBlackA12,
  appBarBorderWidth: 1.5,
  appBarIconColor: Theme01Palette.gunMetal,
  appBarTitleColor: Theme01Palette.gunMetal,
  // Navbar
  navbarBackground: Theme01Palette.platinum,
  navbarBorderColor: Theme01Palette.pureBlackA40,
  navbarBorderWidth: 1.5,
  navbarIconColor: Theme01Palette.pureBlackA67,
  navbarDisabledIconColor: Theme01Palette.gunMetal,
  // Fab
  fabBackground: Theme01Palette.pureWhite,
  fabBorderColor: Theme01Palette.gunMetal,
  fabTextColor: Theme01Palette.gunMetal,
  fabBorderWidth: 2,
  confirmFabBackground: Theme01Palette.gunMetal,
  confirmFabForeground: Theme01Palette.platinum,
  confirmFabBorderColor: Theme01Palette.gunMetal,
  // Text
  textPrimary: Theme01Palette.gunMetal,
  textSecondary: Theme01Palette.pureBlackA67,
  // Accent
  accentColor: Theme01Palette.gunMetal,
  accentColorText: Theme01Palette.platinum,
  // Danger
  dangerColor: Theme01Colors.danger,
  dangerColorText: Theme01Palette.platinum,
  // BottomSheet
  bottomSheetBackground: Theme01Palette.pureWhite,
  bottomSheetBorderColor: Theme01Palette.platinum,
  bottomSheetScrimColor: Theme01Palette.pureBlackA50,
  bottomSheetBorderRadius: 12.0,
  bottomSheetBorderWidth: 2.0,
  bottomSheetBlurSigma: 0.0,
  bottomSheetPadding: 16.0,
  // Modal
  modalBorderRadius: 8.0,
  // Control
  controlBackground: Theme01Palette.alabaster,
  controlBorder: Theme01Palette.alabaster,
  controlForeground: Theme01Palette.gunMetal,
  controlAccentBackground: Theme01Palette.gunMetal,
  controlAccentForeground: Theme01Palette.platinum,
  controlDangerBackground: Theme01Colors.danger,
  controlDangerForeground: Theme01Palette.platinum,
  controlBorderRadius: 8.0,
  controlBorderWidth: 2.0,
  // Toggle
  toggleBorderRadius: 4.0,
  disabledOpacity: 0.4,
  // Divider
  dividerColor: Theme01Palette.pureBlackA12,
  dividerWidth: 1.0,
  // Progress bar
  progressBarFilled: Theme01Palette.gunMetal,
  progressBarUnfilled: Theme01Palette.pureBlackA12,
  progressBarBorderRadius: 4.0,
  progressBarCompactHeight: 6.0,
  progressBarDetailedHeight: 8.0,
  // Button
  buttonBorderRadius: 8.0,
  buttonBorderWidth: 2.0,
  // Note
  noteBackground: Theme01Palette.platinum,
  noteBorderColor: Theme01Palette.platinum,
  noteBorderRadius: 8.0,
  noteBorderWidth: 1.0,
  noteTextColor: Theme01Palette.pureBlackA67,
  // Card
  cardBackground: Theme01Palette.platinum,
  cardBorderColor: Theme01Palette.platinum,
  cardBorderRadius: 8.0,
  cardBorderWidth: 2.0,
  // Tile
  tileBackground: Theme01Palette.alabaster,
  tileForeground: Theme01Palette.gunMetal,
  tileBorderColor: Theme01Palette.platinum,
  tileBorderWidth: 2.0,
  tileBorderRadius: 8.0,
  // Deck icon
  deckIconColor: Theme01Palette.gunMetal,
  deckIconBackground: Theme01Palette.pureBlackA12,
  deckIconBorderRadius: 8.0,
  // Dash
  dashCardBackground: Theme01Palette.platinum,
  dashCardBorderColor: Theme01Palette.platinum,
  dashCardBorderRadius: 8.0,
  dashCardBorderWidth: 2.0,
  // ListItem
  listItemBorderColor: Theme01Palette.gunMetal,
  listItemBorderRadius: 8.0,
  listItemBorderWidth: 2.0,
  // Badge
  badgeBorderRadius: 4.0,
  badgeBorderWidth: 1.5,
  // Tag
  tag1Bg: Theme01Palette.pureWhite,
  tag1BorderColor: Theme01Colors.tag1,
  tag1TextColor: Theme01Palette.pureBlack,
  tag2Bg: Theme01Palette.pureWhite,
  tag2BorderColor: Theme01Colors.tag2,
  tag2TextColor: Theme01Palette.pureBlack,
  tag3Bg: Theme01Palette.pureWhite,
  tag3BorderColor: Theme01Colors.tag3,
  tag3TextColor: Theme01Palette.pureBlack,
  tag4Bg: Theme01Palette.pureWhite,
  tag4BorderColor: Theme01Colors.tag4,
  tag4TextColor: Theme01Palette.pureBlack,
  tag5Bg: Theme01Palette.pureWhite,
  tag5BorderColor: Theme01Colors.tag5,
  tag5TextColor: Theme01Palette.pureWhite,
  tagBorderRadius: 4.0,
  tagBorderWidth: 1.0,
  tagChipBorder: Theme01Palette.pureBlack,
  tagColor1: Theme01Colors.tag1,
  tagColor2: Theme01Colors.tag2,
  tagColor3: Theme01Colors.tag3,
  tagColor4: Theme01Colors.tag4,
  tagColor5: Theme01Colors.tag5,
  tagNoneBg: Colors.transparent,
  tagNoneBorderColor: Theme01Palette.pureBlack,
  tagNoneTextColor: Theme01Palette.pureBlack,
  // Test badge
  testBadgeBackground: Theme01Palette.gunMetal,
  testBadgePercentage: Theme01Palette.platinum,
  testBadgeDateRecent: Theme01Palette.greyLight,
  testBadgeDateStale: Theme01Palette.platinum,
  testBadgeDateOld: Theme01Palette.crimsonRed,
  // Retention
  retentionNone: Color(0xFFBDBDBD),
  retentionWeak: Color(0xFFFFCC80),
  retentionGood: Color(0xFFA5D6A7),
  retentionStrong: Color(0xFF81C784),
  retentionSuper: Color(0xFF66BB6A),
  retentionText: Theme01Palette.pureWhite,
  // Shadow
  componentShadow: null,
  appBarShadow: null,
  navbarShadow: null,
  // Snackbar
  snackbarBackground: Theme01Palette.pureBlack,
  snackbarTextColor: Theme01Palette.pureWhite,
  snackbarBorderRadius: 8.0,
  // Note accent
  noteAccentBackground: Theme01Palette.gunMetal,
  noteAccentBorderColor: Theme01Palette.gunMetal,
  noteAccentTextColor: Theme01Palette.platinum,
  // Mode tile
  modeTileBackground: Theme01Palette.alabaster,
  modeTileForeground: Theme01Palette.gunMetal,
  modeTileBorderColor: Theme01Palette.platinum,
  modeTileAccentBackground: Theme01Palette.gunMetal,
  modeTileAccentForeground: Theme01Palette.platinum,
  modeTileAccentBorderColor: Theme01Palette.gunMetal,
);

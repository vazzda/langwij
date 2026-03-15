import 'package:flutter/material.dart';
import '../vessel_themes.dart';

// ==========================================================================
// RAW PALETTE
// ==========================================================================
class Theme03Palette {
  Theme03Palette._();

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
class Theme03Colors {
  Theme03Colors._();

  static const Color danger = Theme03Palette.crimsonRed;
  static const Color tag1 = Theme03Palette.coralRed;
  static const Color tag2 = Theme03Palette.goldenYellow;
  static const Color tag3 = Theme03Palette.limeGreen;
  static const Color tag4 = Theme03Palette.ceruleanBlue;
  static const Color tag5 = Theme03Palette.deepPurple;
}

const VesselThemeData theme03Theme = VesselThemeData(
  themeType: AppTheme.theme03,
  // Scaffold
  scaffoldBackground: Theme03Palette.platinum,
  // Display
  displayBackground: Theme03Palette.platinum,
  displayBorderRadius: 12.0,
  // AppBar
  appBarBackground: Theme03Palette.platinum,
  appBarForeground: Theme03Palette.gunMetal,
  appBarBorderColor: Theme03Palette.gunMetal,
  appBarBorderWidth: 2,
  appBarIconColor: Theme03Palette.gunMetal,
  appBarTitleColor: Theme03Palette.gunMetal,
  // Navbar
  navbarBackground: Theme03Palette.pureWhite,
  navbarBorderColor: Theme03Palette.gunMetal,
  navbarBorderWidth: 2.0,
  navbarIconColor: Theme03Palette.gunMetal,
  navbarDisabledIconColor: Theme03Palette.gunMetal,
  // Fab
  fabBackground: Theme03Palette.pureWhite,
  fabBorderColor: Theme03Palette.gunMetal,
  fabTextColor: Theme03Palette.gunMetal,
  fabBorderWidth: 2,
  confirmFabBackground: Theme03Palette.gunMetal,
  confirmFabForeground: Theme03Palette.platinum,
  confirmFabBorderColor: Theme03Palette.gunMetal,
  // Text
  textPrimary: Theme03Palette.gunMetal,
  textSecondary: Theme03Palette.pureBlackA67,
  // Accent
  accentColor: Theme03Palette.gunMetal,
  accentColorText: Theme03Palette.platinum,
  // Danger
  dangerColor: Theme03Colors.danger,
  dangerColorText: Theme03Palette.platinum,
  // BottomSheet
  bottomSheetBackground: Theme03Palette.platinum,
  bottomSheetBorderColor: Theme03Palette.gunMetal,
  bottomSheetScrimColor: Theme03Palette.pureBlackA50,
  bottomSheetBorderRadius: 12.0,
  bottomSheetBorderWidth: 2.0,
  bottomSheetBlurSigma: 0.0,
  bottomSheetPadding: 16.0,
  // Modal
  modalBorderRadius: 4.0,
  // Control
  controlAccentBackground: Theme03Palette.gunMetal,
  controlAccentForeground: Theme03Palette.platinum,
  controlBackground: Theme03Palette.pureWhite,
  controlBorder: Theme03Palette.gunMetal,
  controlDangerBackground: Theme03Colors.danger,
  controlDangerForeground: Theme03Palette.platinum,
  controlForeground: Theme03Palette.gunMetal,
  controlBorderRadius: 4.0,
  controlBorderWidth: 2.0,
  // Toggle
  toggleBorderRadius: 4.0,
  disabledOpacity: 0.4,
  // Divider
  dividerColor: Theme03Palette.pureBlackA12,
  dividerWidth: 1.0,
  // Progress bar
  progressBarFilled: Theme03Palette.gunMetal,
  progressBarUnfilled: Theme03Palette.pureBlackA12,
  progressBarBorderRadius: 2.0,
  progressBarCompactHeight: 5.0,
  progressBarDetailedHeight: 6.0,
  // Button
  buttonBorderRadius: 4.0,
  buttonBorderWidth: 2.0,
  // Note
  noteBackground: Theme03Palette.pureBlackA06,
  noteBorderColor: Theme03Palette.pureBlackA40,
  noteBorderRadius: 4.0,
  noteBorderWidth: 1.0,
  noteTextColor: Theme03Palette.pureBlackA67,
  // Card
  cardBackground: Theme03Palette.pureWhite,
  cardBorderColor: Theme03Palette.gunMetal,
  cardBorderRadius: 4.0,
  cardBorderWidth: 2.0,
  // Tile
  tileBackground: Theme03Palette.pureWhite,
  tileForeground: Theme03Palette.gunMetal,
  tileBorderColor: Theme03Palette.gunMetal,
  tileBorderWidth: 2.0,
  tileBorderRadius: 4.0,
  // Round answer tile
  roundAnswerTileBackground: Theme03Palette.pureWhite,
  roundAnswerTileBorderColor: Theme03Palette.gunMetal,
  roundAnswerTileBorderWidth: 2.0,
  roundAnswerTileCorrectColor: Theme03Palette.gunMetal,
  roundAnswerTileWrongColor: Theme03Colors.danger,
  // Deck icon
  deckIconColor: Theme03Palette.gunMetal,
  deckIconBackground: Theme03Palette.platinum,
  deckIconBorderRadius: 4.0,
  // Dash
  dashCardBackground: Theme03Palette.pureWhite,
  dashCardBorderColor: Theme03Palette.gunMetal,
  dashCardBorderRadius: 4.0,
  dashCardBorderWidth: 2.0,
  // ListItem
  listItemBorderColor: Theme03Palette.gunMetal,
  listItemBorderRadius: 4.0,
  listItemBorderWidth: 2.0,
  // Badge
  badgeBorderRadius: 2.0,
  badgeBorderWidth: 1.5,
  // Tag
  tag1Bg: Theme03Palette.pureWhite,
  tag1BorderColor: Theme03Colors.tag1,
  tag1TextColor: Theme03Palette.pureBlack,
  tag2Bg: Theme03Palette.pureWhite,
  tag2BorderColor: Theme03Colors.tag2,
  tag2TextColor: Theme03Palette.pureBlack,
  tag3Bg: Theme03Palette.pureWhite,
  tag3BorderColor: Theme03Colors.tag3,
  tag3TextColor: Theme03Palette.pureBlack,
  tag4Bg: Theme03Palette.pureWhite,
  tag4BorderColor: Theme03Colors.tag4,
  tag4TextColor: Theme03Palette.pureBlack,
  tag5Bg: Theme03Palette.pureWhite,
  tag5BorderColor: Theme03Colors.tag5,
  tag5TextColor: Theme03Palette.pureWhite,
  tagBorderRadius: 4.0,
  tagBorderWidth: 1.0,
  tagChipBorder: Theme03Palette.pureBlack,
  tagColor1: Theme03Colors.tag1,
  tagColor2: Theme03Colors.tag2,
  tagColor3: Theme03Colors.tag3,
  tagColor4: Theme03Colors.tag4,
  tagColor5: Theme03Colors.tag5,
  tagNoneBg: Colors.transparent,
  tagNoneBorderColor: Theme03Palette.pureBlack,
  tagNoneTextColor: Theme03Palette.pureBlack,
  // Test badge
  testBadgeBackground: Theme03Palette.gunMetal,
  testBadgePercentage: Theme03Palette.platinum,
  testBadgeDateRecent: Theme03Palette.greyLight,
  testBadgeDateStale: Theme03Palette.platinum,
  testBadgeDateOld: Theme03Palette.crimsonRed,
  // Retention
  retentionNone: Color(0xFFBDBDBD),
  retentionWeak: Color(0xFFFFCC80),
  retentionGood: Color(0xFFA5D6A7),
  retentionStrong: Color(0xFF81C784),
  retentionSuper: Color(0xFF66BB6A),
  retentionText: Theme03Palette.pureWhite,
  // Shadow
  componentShadow: null,
  appBarShadow: null,
  navbarShadow: null,
  // Snackbar
  snackbarBackground: Theme03Palette.pureBlack,
  snackbarTextColor: Theme03Palette.pureWhite,
  snackbarBorderRadius: 4.0,
  // Note accent
  noteAccentBackground: Theme03Palette.gunMetal,
  noteAccentBorderColor: Theme03Palette.gunMetal,
  noteAccentTextColor: Theme03Palette.platinum,
  // Mode tile
  modeTileBackground: Theme03Palette.pureWhite,
  modeTileForeground: Theme03Palette.gunMetal,
  modeTileBorderColor: Theme03Palette.gunMetal,
  modeTileAccentBackground: Theme03Palette.gunMetal,
  modeTileAccentForeground: Theme03Palette.platinum,
  modeTileAccentBorderColor: Theme03Palette.gunMetal,
);

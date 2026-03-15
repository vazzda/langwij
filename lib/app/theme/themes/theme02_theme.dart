import 'package:flutter/material.dart';
import '../vessel_themes.dart';

// ==========================================================================
// RAW PALETTE
// ==========================================================================
class Theme02Palette {
  Theme02Palette._();

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
class Theme02Colors {
  Theme02Colors._();

  static const Color glass = Theme02Palette.powderTealA25;
  static const Color glassScrim = Theme02Palette.powderTealA50;
  static const Color danger = Theme02Palette.crimsonRed;
  static const Color tag1 = Theme02Palette.crimsonRedA67;
  static const Color tag2 = Theme02Palette.mintCreamA67;
  static const Color tag3 = Theme02Palette.powderTealA67;
  static const Color tag4 = Theme02Palette.steelBlueA67;
  static const Color tag5 = Theme02Palette.navyBlueA67;
}

const VesselThemeData theme02Theme = VesselThemeData(
  themeType: AppTheme.theme02,
  // Scaffold
  scaffoldBackground: Theme02Palette.powderTeal,
  // Display
  displayBackground: Theme02Palette.powderTeal,
  displayBorderRadius: 12.0,
  // AppBar
  appBarBackground: Theme02Palette.mintCream,
  appBarForeground: Theme02Palette.darkNavy,
  appBarBorderColor: Theme02Palette.darkNavy,
  appBarBorderWidth: 2,
  appBarIconColor: Theme02Palette.darkNavy,
  appBarTitleColor: Theme02Palette.darkNavy,
  // Navbar
  navbarBackground: Theme02Palette.mintCream,
  navbarBorderColor: Theme02Palette.darkNavy,
  navbarBorderWidth: 2.0,
  navbarIconColor: Theme02Palette.darkNavy,
  navbarDisabledIconColor: Theme02Palette.darkNavy,
  // Fab
  fabBackground: Theme02Palette.mintCream,
  fabBorderColor: Theme02Palette.darkNavy,
  fabTextColor: Theme02Palette.darkNavy,
  fabBorderWidth: 2,
  confirmFabBackground: Theme02Palette.darkNavy,
  confirmFabForeground: Theme02Palette.mintCream,
  confirmFabBorderColor: Theme02Palette.darkNavy,
  // Text
  textPrimary: Theme02Palette.darkNavy,
  textSecondary: Theme02Palette.darkNavyA67,
  // Accent
  accentColor: Theme02Palette.darkNavy,
  accentColorText: Theme02Palette.mintCream,
  // Danger
  dangerColor: Theme02Colors.danger,
  dangerColorText: Theme02Palette.mintCream,
  // BottomSheet
  bottomSheetBackground: Theme02Colors.glass,
  bottomSheetBorderColor: Theme02Palette.darkNavy,
  bottomSheetScrimColor: Theme02Colors.glassScrim,
  bottomSheetBorderRadius: 12.0,
  bottomSheetBorderWidth: 2.0,
  bottomSheetBlurSigma: 10.0,
  bottomSheetPadding: 16.0,
  // Modal
  modalBorderRadius: 8.0,
  // Control
  controlAccentBackground: Theme02Palette.darkNavy,
  controlAccentForeground: Theme02Palette.mintCream,
  controlBackground: Theme02Palette.mintCream,
  controlBorder: Theme02Palette.darkNavy,
  controlDangerBackground: Theme02Colors.danger,
  controlDangerForeground: Theme02Palette.mintCream,
  controlForeground: Theme02Palette.darkNavy,
  controlBorderRadius: 8.0,
  controlBorderWidth: 2.0,
  // Toggle
  toggleBorderRadius: 4.0,
  disabledOpacity: 0.4,
  // Divider
  dividerColor: Theme02Palette.darkNavyA12,
  dividerWidth: 1.0,
  // Progress bar
  progressBarFilled: Theme02Palette.darkNavy,
  progressBarUnfilled: Theme02Palette.darkNavyA12,
  progressBarBorderRadius: 4.0,
  progressBarCompactHeight: 6.0,
  progressBarDetailedHeight: 8.0,
  // Button
  buttonBorderRadius: 8.0,
  buttonBorderWidth: 2.0,
  // Note
  noteBackground: Theme02Palette.darkNavyA06,
  noteBorderColor: Theme02Palette.darkNavyA40,
  noteBorderRadius: 8.0,
  noteBorderWidth: 1.0,
  noteTextColor: Theme02Palette.darkNavyA67,
  // Card
  cardBackground: Theme02Palette.mintCream,
  cardBorderColor: Theme02Palette.darkNavy,
  cardBorderRadius: 8.0,
  cardBorderWidth: 2.0,
  // Tile
  tileBackground: Theme02Palette.mintCream,
  tileForeground: Theme02Palette.darkNavy,
  tileBorderColor: Theme02Palette.darkNavy,
  tileBorderWidth: 2.0,
  tileBorderRadius: 8.0,
  // Round answer tile
  roundAnswerTileBackground: Theme02Palette.mintCream,
  roundAnswerTileBorderColor: Theme02Palette.darkNavy,
  roundAnswerTileBorderWidth: 2.0,
  roundAnswerTileCorrectColor: Theme02Palette.darkNavy,
  roundAnswerTileWrongColor: Theme02Colors.danger,
  // Deck icon
  deckIconColor: Theme02Palette.darkNavy,
  deckIconBackground: Theme02Palette.powderTeal,
  deckIconBorderRadius: 8.0,
  // Dash
  dashCardBackground: Theme02Palette.mintCream,
  dashCardBorderColor: Theme02Palette.darkNavy,
  dashCardBorderRadius: 8.0,
  dashCardBorderWidth: 2.0,
  // ListItem
  listItemBorderColor: Theme02Palette.darkNavy,
  listItemBorderRadius: 8.0,
  listItemBorderWidth: 2.0,
  // Badge
  badgeBorderRadius: 4.0,
  badgeBorderWidth: 1.5,
  // Tag
  tag1Bg: Theme02Colors.tag1,
  tag1BorderColor: Theme02Colors.tag1,
  tag1TextColor: Theme02Palette.darkNavy,
  tag2Bg: Theme02Colors.tag2,
  tag2BorderColor: Theme02Colors.tag2,
  tag2TextColor: Theme02Palette.darkNavy,
  tag3Bg: Theme02Colors.tag3,
  tag3BorderColor: Theme02Colors.tag3,
  tag3TextColor: Theme02Palette.darkNavy,
  tag4Bg: Theme02Colors.tag4,
  tag4BorderColor: Theme02Colors.tag4,
  tag4TextColor: Theme02Palette.darkNavy,
  tag5Bg: Theme02Colors.tag5,
  tag5BorderColor: Theme02Colors.tag5,
  tag5TextColor: Theme02Palette.mintCream,
  tagBorderRadius: 8.0,
  tagBorderWidth: 1.0,
  tagChipBorder: Theme02Palette.darkNavy,
  tagColor1: Theme02Colors.tag1,
  tagColor2: Theme02Colors.tag2,
  tagColor3: Theme02Colors.tag3,
  tagColor4: Theme02Colors.tag4,
  tagColor5: Theme02Colors.tag5,
  tagNoneBg: Colors.transparent,
  tagNoneBorderColor: Theme02Palette.darkNavy,
  tagNoneTextColor: Theme02Palette.darkNavy,
  // Test badge
  testBadgeBackground: Theme02Palette.darkNavy,
  testBadgePercentage: Theme02Palette.mintCream,
  testBadgeDateRecent: Theme02Palette.greyLight,
  testBadgeDateStale: Theme02Palette.mintCream,
  testBadgeDateOld: Theme02Palette.crimsonRed,
  // Retention
  retentionNone: Color(0xFFBDBDBD),
  retentionWeak: Color(0xFFFFCC80),
  retentionGood: Color(0xFFA5D6A7),
  retentionStrong: Color(0xFF81C784),
  retentionSuper: Color(0xFF66BB6A),
  retentionText: Theme02Palette.mintCream,
  // Shadow
  componentShadow: null,
  appBarShadow: null,
  navbarShadow: null,
  // Snackbar
  snackbarBackground: Theme02Palette.darkNavy,
  snackbarTextColor: Theme02Palette.mintCream,
  snackbarBorderRadius: 8.0,
  // Note accent
  noteAccentBackground: Theme02Palette.darkNavy,
  noteAccentBorderColor: Theme02Palette.darkNavy,
  noteAccentTextColor: Theme02Palette.mintCream,
  // Mode tile
  modeTileBackground: Theme02Palette.mintCream,
  modeTileForeground: Theme02Palette.darkNavy,
  modeTileBorderColor: Theme02Palette.darkNavy,
  modeTileAccentBackground: Theme02Palette.darkNavy,
  modeTileAccentForeground: Theme02Palette.mintCream,
  modeTileAccentBorderColor: Theme02Palette.darkNavy,
);

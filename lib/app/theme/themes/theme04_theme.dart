import 'package:flutter/material.dart';
import '../vessel_themes.dart';

// ==========================================================================
// RAW PALETTE
// ==========================================================================
class Theme04Palette {
  Theme04Palette._();

  static const Color porcleain = Color(0xFFFCFBF7);
  static const Color oldlace = Color(0xFFEBE9E6);
  static const Color dustgray = Color(0xFFDBD7D2);
  static const Color silverdust = Color(0xFFD2CCC6);

  static const Color lightCoral = Color(0xFFE07A5F);
  static const Color lightCoral25 = Color(0x25E07A5F);
  static const Color heavyBronze50 = Color(0x50F2CC8F);

  static const Color deepWalnut = Color(0xFF3D405D);
  static const Color deepWalnutA12 = Color(0x103D405D);
  static const Color deepWalnutA40 = Color(0x403D405D);
  static const Color deepWalnutA80 = Color(0x803D405D);

  static const Color greyLight = Color(0xFF9E9E9E);
}

// ==========================================================================
// FUNCTIONAL PALETTE
// ==========================================================================
class Theme04Colors {
  Theme04Colors._();

  static const Color glass = Theme04Palette.lightCoral25;
  static const Color glassScrim = Theme04Palette.heavyBronze50;
  static const Color danger = Theme04Palette.lightCoral;
  static const Color tag1 = Theme04Palette.deepWalnut;
  static const Color tag2 = Theme04Palette.deepWalnut;
  static const Color tag3 = Theme04Palette.deepWalnut;
  static const Color tag4 = Theme04Palette.deepWalnut;
  static const Color tag5 = Theme04Palette.deepWalnut;
}

const VesselThemeData theme04Theme = VesselThemeData(
  themeType: AppTheme.theme04,
  // Scaffold
  scaffoldBackground: Theme04Palette.porcleain,
  // Display
  displayBackground: Theme04Palette.porcleain,
  displayBorderRadius: 12.0,
  // AppBar
  appBarBackground: Theme04Palette.porcleain,
  appBarForeground: Theme04Palette.deepWalnut,
  appBarBorderColor: Theme04Palette.deepWalnut,
  appBarBorderWidth: 2,
  appBarIconColor: Theme04Palette.deepWalnut,
  appBarTitleColor: Theme04Palette.deepWalnut,
  // Navbar
  navbarBackground: Theme04Palette.porcleain,
  navbarBorderColor: Theme04Palette.deepWalnut,
  navbarBorderWidth: 2.0,
  navbarIconColor: Theme04Palette.deepWalnut,
  navbarDisabledIconColor: Theme04Palette.deepWalnut,
  // Fab
  fabBackground: Theme04Palette.oldlace,
  fabBorderColor: Theme04Palette.deepWalnut,
  fabTextColor: Theme04Palette.deepWalnut,
  fabBorderWidth: 2,
  confirmFabBackground: Theme04Palette.deepWalnut,
  confirmFabForeground: Theme04Palette.oldlace,
  confirmFabBorderColor: Theme04Palette.deepWalnut,
  // Text
  textPrimary: Theme04Palette.deepWalnut,
  textSecondary: Theme04Palette.deepWalnutA80,
  // Accent
  accentColor: Theme04Palette.deepWalnut,
  accentColorText: Theme04Palette.oldlace,
  // Danger
  dangerColor: Theme04Colors.danger,
  dangerColorText: Theme04Palette.oldlace,
  // BottomSheet
  bottomSheetBackground: Theme04Colors.glass,
  bottomSheetBorderColor: Theme04Palette.deepWalnut,
  bottomSheetScrimColor: Theme04Colors.glassScrim,
  bottomSheetBorderRadius: 12.0,
  bottomSheetBorderWidth: 2.0,
  bottomSheetBlurSigma: 10.0,
  bottomSheetPadding: 16.0,
  // Modal
  modalBorderRadius: 8.0,
  // Control
  controlAccentBackground: Theme04Palette.deepWalnut,
  controlAccentForeground: Theme04Palette.oldlace,
  controlBackground: Theme04Palette.oldlace,
  controlBorder: Theme04Palette.dustgray,
  controlDangerBackground: Theme04Colors.danger,
  controlDangerForeground: Theme04Palette.oldlace,
  controlForeground: Theme04Palette.deepWalnut,
  controlBorderRadius: 8.0,
  controlBorderWidth: 2.0,
  // Toggle
  toggleBorderRadius: 4.0,
  disabledOpacity: 0.4,
  // Divider
  dividerColor: Theme04Palette.deepWalnutA40,
  dividerWidth: 1.0,
  // Progress bar
  progressBarFilled: Theme04Palette.deepWalnut,
  progressBarUnfilled: Theme04Palette.silverdust,
  progressBarBorderRadius: 4.0,
  progressBarCompactHeight: 6.0,
  progressBarDetailedHeight: 8.0,
  // Button
  buttonBorderRadius: 8.0,
  buttonBorderWidth: 2.0,
  // Note
  noteBackground: Theme04Palette.oldlace,
  noteBorderColor: Theme04Palette.silverdust,
  noteBorderRadius: 8.0,
  noteBorderWidth: 1.0,
  noteTextColor: Theme04Palette.deepWalnutA80,
  // Card
  cardBackground: Theme04Palette.oldlace,
  cardBorderColor: Theme04Palette.dustgray,
  cardBorderRadius: 8.0,
  cardBorderWidth: 2.0,
  // Tile
  tileBackground: Theme04Palette.dustgray,
  tileForeground: Theme04Palette.deepWalnut,
  tileBorderColor: Theme04Palette.silverdust,
  tileBorderWidth: 2.0,
  tileBorderRadius: 8.0,
  // Round answer tile
  roundAnswerTileBackground: Theme04Palette.dustgray,
  roundAnswerTileBorderColor: Theme04Palette.silverdust,
  roundAnswerTileBorderWidth: 2.0,
  roundAnswerTileCorrectColor: Theme04Palette.deepWalnut,
  roundAnswerTileWrongColor: Theme04Colors.danger,
  // Deck icon
  deckIconColor: Theme04Palette.deepWalnut,
  deckIconBackground: Theme04Palette.silverdust,
  deckIconBorderRadius: 8.0,
  // Dash
  dashCardBackground: Theme04Palette.oldlace,
  dashCardBorderColor: Theme04Palette.oldlace,
  dashCardBorderRadius: 8.0,
  dashCardBorderWidth: 2.0,
  // ListItem
  listItemBorderColor: Theme04Palette.oldlace,
  listItemBorderRadius: 8.0,
  listItemBorderWidth: 2.0,
  // Badge
  badgeBorderRadius: 4.0,
  badgeBorderWidth: 1.5,
  // Tag
  tag1Bg: Theme04Colors.tag1,
  tag1BorderColor: Theme04Colors.tag1,
  tag1TextColor: Theme04Palette.deepWalnut,
  tag2Bg: Theme04Colors.tag2,
  tag2BorderColor: Theme04Colors.tag2,
  tag2TextColor: Theme04Palette.deepWalnut,
  tag3Bg: Theme04Colors.tag3,
  tag3BorderColor: Theme04Colors.tag3,
  tag3TextColor: Theme04Palette.deepWalnut,
  tag4Bg: Theme04Colors.tag4,
  tag4BorderColor: Theme04Colors.tag4,
  tag4TextColor: Theme04Palette.deepWalnut,
  tag5Bg: Theme04Colors.tag5,
  tag5BorderColor: Theme04Colors.tag5,
  tag5TextColor: Theme04Palette.oldlace,
  tagBorderRadius: 8.0,
  tagBorderWidth: 1.0,
  tagChipBorder: Theme04Palette.deepWalnut,
  tagColor1: Theme04Colors.tag1,
  tagColor2: Theme04Colors.tag2,
  tagColor3: Theme04Colors.tag3,
  tagColor4: Theme04Colors.tag4,
  tagColor5: Theme04Colors.tag5,
  tagNoneBg: Colors.transparent,
  tagNoneBorderColor: Theme04Palette.deepWalnut,
  tagNoneTextColor: Theme04Palette.deepWalnut,
  // Test badge
  testBadgeBackground: Theme04Palette.deepWalnut,
  testBadgePercentage: Theme04Palette.oldlace,
  testBadgeDateRecent: Theme04Palette.greyLight,
  testBadgeDateStale: Theme04Palette.oldlace,
  testBadgeDateOld: Theme04Palette.lightCoral,
  // Retention
  retentionNone: Color(0xFFBDBDBD),
  retentionWeak: Color(0xFFFFCC80),
  retentionGood: Color(0xFFA5D6A7),
  retentionStrong: Color(0xFF81C784),
  retentionSuper: Color(0xFF66BB6A),
  retentionText: Theme04Palette.porcleain,
  // Shadow
  componentShadow: null,
  appBarShadow: null,
  navbarShadow: null,
  // Snackbar
  snackbarBackground: Theme04Palette.deepWalnut,
  snackbarTextColor: Theme04Palette.oldlace,
  snackbarBorderRadius: 8.0,
  // Note accent
  noteAccentBackground: Theme04Palette.deepWalnut,
  noteAccentBorderColor: Theme04Palette.deepWalnut,
  noteAccentTextColor: Theme04Palette.oldlace,
  // Mode tile
  modeTileBackground: Theme04Palette.oldlace,
  modeTileForeground: Theme04Palette.deepWalnut,
  modeTileBorderColor: Theme04Palette.dustgray,
  modeTileAccentBackground: Theme04Palette.deepWalnut,
  modeTileAccentForeground: Theme04Palette.oldlace,
  modeTileAccentBorderColor: Theme04Palette.deepWalnut,
);

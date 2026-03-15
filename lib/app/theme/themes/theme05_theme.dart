import 'package:flutter/material.dart';
import '../vessel_themes.dart';

// ==========================================================================
// RAW PALETTE
// ==========================================================================
class Theme05Palette {
  Theme05Palette._();

  static const Color porcleain = Color(0xFFFCFBF7);
  static const Color porcleain50 = Color(0x90FCFBF7);
  static const Color oldlace = Color(0xFFEBE9E6);
  static const Color dustyGrape = Color(0xFF5A5F87);
  static const Color twilightIndigo = Color(0xFF3D405B);
  static const Color spaceIndigo = Color(0xFF292B3D);
  static const Color spaceIndigo50 = Color(0x50292B3D);

  static const Color burntPeach = Color(0xFFE07A5F);

  static const Color deepWalnut = Color(0xFFFFFFFF);
  static const Color deepWalnutA12 = Color(0x10FFFFFF);
  static const Color deepWalnutA40 = Color(0x40FFFFFF);
  static const Color deepWalnutA80 = Color(0x80FFFFFF);

  static const Color black = Color(0xFF101118);
  static const Color greyLight = Color(0xFF9E9E9E);
}

// ==========================================================================
// FUNCTIONAL PALETTE
// ==========================================================================
class Theme05Colors {
  Theme05Colors._();

  static const Color glass = Theme05Palette.spaceIndigo50;
  static const Color glassScrim = Theme05Palette.spaceIndigo50;
  static const Color danger = Theme05Palette.burntPeach;
  static const Color tag1 = Theme05Palette.deepWalnut;
  static const Color tag2 = Theme05Palette.deepWalnut;
  static const Color tag3 = Theme05Palette.deepWalnut;
  static const Color tag4 = Theme05Palette.deepWalnut;
  static const Color tag5 = Theme05Palette.deepWalnut;
}

const VesselThemeData theme05Theme = VesselThemeData(
  themeType: AppTheme.theme05,
  // Scaffold
  scaffoldBackground: Theme05Palette.spaceIndigo,
  // Display
  displayBackground: Theme05Palette.spaceIndigo,
  displayBorderRadius: 12.0,
  // AppBar
  appBarBackground: Theme05Palette.spaceIndigo,
  appBarForeground: Theme05Palette.deepWalnut,
  appBarBorderColor: Theme05Palette.black,
  appBarBorderWidth: 2,
  appBarIconColor: Theme05Palette.deepWalnut,
  appBarTitleColor: Theme05Palette.deepWalnut,
  // Navbar
  navbarBackground: Theme05Palette.spaceIndigo,
  navbarBorderColor: Theme05Palette.black,
  navbarBorderWidth: 2.0,
  navbarIconColor: Theme05Palette.deepWalnut,
  navbarDisabledIconColor: Theme05Palette.deepWalnut,
  // Fab
  fabBackground: Theme05Palette.twilightIndigo,
  fabBorderColor: Theme05Palette.black,
  fabTextColor: Theme05Palette.black,
  fabBorderWidth: 2,
  confirmFabBackground: Theme05Palette.deepWalnut,
  confirmFabForeground: Theme05Palette.oldlace,
  confirmFabBorderColor: Theme05Palette.deepWalnut,
  // Text
  textPrimary: Theme05Palette.deepWalnut,
  textSecondary: Theme05Palette.deepWalnutA80,
  // Accent
  accentColor: Theme05Palette.deepWalnut,
  accentColorText: Theme05Palette.oldlace,
  // Danger
  dangerColor: Theme05Colors.danger,
  dangerColorText: Theme05Palette.oldlace,
  // BottomSheet
  bottomSheetBackground: Theme05Colors.glass,
  bottomSheetBorderColor: Theme05Palette.porcleain50,
  bottomSheetScrimColor: Theme05Colors.glassScrim,
  bottomSheetBorderRadius: 12.0,
  bottomSheetBorderWidth: 2.0,
  bottomSheetBlurSigma: 10.0,
  bottomSheetPadding: 16.0,
  // Modal
  modalBorderRadius: 8.0,
  // Control
  controlAccentBackground: Theme05Palette.deepWalnut,
  controlAccentForeground: Theme05Palette.spaceIndigo,
  controlBackground: Theme05Palette.spaceIndigo,
  controlBorder: Theme05Palette.spaceIndigo,
  controlForeground: Theme05Palette.deepWalnut,
  controlDangerBackground: Theme05Colors.danger,
  controlDangerForeground: Theme05Palette.oldlace,
  controlBorderRadius: 8.0,
  controlBorderWidth: 2.0,
  // Toggle
  toggleBorderRadius: 4.0,
  disabledOpacity: 0.4,
  // Divider
  dividerColor: Theme05Palette.deepWalnutA40,
  dividerWidth: 1.0,
  // Progress bar
  progressBarFilled: Theme05Palette.deepWalnut,
  progressBarUnfilled: Theme05Palette.deepWalnutA12,
  progressBarBorderRadius: 4.0,
  progressBarCompactHeight: 6.0,
  progressBarDetailedHeight: 8.0,
  // Button
  buttonBorderRadius: 8.0,
  buttonBorderWidth: 2.0,
  // Note
  noteBackground: Theme05Palette.spaceIndigo,
  noteBorderColor: Theme05Palette.spaceIndigo,
  noteBorderRadius: 8.0,
  noteBorderWidth: 1.0,
  noteTextColor: Theme05Palette.deepWalnutA80,
  // Card
  cardBackground: Theme05Palette.twilightIndigo,
  cardBorderColor: Theme05Palette.twilightIndigo,
  cardBorderRadius: 8.0,
  cardBorderWidth: 2.0,
  // Tile
  tileBackground: Theme05Palette.dustyGrape,
  tileForeground: Theme05Palette.deepWalnut,
  tileBorderColor: Theme05Palette.dustyGrape,
  tileBorderWidth: 2.0,
  tileBorderRadius: 8.0,
  // Round answer tile
  roundAnswerTileBackground: Theme05Palette.dustyGrape,
  roundAnswerTileBorderColor: Theme05Palette.dustyGrape,
  roundAnswerTileBorderWidth: 2.0,
  roundAnswerTileCorrectColor: Theme05Palette.deepWalnut,
  roundAnswerTileWrongColor: Theme05Colors.danger,
  // Deck icon
  deckIconColor: Theme05Palette.deepWalnut,
  deckIconBackground: Theme05Palette.spaceIndigo,
  deckIconBorderRadius: 8.0,
  // Dash
  dashCardBackground: Theme05Palette.dustyGrape,
  dashCardBorderColor: Theme05Palette.dustyGrape,
  dashCardBorderRadius: 8.0,
  dashCardBorderWidth: 2.0,
  // ListItem
  listItemBorderColor: Theme05Palette.twilightIndigo,
  listItemBorderRadius: 8.0,
  listItemBorderWidth: 2.0,
  // Badge
  badgeBorderRadius: 4.0,
  badgeBorderWidth: 1.5,
  // Tag
  tag1Bg: Theme05Colors.tag1,
  tag1BorderColor: Theme05Colors.tag1,
  tag1TextColor: Theme05Palette.deepWalnut,
  tag2Bg: Theme05Colors.tag2,
  tag2BorderColor: Theme05Colors.tag2,
  tag2TextColor: Theme05Palette.deepWalnut,
  tag3Bg: Theme05Colors.tag3,
  tag3BorderColor: Theme05Colors.tag3,
  tag3TextColor: Theme05Palette.deepWalnut,
  tag4Bg: Theme05Colors.tag4,
  tag4BorderColor: Theme05Colors.tag4,
  tag4TextColor: Theme05Palette.deepWalnut,
  tag5Bg: Theme05Colors.tag5,
  tag5BorderColor: Theme05Colors.tag5,
  tag5TextColor: Theme05Palette.oldlace,
  tagBorderRadius: 8.0,
  tagBorderWidth: 1.0,
  tagChipBorder: Theme05Palette.deepWalnut,
  tagColor1: Theme05Colors.tag1,
  tagColor2: Theme05Colors.tag2,
  tagColor3: Theme05Colors.tag3,
  tagColor4: Theme05Colors.tag4,
  tagColor5: Theme05Colors.tag5,
  tagNoneBg: Colors.transparent,
  tagNoneBorderColor: Theme05Palette.deepWalnut,
  tagNoneTextColor: Theme05Palette.deepWalnut,
  // Test badge
  testBadgeBackground: Theme05Palette.deepWalnut,
  testBadgePercentage: Theme05Palette.spaceIndigo,
  testBadgeDateRecent: Theme05Palette.greyLight,
  testBadgeDateStale: Theme05Palette.spaceIndigo,
  testBadgeDateOld: Theme05Palette.burntPeach,
  // Retention
  retentionNone: Color(0xFF78909C),
  retentionWeak: Color(0xFFFFCC80),
  retentionGood: Color(0xFFA5D6A7),
  retentionStrong: Color(0xFF81C784),
  retentionSuper: Color(0xFF66BB6A),
  retentionText: Theme05Palette.spaceIndigo,
  // Shadow
  componentShadow: null,
  appBarShadow: null,
  navbarShadow: null,
  // Snackbar
  snackbarBackground: Theme05Palette.deepWalnut,
  snackbarTextColor: Theme05Palette.oldlace,
  snackbarBorderRadius: 8.0,
  // Note accent
  noteAccentBackground: Theme05Palette.deepWalnut,
  noteAccentBorderColor: Theme05Palette.deepWalnut,
  noteAccentTextColor: Theme05Palette.oldlace,
  // Mode tile
  modeTileBackground: Theme05Palette.dustyGrape,
  modeTileForeground: Theme05Palette.deepWalnut,
  modeTileBorderColor: Theme05Palette.dustyGrape,
  modeTileAccentBackground: Theme05Palette.deepWalnut,
  modeTileAccentForeground: Theme05Palette.spaceIndigo,
  modeTileAccentBorderColor: Theme05Palette.deepWalnut,
);

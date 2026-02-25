import 'package:flutter/material.dart';
import '../app_themes.dart';

// ==========================================================================
// RAW PALETTE
// ==========================================================================
class Candidate08Palette {
  Candidate08Palette._();

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
class Candidate08Colors {
  Candidate08Colors._();

  static const Color glass = Candidate08Palette.spaceIndigo50;
  static const Color glassScrim = Candidate08Palette.spaceIndigo50;
  static const Color danger = Candidate08Palette.burntPeach;
  static const Color tag1 = Candidate08Palette.deepWalnut;
  static const Color tag2 = Candidate08Palette.deepWalnut;
  static const Color tag3 = Candidate08Palette.deepWalnut;
  static const Color tag4 = Candidate08Palette.deepWalnut;
  static const Color tag5 = Candidate08Palette.deepWalnut;
}

const AppThemeData candidate08Theme = AppThemeData(
  themeType: AppTheme.candidate08,
  // Scaffold
  scaffoldBackground: Candidate08Palette.twilightIndigo,
  // Display
  displayBackground: Candidate08Palette.twilightIndigo,
  displayBorderRadius: 12.0,
  // AppBar
  appBarBackground: Candidate08Palette.spaceIndigo,
  appBarForeground: Candidate08Palette.deepWalnut,
  appBarBorderColor: Candidate08Palette.black,
  appBarBorderWidth: 2,
  appBarIconColor: Candidate08Palette.deepWalnut,
  appBarTitleColor: Candidate08Palette.deepWalnut,
  // Navbar
  navbarBackground: Candidate08Palette.spaceIndigo,
  navbarBorderColor: Candidate08Palette.black,
  navbarBorderWidth: 2.0,
  navbarIconColor: Candidate08Palette.deepWalnut,
  navbarDisabledIconColor: Candidate08Palette.deepWalnutA40,
  // Fab
  fabBackground: Candidate08Palette.twilightIndigo,
  fabBorderColor: Candidate08Palette.black,
  fabTextColor: Candidate08Palette.black,
  fabBorderWidth: 2,
  confirmFabBackground: Candidate08Palette.deepWalnut,
  confirmFabForeground: Candidate08Palette.oldlace,
  confirmFabBorderColor: Candidate08Palette.deepWalnut,
  // Text
  textPrimary: Candidate08Palette.deepWalnut,
  textSecondary: Candidate08Palette.deepWalnutA80,
  // Accent
  accentColor: Candidate08Palette.deepWalnut,
  accentColorText: Candidate08Palette.oldlace,
  // Danger
  dangerColor: Candidate08Colors.danger,
  dangerColorText: Candidate08Palette.oldlace,
  // BottomSheet
  bottomSheetBackground: Candidate08Colors.glass,
  bottomSheetBorderColor: Candidate08Palette.porcleain50,
  bottomSheetScrimColor: Candidate08Colors.glassScrim,
  bottomSheetBorderRadius: 12.0,
  bottomSheetBorderWidth: 2.0,
  bottomSheetBlurSigma: 10.0,
  bottomSheetPadding: 16.0,
  // Modal
  modalBorderRadius: 8.0,
  // Control
  controlAccentBackground: Candidate08Palette.deepWalnut,
  controlAccentForeground: Candidate08Palette.spaceIndigo,
  controlBackground: Candidate08Palette.spaceIndigo,
  controlBorder: Candidate08Palette.spaceIndigo,
  controlForeground: Candidate08Palette.deepWalnut,
  controlDangerBackground: Candidate08Colors.danger,
  controlDangerForeground: Candidate08Palette.oldlace,
  controlBorderRadius: 8.0,
  controlBorderWidth: 2.0,
  // Toggle
  toggleBorderRadius: 4.0,
  disabledOpacity: 0.4,
  // Divider
  dividerColor: Candidate08Palette.deepWalnutA40,
  dividerWidth: 1.0,
  // Button
  buttonBorderRadius: 8.0,
  buttonBorderWidth: 2.0,
  // Note
  noteBackground: Candidate08Palette.spaceIndigo,
  noteBorderColor: Candidate08Palette.spaceIndigo,
  noteBorderRadius: 8.0,
  noteBorderWidth: 1.0,
  noteTextColor: Candidate08Palette.deepWalnutA80,
  // Card
  cardBackground: Candidate08Palette.dustyGrape,
  cardBorderColor: Candidate08Palette.dustyGrape,
  cardBorderRadius: 8.0,
  cardBorderWidth: 2.0,
  // Dash
  dashCardBackground: Candidate08Palette.dustyGrape,
  dashCardBorderColor: Candidate08Palette.dustyGrape,
  dashCardBorderRadius: 8.0,
  dashCardBorderWidth: 2.0,
  // ListItem
  listItemBorderColor: Candidate08Palette.twilightIndigo,
  listItemBorderRadius: 8.0,
  listItemBorderWidth: 2.0,
  // Badge
  badgeBorderRadius: 4.0,
  badgeBorderWidth: 1.5,
  // Tag
  tag1Bg: Candidate08Colors.tag1,
  tag1BorderColor: Candidate08Colors.tag1,
  tag1TextColor: Candidate08Palette.deepWalnut,
  tag2Bg: Candidate08Colors.tag2,
  tag2BorderColor: Candidate08Colors.tag2,
  tag2TextColor: Candidate08Palette.deepWalnut,
  tag3Bg: Candidate08Colors.tag3,
  tag3BorderColor: Candidate08Colors.tag3,
  tag3TextColor: Candidate08Palette.deepWalnut,
  tag4Bg: Candidate08Colors.tag4,
  tag4BorderColor: Candidate08Colors.tag4,
  tag4TextColor: Candidate08Palette.deepWalnut,
  tag5Bg: Candidate08Colors.tag5,
  tag5BorderColor: Candidate08Colors.tag5,
  tag5TextColor: Candidate08Palette.oldlace,
  tagBorderRadius: 8.0,
  tagBorderWidth: 1.0,
  tagChipBorder: Candidate08Palette.deepWalnut,
  tagColor1: Candidate08Colors.tag1,
  tagColor2: Candidate08Colors.tag2,
  tagColor3: Candidate08Colors.tag3,
  tagColor4: Candidate08Colors.tag4,
  tagColor5: Candidate08Colors.tag5,
  tagNoneBg: Colors.transparent,
  tagNoneBorderColor: Candidate08Palette.deepWalnut,
  tagNoneTextColor: Candidate08Palette.deepWalnut,
  // Test badge
  testBadgeBackground: Candidate08Palette.deepWalnut,
  testBadgePercentage: Candidate08Palette.spaceIndigo,
  testBadgeDateRecent: Candidate08Palette.greyLight,
  testBadgeDateStale: Candidate08Palette.spaceIndigo,
  testBadgeDateOld: Candidate08Palette.burntPeach,
  // Retention
  retentionNone: Color(0xFF78909C),
  retentionWeak: Color(0xFFFFCC80),
  retentionGood: Color(0xFFA5D6A7),
  retentionStrong: Color(0xFF81C784),
  retentionSuper: Color(0xFF66BB6A),
  retentionText: Candidate08Palette.spaceIndigo,
  // Shadow
  componentShadow: null,
  appBarShadow: null,
  navbarShadow: null,
  // Snackbar
  snackbarBackground: Candidate08Palette.deepWalnut,
  snackbarTextColor: Candidate08Palette.oldlace,
  snackbarBorderRadius: 8.0,
);

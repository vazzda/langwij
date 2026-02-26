import 'package:flutter/material.dart';
import '../app_themes.dart';

// ==========================================================================
// RAW PALETTE
// ==========================================================================
class Candidate07Palette {
  Candidate07Palette._();

  static const Color porcleain = Color(0xFFFCFBF7);
  static const Color oldlace = Color(0xFFEBE9E6);

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
class Candidate07Colors {
  Candidate07Colors._();

  static const Color glass = Candidate07Palette.lightCoral25;
  static const Color glassScrim = Candidate07Palette.heavyBronze50;
  static const Color danger = Candidate07Palette.lightCoral;
  static const Color tag1 = Candidate07Palette.deepWalnut;
  static const Color tag2 = Candidate07Palette.deepWalnut;
  static const Color tag3 = Candidate07Palette.deepWalnut;
  static const Color tag4 = Candidate07Palette.deepWalnut;
  static const Color tag5 = Candidate07Palette.deepWalnut;
}

const AppThemeData candidate07Theme = AppThemeData(
  themeType: AppTheme.candidate07,
  // Scaffold
  scaffoldBackground: Candidate07Palette.porcleain,
  // Display
  displayBackground: Candidate07Palette.porcleain,
  displayBorderRadius: 12.0,
  // AppBar
  appBarBackground: Candidate07Palette.porcleain,
  appBarForeground: Candidate07Palette.deepWalnut,
  appBarBorderColor: Candidate07Palette.deepWalnut,
  appBarBorderWidth: 2,
  appBarIconColor: Candidate07Palette.deepWalnut,
  appBarTitleColor: Candidate07Palette.deepWalnut,
  // Navbar
  navbarBackground: Candidate07Palette.porcleain,
  navbarBorderColor: Candidate07Palette.deepWalnut,
  navbarBorderWidth: 2.0,
  navbarIconColor: Candidate07Palette.deepWalnut,
  navbarDisabledIconColor: Candidate07Palette.deepWalnutA40,
  // Fab
  fabBackground: Candidate07Palette.oldlace,
  fabBorderColor: Candidate07Palette.deepWalnut,
  fabTextColor: Candidate07Palette.deepWalnut,
  fabBorderWidth: 2,
  confirmFabBackground: Candidate07Palette.deepWalnut,
  confirmFabForeground: Candidate07Palette.oldlace,
  confirmFabBorderColor: Candidate07Palette.deepWalnut,
  // Text
  textPrimary: Candidate07Palette.deepWalnut,
  textSecondary: Candidate07Palette.deepWalnutA80,
  // Accent
  accentColor: Candidate07Palette.deepWalnut,
  accentColorText: Candidate07Palette.oldlace,
  // Danger
  dangerColor: Candidate07Colors.danger,
  dangerColorText: Candidate07Palette.oldlace,
  // BottomSheet
  bottomSheetBackground: Candidate07Colors.glass,
  bottomSheetBorderColor: Candidate07Palette.deepWalnut,
  bottomSheetScrimColor: Candidate07Colors.glassScrim,
  bottomSheetBorderRadius: 12.0,
  bottomSheetBorderWidth: 2.0,
  bottomSheetBlurSigma: 10.0,
  bottomSheetPadding: 16.0,
  // Modal
  modalBorderRadius: 8.0,
  // Control
  controlAccentBackground: Candidate07Palette.deepWalnut,
  controlAccentForeground: Candidate07Palette.oldlace,
  controlBackground: Candidate07Palette.oldlace,
  controlBorder: Candidate07Palette.oldlace,
  controlDangerBackground: Candidate07Colors.danger,
  controlDangerForeground: Candidate07Palette.oldlace,
  controlForeground: Candidate07Palette.deepWalnut,
  controlBorderRadius: 8.0,
  controlBorderWidth: 2.0,
  // Toggle
  toggleBorderRadius: 4.0,
  disabledOpacity: 0.4,
  // Divider
  dividerColor: Candidate07Palette.deepWalnutA40,
  dividerWidth: 1.0,
  // Progress bar
  progressBarFilled: Candidate07Palette.deepWalnut,
  progressBarUnfilled: Candidate07Palette.deepWalnutA12,
  progressBarBorderRadius: 4.0,
  progressBarCompactHeight: 6.0,
  progressBarDetailedHeight: 8.0,
  // Button
  buttonBorderRadius: 8.0,
  buttonBorderWidth: 2.0,
  // Note
  noteBackground: Candidate07Palette.oldlace,
  noteBorderColor: Candidate07Palette.oldlace,
  noteBorderRadius: 8.0,
  noteBorderWidth: 1.0,
  noteTextColor: Candidate07Palette.deepWalnutA80,
  // Card
  cardBackground: Candidate07Palette.oldlace,
  cardBorderColor: Candidate07Palette.oldlace,
  cardBorderRadius: 8.0,
  cardBorderWidth: 2.0,
  // Tile
  tileBackground: Candidate07Palette.oldlace,
  tileForeground: Candidate07Palette.deepWalnut,
  tileBorderColor: Candidate07Palette.oldlace,
  tileBorderWidth: 2.0,
  tileBorderRadius: 8.0,
  // Dash
  dashCardBackground: Candidate07Palette.oldlace,
  dashCardBorderColor: Candidate07Palette.oldlace,
  dashCardBorderRadius: 8.0,
  dashCardBorderWidth: 2.0,
  // ListItem
  listItemBorderColor: Candidate07Palette.oldlace,
  listItemBorderRadius: 8.0,
  listItemBorderWidth: 2.0,
  // Badge
  badgeBorderRadius: 4.0,
  badgeBorderWidth: 1.5,
  // Tag
  tag1Bg: Candidate07Colors.tag1,
  tag1BorderColor: Candidate07Colors.tag1,
  tag1TextColor: Candidate07Palette.deepWalnut,
  tag2Bg: Candidate07Colors.tag2,
  tag2BorderColor: Candidate07Colors.tag2,
  tag2TextColor: Candidate07Palette.deepWalnut,
  tag3Bg: Candidate07Colors.tag3,
  tag3BorderColor: Candidate07Colors.tag3,
  tag3TextColor: Candidate07Palette.deepWalnut,
  tag4Bg: Candidate07Colors.tag4,
  tag4BorderColor: Candidate07Colors.tag4,
  tag4TextColor: Candidate07Palette.deepWalnut,
  tag5Bg: Candidate07Colors.tag5,
  tag5BorderColor: Candidate07Colors.tag5,
  tag5TextColor: Candidate07Palette.oldlace,
  tagBorderRadius: 8.0,
  tagBorderWidth: 1.0,
  tagChipBorder: Candidate07Palette.deepWalnut,
  tagColor1: Candidate07Colors.tag1,
  tagColor2: Candidate07Colors.tag2,
  tagColor3: Candidate07Colors.tag3,
  tagColor4: Candidate07Colors.tag4,
  tagColor5: Candidate07Colors.tag5,
  tagNoneBg: Colors.transparent,
  tagNoneBorderColor: Candidate07Palette.deepWalnut,
  tagNoneTextColor: Candidate07Palette.deepWalnut,
  // Test badge
  testBadgeBackground: Candidate07Palette.deepWalnut,
  testBadgePercentage: Candidate07Palette.oldlace,
  testBadgeDateRecent: Candidate07Palette.greyLight,
  testBadgeDateStale: Candidate07Palette.oldlace,
  testBadgeDateOld: Candidate07Palette.lightCoral,
  // Retention
  retentionNone: Color(0xFFBDBDBD),
  retentionWeak: Color(0xFFFFCC80),
  retentionGood: Color(0xFFA5D6A7),
  retentionStrong: Color(0xFF81C784),
  retentionSuper: Color(0xFF66BB6A),
  retentionText: Candidate07Palette.porcleain,
  // Shadow
  componentShadow: null,
  appBarShadow: null,
  navbarShadow: null,
  // Snackbar
  snackbarBackground: Candidate07Palette.deepWalnut,
  snackbarTextColor: Candidate07Palette.oldlace,
  snackbarBorderRadius: 8.0,
);

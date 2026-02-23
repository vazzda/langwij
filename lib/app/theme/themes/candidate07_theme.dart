import 'package:flutter/material.dart';
import '../app_themes.dart';

class Candidate07Palette {
  Candidate07Palette._();
  static const Color porcleain = Color(0xFFFCFBF7);
  static const Color oldlace = Color(0xFFEBE9E6);
  static const Color deepWalnut = Color(0xFF3D405D);
  static const Color deepWalnutA80 = Color(0x803D405D);
  static const Color deepWalnutA40 = Color(0x403D405D);
  static const Color deepWalnutA12 = Color(0x103D405D);
  static const Color lightCoral = Color(0xFFE07A5F);
  static const Color lightCoral25 = Color(0x25E07A5F);
  static const Color heavyBronze50 = Color(0x50F2CC8F);
}

const AppThemeData candidate07Theme = AppThemeData(
  themeType: AppTheme.candidate07,
  scaffoldBackground: Candidate07Palette.porcleain,
  appBarBackground: Candidate07Palette.porcleain,
  appBarBorderColor: Candidate07Palette.deepWalnut,
  appBarBorderWidth: 2.0,
  appBarForeground: Candidate07Palette.deepWalnut,
  appBarTitleColor: Candidate07Palette.deepWalnut,
  navbarBackground: Candidate07Palette.porcleain,
  navbarBorderColor: Candidate07Palette.deepWalnut,
  navbarBorderWidth: 2.0,
  navbarIconColor: Candidate07Palette.deepWalnut,
  navbarDisabledIconColor: Candidate07Palette.deepWalnutA40,
  textPrimary: Candidate07Palette.deepWalnut,
  textSecondary: Candidate07Palette.deepWalnutA80,
  accentColor: Candidate07Palette.deepWalnut,
  accentColorText: Candidate07Palette.oldlace,
  dangerColor: Candidate07Palette.lightCoral,
  dangerColorText: Candidate07Palette.oldlace,
  cardBackground: Candidate07Palette.oldlace,
  cardBorderColor: Candidate07Palette.oldlace,
  cardBorderRadius: 8.0,
  cardBorderWidth: 2.0,
  controlAccentBackground: Candidate07Palette.deepWalnut,
  controlAccentForeground: Candidate07Palette.oldlace,
  controlBackground: Candidate07Palette.oldlace,
  controlBorder: Candidate07Palette.oldlace,
  controlBorderRadius: 8.0,
  controlBorderWidth: 2.0,
  controlForeground: Candidate07Palette.deepWalnut,
  buttonBorderRadius: 8.0,
  buttonBorderWidth: 2.0,
  bottomSheetBackground: Candidate07Palette.lightCoral25,
  bottomSheetBorderColor: Candidate07Palette.deepWalnut,
  bottomSheetBorderRadius: 12.0,
  bottomSheetBorderWidth: 2.0,
  bottomSheetScrimColor: Candidate07Palette.heavyBronze50,
  bottomSheetPadding: 16.0,
  dividerColor: Candidate07Palette.deepWalnutA40,
  dividerWidth: 1.0,
  testBadgeBackground: Candidate07Palette.deepWalnut,
  testBadgePercentage: Candidate07Palette.porcleain,
  testBadgeDateRecent: Candidate07Palette.deepWalnutA80,
  testBadgeDateStale: Candidate07Palette.porcleain,
  testBadgeDateOld: Candidate07Palette.lightCoral,
  chipSelectedBackground: Candidate07Palette.oldlace,
  chipSelectedForeground: Candidate07Palette.deepWalnut,
  retentionNone: Color(0xFFBDBDBD),
  retentionWeak: Color(0xFFFFCC80),
  retentionGood: Color(0xFFA5D6A7),
  retentionStrong: Color(0xFF81C784),
  retentionSuper: Color(0xFF66BB6A),
  retentionText: Candidate07Palette.porcleain,
  disabledOpacity: 0.4,
);

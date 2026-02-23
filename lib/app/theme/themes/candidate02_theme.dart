import 'package:flutter/material.dart';
import '../app_themes.dart';

class Candidate02Palette {
  Candidate02Palette._();
  static const Color mintCream = Color(0xFFF1FAEE);
  static const Color darkNavy = Color(0xFF0F1C2E);
  static const Color darkNavyA67 = Color(0xAA0F1C2E);
  static const Color darkNavyA40 = Color(0x660F1C2E);
  static const Color darkNavyA12 = Color(0x200F1C2E);
  static const Color crimsonRed = Color(0xFFE63946);
  static const Color powderTeal = Color(0xFFa8dadc);
  static const Color powderTealA25 = Color(0x40a8dadc);
  static const Color powderTealA50 = Color(0x80a8dadc);
  static const Color greyLight = Color(0xFF9E9E9E);
}

const AppThemeData candidate02Theme = AppThemeData(
  themeType: AppTheme.candidate02,
  scaffoldBackground: Candidate02Palette.powderTeal,
  appBarBackground: Candidate02Palette.mintCream,
  appBarBorderColor: Candidate02Palette.darkNavy,
  appBarBorderWidth: 2.0,
  appBarForeground: Candidate02Palette.darkNavy,
  appBarTitleColor: Candidate02Palette.darkNavy,
  navbarBackground: Candidate02Palette.mintCream,
  navbarBorderColor: Candidate02Palette.darkNavy,
  navbarBorderWidth: 2.0,
  navbarIconColor: Candidate02Palette.darkNavy,
  navbarDisabledIconColor: Candidate02Palette.darkNavyA40,
  textPrimary: Candidate02Palette.darkNavy,
  textSecondary: Candidate02Palette.darkNavyA67,
  accentColor: Candidate02Palette.darkNavy,
  accentColorText: Candidate02Palette.mintCream,
  dangerColor: Candidate02Palette.crimsonRed,
  dangerColorText: Candidate02Palette.mintCream,
  cardBackground: Candidate02Palette.mintCream,
  cardBorderColor: Candidate02Palette.darkNavy,
  cardBorderRadius: 8.0,
  cardBorderWidth: 2.0,
  controlAccentBackground: Candidate02Palette.darkNavy,
  controlAccentForeground: Candidate02Palette.mintCream,
  controlBackground: Candidate02Palette.mintCream,
  controlBorder: Candidate02Palette.darkNavy,
  controlBorderRadius: 8.0,
  controlBorderWidth: 2.0,
  controlForeground: Candidate02Palette.darkNavy,
  buttonBorderRadius: 8.0,
  buttonBorderWidth: 2.0,
  bottomSheetBackground: Candidate02Palette.powderTealA25,
  bottomSheetBorderColor: Candidate02Palette.darkNavy,
  bottomSheetBorderRadius: 12.0,
  bottomSheetBorderWidth: 2.0,
  bottomSheetScrimColor: Candidate02Palette.powderTealA50,
  bottomSheetPadding: 16.0,
  dividerColor: Candidate02Palette.darkNavyA12,
  dividerWidth: 1.0,
  testBadgeBackground: Candidate02Palette.darkNavy,
  testBadgePercentage: Candidate02Palette.mintCream,
  testBadgeDateRecent: Candidate02Palette.darkNavyA67,
  testBadgeDateStale: Candidate02Palette.mintCream,
  testBadgeDateOld: Candidate02Palette.crimsonRed,
  chipSelectedBackground: Candidate02Palette.powderTeal,
  chipSelectedForeground: Candidate02Palette.darkNavy,
  retentionNone: Color(0xFFBDBDBD),
  retentionWeak: Color(0xFFFFCC80),
  retentionGood: Color(0xFFA5D6A7),
  retentionStrong: Color(0xFF81C784),
  retentionSuper: Color(0xFF66BB6A),
  retentionText: Candidate02Palette.mintCream,
  disabledOpacity: 0.4,
);

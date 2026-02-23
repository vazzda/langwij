import 'package:flutter/material.dart';
import '../app_themes.dart';

class Candidate01Palette {
  Candidate01Palette._();
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color platinum = Color(0xFFF4F5F6);
  static const Color pureBlack = Color(0xFF000000);
  static const Color pureBlackA67 = Color(0xAA000000);
  static const Color pureBlackA50 = Color(0x80000000);
  static const Color pureBlackA40 = Color(0x66000000);
  static const Color pureBlackA12 = Color(0x20000000);
  static const Color gunMetal = Color(0xFF373D43);
  static const Color crimsonRed = Color(0xFFE63946);
  static const Color greyLight = Color(0xFF9E9E9E);
}

const AppThemeData candidate01Theme = AppThemeData(
  themeType: AppTheme.candidate01,
  scaffoldBackground: Candidate01Palette.platinum,
  appBarBackground: Candidate01Palette.platinum,
  appBarBorderColor: Candidate01Palette.gunMetal,
  appBarBorderWidth: 2.0,
  appBarForeground: Candidate01Palette.gunMetal,
  appBarTitleColor: Candidate01Palette.gunMetal,
  navbarBackground: Candidate01Palette.pureWhite,
  navbarBorderColor: Candidate01Palette.gunMetal,
  navbarBorderWidth: 2.0,
  navbarIconColor: Candidate01Palette.gunMetal,
  navbarDisabledIconColor: Candidate01Palette.pureBlackA40,
  textPrimary: Candidate01Palette.gunMetal,
  textSecondary: Candidate01Palette.pureBlackA67,
  accentColor: Candidate01Palette.gunMetal,
  accentColorText: Candidate01Palette.platinum,
  dangerColor: Candidate01Palette.crimsonRed,
  dangerColorText: Candidate01Palette.platinum,
  cardBackground: Candidate01Palette.pureWhite,
  cardBorderColor: Candidate01Palette.gunMetal,
  cardBorderRadius: 4.0,
  cardBorderWidth: 2.0,
  controlAccentBackground: Candidate01Palette.gunMetal,
  controlAccentForeground: Candidate01Palette.platinum,
  controlBackground: Candidate01Palette.pureWhite,
  controlBorder: Candidate01Palette.gunMetal,
  controlBorderRadius: 4.0,
  controlBorderWidth: 2.0,
  controlForeground: Candidate01Palette.gunMetal,
  buttonBorderRadius: 4.0,
  buttonBorderWidth: 2.0,
  bottomSheetBackground: Candidate01Palette.platinum,
  bottomSheetBorderColor: Candidate01Palette.gunMetal,
  bottomSheetBorderRadius: 12.0,
  bottomSheetBorderWidth: 2.0,
  bottomSheetScrimColor: Candidate01Palette.pureBlackA50,
  bottomSheetPadding: 16.0,
  dividerColor: Candidate01Palette.pureBlackA12,
  dividerWidth: 1.0,
  testBadgeBackground: Candidate01Palette.gunMetal,
  testBadgePercentage: Candidate01Palette.pureWhite,
  testBadgeDateRecent: Candidate01Palette.greyLight,
  testBadgeDateStale: Candidate01Palette.pureWhite,
  testBadgeDateOld: Candidate01Palette.crimsonRed,
  chipSelectedBackground: Candidate01Palette.pureWhite,
  chipSelectedForeground: Candidate01Palette.gunMetal,
  retentionNone: Color(0xFFBDBDBD),
  retentionWeak: Color(0xFFFFCC80),
  retentionGood: Color(0xFFA5D6A7),
  retentionStrong: Color(0xFF81C784),
  retentionSuper: Color(0xFF66BB6A),
  retentionText: Candidate01Palette.pureWhite,
  disabledOpacity: 0.4,
);

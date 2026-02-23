import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFontStyles {
  AppFontStyles._();

  // ---------------------------------------------------------------------------
  // GLOBAL FONT STYLES (PRIVATE)
  // ---------------------------------------------------------------------------

  // Body styles — Roboto Mono
  static TextStyle get _bodyXs =>
      GoogleFonts.robotoMono(fontSize: 9, fontWeight: FontWeight.normal);
  static TextStyle get _bodyS =>
      GoogleFonts.robotoMono(fontSize: 12, fontWeight: FontWeight.normal);
  static TextStyle get _bodySAccented =>
      GoogleFonts.robotoMono(fontSize: 12, fontWeight: FontWeight.bold);
  static TextStyle get _bodyM =>
      GoogleFonts.robotoMono(fontSize: 14, fontWeight: FontWeight.normal);
  static TextStyle get _bodyMAccented =>
      GoogleFonts.robotoMono(fontSize: 14, fontWeight: FontWeight.bold);
  static TextStyle get _bodyL =>
      GoogleFonts.robotoMono(fontSize: 16, fontWeight: FontWeight.normal);
  static TextStyle get _bodyLAccented =>
      GoogleFonts.robotoMono(fontSize: 16, fontWeight: FontWeight.bold);

  // Header styles — Big Shoulders Display
  static TextStyle get _headerS =>
      GoogleFonts.bigShouldersDisplay(fontSize: 14, fontWeight: FontWeight.w600);
  static TextStyle get _headerM =>
      GoogleFonts.bigShouldersDisplay(fontSize: 16, fontWeight: FontWeight.w600);
  static TextStyle get _headerL =>
      GoogleFonts.bigShouldersDisplay(fontSize: 20, fontWeight: FontWeight.w600);
  static TextStyle get _headerXl =>
      GoogleFonts.bigShouldersDisplay(fontSize: 24, fontWeight: FontWeight.w600);
  static TextStyle get _headerXxl =>
      GoogleFonts.bigShouldersDisplay(fontSize: 28, fontWeight: FontWeight.w600);

  // ---------------------------------------------------------------------------
  // PRODUCT-LEVEL TEXT STYLES
  // ---------------------------------------------------------------------------

  // Titles & Headings
  static TextStyle get textTitle => _headerXxl;
  static TextStyle get textSubtitle => _headerXl;
  static TextStyle get textSectionHeader => _headerL;
  static TextStyle get textContentHeader => _headerM;

  // Sheet styles
  static TextStyle get textSheetTitle => _headerL;
  static TextStyle get textSheetSubtitle => _bodyM;
  static TextStyle get textSheetContent => _bodyM;
  static TextStyle get textSheetAction => _bodyLAccented;

  // Form styles
  static TextStyle get textFormLabel => _bodyM;
  static TextStyle get textFormInput => _bodyM;
  static TextStyle get textFormHint => _bodyM;
  static TextStyle get textFormError => _bodyS;

  // List item styles
  static TextStyle get textListItem => _bodyM;
  static TextStyle get textListItemAccented => _bodyMAccented;

  // Control styles
  static TextStyle get textControlLabel => _bodySAccented;
  static TextStyle get textControlInput => _bodyMAccented;
  static TextStyle get textControlHint => _bodyM;
  static TextStyle get textButton => _bodyLAccented;
  static TextStyle get textButtonSmall => _bodyMAccented;

  // Body & Caption
  static TextStyle get textCaption => _bodyS;
  static TextStyle get textBody => _bodyM;
  static TextStyle get textBodyAccent => _bodyMAccented;
  static TextStyle get textBodyLarge => _bodyL;
  static TextStyle get textBodyLargeAccented => _bodyLAccented;

  // Tile styles
  static TextStyle get textTileHeader => _headerM;
  static TextStyle get textTileContent => _bodySAccented;

  // Badge styles
  static TextStyle get textBadgePercentage => _bodyMAccented;
  static TextStyle get textBadgeDate => _bodyXs;

  // Prompt (quiz card)
  static TextStyle get textPrompt => _headerXxl;

  // Score
  static TextStyle get textScore => _headerS;
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VesselFonts {
  VesselFonts._();

  /// Font family used for headers and display text.
  static const headerFontFamily = 'IosevkaCustom3';

  // ---------------------------------------------------------------------------
  // GLOBAL FONT STYLES (PRIVATE)
  // ---------------------------------------------------------------------------

  // Body styles — Montserrat
  static TextStyle get _bodyXs =>
      GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.normal);
  static TextStyle get _bodyXsAccented =>
      GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.bold);
  static TextStyle get _bodyS =>
      GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.normal);
  static TextStyle get _bodySAccented =>
      GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold);
  static TextStyle get _bodyM =>
      GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.normal);
  static TextStyle get _bodyMAccented =>
      GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold);
  static TextStyle get _bodyL =>
      GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.normal);
  static TextStyle get _bodyLAccented =>
      GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold);

  // Header styles — IosevkaCustom3
  static const TextStyle _headerXs = TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle _headerS = TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle _headerM = TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w900,
  );
  static const TextStyle _headerL = TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle _headerXl = TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle _headerXxl = TextStyle(
    fontFamily: headerFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
  );

  // ---------------------------------------------------------------------------
  // PRODUCT-LEVEL TEXT STYLES
  // ---------------------------------------------------------------------------

  // Titles & Headings
  static TextStyle get textTitle => _headerXxl;
  static TextStyle get textAppBarTitle => _headerL;
  static TextStyle get textSubtitle => _headerXl;
  static TextStyle get textSectionHeader => _headerL;
  static TextStyle get textContentHeader => _headerXl;

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
  static TextStyle get textButtonLarge => _headerL;

  // Note styles
  static TextStyle get textNote => _bodyM;

  // Body & Caption
  static TextStyle get textCaption => _bodyS;
  static TextStyle get textBody => _bodyM;
  static TextStyle get textBodyAccent => _bodyMAccented;
  static TextStyle get textBodyLarge => _bodyL;
  static TextStyle get textBodyLargeAccented => _bodyLAccented;

  // Tile styles
  static TextStyle get textTileHeader => _headerM;
  static TextStyle get textTileContent => _bodyS;
  static TextStyle get textTileCounter => _bodySAccented;

  // Level styles
  static TextStyle get textLevelHeader => _headerXxl;
  static TextStyle get textLevelCounter => _bodyMAccented;

  // Progress bar
  static TextStyle get textProgressPercentage => _bodyXsAccented;

  // Badge styles
  static TextStyle get textBadgePercentage => _bodyMAccented;
  static TextStyle get textBadgeDate => _bodyXs;
  static TextStyle get textProgressChip => _bodyXsAccented;

  // Prompt (quiz card)
  static TextStyle get textPrompt => _headerXxl;

  // Tag styles
  static TextStyle get textVesselTagChip => _bodySAccented;
  static TextStyle get textTagIcon => _bodyXs;

  // Snackbar styles
  static TextStyle get textSnackbar => _bodyM;

  // Score
  static TextStyle get textScore => _headerS;

  // Quality block (language screen)
  static TextStyle get textQualityPrimary => _bodySAccented;
  static TextStyle get textQualitySecondary => _bodyS;

  // Lang picker
  static TextStyle get textLangPickerLabel => _headerL;
  static TextStyle get textLangPickerValue => _bodyLAccented;

  // Mode tile (quiz mode selection sheet)
  static TextStyle get textModeTileSectionHeader => _headerM;
  static TextStyle get textModeTileLabel => _bodyMAccented;
}

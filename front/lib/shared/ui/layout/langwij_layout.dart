/// Langwij-app layout constants for product-specific dimensions that don't
/// belong in flessel (too app-specific or no flessel equivalent).
class LangwijLayout {
  LangwijLayout._();

  // Quiz mode/count tile dimensions
  static const double modeTileIconSize = 45.0;
  static const double modeTileFlagWidth = 45.0;
  static const double modeTileFlagHeight = 28.0;
  static const double modeTileFlagBorderRadius = 4.0;
  static const double quizSheetMinHeight = 360.0;

  // Vocab tile (LangwijVocabDeckTile)
  static const double vocabTileHeight = 180.0;
  static const double vocabTileMinWidth = 120.0;
  static const double vocabTileIconSize = 40.0;
  static const double vocabTileIconTopOffset = -2.0;
  static const double vocabTileHeaderTop = 49.0;
  static const double vocabTileHeaderLeft = 8.0;
  static const double vocabTileHeaderRight = 8.0;
  static const double vocabTileHeaderGap = 10.0;
  static const double vocabTileHeaderRowGap = 2.0;
  static const double vocabTileNameTop = 8.0;
  static const double vocabTileNameLeft = 10.0;
  static const double vocabTileNameRight = 8.0;
  static const double vocabTileWordsTop = 116.0;
  static const double vocabTileWordsLeft = 8.0;
  static const double vocabTileWordsRight = 8.0;
  static const double vocabTileProgressPercentGap = 4.0;
  static const double vocabTileProgressPercentWidth = 30.0;

  // Vocab level card (LangwijVocabLevelCard)
  static const double vocabProgressSpacingAfter = 18.0;
  static const double vocabProgressWordsWidth = 30.0;
  static const double vocabProgressPercentWidth = 30.0;

  // Round screen
  static const double roundOptionTileAspectRatio = 1.8;

  // Result screen
  static const double resultEntryPaddingV = 12.0;
  static const double resultEntryPaddingH = 16.0;

  // Language screen — flag/progression sizing
  static const double langFlagWidth = 64.0;
  static const double langFlagHeight = 44.0;
  static const double langProgressLabelWidth = 72.0;
  static const double langProgressPercentWidth = 36.0;
  static const double langProgressionFlagWidth = 24.0;
  static const double langProgressionFlagHeight = 16.0;
  static const double langArrowZoneWidth = 36.0;
  static const double langBoxPaddingLeft = 12.0;
  static const double langBoxPaddingTop = 14.0;
  static const double langBoxPaddingRight = 12.0;
  static const double langBoxPaddingBottom = 8.0;
  static const double langPickerQualitySegmentWidth = 56.0;

  // Deck icon
  static const double deckIconPadding = 8.0;
}

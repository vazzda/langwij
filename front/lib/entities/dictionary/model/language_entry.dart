class LanguageEntry {
  const LanguageEntry({
    required this.code,
    required this.labelKey,
    required this.humanVerified,
    required this.isAiGenerated,
    this.nativeNote,
  });

  final String code;
  final String labelKey;
  final int humanVerified;

  /// Whether the language is listed among the AI generated ones, apart from
  /// the languages offered without that warning.
  final bool isAiGenerated;
  final String? nativeNote;
}

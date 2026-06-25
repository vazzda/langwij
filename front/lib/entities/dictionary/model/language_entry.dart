class LanguageEntry {
  const LanguageEntry({
    required this.code,
    required this.labelKey,
    required this.humanVerified,
    this.nativeNote,
  });

  final String code;
  final String labelKey;
  final int humanVerified;
  final String? nativeNote;
}

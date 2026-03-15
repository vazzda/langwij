/// A language declared in plan.json — code + ARB label key + optional metadata.
class LanguageEntry {
  const LanguageEntry({
    required this.code,
    required this.labelKey,
    required this.humanVerified,
    this.nativeNote,
  });

  /// ISO-ish language code: "en", "sr", "ru".
  final String code;

  /// ARB key for the language's display name (e.g., "lang_english").
  final String labelKey;

  /// Percentage of dictionary entries that are human-verified (0–100).
  final int humanVerified;

  /// Optional note shown when this language is selected as native.
  final String? nativeNote;
}

/// A language declared in plan.json — code + ARB label key.
class LanguageEntry {
  const LanguageEntry({required this.code, required this.labelKey});

  /// ISO-ish language code: "en", "sr", "ru".
  final String code;

  /// ARB key for the language's display name (e.g., "lang_english").
  final String labelKey;
}

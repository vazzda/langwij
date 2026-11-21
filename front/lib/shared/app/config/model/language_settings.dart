import 'lang_codes.dart';

class LanguageSettings {
  const LanguageSettings({
    required this.targetLang,
    required this.nativeLang,
  });

  final String targetLang;
  final String nativeLang;

  static const defaultSettings = LanguageSettings(
    targetLang: LangCodes.serbian,
    nativeLang: LangCodes.english,
  );

  LanguageSettings copyWith({
    String? targetLang,
    String? nativeLang,
  }) {
    return LanguageSettings(
      targetLang: targetLang ?? this.targetLang,
      nativeLang: nativeLang ?? this.nativeLang,
    );
  }
}

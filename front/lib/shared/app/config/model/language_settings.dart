import 'lang_codes.dart';

class LanguageSettings {
  const LanguageSettings({
    required this.targetLang,
    required this.nativeLang,
    required this.uiLang,
  });

  final String targetLang;
  final String nativeLang;
  final String uiLang;

  static const defaultSettings = LanguageSettings(
    targetLang: LangCodes.serbian,
    nativeLang: LangCodes.english,
    uiLang: LangCodes.english,
  );

  LanguageSettings copyWith({
    String? targetLang,
    String? nativeLang,
    String? uiLang,
  }) {
    return LanguageSettings(
      targetLang: targetLang ?? this.targetLang,
      nativeLang: nativeLang ?? this.nativeLang,
      uiLang: uiLang ?? this.uiLang,
    );
  }
}

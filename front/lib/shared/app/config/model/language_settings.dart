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

  /// The pair after [pickedLang] is picked as the language spoken. A pair
  /// never holds one language twice: picking the language being learned
  /// moves the language spoken until now to the learned side.
  LanguageSettings withNativeLangPicked(String pickedLang) {
    return LanguageSettings(
      nativeLang: pickedLang,
      targetLang: pickedLang == targetLang ? nativeLang : targetLang,
    );
  }

  /// The pair after [pickedLang] is picked as the language being learned.
  /// A pair never holds one language twice: picking the language spoken
  /// moves the language learned until now to the spoken side.
  LanguageSettings withTargetLangPicked(String pickedLang) {
    return LanguageSettings(
      targetLang: pickedLang,
      nativeLang: pickedLang == nativeLang ? targetLang : nativeLang,
    );
  }

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

import 'package:flutter_test/flutter_test.dart';
import 'package:langwij/shared/app/config/config.dart';

const LanguageSettings _speaksSerbianLearnsEnglish = LanguageSettings(
  nativeLang: LangCodes.serbian,
  targetLang: LangCodes.english,
);

void _expectPair(
  LanguageSettings languagePair, {
  required String nativeLang,
  required String targetLang,
}) {
  expect(
    (nativeLang: languagePair.nativeLang, targetLang: languagePair.targetLang),
    (nativeLang: nativeLang, targetLang: targetLang),
  );
}

void main() {
  group('LanguageSettings.withNativeLangPicked', () {
    test('picking the language being learned swaps the two', () {
      _expectPair(
        _speaksSerbianLearnsEnglish.withNativeLangPicked(LangCodes.english),
        nativeLang: LangCodes.english,
        targetLang: LangCodes.serbian,
      );
    });

    test('picking another language leaves the language being learned', () {
      _expectPair(
        _speaksSerbianLearnsEnglish.withNativeLangPicked(LangCodes.russian),
        nativeLang: LangCodes.russian,
        targetLang: LangCodes.english,
      );
    });

    test('picking the language already spoken leaves the pair', () {
      _expectPair(
        _speaksSerbianLearnsEnglish.withNativeLangPicked(LangCodes.serbian),
        nativeLang: LangCodes.serbian,
        targetLang: LangCodes.english,
      );
    });
  });

  group('LanguageSettings.withTargetLangPicked', () {
    test('picking the language spoken swaps the two', () {
      _expectPair(
        _speaksSerbianLearnsEnglish.withTargetLangPicked(LangCodes.serbian),
        nativeLang: LangCodes.english,
        targetLang: LangCodes.serbian,
      );
    });

    test('picking another language leaves the language spoken', () {
      _expectPair(
        _speaksSerbianLearnsEnglish.withTargetLangPicked(LangCodes.russian),
        nativeLang: LangCodes.serbian,
        targetLang: LangCodes.russian,
      );
    });

    test('picking the language already being learned leaves the pair', () {
      _expectPair(
        _speaksSerbianLearnsEnglish.withTargetLangPicked(LangCodes.english),
        nativeLang: LangCodes.serbian,
        targetLang: LangCodes.english,
      );
    });
  });
}

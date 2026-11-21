// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Serbian (`sr`).
class AppLocalizationsSr extends AppLocalizations {
  AppLocalizationsSr([String locale = 'sr']) : super(locale);

  @override
  String get appTitle => 'Langwij';

  @override
  String get parentAgreement => 'Slaganje u rodu';

  @override
  String get groupWords => 'Osnovni glagoli';

  @override
  String wordsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reči',
      few: '$count reči',
      one: '$count reč',
    );
    return '$_temp0';
  }

  @override
  String vocab_termsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count termina',
      few: '$count termina',
      one: '$count termin',
    );
    return '$_temp0';
  }

  @override
  String get groupEndingsImEAti => '-ATI (IM|E)';

  @override
  String get groupEndingsImEEti => '-ETI (IM|E)';

  @override
  String get groupEndingsImEIti => '-ITI (IM|E)';

  @override
  String get groupEndingsAmAju => '-ATI (AM|AJU)';

  @override
  String get groupEndingsEmUGati => '-GATI (EM|U)';

  @override
  String get groupEndingsEmUHati => '-HATI (EM|U)';

  @override
  String get groupEndingsEmUKati => '-KATI (EM|U)';

  @override
  String get groupEndingsEmUAvati => '-AVATI (EM|U)';

  @override
  String get groupEndingsEmUIvati => '-IVATI (EM|U)';

  @override
  String get groupEndingsEmUOvati => '-OVATI (EM|U)';

  @override
  String get groupEndingsEmUCi => '-ĆI (EM|U)';

  @override
  String get groupEndingsEmEju => '-ETI (EM|EJU)';

  @override
  String get groupIrregular => 'Nepravilni';

  @override
  String get chooseQuestionsCount => 'Koliko termina?';

  @override
  String get questions5 => '5';

  @override
  String get questions10 => '10';

  @override
  String get questions20 => '20';

  @override
  String get cancel => 'Otkaži';

  @override
  String get next => 'Dalje';

  @override
  String get submit => 'Odgovori';

  @override
  String get yourAnswer => 'Tvoj odgovor';

  @override
  String get correct => 'Tačno';

  @override
  String get wrong => 'Netačno';

  @override
  String get resultTitle => 'Rezultat runde';

  @override
  String correctCount(int count) {
    return 'Tačno: $count';
  }

  @override
  String wrongCount(int count) {
    return 'Netačno: $count';
  }

  @override
  String get reviewWrongTitle => 'Promašene kartice';

  @override
  String get reviewWrongSubtitle => 'Kartice sa netačnim odgovorom';

  @override
  String get again => 'Ponovo';

  @override
  String get back => 'Nazad';

  @override
  String get pageNotFound => 'Stranica nije pronađena';

  @override
  String get loadError => 'Učitavanje grupa nije uspelo. Pokušaj ponovo.';

  @override
  String get correctAnswerLabel => 'Tačan odgovor:';

  @override
  String get youWrote => 'Tvoj unos:';

  @override
  String get youPicked => 'Tvoj izbor:';

  @override
  String get emptyAnswer => '(prazno)';

  @override
  String get pronounYouInformal => 'ti (neformalno, jednina)';

  @override
  String get pronounYouFormal => 'vi (formalno, množina)';

  @override
  String questionsLeft(int count) {
    return 'Preostalo: $count';
  }

  @override
  String get exitRound => 'Izađi iz runde';

  @override
  String get exitRoundConfirm => 'Izaći iz runde? Napredak će biti izgubljen.';

  @override
  String get exit => 'Izađi';

  @override
  String get dailyActivityTitle => 'Danas';

  @override
  String get dailyActivityEmpty => 'Danas nema aktivnosti';

  @override
  String get mode_guessingHeader => 'Pogađanje';

  @override
  String get mode_writingHeader => 'Pisanje';

  @override
  String mode_langCards(String language) {
    return 'Kartice: $language';
  }

  @override
  String get mode_training => 'Trening';

  @override
  String get mode_test => 'Test';

  @override
  String get relativeDateToday => 'danas';

  @override
  String get relativeDateYesterday => 'juče';

  @override
  String relativeDateDays(int count) {
    return 'pre $count d';
  }

  @override
  String relativeDateMonths(int count) {
    return 'pre $count mes.';
  }

  @override
  String relativeDateYears(int count) {
    return 'pre $count god.';
  }

  @override
  String questionsAll(int count) {
    return 'SVE ($count)';
  }

  @override
  String get settingsTitle => 'Podešavanja';

  @override
  String get navLanguage => 'Jezik';

  @override
  String get navProgress => 'Napredak';

  @override
  String get navVocabulary => 'Rečnik';

  @override
  String get navSpecialized => 'Specijalizovano';

  @override
  String get navTools => 'Alati';

  @override
  String get navSettings => 'Podešavanja';

  @override
  String get navLabelVocabulary => 'Top1000';

  @override
  String get navLabelSpecialized => 'Posebno';

  @override
  String get navLabelTools => 'Alati';

  @override
  String get navLabelLanguage => 'Jezik';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get lang_english => 'Engleski';

  @override
  String get lang_serbian => 'Srpski';

  @override
  String get lang_russian => 'Ruski';

  @override
  String get lang_italian => 'Italijanski';

  @override
  String get lang_french => 'Francuski';

  @override
  String get lang_spanish => 'Španski';

  @override
  String get lang_portuguese => 'Portugalski';

  @override
  String get lang_german => 'Nemački';

  @override
  String get language_iSpeak => 'Govorim';

  @override
  String get language_iLearn => 'Učim';

  @override
  String language_qualityAi(int aiPct) {
    return '$aiPct% napravio AI';
  }

  @override
  String language_qualityHuman(int humanPct) {
    return '$humanPct% napravili ljudi';
  }

  @override
  String get language_progression => 'Napredovanje';

  @override
  String get language_incompleteDictionaries => 'Nepotpuni rečnici';

  @override
  String language_termsCount(int done, int total) {
    return '$done/$total termina';
  }

  @override
  String get tools_conjugations => 'Konjugacije';

  @override
  String get tools_agreement => 'Slaganje u rodu';

  @override
  String get tools_emptyState => 'Za ovaj jezik nema alata';

  @override
  String get settingsHide => 'Sakrij';

  @override
  String get settingsDeveloper => 'Programer';

  @override
  String get dev_enterPassword => 'Zdravo';

  @override
  String get dev_unlock => 'Otključaj';

  @override
  String get dev_wrongPassword => 'Jok!';

  @override
  String get quiz_aspectImperfective => 'Nesvršeni vid:';

  @override
  String get quiz_aspectPerfective => 'Svršeni vid:';

  @override
  String get quiz_aspectPairPrompt => 'Unesi oba vidska oblika';

  @override
  String get vocab_train => 'Vežbaj';

  @override
  String get vocab_studied => 'Naučeno';

  @override
  String get vocab_trained => 'Uvežbano';

  @override
  String get vocab_lastTrained => 'poslednji trening:';

  @override
  String get vocab_termsLabel => 'termina:';

  @override
  String get vocab_masteryLabel => 'savladanost:';

  @override
  String vocab_masteryCount(int count) {
    return 'savladanost: $count';
  }

  @override
  String get result_techWork => 'Tehnički rad — ne računa se u napredak';

  @override
  String get language_progressionEmpty =>
      'Još nema napretka. Vreme je da počneš da učiš jezike!';

  @override
  String get language_resetConfirmTitle => 'Resetuj napredak';

  @override
  String language_resetConfirmBody(String language) {
    return 'Resetovati sav napredak za jezik: $language? Ovo se ne može poništiti.';
  }

  @override
  String get language_resetButton => 'Resetuj';

  @override
  String get result_correctTitle => 'Tačni odgovori';

  @override
  String get result_correctSubtitle => 'Reči sa tačnim odgovorom';

  @override
  String get bugReport_title => 'Prijavi problem';

  @override
  String get bugReport_typeBadTranslation => 'Loš prevod';

  @override
  String get bugReport_typeUiBug => 'Greška u interfejsu';

  @override
  String get bugReport_messagePlaceholder => 'Opiši problem...';

  @override
  String get bugReport_submit => 'Pošalji';

  @override
  String get settings_validateConfigs => 'Proveri sve konfiguracije';

  @override
  String get settings_validateSuccess => 'Sve konfiguracije su ispravne';

  @override
  String settings_validateError(String message) {
    return 'Provera nije uspela: $message';
  }

  @override
  String get settings_seeds => 'Probni podaci';

  @override
  String get settings_seedFull => 'Pun';

  @override
  String get settings_deleteContent => 'Obriši sadržaj';

  @override
  String settings_seedError(String message) {
    return 'Učitavanje podataka nije uspelo: $message';
  }

  @override
  String get settings_contentDeleted => 'Sadržaj je obrisan';

  @override
  String get language_aiDictionaryWarning =>
      'Rečnik je napravila veštačka inteligencija. Moguće su greške. Provera od strane ljudi je u toku — koristiš na sopstvenu odgovornost.';

  @override
  String get language_pairUnavailable => 'Ovaj jezički par još nije dostupan.';

  @override
  String termCard_gender(String gender) {
    return 'Rod: $gender';
  }

  @override
  String get termCard_example => 'Primer:';

  @override
  String termCard_cocaRank(int rank) {
    return 'COCA rang: $rank';
  }

  @override
  String get termCard_soundSemantics => 'Izgovori';

  @override
  String get termCard_soundFailed => 'Izgovor nije dostupan';
}

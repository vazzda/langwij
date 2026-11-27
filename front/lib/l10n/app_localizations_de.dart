// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Langwij';

  @override
  String get parentAgreement => 'Genus-Kongruenz';

  @override
  String get groupWords => 'Grundverben';

  @override
  String wordsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Wörter',
      one: '$count Wort',
    );
    return '$_temp0';
  }

  @override
  String vocab_termsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Begriffe',
      one: '$count Begriff',
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
  String get groupIrregular => 'Unregelmäßig';

  @override
  String get chooseQuestionsCount => 'Wie viele Begriffe?';

  @override
  String get questions5 => '5';

  @override
  String get questions10 => '10';

  @override
  String get questions20 => '20';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get next => 'Weiter';

  @override
  String get submit => 'Antworten';

  @override
  String get yourAnswer => 'Deine Antwort';

  @override
  String get correct => 'Richtig';

  @override
  String get wrong => 'Falsch';

  @override
  String get resultTitle => 'Rundenergebnis';

  @override
  String correctCount(int count) {
    return 'Richtig: $count';
  }

  @override
  String wrongCount(int count) {
    return 'Falsch: $count';
  }

  @override
  String get reviewWrongTitle => 'Verpasste Karten';

  @override
  String get reviewWrongSubtitle => 'Karten mit falscher Antwort';

  @override
  String get again => 'Nochmal';

  @override
  String get back => 'Zurück';

  @override
  String get pageNotFound => 'Seite nicht gefunden';

  @override
  String get loadError =>
      'Gruppen konnten nicht geladen werden. Versuch es noch einmal.';

  @override
  String get correctAnswerLabel => 'Richtige Antwort:';

  @override
  String get youWrote => 'Du hast geschrieben:';

  @override
  String get youPicked => 'Du hast gewählt:';

  @override
  String get emptyAnswer => '(leer)';

  @override
  String get pronounYouInformal => 'du (informell, Singular)';

  @override
  String get pronounYouFormal => 'ihr/Sie (formell, Plural)';

  @override
  String questionsLeft(int count) {
    return 'Übrig: $count';
  }

  @override
  String get exitRound => 'Runde verlassen';

  @override
  String get exitRoundConfirm =>
      'Runde verlassen? Dein Fortschritt geht verloren.';

  @override
  String get exit => 'Verlassen';

  @override
  String get dailyActivityTitle => 'Heute';

  @override
  String get dailyActivityEmpty => 'Heute keine Aktivität';

  @override
  String get mode_guessingHeader => 'Karten';

  @override
  String get mode_writingHeader => 'Tippen';

  @override
  String mode_langCards(String language) {
    return 'Karten: $language';
  }

  @override
  String get mode_training => 'Training';

  @override
  String get mode_test => 'Test';

  @override
  String get relativeDateToday => 'heute';

  @override
  String get relativeDateYesterday => 'gestern';

  @override
  String relativeDateDays(int count) {
    return 'vor $count T.';
  }

  @override
  String relativeDateMonths(int count) {
    return 'vor $count Mon.';
  }

  @override
  String relativeDateYears(int count) {
    return 'vor $count J.';
  }

  @override
  String questionsAll(int count) {
    return 'ALLE ($count)';
  }

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get navLanguage => 'Sprache';

  @override
  String get navProgress => 'Fortschritt';

  @override
  String get navVocabulary => 'Wortschatz';

  @override
  String get navSpecialized => 'Spezialisiert';

  @override
  String get navTools => 'Werkzeuge';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get navLabelVocabulary => 'Top1000';

  @override
  String get navLabelSpecialized => 'Spezial';

  @override
  String get navLabelTools => 'Werkzeuge';

  @override
  String get navLabelLanguage => 'Sprache';

  @override
  String get lang_english => 'Englisch';

  @override
  String get lang_serbian => 'Serbisch';

  @override
  String get lang_russian => 'Russisch';

  @override
  String get lang_italian => 'Italienisch';

  @override
  String get lang_french => 'Französisch';

  @override
  String get lang_spanish => 'Spanisch';

  @override
  String get lang_portuguese => 'Portugiesisch';

  @override
  String get lang_german => 'Deutsch';

  @override
  String get language_iSpeak => 'Ich spreche';

  @override
  String get language_iLearn => 'Ich lerne';

  @override
  String language_iSpeakLanguage(String language) {
    return 'Ich spreche $language';
  }

  @override
  String language_iLearnLanguage(String language) {
    return 'Ich lerne $language';
  }

  @override
  String get language_progression => 'Verlauf';

  @override
  String get language_incompleteDictionaries => 'Unvollständige Wörterbücher';

  @override
  String language_termsCount(int done, int total) {
    return '$done/$total Begriffe';
  }

  @override
  String get tools_conjugations => 'Konjugationen';

  @override
  String get tools_agreement => 'Genus-Kongruenz';

  @override
  String get tools_emptyState => 'Für diese Sprache gibt es keine Werkzeuge';

  @override
  String get settingsHide => 'Ausblenden';

  @override
  String get settingsDeveloper => 'Entwickler';

  @override
  String get dev_enterPassword => 'Hallo';

  @override
  String get dev_unlock => 'Entsperren';

  @override
  String get dev_wrongPassword => 'Nö!';

  @override
  String get quiz_aspectImperfective => 'Imperfektiv:';

  @override
  String get quiz_aspectPerfective => 'Perfektiv:';

  @override
  String get quiz_aspectPairPrompt => 'Gib beide Aspektformen ein';

  @override
  String get vocab_train => 'Trainieren';

  @override
  String get vocab_studied => 'Gelernt';

  @override
  String get vocab_trained => 'Trainiert';

  @override
  String get vocab_lastTrained => 'zuletzt trainiert:';

  @override
  String get vocab_termsLabel => 'Begriffe:';

  @override
  String get vocab_studiedLabel => 'Gelernt:';

  @override
  String get vocab_masteryLabel => 'Beherrschung:';

  @override
  String vocab_nextStarIn(int percent) {
    return 'nächster Stern in $percent%';
  }

  @override
  String get result_techWork =>
      'Technische Runde — zählt nicht zum Fortschritt';

  @override
  String get language_progressionEmpty =>
      'Noch kein Fortschritt. Zeit, Sprachen zu lernen!';

  @override
  String get language_resetConfirmTitle => 'Fortschritt zurücksetzen';

  @override
  String language_resetConfirmBody(String language) {
    return 'Gesamten Fortschritt für $language zurücksetzen? Das kann nicht rückgängig gemacht werden.';
  }

  @override
  String get language_resetButton => 'Zurücksetzen';

  @override
  String get result_correctTitle => 'Richtige Antworten';

  @override
  String get result_correctSubtitle => 'Wörter mit richtiger Antwort';

  @override
  String get bugReport_title => 'Problem melden';

  @override
  String get bugReport_typeBadTranslation => 'Schlechte Übersetzung';

  @override
  String get bugReport_typeUiBug => 'UI-Fehler';

  @override
  String get bugReport_messagePlaceholder => 'Beschreibe das Problem...';

  @override
  String get bugReport_submit => 'Senden';

  @override
  String get settings_validateConfigs => 'Alle Konfigurationen prüfen';

  @override
  String get settings_validateSuccess => 'Alle Konfigurationen gültig';

  @override
  String settings_validateError(String message) {
    return 'Prüfung fehlgeschlagen: $message';
  }

  @override
  String get settings_seeds => 'Testdaten';

  @override
  String get settings_seedFull => 'Voll';

  @override
  String get settings_deleteContent => 'Inhalte löschen';

  @override
  String settings_seedError(String message) {
    return 'Testdaten fehlgeschlagen: $message';
  }

  @override
  String get settings_contentDeleted => 'Inhalte gelöscht';

  @override
  String get language_aiWarningTitle => 'KI-Warnung';

  @override
  String get language_aiDictionaryWarning =>
      'KI-generiertes Wörterbuch. Kann Fehler enthalten. Die Prüfung durch Menschen läuft — Nutzung auf eigene Gefahr.';

  @override
  String get language_aiGeneratedTitle => 'KI-generiert';

  @override
  String get language_aiGeneratedNote =>
      'Die Stapel dieser Sprachen wurden von KI erstellt und nur teilweise von Fachleuten geprüft. Du kannst sie verwenden: Sie sind größtenteils gut, aber Fehler sind weiterhin möglich.';

  @override
  String get language_inDevelopmentTitle => 'In Entwicklung';

  @override
  String termCard_gender(String gender) {
    return 'Genus: $gender';
  }

  @override
  String get termCard_example => 'Beispiel:';

  @override
  String termCard_cocaRank(int rank) {
    return 'Häufigkeit: $rank';
  }

  @override
  String termCard_article(String article) {
    return 'Artikel: $article';
  }

  @override
  String termCard_aspect(String aspect) {
    return 'Aspekt: $aspect';
  }

  @override
  String get termCard_typePhrase => 'Phrase';

  @override
  String get termCard_typeInterrogative => 'Fragewort';

  @override
  String get termCard_typePronoun => 'Pronomen';

  @override
  String get termCard_typePreposition => 'Präposition';

  @override
  String get termCard_typeConjunction => 'Konjunktion';

  @override
  String get termCard_typeNumeral => 'Zahlwort';

  @override
  String get termCard_typeVerb => 'Verb';

  @override
  String get termCard_typeAdverb => 'Adverb';

  @override
  String get termCard_typeAdjective => 'Adjektiv';

  @override
  String get termCard_typeNoun => 'Substantiv';

  @override
  String get termCard_genderMasculine => 'männlich';

  @override
  String get termCard_genderFeminine => 'weiblich';

  @override
  String get termCard_genderNeuter => 'sächlich';

  @override
  String get termCard_aspectImperfective => 'imperfektiv';

  @override
  String get termCard_aspectPerfective => 'perfektiv';

  @override
  String get termCard_soundSemantics => 'Aussprechen';

  @override
  String get termCard_soundFailed => 'Aussprache nicht verfügbar';
}

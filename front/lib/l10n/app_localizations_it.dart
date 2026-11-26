// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Langwij';

  @override
  String get parentAgreement => 'Accordi di genere';

  @override
  String get groupWords => 'Verbi di base';

  @override
  String wordsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parole',
      one: '$count parola',
    );
    return '$_temp0';
  }

  @override
  String vocab_termsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count termini',
      one: '$count termine',
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
  String get groupIrregular => 'Irregolari';

  @override
  String get chooseQuestionsCount => 'Quanti termini?';

  @override
  String get questions5 => '5';

  @override
  String get questions10 => '10';

  @override
  String get questions20 => '20';

  @override
  String get cancel => 'Annulla';

  @override
  String get next => 'Avanti';

  @override
  String get submit => 'Rispondi';

  @override
  String get yourAnswer => 'La tua risposta';

  @override
  String get correct => 'Corretto';

  @override
  String get wrong => 'Sbagliato';

  @override
  String get resultTitle => 'Risultato del round';

  @override
  String correctCount(int count) {
    return 'Corrette: $count';
  }

  @override
  String wrongCount(int count) {
    return 'Sbagliate: $count';
  }

  @override
  String get reviewWrongTitle => 'Carte sbagliate';

  @override
  String get reviewWrongSubtitle => 'Carte con risposta sbagliata';

  @override
  String get again => 'Ancora';

  @override
  String get back => 'Indietro';

  @override
  String get pageNotFound => 'Pagina non trovata';

  @override
  String get loadError => 'Impossibile caricare i gruppi. Riprova.';

  @override
  String get correctAnswerLabel => 'Risposta corretta:';

  @override
  String get youWrote => 'Hai scritto:';

  @override
  String get youPicked => 'Hai scelto:';

  @override
  String get emptyAnswer => '(vuoto)';

  @override
  String get pronounYouInformal => 'tu (informale, singolare)';

  @override
  String get pronounYouFormal => 'voi/Lei (formale, plurale)';

  @override
  String questionsLeft(int count) {
    return 'Rimaste: $count';
  }

  @override
  String get exitRound => 'Esci dal round';

  @override
  String get exitRoundConfirm =>
      'Uscire dal round? I tuoi progressi andranno persi.';

  @override
  String get exit => 'Esci';

  @override
  String get dailyActivityTitle => 'Oggi';

  @override
  String get dailyActivityEmpty => 'Nessuna attività oggi';

  @override
  String get mode_guessingHeader => 'Carte';

  @override
  String get mode_writingHeader => 'Scrittura';

  @override
  String mode_langCards(String language) {
    return 'Carte: $language';
  }

  @override
  String get mode_training => 'Allenamento';

  @override
  String get mode_test => 'Test';

  @override
  String get relativeDateToday => 'oggi';

  @override
  String get relativeDateYesterday => 'ieri';

  @override
  String relativeDateDays(int count) {
    return '$count g fa';
  }

  @override
  String relativeDateMonths(int count) {
    return '$count m fa';
  }

  @override
  String relativeDateYears(int count) {
    return '$count a fa';
  }

  @override
  String questionsAll(int count) {
    return 'TUTTI ($count)';
  }

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get navLanguage => 'Lingua';

  @override
  String get navProgress => 'Progressi';

  @override
  String get navVocabulary => 'Vocabolario';

  @override
  String get navSpecialized => 'Specializzato';

  @override
  String get navTools => 'Strumenti';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get navLabelVocabulary => 'Top1000';

  @override
  String get navLabelSpecialized => 'Speciale';

  @override
  String get navLabelTools => 'Strumenti';

  @override
  String get navLabelLanguage => 'Lingua';

  @override
  String get lang_english => 'Inglese';

  @override
  String get lang_serbian => 'Serbo';

  @override
  String get lang_russian => 'Russo';

  @override
  String get lang_italian => 'Italiano';

  @override
  String get lang_french => 'Francese';

  @override
  String get lang_spanish => 'Spagnolo';

  @override
  String get lang_portuguese => 'Portoghese';

  @override
  String get lang_german => 'Tedesco';

  @override
  String get language_iSpeak => 'Parlo';

  @override
  String get language_iLearn => 'Imparo';

  @override
  String language_iSpeakLanguage(String language) {
    return 'Parlo $language';
  }

  @override
  String language_iLearnLanguage(String language) {
    return 'Imparo $language';
  }

  @override
  String get language_progression => 'Progressione';

  @override
  String get language_incompleteDictionaries => 'Dizionari incompleti';

  @override
  String language_termsCount(int done, int total) {
    return '$done/$total termini';
  }

  @override
  String get tools_conjugations => 'Coniugazioni';

  @override
  String get tools_agreement => 'Accordo di genere';

  @override
  String get tools_emptyState =>
      'Nessuno strumento disponibile per questa lingua';

  @override
  String get settingsHide => 'Nascondi';

  @override
  String get settingsDeveloper => 'Sviluppatore';

  @override
  String get dev_enterPassword => 'Ciao';

  @override
  String get dev_unlock => 'Sblocca';

  @override
  String get dev_wrongPassword => 'Macché!';

  @override
  String get quiz_aspectImperfective => 'Imperfettivo:';

  @override
  String get quiz_aspectPerfective => 'Perfettivo:';

  @override
  String get quiz_aspectPairPrompt => 'Scrivi entrambe le forme di aspetto';

  @override
  String get vocab_train => 'Allenati';

  @override
  String get vocab_studied => 'Studiato';

  @override
  String get vocab_trained => 'Allenato';

  @override
  String get vocab_lastTrained => 'ultimo allenamento:';

  @override
  String get vocab_termsLabel => 'termini:';

  @override
  String get vocab_studiedLabel => 'Studiato:';

  @override
  String get vocab_masteryLabel => 'Padronanza:';

  @override
  String vocab_nextStarIn(int percent) {
    return 'prossima stella tra $percent%';
  }

  @override
  String get result_techWork => 'Lavoro tecnico — non conta per i progressi';

  @override
  String get language_progressionEmpty =>
      'Ancora nessun progresso. È ora di iniziare a imparare le lingue!';

  @override
  String get language_resetConfirmTitle => 'Azzera i progressi';

  @override
  String language_resetConfirmBody(String language) {
    return 'Azzerare tutti i progressi per $language? L\'operazione non può essere annullata.';
  }

  @override
  String get language_resetButton => 'Azzera';

  @override
  String get result_correctTitle => 'Risposte corrette';

  @override
  String get result_correctSubtitle => 'Parole con risposta corretta';

  @override
  String get bugReport_title => 'Segnala un problema';

  @override
  String get bugReport_typeBadTranslation => 'Traduzione errata';

  @override
  String get bugReport_typeUiBug => 'Bug dell\'interfaccia';

  @override
  String get bugReport_messagePlaceholder => 'Descrivi il problema...';

  @override
  String get bugReport_submit => 'Invia';

  @override
  String get settings_validateConfigs => 'Convalida tutte le configurazioni';

  @override
  String get settings_validateSuccess => 'Tutte le configurazioni sono valide';

  @override
  String settings_validateError(String message) {
    return 'Convalida non riuscita: $message';
  }

  @override
  String get settings_seeds => 'Dati di prova';

  @override
  String get settings_seedFull => 'Completo';

  @override
  String get settings_deleteContent => 'Elimina contenuti';

  @override
  String settings_seedError(String message) {
    return 'Dati di prova non riusciti: $message';
  }

  @override
  String get settings_contentDeleted => 'Contenuti eliminati';

  @override
  String get language_aiWarningTitle => 'Avviso IA';

  @override
  String get language_aiDictionaryWarning =>
      'Dizionario generato dall\'IA. Può contenere errori. Revisione umana in corso — usalo a tuo rischio.';

  @override
  String get language_aiGeneratedTitle => 'Generato dall\'IA';

  @override
  String get language_aiGeneratedNote =>
      'I mazzi di queste lingue sono stati generati dall\'IA e controllati solo in parte da esperti. Puoi usarli: sono per lo più buoni, ma possono ancora esserci errori.';

  @override
  String get language_inDevelopmentTitle => 'In sviluppo';

  @override
  String termCard_gender(String gender) {
    return 'Genere: $gender';
  }

  @override
  String get termCard_example => 'Esempio:';

  @override
  String termCard_cocaRank(int rank) {
    return 'Posizione COCA: $rank';
  }

  @override
  String get termCard_soundSemantics => 'Pronuncia';

  @override
  String get termCard_soundFailed => 'Pronuncia non disponibile';
}

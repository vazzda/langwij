// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Langwij';

  @override
  String get parentAgreement => 'Gender agreements';

  @override
  String get groupWords => 'Basic verbs';

  @override
  String wordsCount(int count) {
    return '$count words';
  }

  @override
  String vocab_termsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count terms',
      one: '1 term',
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
  String get groupIrregular => 'Irregular';

  @override
  String get chooseQuestionsCount => 'How many terms?';

  @override
  String get questions5 => '5';

  @override
  String get questions10 => '10';

  @override
  String get questions20 => '20';

  @override
  String get cancel => 'Cancel';

  @override
  String get next => 'Next';

  @override
  String get submit => 'Submit';

  @override
  String get yourAnswer => 'Your answer';

  @override
  String get correct => 'Correct';

  @override
  String get wrong => 'Wrong';

  @override
  String get resultTitle => 'Round result';

  @override
  String correctCount(int count) {
    return 'Correct: $count';
  }

  @override
  String wrongCount(int count) {
    return 'Wrong: $count';
  }

  @override
  String get reviewWrongTitle => 'Missed cards';

  @override
  String get reviewWrongSubtitle => 'Cards you got wrong';

  @override
  String get again => 'Again';

  @override
  String get back => 'Back';

  @override
  String get pageNotFound => 'Page not found';

  @override
  String get loadError => 'Could not load groups. Please try again.';

  @override
  String get correctAnswerLabel => 'Correct answer:';

  @override
  String get youWrote => 'You wrote:';

  @override
  String get youPicked => 'You picked:';

  @override
  String get emptyAnswer => '(empty)';

  @override
  String get pronounYouInformal => 'you (informal, singular)';

  @override
  String get pronounYouFormal => 'you (formal, plural)';

  @override
  String questionsLeft(int count) {
    return 'Left: $count';
  }

  @override
  String get exitRound => 'Exit round';

  @override
  String get exitRoundConfirm => 'Exit round? Your progress will be lost.';

  @override
  String get exit => 'Exit';

  @override
  String get dailyActivityTitle => 'Today';

  @override
  String get dailyActivityEmpty => 'No activity today';

  @override
  String get mode_guessingHeader => 'Cards';

  @override
  String get mode_writingHeader => 'Typing';

  @override
  String mode_langCards(String language) {
    return '$language cards';
  }

  @override
  String get mode_training => 'Training';

  @override
  String get mode_test => 'Test';

  @override
  String get relativeDateToday => 'today';

  @override
  String get relativeDateYesterday => 'yesterday';

  @override
  String relativeDateDays(int count) {
    return '${count}d ago';
  }

  @override
  String relativeDateMonths(int count) {
    return '${count}mo ago';
  }

  @override
  String relativeDateYears(int count) {
    return '${count}y ago';
  }

  @override
  String questionsAll(int count) {
    return 'ALL ($count)';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get navLanguage => 'Language';

  @override
  String get navProgress => 'Progress';

  @override
  String get navVocabulary => 'Vocabulary';

  @override
  String get navSpecialized => 'Specialized';

  @override
  String get navTools => 'Tools';

  @override
  String get navSettings => 'Settings';

  @override
  String get navLabelVocabulary => 'Top1000';

  @override
  String get navLabelSpecialized => 'Special';

  @override
  String get navLabelTools => 'Tools';

  @override
  String get navLabelLanguage => 'Language';

  @override
  String get lang_english => 'English';

  @override
  String get lang_serbian => 'Serbian';

  @override
  String get lang_russian => 'Russian';

  @override
  String get lang_italian => 'Italian';

  @override
  String get lang_french => 'French';

  @override
  String get lang_spanish => 'Spanish';

  @override
  String get lang_portuguese => 'Portuguese';

  @override
  String get lang_german => 'German';

  @override
  String get language_iSpeak => 'I speak';

  @override
  String get language_iLearn => 'I learn';

  @override
  String language_iSpeakLanguage(String language) {
    return 'I speak $language';
  }

  @override
  String language_iLearnLanguage(String language) {
    return 'I learn $language';
  }

  @override
  String get language_progression => 'Progression';

  @override
  String get language_incompleteDictionaries => 'Incomplete dictionaries';

  @override
  String language_termsCount(int done, int total) {
    return '$done/$total terms';
  }

  @override
  String get tools_conjugations => 'Conjugations';

  @override
  String get tools_agreement => 'Gender agreement';

  @override
  String get tools_emptyState => 'No tools available for this language';

  @override
  String get settingsHide => 'Hide';

  @override
  String get settingsDeveloper => 'Developer';

  @override
  String get dev_enterPassword => 'Hello';

  @override
  String get dev_unlock => 'Unlock';

  @override
  String get dev_wrongPassword => 'Nope!';

  @override
  String get quiz_aspectImperfective => 'Imperfective:';

  @override
  String get quiz_aspectPerfective => 'Perfective:';

  @override
  String get quiz_aspectPairPrompt => 'Type both aspect forms';

  @override
  String get vocab_train => 'Train';

  @override
  String get vocab_studied => 'Studied';

  @override
  String get vocab_trained => 'Trained';

  @override
  String get vocab_lastTrained => 'last trained:';

  @override
  String get vocab_termsLabel => 'terms:';

  @override
  String get vocab_studiedLabel => 'Studied:';

  @override
  String get vocab_masteryLabel => 'Mastery:';

  @override
  String vocab_nextStarIn(int percent) {
    return 'next star in $percent%';
  }

  @override
  String get result_techWork => 'Tech work — no progress contribution';

  @override
  String get language_progressionEmpty =>
      'No progress have been made. Time to start learning languages!';

  @override
  String get language_resetConfirmTitle => 'Reset progress';

  @override
  String language_resetConfirmBody(String language) {
    return 'Reset all progress for $language? This cannot be undone.';
  }

  @override
  String get language_resetButton => 'Reset';

  @override
  String get result_correctTitle => 'Review Correct';

  @override
  String get result_correctSubtitle => 'Words you answered correctly';

  @override
  String get bugReport_title => 'Report Issue';

  @override
  String get bugReport_typeBadTranslation => 'Bad translation';

  @override
  String get bugReport_typeUiBug => 'UI bug';

  @override
  String get bugReport_messagePlaceholder => 'Describe the issue...';

  @override
  String get bugReport_submit => 'Submit';

  @override
  String get settings_validateConfigs => 'Validate All Configs';

  @override
  String get settings_validateSuccess => 'All configs valid';

  @override
  String settings_validateError(String message) {
    return 'Validation failed: $message';
  }

  @override
  String get settings_seeds => 'Seeds';

  @override
  String get settings_seedFull => 'Full';

  @override
  String get settings_deleteContent => 'Delete content';

  @override
  String settings_seedError(String message) {
    return 'Seed failed: $message';
  }

  @override
  String get settings_contentDeleted => 'Content deleted';

  @override
  String get language_aiWarningTitle => 'AI warning';

  @override
  String get language_aiDictionaryWarning =>
      'AI-generated dictionary. May contain errors. Human review in progress — use at your own risk.';

  @override
  String get language_aiGeneratedTitle => 'AI generated';

  @override
  String get language_aiGeneratedNote =>
      'The decks of these languages were generated by AI and only partly checked by experts. You can use them: they are mostly good, but mistakes can still occur.';

  @override
  String get language_inDevelopmentTitle => 'In development';

  @override
  String termCard_gender(String gender) {
    return 'Gender: $gender';
  }

  @override
  String get termCard_example => 'Example:';

  @override
  String termCard_cocaRank(int rank) {
    return 'Frequency: $rank';
  }

  @override
  String termCard_article(String article) {
    return 'Article: $article';
  }

  @override
  String termCard_aspect(String aspect) {
    return 'Aspect: $aspect';
  }

  @override
  String get termCard_typePhrase => 'Phrase';

  @override
  String get termCard_typeInterrogative => 'Question word';

  @override
  String get termCard_typePronoun => 'Pronoun';

  @override
  String get termCard_typePreposition => 'Preposition';

  @override
  String get termCard_typeConjunction => 'Conjunction';

  @override
  String get termCard_typeNumeral => 'Numeral';

  @override
  String get termCard_typeVerb => 'Verb';

  @override
  String get termCard_typeAdverb => 'Adverb';

  @override
  String get termCard_typeAdjective => 'Adjective';

  @override
  String get termCard_typeNoun => 'Noun';

  @override
  String get termCard_genderMasculine => 'masculine';

  @override
  String get termCard_genderFeminine => 'feminine';

  @override
  String get termCard_genderNeuter => 'neuter';

  @override
  String get termCard_aspectImperfective => 'imperfective';

  @override
  String get termCard_aspectPerfective => 'perfective';

  @override
  String get termCard_soundSemantics => 'Pronounce';

  @override
  String get termCard_soundFailed => 'Pronunciation unavailable';
}

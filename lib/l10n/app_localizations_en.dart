// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Srpski Card';

  @override
  String get appBarTitle => 'Srpski';

  @override
  String get parentVocabulary => 'Vocabulary';

  @override
  String get parentConjugations => 'Conjugations';

  @override
  String get parentAgreement => 'Gender agreements';

  @override
  String agreementSessionGender(String gender) {
    return 'Gender: $gender';
  }

  @override
  String get groupWords => 'Basic verbs';

  @override
  String get vocabSectionSettingWords => 'Setting words';

  @override
  String get vocabSectionBasicNouns => 'Basic nouns';

  @override
  String get vocabSectionBasicAdjectives => 'Basic adjectives';

  @override
  String wordsCount(int count) {
    return '$count words';
  }

  @override
  String wordsCountWithPreview(int count, String preview) {
    return '$count words: $preview';
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
  String get chooseMode => 'Choose mode';

  @override
  String get modeSerbianShown => 'Serbian shown (pick English)';

  @override
  String get modeEnglishShown => 'English shown (pick target)';

  @override
  String get modeWrite => 'Write (type target)';

  @override
  String get chooseQuestionsCount => 'How many questions?';

  @override
  String get questions5 => '5';

  @override
  String get questions10 => '10';

  @override
  String get questions20 => '20';

  @override
  String get questions50 => '50';

  @override
  String get start => 'Start';

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
  String get resultTitle => 'Session result';

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
  String get done => 'Done';

  @override
  String get backToGroups => 'Back to groups';

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
  String get exitSession => 'Exit session';

  @override
  String get exitSessionConfirm => 'Exit session? Your progress will be lost.';

  @override
  String get exit => 'Exit';

  @override
  String get dailyActivityTitle => 'Today';

  @override
  String get dailyActivityEmpty => 'No activity today';

  @override
  String get trainHeader => 'TRAIN';

  @override
  String get testHeader => 'TESTING';

  @override
  String get modeEngCards => 'TARGET SHOWN';

  @override
  String get modeSrpskiCards => 'NATIVE SHOWN';

  @override
  String get modeWriting => 'WRITING';

  @override
  String get modeTest => 'TEST';

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
  String get retentionNone => 'None';

  @override
  String get retentionWeak => 'Weak';

  @override
  String get retentionGood => 'Good';

  @override
  String get retentionStrong => 'Strong';

  @override
  String get retentionSuper => 'Super';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsDecaySpeed => 'Learning pace';

  @override
  String get decayRelaxed => 'Relaxed';

  @override
  String get decayRelaxedDesc => 'Slow decay (14 days)';

  @override
  String get decayStandard => 'Standard';

  @override
  String get decayStandardDesc => 'Balanced (7 days)';

  @override
  String get decayIntensive => 'Intensive';

  @override
  String get decayIntensiveDesc => 'Fast decay (4 days)';

  @override
  String get decayHardcore => 'Hardcore';

  @override
  String get decayHardcoreDesc => 'Very fast (2 days)';

  @override
  String get navLanguage => 'Language';

  @override
  String get navVocabulary => 'Vocabulary';

  @override
  String get navTools => 'Tools';

  @override
  String get navSettings => 'Settings';

  @override
  String get underDevelopmentTitle => 'Coming soon';

  @override
  String get underDevelopmentBody => 'This feature is under development.';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get lang_english => 'English';

  @override
  String get lang_serbian => 'Serbian';

  @override
  String get lang_russian => 'Russian';

  @override
  String get aspect_perfective => 'perfective';

  @override
  String get aspect_imperfective => 'imperfective';

  @override
  String get language_learning => 'Learning';

  @override
  String get language_native => 'Native language';

  @override
  String get language_appLanguage => 'App language';

  @override
  String get language_sameAsLearning => 'Same as learning language selected';

  @override
  String get language_myProgress => 'My progress';

  @override
  String get language_progression => 'Progression';

  @override
  String get language_incompleteDictionaries => 'Incomplete dictionaries';

  @override
  String language_groupsProgress(int done, int total) {
    return '$done/$total groups';
  }

  @override
  String language_wordsTouched(int count) {
    return '$count words';
  }

  @override
  String language_conceptsMissing(int count) {
    return '$count missing';
  }

  @override
  String language_conceptsCount(int done, int total) {
    return '$done/$total concepts';
  }

  @override
  String get modeTargetShown => 'Target shown (pick native)';

  @override
  String get modeNativeShown => 'Native shown (pick target)';

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
  String get settingsControlsList => 'Controls List';

  @override
  String get quiz_aspectImperfective => 'Imperfective:';

  @override
  String get quiz_aspectPerfective => 'Perfective:';

  @override
  String get quiz_aspectPairPrompt => 'Type both aspect forms';
}

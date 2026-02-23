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
  String get groupBasicVerbs01 => 'Basic verbs 01';

  @override
  String get groupBasicVerbs02 => 'Basic verbs 02';

  @override
  String get groupBasicVerbs03 => 'Basic verbs 03';

  @override
  String get groupBasicVerbs04 => 'Basic verbs 04';

  @override
  String get groupBasicVerbs05 => 'Basic verbs 05';

  @override
  String get groupBasicVerbs06 => 'Basic verbs 06';

  @override
  String get groupBasicVerbs07 => 'Basic verbs 07';

  @override
  String get groupBasicVerbs08 => 'Basic verbs 08';

  @override
  String get groupBasicVerbs09 => 'Basic verbs 09';

  @override
  String get groupBasicVerbs10 => 'Basic verbs 10';

  @override
  String get groupBasicVerbs11 => 'Basic verbs 11';

  @override
  String get groupAdverbsOfTime => 'Adverbs of time';

  @override
  String get groupPrepositions => 'Prepositions';

  @override
  String get groupDemonstrativePronouns => 'Demonstrative Pronouns';

  @override
  String get groupRelativeDirection => 'Relative Direction';

  @override
  String get groupDegreeAndQuantity => 'Degree & Quantity';

  @override
  String get groupPeople => 'People';

  @override
  String get groupPlaces => 'Places';

  @override
  String get groupDailyItemsAndObjects => 'Daily Items & Objects';

  @override
  String get groupTimeAndNature => 'Time & Nature';

  @override
  String get groupAbstractConcepts => 'Abstract Concepts';

  @override
  String get groupGeneralQualities => 'General Qualities';

  @override
  String get groupPeopleAndEmotions => 'People & Emotions';

  @override
  String get groupSensesAndFeelings => 'Senses & Feelings';

  @override
  String get groupColors => 'Colors';

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
  String get modeEnglishShown => 'English shown (pick Serbian)';

  @override
  String get modeWrite => 'Write (type Serbian)';

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
  String get reviewWrongSubtitle => 'Cards you got wrong (Serbian → English)';

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
  String get modeEngCards => 'ENG CARDS';

  @override
  String get modeSrpskiCards => 'SRPSKI CARDS';

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
}

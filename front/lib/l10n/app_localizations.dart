import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt'),
    Locale('ru'),
    Locale('sr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Langwij'**
  String get appTitle;

  /// No description provided for @parentAgreement.
  ///
  /// In en, this message translates to:
  /// **'Gender agreements'**
  String get parentAgreement;

  /// No description provided for @groupWords.
  ///
  /// In en, this message translates to:
  /// **'Basic verbs'**
  String get groupWords;

  /// No description provided for @wordsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} words'**
  String wordsCount(int count);

  /// No description provided for @vocab_termsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 term} other{{count} terms}}'**
  String vocab_termsCount(int count);

  /// No description provided for @groupEndingsImEAti.
  ///
  /// In en, this message translates to:
  /// **'-ATI (IM|E)'**
  String get groupEndingsImEAti;

  /// No description provided for @groupEndingsImEEti.
  ///
  /// In en, this message translates to:
  /// **'-ETI (IM|E)'**
  String get groupEndingsImEEti;

  /// No description provided for @groupEndingsImEIti.
  ///
  /// In en, this message translates to:
  /// **'-ITI (IM|E)'**
  String get groupEndingsImEIti;

  /// No description provided for @groupEndingsAmAju.
  ///
  /// In en, this message translates to:
  /// **'-ATI (AM|AJU)'**
  String get groupEndingsAmAju;

  /// No description provided for @groupEndingsEmUGati.
  ///
  /// In en, this message translates to:
  /// **'-GATI (EM|U)'**
  String get groupEndingsEmUGati;

  /// No description provided for @groupEndingsEmUHati.
  ///
  /// In en, this message translates to:
  /// **'-HATI (EM|U)'**
  String get groupEndingsEmUHati;

  /// No description provided for @groupEndingsEmUKati.
  ///
  /// In en, this message translates to:
  /// **'-KATI (EM|U)'**
  String get groupEndingsEmUKati;

  /// No description provided for @groupEndingsEmUAvati.
  ///
  /// In en, this message translates to:
  /// **'-AVATI (EM|U)'**
  String get groupEndingsEmUAvati;

  /// No description provided for @groupEndingsEmUIvati.
  ///
  /// In en, this message translates to:
  /// **'-IVATI (EM|U)'**
  String get groupEndingsEmUIvati;

  /// No description provided for @groupEndingsEmUOvati.
  ///
  /// In en, this message translates to:
  /// **'-OVATI (EM|U)'**
  String get groupEndingsEmUOvati;

  /// No description provided for @groupEndingsEmUCi.
  ///
  /// In en, this message translates to:
  /// **'-ĆI (EM|U)'**
  String get groupEndingsEmUCi;

  /// No description provided for @groupEndingsEmEju.
  ///
  /// In en, this message translates to:
  /// **'-ETI (EM|EJU)'**
  String get groupEndingsEmEju;

  /// No description provided for @groupIrregular.
  ///
  /// In en, this message translates to:
  /// **'Irregular'**
  String get groupIrregular;

  /// No description provided for @chooseQuestionsCount.
  ///
  /// In en, this message translates to:
  /// **'How many terms?'**
  String get chooseQuestionsCount;

  /// No description provided for @questions5.
  ///
  /// In en, this message translates to:
  /// **'5'**
  String get questions5;

  /// No description provided for @questions10.
  ///
  /// In en, this message translates to:
  /// **'10'**
  String get questions10;

  /// No description provided for @questions20.
  ///
  /// In en, this message translates to:
  /// **'20'**
  String get questions20;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @yourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get yourAnswer;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correct;

  /// No description provided for @wrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get wrong;

  /// No description provided for @resultTitle.
  ///
  /// In en, this message translates to:
  /// **'Round result'**
  String get resultTitle;

  /// No description provided for @correctCount.
  ///
  /// In en, this message translates to:
  /// **'Correct: {count}'**
  String correctCount(int count);

  /// No description provided for @wrongCount.
  ///
  /// In en, this message translates to:
  /// **'Wrong: {count}'**
  String wrongCount(int count);

  /// No description provided for @reviewWrongTitle.
  ///
  /// In en, this message translates to:
  /// **'Missed cards'**
  String get reviewWrongTitle;

  /// No description provided for @reviewWrongSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cards you got wrong'**
  String get reviewWrongSubtitle;

  /// No description provided for @again.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get again;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFound;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load groups. Please try again.'**
  String get loadError;

  /// No description provided for @correctAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Correct answer:'**
  String get correctAnswerLabel;

  /// No description provided for @youWrote.
  ///
  /// In en, this message translates to:
  /// **'You wrote:'**
  String get youWrote;

  /// No description provided for @youPicked.
  ///
  /// In en, this message translates to:
  /// **'You picked:'**
  String get youPicked;

  /// No description provided for @emptyAnswer.
  ///
  /// In en, this message translates to:
  /// **'(empty)'**
  String get emptyAnswer;

  /// No description provided for @pronounYouInformal.
  ///
  /// In en, this message translates to:
  /// **'you (informal, singular)'**
  String get pronounYouInformal;

  /// No description provided for @pronounYouFormal.
  ///
  /// In en, this message translates to:
  /// **'you (formal, plural)'**
  String get pronounYouFormal;

  /// No description provided for @questionsLeft.
  ///
  /// In en, this message translates to:
  /// **'Left: {count}'**
  String questionsLeft(int count);

  /// No description provided for @exitRound.
  ///
  /// In en, this message translates to:
  /// **'Exit round'**
  String get exitRound;

  /// No description provided for @exitRoundConfirm.
  ///
  /// In en, this message translates to:
  /// **'Exit round? Your progress will be lost.'**
  String get exitRoundConfirm;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @dailyActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dailyActivityTitle;

  /// No description provided for @dailyActivityEmpty.
  ///
  /// In en, this message translates to:
  /// **'No activity today'**
  String get dailyActivityEmpty;

  /// No description provided for @mode_guessingHeader.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get mode_guessingHeader;

  /// No description provided for @mode_writingHeader.
  ///
  /// In en, this message translates to:
  /// **'Typing'**
  String get mode_writingHeader;

  /// No description provided for @mode_langCards.
  ///
  /// In en, this message translates to:
  /// **'{language} cards'**
  String mode_langCards(String language);

  /// No description provided for @mode_training.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get mode_training;

  /// No description provided for @mode_test.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get mode_test;

  /// No description provided for @relativeDateToday.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get relativeDateToday;

  /// No description provided for @relativeDateYesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get relativeDateYesterday;

  /// No description provided for @relativeDateDays.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String relativeDateDays(int count);

  /// No description provided for @relativeDateMonths.
  ///
  /// In en, this message translates to:
  /// **'{count}mo ago'**
  String relativeDateMonths(int count);

  /// No description provided for @relativeDateYears.
  ///
  /// In en, this message translates to:
  /// **'{count}y ago'**
  String relativeDateYears(int count);

  /// No description provided for @questionsAll.
  ///
  /// In en, this message translates to:
  /// **'ALL ({count})'**
  String questionsAll(int count);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @navLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get navLanguage;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @navVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get navVocabulary;

  /// No description provided for @navSpecialized.
  ///
  /// In en, this message translates to:
  /// **'Specialized'**
  String get navSpecialized;

  /// No description provided for @navTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get navTools;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navLabelVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Top1000'**
  String get navLabelVocabulary;

  /// No description provided for @navLabelSpecialized.
  ///
  /// In en, this message translates to:
  /// **'Special'**
  String get navLabelSpecialized;

  /// No description provided for @navLabelTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get navLabelTools;

  /// No description provided for @navLabelLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get navLabelLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @lang_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get lang_english;

  /// No description provided for @lang_serbian.
  ///
  /// In en, this message translates to:
  /// **'Serbian'**
  String get lang_serbian;

  /// No description provided for @lang_russian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get lang_russian;

  /// No description provided for @lang_italian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get lang_italian;

  /// No description provided for @lang_french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get lang_french;

  /// No description provided for @lang_spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get lang_spanish;

  /// No description provided for @lang_portuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get lang_portuguese;

  /// No description provided for @lang_german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get lang_german;

  /// No description provided for @language_iSpeak.
  ///
  /// In en, this message translates to:
  /// **'I speak'**
  String get language_iSpeak;

  /// No description provided for @language_iLearn.
  ///
  /// In en, this message translates to:
  /// **'I learn'**
  String get language_iLearn;

  /// No description provided for @language_qualityAi.
  ///
  /// In en, this message translates to:
  /// **'{aiPct}% AI made'**
  String language_qualityAi(int aiPct);

  /// No description provided for @language_qualityHuman.
  ///
  /// In en, this message translates to:
  /// **'{humanPct}% human made'**
  String language_qualityHuman(int humanPct);

  /// No description provided for @language_progression.
  ///
  /// In en, this message translates to:
  /// **'Progression'**
  String get language_progression;

  /// No description provided for @language_incompleteDictionaries.
  ///
  /// In en, this message translates to:
  /// **'Incomplete dictionaries'**
  String get language_incompleteDictionaries;

  /// No description provided for @language_termsCount.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} terms'**
  String language_termsCount(int done, int total);

  /// No description provided for @tools_conjugations.
  ///
  /// In en, this message translates to:
  /// **'Conjugations'**
  String get tools_conjugations;

  /// No description provided for @tools_agreement.
  ///
  /// In en, this message translates to:
  /// **'Gender agreement'**
  String get tools_agreement;

  /// No description provided for @tools_emptyState.
  ///
  /// In en, this message translates to:
  /// **'No tools available for this language'**
  String get tools_emptyState;

  /// No description provided for @settingsHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get settingsHide;

  /// No description provided for @settingsDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get settingsDeveloper;

  /// No description provided for @dev_enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get dev_enterPassword;

  /// No description provided for @dev_unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get dev_unlock;

  /// No description provided for @dev_wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Nope!'**
  String get dev_wrongPassword;

  /// No description provided for @quiz_aspectImperfective.
  ///
  /// In en, this message translates to:
  /// **'Imperfective:'**
  String get quiz_aspectImperfective;

  /// No description provided for @quiz_aspectPerfective.
  ///
  /// In en, this message translates to:
  /// **'Perfective:'**
  String get quiz_aspectPerfective;

  /// No description provided for @quiz_aspectPairPrompt.
  ///
  /// In en, this message translates to:
  /// **'Type both aspect forms'**
  String get quiz_aspectPairPrompt;

  /// No description provided for @vocab_train.
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get vocab_train;

  /// No description provided for @vocab_studied.
  ///
  /// In en, this message translates to:
  /// **'Studied'**
  String get vocab_studied;

  /// No description provided for @vocab_trained.
  ///
  /// In en, this message translates to:
  /// **'Trained'**
  String get vocab_trained;

  /// No description provided for @vocab_lastTrained.
  ///
  /// In en, this message translates to:
  /// **'last trained:'**
  String get vocab_lastTrained;

  /// No description provided for @vocab_termsLabel.
  ///
  /// In en, this message translates to:
  /// **'terms:'**
  String get vocab_termsLabel;

  /// No description provided for @vocab_studiedLabel.
  ///
  /// In en, this message translates to:
  /// **'Studied:'**
  String get vocab_studiedLabel;

  /// No description provided for @vocab_masteryLabel.
  ///
  /// In en, this message translates to:
  /// **'Mastery:'**
  String get vocab_masteryLabel;

  /// No description provided for @vocab_nextStarIn.
  ///
  /// In en, this message translates to:
  /// **'next star in {percent}%'**
  String vocab_nextStarIn(int percent);

  /// No description provided for @result_techWork.
  ///
  /// In en, this message translates to:
  /// **'Tech work — no progress contribution'**
  String get result_techWork;

  /// No description provided for @language_progressionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No progress have been made. Time to start learning languages!'**
  String get language_progressionEmpty;

  /// No description provided for @language_resetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset progress'**
  String get language_resetConfirmTitle;

  /// No description provided for @language_resetConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Reset all progress for {language}? This cannot be undone.'**
  String language_resetConfirmBody(String language);

  /// No description provided for @language_resetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get language_resetButton;

  /// No description provided for @result_correctTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Correct'**
  String get result_correctTitle;

  /// No description provided for @result_correctSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Words you answered correctly'**
  String get result_correctSubtitle;

  /// No description provided for @bugReport_title.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get bugReport_title;

  /// No description provided for @bugReport_typeBadTranslation.
  ///
  /// In en, this message translates to:
  /// **'Bad translation'**
  String get bugReport_typeBadTranslation;

  /// No description provided for @bugReport_typeUiBug.
  ///
  /// In en, this message translates to:
  /// **'UI bug'**
  String get bugReport_typeUiBug;

  /// No description provided for @bugReport_messagePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue...'**
  String get bugReport_messagePlaceholder;

  /// No description provided for @bugReport_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get bugReport_submit;

  /// No description provided for @settings_validateConfigs.
  ///
  /// In en, this message translates to:
  /// **'Validate All Configs'**
  String get settings_validateConfigs;

  /// No description provided for @settings_validateSuccess.
  ///
  /// In en, this message translates to:
  /// **'All configs valid'**
  String get settings_validateSuccess;

  /// No description provided for @settings_validateError.
  ///
  /// In en, this message translates to:
  /// **'Validation failed: {message}'**
  String settings_validateError(String message);

  /// No description provided for @settings_seeds.
  ///
  /// In en, this message translates to:
  /// **'Seeds'**
  String get settings_seeds;

  /// No description provided for @settings_seedFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get settings_seedFull;

  /// No description provided for @settings_deleteContent.
  ///
  /// In en, this message translates to:
  /// **'Delete content'**
  String get settings_deleteContent;

  /// No description provided for @settings_seedError.
  ///
  /// In en, this message translates to:
  /// **'Seed failed: {message}'**
  String settings_seedError(String message);

  /// No description provided for @settings_contentDeleted.
  ///
  /// In en, this message translates to:
  /// **'Content deleted'**
  String get settings_contentDeleted;

  /// No description provided for @language_aiDictionaryWarning.
  ///
  /// In en, this message translates to:
  /// **'AI-generated dictionary. May contain errors. Human review in progress — use at your own risk.'**
  String get language_aiDictionaryWarning;

  /// No description provided for @language_pairUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This language pair is not available yet.'**
  String get language_pairUnavailable;

  /// No description provided for @language_aiGeneratedTitle.
  ///
  /// In en, this message translates to:
  /// **'AI generated'**
  String get language_aiGeneratedTitle;

  /// No description provided for @language_aiGeneratedNote.
  ///
  /// In en, this message translates to:
  /// **'The decks of these languages were generated by AI and only partly checked by experts. You can use them: they are mostly good, but mistakes can still occur.'**
  String get language_aiGeneratedNote;

  /// No description provided for @termCard_gender.
  ///
  /// In en, this message translates to:
  /// **'Gender: {gender}'**
  String termCard_gender(String gender);

  /// No description provided for @termCard_example.
  ///
  /// In en, this message translates to:
  /// **'Example:'**
  String get termCard_example;

  /// No description provided for @termCard_cocaRank.
  ///
  /// In en, this message translates to:
  /// **'COCA rank: {rank}'**
  String termCard_cocaRank(int rank);

  /// No description provided for @termCard_soundSemantics.
  ///
  /// In en, this message translates to:
  /// **'Pronounce'**
  String get termCard_soundSemantics;

  /// No description provided for @termCard_soundFailed.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation unavailable'**
  String get termCard_soundFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'pt',
    'ru',
    'sr',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'sr':
      return AppLocalizationsSr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

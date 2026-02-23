import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Srpski Card'**
  String get appTitle;

  /// No description provided for @appBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Srpski'**
  String get appBarTitle;

  /// No description provided for @parentVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get parentVocabulary;

  /// No description provided for @parentConjugations.
  ///
  /// In en, this message translates to:
  /// **'Conjugations'**
  String get parentConjugations;

  /// No description provided for @parentAgreement.
  ///
  /// In en, this message translates to:
  /// **'Gender agreements'**
  String get parentAgreement;

  /// No description provided for @agreementSessionGender.
  ///
  /// In en, this message translates to:
  /// **'Gender: {gender}'**
  String agreementSessionGender(String gender);

  /// No description provided for @groupWords.
  ///
  /// In en, this message translates to:
  /// **'Basic verbs'**
  String get groupWords;

  /// No description provided for @groupBasicVerbs01.
  ///
  /// In en, this message translates to:
  /// **'Basic verbs 01'**
  String get groupBasicVerbs01;

  /// No description provided for @groupBasicVerbs02.
  ///
  /// In en, this message translates to:
  /// **'Basic verbs 02'**
  String get groupBasicVerbs02;

  /// No description provided for @groupBasicVerbs03.
  ///
  /// In en, this message translates to:
  /// **'Basic verbs 03'**
  String get groupBasicVerbs03;

  /// No description provided for @groupBasicVerbs04.
  ///
  /// In en, this message translates to:
  /// **'Basic verbs 04'**
  String get groupBasicVerbs04;

  /// No description provided for @groupBasicVerbs05.
  ///
  /// In en, this message translates to:
  /// **'Basic verbs 05'**
  String get groupBasicVerbs05;

  /// No description provided for @groupBasicVerbs06.
  ///
  /// In en, this message translates to:
  /// **'Basic verbs 06'**
  String get groupBasicVerbs06;

  /// No description provided for @groupBasicVerbs07.
  ///
  /// In en, this message translates to:
  /// **'Basic verbs 07'**
  String get groupBasicVerbs07;

  /// No description provided for @groupBasicVerbs08.
  ///
  /// In en, this message translates to:
  /// **'Basic verbs 08'**
  String get groupBasicVerbs08;

  /// No description provided for @groupBasicVerbs09.
  ///
  /// In en, this message translates to:
  /// **'Basic verbs 09'**
  String get groupBasicVerbs09;

  /// No description provided for @groupBasicVerbs10.
  ///
  /// In en, this message translates to:
  /// **'Basic verbs 10'**
  String get groupBasicVerbs10;

  /// No description provided for @groupBasicVerbs11.
  ///
  /// In en, this message translates to:
  /// **'Basic verbs 11'**
  String get groupBasicVerbs11;

  /// No description provided for @groupAdverbsOfTime.
  ///
  /// In en, this message translates to:
  /// **'Adverbs of time'**
  String get groupAdverbsOfTime;

  /// No description provided for @groupPrepositions.
  ///
  /// In en, this message translates to:
  /// **'Prepositions'**
  String get groupPrepositions;

  /// No description provided for @groupDemonstrativePronouns.
  ///
  /// In en, this message translates to:
  /// **'Demonstrative Pronouns'**
  String get groupDemonstrativePronouns;

  /// No description provided for @groupRelativeDirection.
  ///
  /// In en, this message translates to:
  /// **'Relative Direction'**
  String get groupRelativeDirection;

  /// No description provided for @groupDegreeAndQuantity.
  ///
  /// In en, this message translates to:
  /// **'Degree & Quantity'**
  String get groupDegreeAndQuantity;

  /// No description provided for @groupPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get groupPeople;

  /// No description provided for @groupPlaces.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get groupPlaces;

  /// No description provided for @groupDailyItemsAndObjects.
  ///
  /// In en, this message translates to:
  /// **'Daily Items & Objects'**
  String get groupDailyItemsAndObjects;

  /// No description provided for @groupTimeAndNature.
  ///
  /// In en, this message translates to:
  /// **'Time & Nature'**
  String get groupTimeAndNature;

  /// No description provided for @groupAbstractConcepts.
  ///
  /// In en, this message translates to:
  /// **'Abstract Concepts'**
  String get groupAbstractConcepts;

  /// No description provided for @groupGeneralQualities.
  ///
  /// In en, this message translates to:
  /// **'General Qualities'**
  String get groupGeneralQualities;

  /// No description provided for @groupPeopleAndEmotions.
  ///
  /// In en, this message translates to:
  /// **'People & Emotions'**
  String get groupPeopleAndEmotions;

  /// No description provided for @groupSensesAndFeelings.
  ///
  /// In en, this message translates to:
  /// **'Senses & Feelings'**
  String get groupSensesAndFeelings;

  /// No description provided for @groupColors.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get groupColors;

  /// No description provided for @vocabSectionSettingWords.
  ///
  /// In en, this message translates to:
  /// **'Setting words'**
  String get vocabSectionSettingWords;

  /// No description provided for @vocabSectionBasicNouns.
  ///
  /// In en, this message translates to:
  /// **'Basic nouns'**
  String get vocabSectionBasicNouns;

  /// No description provided for @vocabSectionBasicAdjectives.
  ///
  /// In en, this message translates to:
  /// **'Basic adjectives'**
  String get vocabSectionBasicAdjectives;

  /// No description provided for @wordsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} words'**
  String wordsCount(int count);

  /// No description provided for @wordsCountWithPreview.
  ///
  /// In en, this message translates to:
  /// **'{count} words: {preview}'**
  String wordsCountWithPreview(int count, String preview);

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

  /// No description provided for @chooseMode.
  ///
  /// In en, this message translates to:
  /// **'Choose mode'**
  String get chooseMode;

  /// No description provided for @modeSerbianShown.
  ///
  /// In en, this message translates to:
  /// **'Serbian shown (pick English)'**
  String get modeSerbianShown;

  /// No description provided for @modeEnglishShown.
  ///
  /// In en, this message translates to:
  /// **'English shown (pick Serbian)'**
  String get modeEnglishShown;

  /// No description provided for @modeWrite.
  ///
  /// In en, this message translates to:
  /// **'Write (type Serbian)'**
  String get modeWrite;

  /// No description provided for @chooseQuestionsCount.
  ///
  /// In en, this message translates to:
  /// **'How many questions?'**
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

  /// No description provided for @questions50.
  ///
  /// In en, this message translates to:
  /// **'50'**
  String get questions50;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

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
  /// **'Session result'**
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
  /// **'Cards you got wrong (Serbian → English)'**
  String get reviewWrongSubtitle;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @backToGroups.
  ///
  /// In en, this message translates to:
  /// **'Back to groups'**
  String get backToGroups;

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

  /// No description provided for @exitSession.
  ///
  /// In en, this message translates to:
  /// **'Exit session'**
  String get exitSession;

  /// No description provided for @exitSessionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Exit session? Your progress will be lost.'**
  String get exitSessionConfirm;

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

  /// No description provided for @trainHeader.
  ///
  /// In en, this message translates to:
  /// **'TRAIN'**
  String get trainHeader;

  /// No description provided for @testHeader.
  ///
  /// In en, this message translates to:
  /// **'TESTING'**
  String get testHeader;

  /// No description provided for @modeEngCards.
  ///
  /// In en, this message translates to:
  /// **'ENG CARDS'**
  String get modeEngCards;

  /// No description provided for @modeSrpskiCards.
  ///
  /// In en, this message translates to:
  /// **'SRPSKI CARDS'**
  String get modeSrpskiCards;

  /// No description provided for @modeWriting.
  ///
  /// In en, this message translates to:
  /// **'WRITING'**
  String get modeWriting;

  /// No description provided for @modeTest.
  ///
  /// In en, this message translates to:
  /// **'TEST'**
  String get modeTest;

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

  /// No description provided for @retentionNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get retentionNone;

  /// No description provided for @retentionWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get retentionWeak;

  /// No description provided for @retentionGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get retentionGood;

  /// No description provided for @retentionStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get retentionStrong;

  /// No description provided for @retentionSuper.
  ///
  /// In en, this message translates to:
  /// **'Super'**
  String get retentionSuper;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsDecaySpeed.
  ///
  /// In en, this message translates to:
  /// **'Learning pace'**
  String get settingsDecaySpeed;

  /// No description provided for @decayRelaxed.
  ///
  /// In en, this message translates to:
  /// **'Relaxed'**
  String get decayRelaxed;

  /// No description provided for @decayRelaxedDesc.
  ///
  /// In en, this message translates to:
  /// **'Slow decay (14 days)'**
  String get decayRelaxedDesc;

  /// No description provided for @decayStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get decayStandard;

  /// No description provided for @decayStandardDesc.
  ///
  /// In en, this message translates to:
  /// **'Balanced (7 days)'**
  String get decayStandardDesc;

  /// No description provided for @decayIntensive.
  ///
  /// In en, this message translates to:
  /// **'Intensive'**
  String get decayIntensive;

  /// No description provided for @decayIntensiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Fast decay (4 days)'**
  String get decayIntensiveDesc;

  /// No description provided for @decayHardcore.
  ///
  /// In en, this message translates to:
  /// **'Hardcore'**
  String get decayHardcore;

  /// No description provided for @decayHardcoreDesc.
  ///
  /// In en, this message translates to:
  /// **'Very fast (2 days)'**
  String get decayHardcoreDesc;

  /// No description provided for @navLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get navLanguage;

  /// No description provided for @navVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get navVocabulary;

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

  /// No description provided for @underDevelopmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get underDevelopmentTitle;

  /// No description provided for @underDevelopmentBody.
  ///
  /// In en, this message translates to:
  /// **'This feature is under development.'**
  String get underDevelopmentBody;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

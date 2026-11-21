// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Langwij';

  @override
  String get parentAgreement => 'Accords en genre';

  @override
  String get groupWords => 'Verbes de base';

  @override
  String wordsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mots',
      one: '$count mot',
    );
    return '$_temp0';
  }

  @override
  String vocab_termsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count termes',
      one: '$count terme',
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
  String get groupIrregular => 'Irréguliers';

  @override
  String get chooseQuestionsCount => 'Combien de termes ?';

  @override
  String get questions5 => '5';

  @override
  String get questions10 => '10';

  @override
  String get questions20 => '20';

  @override
  String get cancel => 'Annuler';

  @override
  String get next => 'Suivant';

  @override
  String get submit => 'Valider';

  @override
  String get yourAnswer => 'Ta réponse';

  @override
  String get correct => 'Correct';

  @override
  String get wrong => 'Faux';

  @override
  String get resultTitle => 'Résultat de la manche';

  @override
  String correctCount(int count) {
    return 'Correct : $count';
  }

  @override
  String wrongCount(int count) {
    return 'Faux : $count';
  }

  @override
  String get reviewWrongTitle => 'Cartes ratées';

  @override
  String get reviewWrongSubtitle => 'Cartes avec une mauvaise réponse';

  @override
  String get again => 'Encore';

  @override
  String get back => 'Retour';

  @override
  String get pageNotFound => 'Page introuvable';

  @override
  String get loadError => 'Impossible de charger les groupes. Réessaie.';

  @override
  String get correctAnswerLabel => 'Bonne réponse :';

  @override
  String get youWrote => 'Tu as écrit :';

  @override
  String get youPicked => 'Tu as choisi :';

  @override
  String get emptyAnswer => '(vide)';

  @override
  String get pronounYouInformal => 'tu (informel, singulier)';

  @override
  String get pronounYouFormal => 'vous (formel, pluriel)';

  @override
  String questionsLeft(int count) {
    return 'Restant : $count';
  }

  @override
  String get exitRound => 'Quitter la manche';

  @override
  String get exitRoundConfirm =>
      'Quitter la manche ? Ta progression sera perdue.';

  @override
  String get exit => 'Quitter';

  @override
  String get dailyActivityTitle => 'Aujourd\'hui';

  @override
  String get dailyActivityEmpty => 'Aucune activité aujourd\'hui';

  @override
  String get mode_guessingHeader => 'Deviner';

  @override
  String get mode_writingHeader => 'Écrire';

  @override
  String mode_langCards(String language) {
    return 'Cartes : $language';
  }

  @override
  String get mode_training => 'Entraînement';

  @override
  String get mode_test => 'Test';

  @override
  String get relativeDateToday => 'aujourd\'hui';

  @override
  String get relativeDateYesterday => 'hier';

  @override
  String relativeDateDays(int count) {
    return 'il y a $count j';
  }

  @override
  String relativeDateMonths(int count) {
    return 'il y a $count mois';
  }

  @override
  String relativeDateYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count ans',
      one: 'il y a $count an',
    );
    return '$_temp0';
  }

  @override
  String questionsAll(int count) {
    return 'TOUT ($count)';
  }

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get navLanguage => 'Langue';

  @override
  String get navProgress => 'Progression';

  @override
  String get navVocabulary => 'Vocabulaire';

  @override
  String get navSpecialized => 'Spécialisé';

  @override
  String get navTools => 'Outils';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get navLabelVocabulary => 'Top1000';

  @override
  String get navLabelSpecialized => 'Spécial';

  @override
  String get navLabelTools => 'Outils';

  @override
  String get navLabelLanguage => 'Langue';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get lang_english => 'Anglais';

  @override
  String get lang_serbian => 'Serbe';

  @override
  String get lang_russian => 'Russe';

  @override
  String get lang_italian => 'Italien';

  @override
  String get lang_french => 'Français';

  @override
  String get lang_spanish => 'Espagnol';

  @override
  String get lang_portuguese => 'Portugais';

  @override
  String get lang_german => 'Allemand';

  @override
  String get language_iSpeak => 'Je parle';

  @override
  String get language_iLearn => 'J\'apprends';

  @override
  String language_qualityAi(int aiPct) {
    return '$aiPct % fait par IA';
  }

  @override
  String language_qualityHuman(int humanPct) {
    return '$humanPct % fait par des humains';
  }

  @override
  String get language_progression => 'Progression';

  @override
  String get language_incompleteDictionaries => 'Dictionnaires incomplets';

  @override
  String language_termsCount(int done, int total) {
    return '$done/$total termes';
  }

  @override
  String get tools_conjugations => 'Conjugaisons';

  @override
  String get tools_agreement => 'Accord en genre';

  @override
  String get tools_emptyState => 'Aucun outil disponible pour cette langue';

  @override
  String get settingsHide => 'Masquer';

  @override
  String get settingsDeveloper => 'Développeur';

  @override
  String get dev_enterPassword => 'Salut';

  @override
  String get dev_unlock => 'Déverrouiller';

  @override
  String get dev_wrongPassword => 'Eh non !';

  @override
  String get quiz_aspectImperfective => 'Imperfectif :';

  @override
  String get quiz_aspectPerfective => 'Perfectif :';

  @override
  String get quiz_aspectPairPrompt => 'Saisis les deux formes d\'aspect';

  @override
  String get vocab_train => 'S\'entraîner';

  @override
  String get vocab_studied => 'Étudié';

  @override
  String get vocab_trained => 'Entraîné';

  @override
  String get vocab_lastTrained => 'dernier entraînement :';

  @override
  String get vocab_termsLabel => 'termes :';

  @override
  String get vocab_masteryLabel => 'maîtrise :';

  @override
  String vocab_masteryCount(int count) {
    return 'maîtrise : $count';
  }

  @override
  String get result_techWork =>
      'Travail technique — ne compte pas dans la progression';

  @override
  String get language_progressionEmpty =>
      'Aucune progression pour l\'instant. Il est temps d\'apprendre des langues !';

  @override
  String get language_resetConfirmTitle => 'Réinitialiser la progression';

  @override
  String language_resetConfirmBody(String language) {
    return 'Réinitialiser toute la progression pour : $language ? Cette action est irréversible.';
  }

  @override
  String get language_resetButton => 'Réinitialiser';

  @override
  String get result_correctTitle => 'Bonnes réponses';

  @override
  String get result_correctSubtitle => 'Mots avec une bonne réponse';

  @override
  String get bugReport_title => 'Signaler un problème';

  @override
  String get bugReport_typeBadTranslation => 'Mauvaise traduction';

  @override
  String get bugReport_typeUiBug => 'Bug d\'interface';

  @override
  String get bugReport_messagePlaceholder => 'Décris le problème...';

  @override
  String get bugReport_submit => 'Envoyer';

  @override
  String get settings_validateConfigs => 'Valider toutes les configurations';

  @override
  String get settings_validateSuccess =>
      'Toutes les configurations sont valides';

  @override
  String settings_validateError(String message) {
    return 'Échec de la validation : $message';
  }

  @override
  String get settings_seeds => 'Données de test';

  @override
  String get settings_seedFull => 'Complet';

  @override
  String get settings_deleteContent => 'Supprimer le contenu';

  @override
  String settings_seedError(String message) {
    return 'Échec des données de test : $message';
  }

  @override
  String get settings_contentDeleted => 'Contenu supprimé';

  @override
  String get language_aiDictionaryWarning =>
      'Dictionnaire généré par IA. Il peut contenir des erreurs. Relecture humaine en cours — à utiliser à tes risques et périls.';

  @override
  String get language_pairUnavailable =>
      'Cette paire de langues n\'est pas encore disponible.';

  @override
  String termCard_gender(String gender) {
    return 'Genre : $gender';
  }

  @override
  String get termCard_example => 'Exemple :';

  @override
  String termCard_cocaRank(int rank) {
    return 'Rang COCA : $rank';
  }

  @override
  String get termCard_soundSemantics => 'Prononcer';

  @override
  String get termCard_soundFailed => 'Prononciation indisponible';
}

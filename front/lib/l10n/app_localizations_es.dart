// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Langwij';

  @override
  String get parentAgreement => 'Concordancia de género';

  @override
  String get groupWords => 'Verbos básicos';

  @override
  String wordsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palabras',
      one: '$count palabra',
    );
    return '$_temp0';
  }

  @override
  String vocab_termsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count términos',
      one: '$count término',
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
  String get groupIrregular => 'Irregulares';

  @override
  String get chooseQuestionsCount => '¿Cuántos términos?';

  @override
  String get questions5 => '5';

  @override
  String get questions10 => '10';

  @override
  String get questions20 => '20';

  @override
  String get cancel => 'Cancelar';

  @override
  String get next => 'Siguiente';

  @override
  String get submit => 'Responder';

  @override
  String get yourAnswer => 'Tu respuesta';

  @override
  String get correct => 'Correcto';

  @override
  String get wrong => 'Incorrecto';

  @override
  String get resultTitle => 'Resultado de la ronda';

  @override
  String correctCount(int count) {
    return 'Correctas: $count';
  }

  @override
  String wrongCount(int count) {
    return 'Incorrectas: $count';
  }

  @override
  String get reviewWrongTitle => 'Tarjetas falladas';

  @override
  String get reviewWrongSubtitle => 'Tarjetas con respuesta incorrecta';

  @override
  String get again => 'Otra vez';

  @override
  String get back => 'Atrás';

  @override
  String get pageNotFound => 'Página no encontrada';

  @override
  String get loadError =>
      'No se pudieron cargar los grupos. Inténtalo de nuevo.';

  @override
  String get correctAnswerLabel => 'Respuesta correcta:';

  @override
  String get youWrote => 'Escribiste:';

  @override
  String get youPicked => 'Elegiste:';

  @override
  String get emptyAnswer => '(vacío)';

  @override
  String get pronounYouInformal => 'tú (informal, singular)';

  @override
  String get pronounYouFormal => 'vosotros/usted (formal, plural)';

  @override
  String questionsLeft(int count) {
    return 'Quedan: $count';
  }

  @override
  String get exitRound => 'Salir de la ronda';

  @override
  String get exitRoundConfirm => '¿Salir de la ronda? Perderás tu progreso.';

  @override
  String get exit => 'Salir';

  @override
  String get dailyActivityTitle => 'Hoy';

  @override
  String get dailyActivityEmpty => 'Sin actividad hoy';

  @override
  String get mode_guessingHeader => 'Tarjetas';

  @override
  String get mode_writingHeader => 'Escritura';

  @override
  String mode_langCards(String language) {
    return 'Tarjetas: $language';
  }

  @override
  String get mode_training => 'Entrenamiento';

  @override
  String get mode_test => 'Prueba';

  @override
  String get relativeDateToday => 'hoy';

  @override
  String get relativeDateYesterday => 'ayer';

  @override
  String relativeDateDays(int count) {
    return 'hace $count d';
  }

  @override
  String relativeDateMonths(int count) {
    return 'hace $count m';
  }

  @override
  String relativeDateYears(int count) {
    return 'hace $count a';
  }

  @override
  String questionsAll(int count) {
    return 'TODO ($count)';
  }

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get navLanguage => 'Idioma';

  @override
  String get navProgress => 'Progreso';

  @override
  String get navVocabulary => 'Vocabulario';

  @override
  String get navSpecialized => 'Especializado';

  @override
  String get navTools => 'Herramientas';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get navLabelVocabulary => 'Top1000';

  @override
  String get navLabelSpecialized => 'Especial';

  @override
  String get navLabelTools => 'Herramientas';

  @override
  String get navLabelLanguage => 'Idioma';

  @override
  String get lang_english => 'Inglés';

  @override
  String get lang_serbian => 'Serbio';

  @override
  String get lang_russian => 'Ruso';

  @override
  String get lang_italian => 'Italiano';

  @override
  String get lang_french => 'Francés';

  @override
  String get lang_spanish => 'Español';

  @override
  String get lang_portuguese => 'Portugués';

  @override
  String get lang_german => 'Alemán';

  @override
  String get language_iSpeak => 'Hablo';

  @override
  String get language_iLearn => 'Aprendo';

  @override
  String language_iSpeakLanguage(String language) {
    return 'Hablo $language';
  }

  @override
  String language_iLearnLanguage(String language) {
    return 'Aprendo $language';
  }

  @override
  String get language_progression => 'Progresión';

  @override
  String get language_incompleteDictionaries => 'Diccionarios incompletos';

  @override
  String language_termsCount(int done, int total) {
    return '$done/$total términos';
  }

  @override
  String get tools_conjugations => 'Conjugaciones';

  @override
  String get tools_agreement => 'Concordancia de género';

  @override
  String get tools_emptyState => 'No hay herramientas para este idioma';

  @override
  String get settingsHide => 'Ocultar';

  @override
  String get settingsDeveloper => 'Desarrollador';

  @override
  String get dev_enterPassword => 'Hola';

  @override
  String get dev_unlock => 'Desbloquear';

  @override
  String get dev_wrongPassword => '¡Qué va!';

  @override
  String get quiz_aspectImperfective => 'Imperfectivo:';

  @override
  String get quiz_aspectPerfective => 'Perfectivo:';

  @override
  String get quiz_aspectPairPrompt => 'Escribe ambas formas de aspecto';

  @override
  String get vocab_train => 'Entrenar';

  @override
  String get vocab_studied => 'Estudiado';

  @override
  String get vocab_trained => 'Entrenado';

  @override
  String get vocab_lastTrained => 'último entrenamiento:';

  @override
  String get vocab_termsLabel => 'términos:';

  @override
  String get vocab_studiedLabel => 'Estudiado:';

  @override
  String get vocab_masteryLabel => 'Dominio:';

  @override
  String vocab_nextStarIn(int percent) {
    return 'siguiente estrella en $percent%';
  }

  @override
  String get result_techWork => 'Trabajo técnico: no cuenta para el progreso';

  @override
  String get language_progressionEmpty =>
      'Aún no hay progreso. ¡Hora de empezar a aprender idiomas!';

  @override
  String get language_resetConfirmTitle => 'Restablecer progreso';

  @override
  String language_resetConfirmBody(String language) {
    return '¿Restablecer todo el progreso de $language? Esto no se puede deshacer.';
  }

  @override
  String get language_resetButton => 'Restablecer';

  @override
  String get result_correctTitle => 'Respuestas correctas';

  @override
  String get result_correctSubtitle => 'Palabras con respuesta correcta';

  @override
  String get bugReport_title => 'Informar de un problema';

  @override
  String get bugReport_typeBadTranslation => 'Mala traducción';

  @override
  String get bugReport_typeUiBug => 'Error de interfaz';

  @override
  String get bugReport_messagePlaceholder => 'Describe el problema...';

  @override
  String get bugReport_submit => 'Enviar';

  @override
  String get settings_validateConfigs => 'Validar todas las configuraciones';

  @override
  String get settings_validateSuccess =>
      'Todas las configuraciones son válidas';

  @override
  String settings_validateError(String message) {
    return 'Error de validación: $message';
  }

  @override
  String get settings_seeds => 'Datos de prueba';

  @override
  String get settings_seedFull => 'Completo';

  @override
  String get settings_deleteContent => 'Eliminar contenido';

  @override
  String settings_seedError(String message) {
    return 'Error en los datos de prueba: $message';
  }

  @override
  String get settings_contentDeleted => 'Contenido eliminado';

  @override
  String get language_aiWarningTitle => 'Aviso de IA';

  @override
  String get language_aiDictionaryWarning =>
      'Diccionario generado por IA. Puede contener errores. Revisión humana en curso: úsalo bajo tu propia responsabilidad.';

  @override
  String get language_aiGeneratedTitle => 'Generado por IA';

  @override
  String get language_aiGeneratedNote =>
      'Los mazos de estos idiomas fueron generados por IA y solo en parte revisados por expertos. Puedes usarlos: en su mayoría son buenos, pero aún puede haber errores.';

  @override
  String get language_inDevelopmentTitle => 'En desarrollo';

  @override
  String termCard_gender(String gender) {
    return 'Género: $gender';
  }

  @override
  String get termCard_example => 'Ejemplo:';

  @override
  String termCard_cocaRank(int rank) {
    return 'Frecuencia: $rank';
  }

  @override
  String termCard_article(String article) {
    return 'Artículo: $article';
  }

  @override
  String termCard_aspect(String aspect) {
    return 'Aspecto: $aspect';
  }

  @override
  String get termCard_typePhrase => 'Frase';

  @override
  String get termCard_typeInterrogative => 'Interrogativo';

  @override
  String get termCard_typePronoun => 'Pronombre';

  @override
  String get termCard_typePreposition => 'Preposición';

  @override
  String get termCard_typeConjunction => 'Conjunción';

  @override
  String get termCard_typeNumeral => 'Numeral';

  @override
  String get termCard_typeVerb => 'Verbo';

  @override
  String get termCard_typeAdverb => 'Adverbio';

  @override
  String get termCard_typeAdjective => 'Adjetivo';

  @override
  String get termCard_typeNoun => 'Sustantivo';

  @override
  String get termCard_genderMasculine => 'masculino';

  @override
  String get termCard_genderFeminine => 'femenino';

  @override
  String get termCard_genderNeuter => 'neutro';

  @override
  String get termCard_aspectImperfective => 'imperfectivo';

  @override
  String get termCard_aspectPerfective => 'perfectivo';

  @override
  String get termCard_soundSemantics => 'Pronunciar';

  @override
  String get termCard_soundFailed => 'Pronunciación no disponible';
}

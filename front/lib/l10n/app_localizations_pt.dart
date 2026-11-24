// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Langwij';

  @override
  String get parentAgreement => 'Concordância de género';

  @override
  String get groupWords => 'Verbos básicos';

  @override
  String wordsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palavras',
      one: '$count palavra',
    );
    return '$_temp0';
  }

  @override
  String vocab_termsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count termos',
      one: '$count termo',
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
  String get chooseQuestionsCount => 'Quantos termos?';

  @override
  String get questions5 => '5';

  @override
  String get questions10 => '10';

  @override
  String get questions20 => '20';

  @override
  String get cancel => 'Cancelar';

  @override
  String get next => 'Seguinte';

  @override
  String get submit => 'Responder';

  @override
  String get yourAnswer => 'A tua resposta';

  @override
  String get correct => 'Certo';

  @override
  String get wrong => 'Errado';

  @override
  String get resultTitle => 'Resultado da ronda';

  @override
  String correctCount(int count) {
    return 'Certas: $count';
  }

  @override
  String wrongCount(int count) {
    return 'Erradas: $count';
  }

  @override
  String get reviewWrongTitle => 'Cartões falhados';

  @override
  String get reviewWrongSubtitle => 'Cartões com resposta errada';

  @override
  String get again => 'Outra vez';

  @override
  String get back => 'Voltar';

  @override
  String get pageNotFound => 'Página não encontrada';

  @override
  String get loadError =>
      'Não foi possível carregar os grupos. Tenta outra vez.';

  @override
  String get correctAnswerLabel => 'Resposta certa:';

  @override
  String get youWrote => 'Escreveste:';

  @override
  String get youPicked => 'Escolheste:';

  @override
  String get emptyAnswer => '(vazio)';

  @override
  String get pronounYouInformal => 'tu (informal, singular)';

  @override
  String get pronounYouFormal => 'vós/você (formal, plural)';

  @override
  String questionsLeft(int count) {
    return 'Restam: $count';
  }

  @override
  String get exitRound => 'Sair da ronda';

  @override
  String get exitRoundConfirm => 'Sair da ronda? O teu progresso será perdido.';

  @override
  String get exit => 'Sair';

  @override
  String get dailyActivityTitle => 'Hoje';

  @override
  String get dailyActivityEmpty => 'Sem atividade hoje';

  @override
  String get mode_guessingHeader => 'Cartões';

  @override
  String get mode_writingHeader => 'Digitação';

  @override
  String mode_langCards(String language) {
    return 'Cartões: $language';
  }

  @override
  String get mode_training => 'Treino';

  @override
  String get mode_test => 'Teste';

  @override
  String get relativeDateToday => 'hoje';

  @override
  String get relativeDateYesterday => 'ontem';

  @override
  String relativeDateDays(int count) {
    return 'há $count d';
  }

  @override
  String relativeDateMonths(int count) {
    return 'há $count m';
  }

  @override
  String relativeDateYears(int count) {
    return 'há $count a';
  }

  @override
  String questionsAll(int count) {
    return 'TUDO ($count)';
  }

  @override
  String get settingsTitle => 'Definições';

  @override
  String get navLanguage => 'Idioma';

  @override
  String get navProgress => 'Progresso';

  @override
  String get navVocabulary => 'Vocabulário';

  @override
  String get navSpecialized => 'Especializado';

  @override
  String get navTools => 'Ferramentas';

  @override
  String get navSettings => 'Definições';

  @override
  String get navLabelVocabulary => 'Top1000';

  @override
  String get navLabelSpecialized => 'Especial';

  @override
  String get navLabelTools => 'Ferramentas';

  @override
  String get navLabelLanguage => 'Idioma';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get lang_english => 'Inglês';

  @override
  String get lang_serbian => 'Sérvio';

  @override
  String get lang_russian => 'Russo';

  @override
  String get lang_italian => 'Italiano';

  @override
  String get lang_french => 'Francês';

  @override
  String get lang_spanish => 'Espanhol';

  @override
  String get lang_portuguese => 'Português';

  @override
  String get lang_german => 'Alemão';

  @override
  String get language_iSpeak => 'Falo';

  @override
  String get language_iLearn => 'Aprendo';

  @override
  String language_qualityAi(int aiPct) {
    return '$aiPct% feito por IA';
  }

  @override
  String language_qualityHuman(int humanPct) {
    return '$humanPct% feito por humanos';
  }

  @override
  String get language_progression => 'Progressão';

  @override
  String get language_incompleteDictionaries => 'Dicionários incompletos';

  @override
  String language_termsCount(int done, int total) {
    return '$done/$total termos';
  }

  @override
  String get tools_conjugations => 'Conjugações';

  @override
  String get tools_agreement => 'Concordância de género';

  @override
  String get tools_emptyState => 'Não há ferramentas para este idioma';

  @override
  String get settingsHide => 'Ocultar';

  @override
  String get settingsDeveloper => 'Programador';

  @override
  String get dev_enterPassword => 'Olá';

  @override
  String get dev_unlock => 'Desbloquear';

  @override
  String get dev_wrongPassword => 'Nada disso!';

  @override
  String get quiz_aspectImperfective => 'Imperfetivo:';

  @override
  String get quiz_aspectPerfective => 'Perfetivo:';

  @override
  String get quiz_aspectPairPrompt => 'Escreve ambas as formas de aspeto';

  @override
  String get vocab_train => 'Treinar';

  @override
  String get vocab_studied => 'Estudado';

  @override
  String get vocab_trained => 'Treinado';

  @override
  String get vocab_lastTrained => 'último treino:';

  @override
  String get vocab_termsLabel => 'termos:';

  @override
  String get vocab_studiedLabel => 'Estudado:';

  @override
  String get vocab_masteryLabel => 'Domínio:';

  @override
  String vocab_nextStarIn(int percent) {
    return 'próxima estrela em $percent%';
  }

  @override
  String get result_techWork => 'Trabalho técnico — não conta para o progresso';

  @override
  String get language_progressionEmpty =>
      'Ainda não há progresso. Está na hora de começar a aprender línguas!';

  @override
  String get language_resetConfirmTitle => 'Repor progresso';

  @override
  String language_resetConfirmBody(String language) {
    return 'Repor todo o progresso de $language? Isto não pode ser desfeito.';
  }

  @override
  String get language_resetButton => 'Repor';

  @override
  String get result_correctTitle => 'Respostas certas';

  @override
  String get result_correctSubtitle => 'Palavras com resposta certa';

  @override
  String get bugReport_title => 'Comunicar problema';

  @override
  String get bugReport_typeBadTranslation => 'Má tradução';

  @override
  String get bugReport_typeUiBug => 'Erro de interface';

  @override
  String get bugReport_messagePlaceholder => 'Descreve o problema...';

  @override
  String get bugReport_submit => 'Enviar';

  @override
  String get settings_validateConfigs => 'Validar todas as configurações';

  @override
  String get settings_validateSuccess => 'Todas as configurações são válidas';

  @override
  String settings_validateError(String message) {
    return 'Falha na validação: $message';
  }

  @override
  String get settings_seeds => 'Dados de teste';

  @override
  String get settings_seedFull => 'Completo';

  @override
  String get settings_deleteContent => 'Eliminar conteúdo';

  @override
  String settings_seedError(String message) {
    return 'Falha nos dados de teste: $message';
  }

  @override
  String get settings_contentDeleted => 'Conteúdo eliminado';

  @override
  String get language_aiDictionaryWarning =>
      'Dicionário gerado por IA. Pode conter erros. Revisão humana em curso — usa por tua conta e risco.';

  @override
  String get language_pairUnavailable =>
      'Este par de idiomas ainda não está disponível.';

  @override
  String get language_aiGeneratedTitle => 'Gerado por IA';

  @override
  String get language_aiGeneratedNote =>
      'Os baralhos destes idiomas foram gerados por IA e apenas em parte verificados por especialistas. Podes usá-los: são bons na sua maioria, mas ainda podem existir erros.';

  @override
  String termCard_gender(String gender) {
    return 'Género: $gender';
  }

  @override
  String get termCard_example => 'Exemplo:';

  @override
  String termCard_cocaRank(int rank) {
    return 'Posição COCA: $rank';
  }

  @override
  String get termCard_soundSemantics => 'Pronunciar';

  @override
  String get termCard_soundFailed => 'Pronúncia indisponível';
}

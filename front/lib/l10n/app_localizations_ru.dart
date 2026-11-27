// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Langwij';

  @override
  String get parentAgreement => 'Согласование по роду';

  @override
  String get groupWords => 'Базовые глаголы';

  @override
  String wordsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count слова',
      many: '$count слов',
      few: '$count слова',
      one: '$count слово',
    );
    return '$_temp0';
  }

  @override
  String vocab_termsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count термина',
      many: '$count терминов',
      few: '$count термина',
      one: '$count термин',
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
  String get groupIrregular => 'Неправильные';

  @override
  String get chooseQuestionsCount => 'Сколько терминов?';

  @override
  String get questions5 => '5';

  @override
  String get questions10 => '10';

  @override
  String get questions20 => '20';

  @override
  String get cancel => 'Отмена';

  @override
  String get next => 'Далее';

  @override
  String get submit => 'Ответить';

  @override
  String get yourAnswer => 'Твой ответ';

  @override
  String get correct => 'Верно';

  @override
  String get wrong => 'Неверно';

  @override
  String get resultTitle => 'Итог раунда';

  @override
  String correctCount(int count) {
    return 'Верно: $count';
  }

  @override
  String wrongCount(int count) {
    return 'Неверно: $count';
  }

  @override
  String get reviewWrongTitle => 'Ошибки';

  @override
  String get reviewWrongSubtitle => 'Карточки с неверным ответом';

  @override
  String get again => 'Ещё раз';

  @override
  String get back => 'Назад';

  @override
  String get pageNotFound => 'Страница не найдена';

  @override
  String get loadError => 'Не удалось загрузить группы. Попробуй ещё раз.';

  @override
  String get correctAnswerLabel => 'Верный ответ:';

  @override
  String get youWrote => 'Введено:';

  @override
  String get youPicked => 'Выбрано:';

  @override
  String get emptyAnswer => '(пусто)';

  @override
  String get pronounYouInformal => 'ты (неформально, ед. число)';

  @override
  String get pronounYouFormal => 'вы (формально, мн. число)';

  @override
  String questionsLeft(int count) {
    return 'Осталось: $count';
  }

  @override
  String get exitRound => 'Выйти из раунда';

  @override
  String get exitRoundConfirm => 'Выйти из раунда? Прогресс будет потерян.';

  @override
  String get exit => 'Выйти';

  @override
  String get dailyActivityTitle => 'Сегодня';

  @override
  String get dailyActivityEmpty => 'Сегодня активности нет';

  @override
  String get mode_guessingHeader => 'Карточки';

  @override
  String get mode_writingHeader => 'Ввод';

  @override
  String mode_langCards(String language) {
    return 'Карточки: $language';
  }

  @override
  String get mode_training => 'Тренировка';

  @override
  String get mode_test => 'Тест';

  @override
  String get relativeDateToday => 'сегодня';

  @override
  String get relativeDateYesterday => 'вчера';

  @override
  String relativeDateDays(int count) {
    return '$count дн. назад';
  }

  @override
  String relativeDateMonths(int count) {
    return '$count мес. назад';
  }

  @override
  String relativeDateYears(int count) {
    return '$count г. назад';
  }

  @override
  String questionsAll(int count) {
    return 'ВСЕ ($count)';
  }

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get navLanguage => 'Язык';

  @override
  String get navProgress => 'Прогресс';

  @override
  String get navVocabulary => 'Словарь';

  @override
  String get navSpecialized => 'Специализированный';

  @override
  String get navTools => 'Инструменты';

  @override
  String get navSettings => 'Настройки';

  @override
  String get navLabelVocabulary => 'Топ1000';

  @override
  String get navLabelSpecialized => 'Особое';

  @override
  String get navLabelTools => 'Инструменты';

  @override
  String get navLabelLanguage => 'Язык';

  @override
  String get lang_english => 'Английский';

  @override
  String get lang_serbian => 'Сербский';

  @override
  String get lang_russian => 'Русский';

  @override
  String get lang_italian => 'Итальянский';

  @override
  String get lang_french => 'Французский';

  @override
  String get lang_spanish => 'Испанский';

  @override
  String get lang_portuguese => 'Португальский';

  @override
  String get lang_german => 'Немецкий';

  @override
  String get language_iSpeak => 'Я говорю';

  @override
  String get language_iLearn => 'Я учу';

  @override
  String language_iSpeakLanguage(String language) {
    return 'Я говорю: $language';
  }

  @override
  String language_iLearnLanguage(String language) {
    return 'Я учу: $language';
  }

  @override
  String get language_progression => 'Продвижение';

  @override
  String get language_incompleteDictionaries => 'Неполные словари';

  @override
  String language_termsCount(int done, int total) {
    return '$done/$total терминов';
  }

  @override
  String get tools_conjugations => 'Спряжения';

  @override
  String get tools_agreement => 'Согласование по роду';

  @override
  String get tools_emptyState => 'Для этого языка инструментов нет';

  @override
  String get settingsHide => 'Скрыть';

  @override
  String get settingsDeveloper => 'Разработчик';

  @override
  String get dev_enterPassword => 'Привет';

  @override
  String get dev_unlock => 'Разблокировать';

  @override
  String get dev_wrongPassword => 'Не-а!';

  @override
  String get quiz_aspectImperfective => 'Несовершенный вид:';

  @override
  String get quiz_aspectPerfective => 'Совершенный вид:';

  @override
  String get quiz_aspectPairPrompt => 'Введи обе видовые формы';

  @override
  String get vocab_train => 'Тренировать';

  @override
  String get vocab_studied => 'Изучено';

  @override
  String get vocab_trained => 'Натренировано';

  @override
  String get vocab_lastTrained => 'последняя тренировка:';

  @override
  String get vocab_termsLabel => 'терминов:';

  @override
  String get vocab_studiedLabel => 'Изучено:';

  @override
  String get vocab_masteryLabel => 'Мастерство:';

  @override
  String vocab_nextStarIn(int percent) {
    return 'до следующей звезды $percent%';
  }

  @override
  String get result_techWork =>
      'Техническая работа — в прогресс не засчитывается';

  @override
  String get language_progressionEmpty =>
      'Прогресса пока нет. Пора учить языки!';

  @override
  String get language_resetConfirmTitle => 'Сбросить прогресс';

  @override
  String language_resetConfirmBody(String language) {
    return 'Сбросить весь прогресс для языка «$language»? Это действие нельзя отменить.';
  }

  @override
  String get language_resetButton => 'Сбросить';

  @override
  String get result_correctTitle => 'Верные ответы';

  @override
  String get result_correctSubtitle => 'Слова с верным ответом';

  @override
  String get bugReport_title => 'Сообщить о проблеме';

  @override
  String get bugReport_typeBadTranslation => 'Плохой перевод';

  @override
  String get bugReport_typeUiBug => 'Ошибка интерфейса';

  @override
  String get bugReport_messagePlaceholder => 'Опиши проблему...';

  @override
  String get bugReport_submit => 'Отправить';

  @override
  String get settings_validateConfigs => 'Проверить все конфигурации';

  @override
  String get settings_validateSuccess => 'Все конфигурации в порядке';

  @override
  String settings_validateError(String message) {
    return 'Проверка не пройдена: $message';
  }

  @override
  String get settings_seeds => 'Тестовые данные';

  @override
  String get settings_seedFull => 'Полный';

  @override
  String get settings_deleteContent => 'Удалить контент';

  @override
  String settings_seedError(String message) {
    return 'Не удалось загрузить данные: $message';
  }

  @override
  String get settings_contentDeleted => 'Контент удалён';

  @override
  String get language_aiWarningTitle => 'Предупреждение об ИИ';

  @override
  String get language_aiDictionaryWarning =>
      'Словарь создан ИИ. Возможны ошибки. Проверка человеком в процессе — используй на свой страх и риск.';

  @override
  String get language_aiGeneratedTitle => 'Сделано ИИ';

  @override
  String get language_aiGeneratedNote =>
      'Колоды этих языков созданы ИИ и лишь частично проверены экспертами. Ими можно пользоваться: в основном они хороши, но ошибки всё ещё возможны.';

  @override
  String get language_inDevelopmentTitle => 'В разработке';

  @override
  String termCard_gender(String gender) {
    return 'Род: $gender';
  }

  @override
  String get termCard_example => 'Пример:';

  @override
  String termCard_cocaRank(int rank) {
    return 'Частотность: $rank';
  }

  @override
  String termCard_article(String article) {
    return 'Артикль: $article';
  }

  @override
  String termCard_aspect(String aspect) {
    return 'Вид: $aspect';
  }

  @override
  String get termCard_typePhrase => 'Фраза';

  @override
  String get termCard_typeInterrogative => 'Вопросительное слово';

  @override
  String get termCard_typePronoun => 'Местоимение';

  @override
  String get termCard_typePreposition => 'Предлог';

  @override
  String get termCard_typeConjunction => 'Союз';

  @override
  String get termCard_typeNumeral => 'Числительное';

  @override
  String get termCard_typeVerb => 'Глагол';

  @override
  String get termCard_typeAdverb => 'Наречие';

  @override
  String get termCard_typeAdjective => 'Прилагательное';

  @override
  String get termCard_typeNoun => 'Существительное';

  @override
  String get termCard_genderMasculine => 'мужской';

  @override
  String get termCard_genderFeminine => 'женский';

  @override
  String get termCard_genderNeuter => 'средний';

  @override
  String get termCard_aspectImperfective => 'несовершенный';

  @override
  String get termCard_aspectPerfective => 'совершенный';

  @override
  String get termCard_soundSemantics => 'Произнести';

  @override
  String get termCard_soundFailed => 'Произношение недоступно';
}

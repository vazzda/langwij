abstract final class DbSchema {
  static const String tableAppSettings    = 'app_settings';
  static const String tableDeckProgress   = 'deck_progress';
  static const String tableRoundRecords   = 'round_records';
  static const String tableDailyActivity  = 'daily_activity';
  static const String tableLanguageStats  = 'language_stats';

  static const String colKey   = 'key';
  static const String colValue = 'value';

  static const String colTargetLang          = 'target_lang';
  static const String colNativeLang          = 'native_lang';
  static const String colUiLang              = 'ui_lang';
  static const String colDecayFormula        = 'decay_formula';
  static const String colLevelFoldOverridesPrefix = 'level_fold_overrides_';

  static const String colDeckId  = 'deck_id';
  static const String colDate    = 'date';
  static const String colScore   = 'score';
  static const String colMode    = 'mode';

  static const String colCorrect  = 'correct';
  static const String colWrong    = 'wrong';
  static const String colWordIds  = 'word_ids';

  static const String colProgress         = 'progress';
  static const String colPeakRetention   = 'peak_retention';
  static const String colLastRoundDate   = 'last_round_date';
  static const String colPractice        = 'practice';
  static const String colMastery         = 'mastery';
  static const String colLastPracticeDate = 'last_practice_date';

  static const String tableTermCoverage  = 'term_coverage';
  static const String colTermId          = 'term_id';
  static const String colCoverage        = 'coverage';

  static const String colTermsTouchedIds = 'terms_touched_ids';

  static const String colPercentage = 'percentage';
}

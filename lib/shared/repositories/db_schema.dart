/// All SQLite table names and column/key identifiers as typed constants.
/// Use these everywhere — never raw string literals in repository or DDL code.
abstract final class DbSchema {
  // Table names
  static const String tableAppSettings    = 'app_settings';
  static const String tableGroupProgress  = 'group_progress';
  static const String tableSessionRecords = 'session_records';
  static const String tableDailyActivity  = 'daily_activity';
  static const String tableLanguageStats  = 'language_stats';

  // app_settings columns
  static const String colKey   = 'key';
  static const String colValue = 'value';

  // app_settings key values (stored as row identifiers in key column)
  static const String colTargetLang    = 'target_lang';
  static const String colNativeLang    = 'native_lang';
  static const String colUiLang        = 'ui_lang';
  static const String colDecayFormula  = 'decay_formula';

  // Shared columns across tables
  static const String colGroupId = 'group_id';
  static const String colDate    = 'date';
  static const String colScore   = 'score';
  static const String colMode    = 'mode';

  // daily_activity columns
  static const String colCorrect  = 'correct';
  static const String colWrong    = 'wrong';
  static const String colWordIds  = 'word_ids';

  // group_progress columns
  static const String colTargetShownProgress = 'target_shown_progress';
  static const String colNativeShownProgress = 'native_shown_progress';
  static const String colWriteProgress       = 'write_progress';
  static const String colPeakRetention       = 'peak_retention';
  static const String colLastSessionDate     = 'last_session_date';

  // language_stats columns
  static const String colConceptsTouchedIds = 'concepts_touched_ids';

  // test_results columns
  static const String colPercentage = 'percentage';
}

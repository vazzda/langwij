/// Quiz mode: what is shown and how user answers.
enum QuizMode {
  /// Card shows Serbian; user picks English from 4 options.
  serbianShown,

  /// Card shows English; user picks Serbian from 4 options.
  englishShown,

  /// Card shows English; user types Serbian.
  write,
}

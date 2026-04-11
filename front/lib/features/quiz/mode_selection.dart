import 'quiz_mode.dart';

/// Result of mode selection: the quiz mode and whether it's a test.
class ModeSelection {
  const ModeSelection({required this.mode, required this.isTest});

  final QuizMode mode;
  final bool isTest;
}

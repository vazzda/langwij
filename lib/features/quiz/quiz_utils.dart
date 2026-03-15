import '../quiz/quiz_mode.dart';
import '../../entities/card/card_model.dart';

/// Normalizes a string for write-mode comparison: trim, lowercase, and
/// replace Serbian diacritic letters with ASCII equivalents (ž→z, č/ć→c, š→s, đ→d).
String normalizeForComparison(String s) {
  final t = s.trim().toLowerCase();
  return t
      .replaceAll('ž', 'z')
      .replaceAll('č', 'c')
      .replaceAll('ć', 'c')
      .replaceAll('š', 's')
      .replaceAll('đ', 'd');
}

/// Collects all valid answer texts for the current card's prompt.
///
/// When two terms share the same prompt text (e.g. "ćao" → "hello" and
/// "ćao" → "goodbye"), both answers are valid. Returns the set of all
/// such answer texts (not normalized — callers normalize as needed).
Set<String> validAnswersForPrompt({
  required CardModel currentCard,
  required QuizMode mode,
  required List<CardModel> allCards,
}) {
  final prompt = mode == QuizMode.targetShown
      ? currentCard.targetText
      : currentCard.nativeText;
  return allCards
      .where((c) => mode == QuizMode.targetShown
          ? c.targetText == prompt
          : c.nativeText == prompt)
      .map((c) => mode == QuizMode.targetShown
          ? c.nativeText
          : c.targetAnswer)
      .toSet();
}

import 'package:langwij/entities/group/group.dart';
import 'package:langwij/entities/progress/progress.dart';

String normalizeForComparison(String s) {
  final t = s.trim().toLowerCase();
  return t
      .replaceAll('ž', 'z')
      .replaceAll('č', 'c')
      .replaceAll('ć', 'c')
      .replaceAll('š', 's')
      .replaceAll('đ', 'd');
}

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

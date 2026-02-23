import 'dart:math';

import '../../entities/card/card_model.dart';
import 'quiz_mode.dart';

/// Builds 4 option cards for "Serbian shown, pick English": correct card + 3 wrong from [allCards].
List<CardModel> buildMultipleChoiceOptionCards({
  required CardModel correctCard,
  required List<CardModel> allCards,
  required Random random,
}) {
  final others = allCards.where((c) => c != correctCard).toList();
  final wrong = <CardModel>[];
  while (wrong.length < 3 && others.isNotEmpty) {
    final i = random.nextInt(others.length);
    wrong.add(others.removeAt(i));
  }
  final options = [correctCard, ...wrong];
  options.shuffle(random);
  return options;
}

/// Builds 4 Serbian option strings for "English shown, pick Serbian": [correctAnswer] + 3 wrong from [allCards].
List<String> buildMultipleChoiceOptions({
  required QuizMode mode,
  required String correctAnswer,
  required List<CardModel> allCards,
  required Random random,
}) {
  final allAnswers = allCards.map((c) => c.serbianAnswer).toSet().toList();
  final others = allAnswers.where((a) => a != correctAnswer).toList();
  final wrong = <String>[];
  while (wrong.length < 3 && others.isNotEmpty) {
    final i = random.nextInt(others.length);
    wrong.add(others.removeAt(i));
  }
  final options = [correctAnswer, ...wrong];
  options.shuffle(random);
  return options;
}

import 'dart:math';

import 'package:langwij/entities/group/group.dart';
import 'package:langwij/entities/progress/progress.dart';

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

List<String> buildMultipleChoiceOptions({
  required QuizMode mode,
  required String correctAnswer,
  required List<CardModel> allCards,
  required Random random,
}) {
  final allAnswers = allCards.map((c) => c.targetAnswer).toSet().toList();
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

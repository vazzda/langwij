import 'card_model.dart';

class PhraseCard implements CardModel {
  const PhraseCard({required this.targetText, required this.nativeText});

  @override
  final String targetText;
  @override
  final String nativeText;

  @override
  String get targetAnswer => targetText;
}

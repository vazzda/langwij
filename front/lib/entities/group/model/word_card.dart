import 'card_model.dart';

class WordCard implements CardModel {
  const WordCard({required this.targetText, required this.nativeText});

  @override
  final String targetText;
  @override
  final String nativeText;

  @override
  String get targetAnswer => targetText;

  factory WordCard.fromJson(Map<String, dynamic> json) => WordCard(
        targetText: json['serbian'] as String,
        nativeText: json['english'] as String,
      );
}

import 'card_model.dart';

class EndingCard implements CardModel {
  const EndingCard({
    required this.pronoun,
    required this.targetText,
    required this.nativeText,
  });

  final String pronoun;
  @override
  final String targetText;
  @override
  final String nativeText;

  @override
  String get targetAnswer => '$pronoun $targetText';

  factory EndingCard.fromJson(Map<String, dynamic> json) => EndingCard(
        pronoun: json['pronoun'] as String,
        targetText: json['serbian'] as String,
        nativeText: json['english'] as String,
      );
}

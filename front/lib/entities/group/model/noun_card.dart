import 'card_model.dart';

class NounCard implements CardModel {
  const NounCard({
    required this.targetText,
    required this.nativeText,
    required this.gender,
  });

  @override
  final String targetText;
  @override
  final String nativeText;
  final String gender;

  @override
  String get targetAnswer => targetText;

  factory NounCard.fromJson(Map<String, dynamic> json) => NounCard(
        targetText: json['serbian'] as String,
        nativeText: json['english'] as String,
        gender: json['gender'] as String,
      );
}

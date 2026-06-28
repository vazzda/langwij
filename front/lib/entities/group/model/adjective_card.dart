import 'card_model.dart';

class AdjectiveCard implements CardModel {
  const AdjectiveCard({
    required this.targetText,
    required this.nativeText,
    required this.feminine,
    required this.neuter,
  });

  @override
  final String targetText;
  @override
  final String nativeText;
  final String feminine;
  final String neuter;

  @override
  String get targetAnswer => targetText;

  String formForGender(String gender) => switch (gender) {
        'm' => targetText,
        'f' => feminine,
        'n' => neuter,
        _ => targetText,
      };

  factory AdjectiveCard.fromJson(Map<String, dynamic> json) => AdjectiveCard(
        targetText: json['serbian'] as String,
        nativeText: json['english'] as String,
        feminine: json['feminine'] as String,
        neuter: json['neuter'] as String,
      );
}

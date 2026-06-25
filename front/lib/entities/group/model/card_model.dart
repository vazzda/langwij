abstract interface class CardModel {
  String get targetText;
  String get nativeText;
  String get targetAnswer;
}

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

class PhraseCard implements CardModel {
  const PhraseCard({required this.targetText, required this.nativeText});

  @override
  final String targetText;
  @override
  final String nativeText;

  @override
  String get targetAnswer => targetText;
}

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

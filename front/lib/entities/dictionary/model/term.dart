import 'part_of_speech.dart';

class Term {
  const Term({
    required this.id,
    required this.pos,
    this.coca,
  });

  final String id;
  final PartOfSpeech pos;
  final int? coca;

  factory Term.fromJson(String id, Map<String, dynamic> json) {
    return Term(
      id: id,
      pos: PartOfSpeech.values.byName(json['pos'] as String),
      coca: json['coca'] as int?,
    );
  }
}

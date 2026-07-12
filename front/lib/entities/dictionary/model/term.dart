class Term {
  const Term({
    required this.id,
    required this.pos,
    this.coca,
  });

  final String id;
  final String pos;
  final int? coca;

  factory Term.fromJson(String id, Map<String, dynamic> json) {
    return Term(
      id: id,
      pos: json['pos'] as String,
      coca: json['coca'] as int?,
    );
  }
}

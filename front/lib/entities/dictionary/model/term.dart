class Term {
  const Term({
    required this.id,
    required this.pos,
  });

  final String id;
  final String pos;

  factory Term.fromJson(String id, Map<String, dynamic> json) {
    return Term(
      id: id,
      pos: json['pos'] as String,
    );
  }
}

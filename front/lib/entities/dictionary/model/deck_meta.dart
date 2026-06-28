class DeckMeta {
  const DeckMeta({required this.name, this.description});

  final String name;
  final String? description;

  factory DeckMeta.fromJson(Map<String, dynamic> json) {
    return DeckMeta(
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }
}

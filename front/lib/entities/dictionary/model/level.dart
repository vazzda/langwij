class Level {
  static const String specializedLevelId = 'specialized';

  const Level({required this.id, required this.deckIds});

  final String id;
  final List<String> deckIds;

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] as String,
      deckIds: (json['decks'] as List<dynamic>).cast<String>(),
    );
  }
}

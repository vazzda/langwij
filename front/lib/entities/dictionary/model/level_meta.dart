class LevelMeta {
  const LevelMeta({required this.name, this.description});

  final String name;
  final String? description;

  factory LevelMeta.fromJson(Map<String, dynamic> json) {
    return LevelMeta(
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }
}

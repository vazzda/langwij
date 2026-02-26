/// Localized display metadata for a [Level], sourced from the native language pack.
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

/// Localized display metadata for a vocabulary group, sourced from the native language pack.
class GroupMeta {
  const GroupMeta({required this.name, this.description});

  final String name;
  final String? description;

  factory GroupMeta.fromJson(Map<String, dynamic> json) {
    return GroupMeta(
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }
}

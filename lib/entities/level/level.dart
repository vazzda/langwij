/// A named grouping of vocabulary groups shown as a section in the vocab screen.
///
/// Levels are the primary content-access unit — free/paid tiers are assigned
/// per level per course. Progress is tracked at the level level by aggregating
/// the progress of all groups it contains.
class Level {
  const Level({required this.id, required this.groupIds});

  /// Unique level identifier (e.g., "intro", "basic").
  final String id;

  /// Ordered list of group IDs belonging to this level.
  final List<String> groupIds;

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] as String,
      groupIds: (json['groups'] as List<dynamic>).cast<String>(),
    );
  }
}

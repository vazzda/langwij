import 'concept.dart';
import '../group/vocab_group_model.dart';
import '../level/level.dart';

/// The universal dictionary loaded from dictionary.json + levels.json.
///
/// Contains all concepts, vocabulary groups, and level definitions.
/// Language-agnostic — translations are in separate LanguagePack files.
class Dictionary {
  const Dictionary({
    required this.concepts,
    required this.groups,
    required this.levels,
  });

  /// All concepts keyed by ID.
  final Map<String, Concept> concepts;

  /// All vocabulary groups keyed by insertion order.
  final List<VocabGroupModel> groups;

  /// Ordered levels, each containing a subset of group IDs.
  final List<Level> levels;

  /// Set of all concept IDs in the dictionary.
  Set<String> get conceptIds => concepts.keys.toSet();

  /// All groups keyed by ID for fast lookup.
  Map<String, VocabGroupModel> get groupsById =>
      {for (final g in groups) g.id: g};

  factory Dictionary.fromJson(Map<String, dynamic> json) {
    final conceptsJson = json['concepts'] as Map<String, dynamic>;
    final concepts = conceptsJson.map(
      (id, data) =>
          MapEntry(id, Concept.fromJson(id, data as Map<String, dynamic>)),
    );

    final groupsJson = json['groups'] as List<dynamic>;
    final groups = groupsJson
        .map((g) => VocabGroupModel.fromJson(g as Map<String, dynamic>))
        .toList();

    final levelsJson = json['levels'] as List<dynamic>;
    final levels = levelsJson
        .map((l) => Level.fromJson(l as Map<String, dynamic>))
        .toList();

    return Dictionary(concepts: concepts, groups: groups, levels: levels);
  }
}

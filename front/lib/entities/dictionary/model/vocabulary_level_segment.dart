/// A named run of vocabulary levels, as listed under `segments` in
/// levels.json. The main vocabulary screen groups its levels by segment.
class VocabularyLevelSegment {
  const VocabularyLevelSegment({required this.id, required this.levelIds});

  final String id;
  final List<String> levelIds;

  factory VocabularyLevelSegment.fromJson(Map<String, dynamic> json) {
    return VocabularyLevelSegment(
      id: json['id'] as String,
      levelIds: (json['levels'] as List<dynamic>).cast<String>(),
    );
  }
}

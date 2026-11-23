/// The translated name of a vocabulary level segment, as listed under
/// `meta.segments` in a translation file.
class VocabularyLevelSegmentMeta {
  const VocabularyLevelSegmentMeta({required this.name});

  final String name;

  factory VocabularyLevelSegmentMeta.fromJson(Map<String, dynamic> json) {
    return VocabularyLevelSegmentMeta(name: json['name'] as String);
  }
}

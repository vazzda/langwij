/// The translated name of a vocabulary level segment and, where the file
/// gives one, its intro, as listed under `meta.segments` in a translation
/// file.
class VocabularyLevelSegmentMeta {
  const VocabularyLevelSegmentMeta({required this.name, this.intro});

  final String name;

  /// A short sample of the speech the words of the segment allow, or none.
  final String? intro;

  factory VocabularyLevelSegmentMeta.fromJson(Map<String, dynamic> json) {
    return VocabularyLevelSegmentMeta(
      name: json['name'] as String,
      intro: json['intro'] as String?,
    );
  }
}

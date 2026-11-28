import '../../deck_card/model/vocab_level_data.dart';

/// Display data of one vocabulary segment: its name, its intro and its
/// levels.
class VocabSegmentSectionData {
  const VocabSegmentSectionData({
    required this.segmentId,
    required this.name,
    required this.intro,
    required this.levels,
  });

  final String segmentId;
  final String name;

  /// A short sample of the speech the words of the segment allow, in the
  /// language the learner speaks; null when that language gives none.
  final String? intro;
  final List<VocabLevelData> levels;

  /// The studied share of the segment, 0 to 100: the mean of the studied
  /// shares of its levels, each level counting equally. 0 for a segment
  /// without levels.
  double get studiedPercent {
    if (levels.isEmpty) return 0.0;
    final studiedPercentSum = levels.fold(
      0.0,
      (sum, level) => sum + level.levelProgress,
    );
    return studiedPercentSum / levels.length;
  }
}

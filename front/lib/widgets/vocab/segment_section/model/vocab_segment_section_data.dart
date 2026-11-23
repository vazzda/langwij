import '../../deck_card/model/vocab_level_data.dart';

/// Display data of one vocabulary segment: its name and its levels.
class VocabSegmentSectionData {
  const VocabSegmentSectionData({
    required this.segmentId,
    required this.name,
    required this.levels,
  });

  final String segmentId;
  final String name;
  final List<VocabLevelData> levels;
}

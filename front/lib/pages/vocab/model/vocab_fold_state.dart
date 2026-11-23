/// Which segment and which level the main vocabulary screen shows unfolded.
/// At most one of each is unfolded.
class VocabFoldState {
  const VocabFoldState({
    required this.unfoldedSegmentId,
    required this.unfoldedLevelId,
  });

  /// Null when every segment is folded.
  final String? unfoldedSegmentId;

  /// Null when every level is folded.
  final String? unfoldedLevelId;
}

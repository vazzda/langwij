class CoreValidationIds {
  const CoreValidationIds({
    required this.termIds,
    required this.deckIds,
    required this.levelIds,
    required this.segmentIds,
  });

  final Set<String> termIds;
  final Set<String> deckIds;
  final Set<String> levelIds;
  final Set<String> segmentIds;
}

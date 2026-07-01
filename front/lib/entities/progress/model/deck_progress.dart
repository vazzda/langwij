class DeckProgress {
  const DeckProgress({
    required this.deckId,
    this.progress = 0.0,
    this.lastRoundDate,
    this.practice = 0.0,
    this.mastery = 0,
    this.lastPracticeDate,
  });

  final String deckId;
  final double progress;
  final DateTime? lastRoundDate;
  final double practice;
  final int mastery;
  final DateTime? lastPracticeDate;

  double get totalProgress => progress;

  DeckProgress copyWith({
    double? progress,
    DateTime? lastRoundDate,
    double? practice,
    int? mastery,
    DateTime? lastPracticeDate,
  }) {
    return DeckProgress(
      deckId: deckId,
      progress: progress ?? this.progress,
      lastRoundDate: lastRoundDate ?? this.lastRoundDate,
      practice: practice ?? this.practice,
      mastery: mastery ?? this.mastery,
      lastPracticeDate: lastPracticeDate ?? this.lastPracticeDate,
    );
  }

  Map<String, dynamic> toMap() => {
        'deckId': deckId,
        'progress': progress,
        'lastRoundDate': lastRoundDate?.toIso8601String(),
        'practice': practice,
        'mastery': mastery,
        'lastPracticeDate': lastPracticeDate?.toIso8601String(),
      };

  factory DeckProgress.fromMap(Map<dynamic, dynamic> map) {
    final lastDateStr = map['lastRoundDate'] as String?;
    final lastPracticeDateStr = map['lastPracticeDate'] as String?;
    return DeckProgress(
      deckId: map['deckId'] as String,
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      lastRoundDate:
          lastDateStr != null ? DateTime.parse(lastDateStr) : null,
      practice: (map['practice'] as num?)?.toDouble() ?? 0.0,
      mastery: (map['mastery'] as num?)?.toInt() ?? 0,
      lastPracticeDate:
          lastPracticeDateStr != null ? DateTime.parse(lastPracticeDateStr) : null,
    );
  }
}

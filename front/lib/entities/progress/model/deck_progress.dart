import 'progress_constants.dart';
import 'round_record.dart';

class DeckProgress {
  const DeckProgress({
    required this.deckId,
    this.progress = 0.0,
    this.peakRetention = 0.0,
    this.recentRounds = const [],
    this.lastRoundDate,
    this.practice = 0.0,
    this.mastery = 0,
    this.lastPracticeDate,
  });

  final String deckId;
  final double progress;
  final double peakRetention;
  final List<RoundRecord> recentRounds;
  final DateTime? lastRoundDate;
  final double practice;
  final int mastery;
  final DateTime? lastPracticeDate;

  double get totalProgress => progress;

  double get retentionFloor =>
      peakRetention * ProgressConstants.retentionFloorMultiplier;

  DeckProgress copyWith({
    double? progress,
    double? peakRetention,
    List<RoundRecord>? recentRounds,
    DateTime? lastRoundDate,
    double? practice,
    int? mastery,
    DateTime? lastPracticeDate,
  }) {
    return DeckProgress(
      deckId: deckId,
      progress: progress ?? this.progress,
      peakRetention: peakRetention ?? this.peakRetention,
      recentRounds: recentRounds ?? this.recentRounds,
      lastRoundDate: lastRoundDate ?? this.lastRoundDate,
      practice: practice ?? this.practice,
      mastery: mastery ?? this.mastery,
      lastPracticeDate: lastPracticeDate ?? this.lastPracticeDate,
    );
  }

  Map<String, dynamic> toMap() => {
        'deckId': deckId,
        'progress': progress,
        'peakRetention': peakRetention,
        'recentRounds': recentRounds.map((s) => s.toMap()).toList(),
        'lastRoundDate': lastRoundDate?.toIso8601String(),
        'practice': practice,
        'mastery': mastery,
        'lastPracticeDate': lastPracticeDate?.toIso8601String(),
      };

  factory DeckProgress.fromMap(Map<dynamic, dynamic> map) {
    final roundsList = (map['recentRounds'] as List<dynamic>?)
            ?.map((s) => RoundRecord.fromMap(s as Map<dynamic, dynamic>))
            .toList() ??
        [];
    final lastDateStr = map['lastRoundDate'] as String?;
    final lastPracticeDateStr = map['lastPracticeDate'] as String?;
    return DeckProgress(
      deckId: map['deckId'] as String,
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      peakRetention: (map['peakRetention'] as num?)?.toDouble() ?? 0.0,
      recentRounds: roundsList,
      lastRoundDate:
          lastDateStr != null ? DateTime.parse(lastDateStr) : null,
      practice: (map['practice'] as num?)?.toDouble() ?? 0.0,
      mastery: (map['mastery'] as num?)?.toInt() ?? 0,
      lastPracticeDate:
          lastPracticeDateStr != null ? DateTime.parse(lastPracticeDateStr) : null,
    );
  }
}

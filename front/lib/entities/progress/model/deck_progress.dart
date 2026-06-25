import 'progress_constants.dart';
import 'round_record.dart';

class DeckProgress {
  const DeckProgress({
    required this.deckId,
    this.progress = 0.0,
    this.peakRetention = 0.0,
    this.recentRounds = const [],
    this.lastRoundDate,
  });

  final String deckId;
  final double progress;
  final double peakRetention;
  final List<RoundRecord> recentRounds;
  final DateTime? lastRoundDate;

  double get totalProgress => progress;

  double get retentionFloor =>
      peakRetention * ProgressConstants.retentionFloorMultiplier;

  DeckProgress copyWith({
    double? progress,
    double? peakRetention,
    List<RoundRecord>? recentRounds,
    DateTime? lastRoundDate,
  }) {
    return DeckProgress(
      deckId: deckId,
      progress: progress ?? this.progress,
      peakRetention: peakRetention ?? this.peakRetention,
      recentRounds: recentRounds ?? this.recentRounds,
      lastRoundDate: lastRoundDate ?? this.lastRoundDate,
    );
  }

  Map<String, dynamic> toMap() => {
        'deckId': deckId,
        'progress': progress,
        'peakRetention': peakRetention,
        'recentRounds': recentRounds.map((s) => s.toMap()).toList(),
        'lastRoundDate': lastRoundDate?.toIso8601String(),
      };

  factory DeckProgress.fromMap(Map<dynamic, dynamic> map) {
    final roundsList = (map['recentRounds'] as List<dynamic>?)
            ?.map((s) => RoundRecord.fromMap(s as Map<dynamic, dynamic>))
            .toList() ??
        [];
    final lastDateStr = map['lastRoundDate'] as String?;
    return DeckProgress(
      deckId: map['deckId'] as String,
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      peakRetention: (map['peakRetention'] as num?)?.toDouble() ?? 0.0,
      recentRounds: roundsList,
      lastRoundDate:
          lastDateStr != null ? DateTime.parse(lastDateStr) : null,
    );
  }
}

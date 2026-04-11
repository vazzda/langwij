import 'package:langwij/shared/lib/progress_constants.dart';
import 'round_record.dart';

/// Progress tracking for a single deck, scoped by target language.
///
/// Single [progress] value (0–100) with mode-based caps:
///   nativeShown → 20%  |  targetShown → 40%  |  write → 80%  |  test → 100%
/// Caps overlap (not additive). See [ProgressConstants] for tuning.
class DeckProgress {
  const DeckProgress({
    required this.deckId,
    this.progress = 0.0,
    this.peakRetention = 0.0,
    this.recentRounds = const [],
    this.lastRoundDate,
  });

  final String deckId;

  /// Unified deck progress (0–100).
  final double progress;

  /// Highest retention ever achieved. Used to calculate decay floor.
  final double peakRetention;

  /// Last 3 rounds for retention calculation.
  final List<RoundRecord> recentRounds;

  /// Date of most recent round.
  final DateTime? lastRoundDate;

  /// Alias for consistency with existing UI code.
  double get totalProgress => progress;

  /// Decay floor — retention cannot drop below this.
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

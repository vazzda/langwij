import 'session_record.dart';

/// Progress tracking for a single group.
class GroupProgress {
  const GroupProgress({
    required this.groupId,
    this.serbianCardsProgress = 0.0,
    this.englishCardsProgress = 0.0,
    this.writeProgress = 0.0,
    this.peakRetention = 0.0,
    this.recentSessions = const [],
    this.lastSessionDate,
  });

  final String groupId;

  /// Progress from serbianShown mode (0-100). Contributes max 20% to total.
  final double serbianCardsProgress;

  /// Progress from englishShown mode (0-100). Contributes max 20% to total.
  final double englishCardsProgress;

  /// Progress from write mode (0-100). Contributes max 60% to total.
  final double writeProgress;

  /// Highest retention ever achieved. Used to calculate decay floor.
  final double peakRetention;

  /// Last 3 sessions for retention calculation.
  final List<SessionRecord> recentSessions;

  /// Date of most recent session.
  final DateTime? lastSessionDate;

  /// Mode contribution caps.
  static const double serbianCardsCap = 20.0;
  static const double englishCardsCap = 20.0;
  static const double writeCap = 60.0;

  /// Total progress (0-100) with mode caps applied.
  double get totalProgress {
    final serbianCapped = (serbianCardsProgress / 100.0 * serbianCardsCap)
        .clamp(0.0, serbianCardsCap);
    final englishCapped = (englishCardsProgress / 100.0 * englishCardsCap)
        .clamp(0.0, englishCardsCap);
    final writeCapped =
        (writeProgress / 100.0 * writeCap).clamp(0.0, writeCap);
    return (serbianCapped + englishCapped + writeCapped).clamp(0.0, 100.0);
  }

  /// Decay floor - retention cannot drop below half of peak.
  double get retentionFloor => peakRetention * 0.5;

  GroupProgress copyWith({
    double? serbianCardsProgress,
    double? englishCardsProgress,
    double? writeProgress,
    double? peakRetention,
    List<SessionRecord>? recentSessions,
    DateTime? lastSessionDate,
  }) {
    return GroupProgress(
      groupId: groupId,
      serbianCardsProgress: serbianCardsProgress ?? this.serbianCardsProgress,
      englishCardsProgress: englishCardsProgress ?? this.englishCardsProgress,
      writeProgress: writeProgress ?? this.writeProgress,
      peakRetention: peakRetention ?? this.peakRetention,
      recentSessions: recentSessions ?? this.recentSessions,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
    );
  }

  Map<String, dynamic> toMap() => {
        'groupId': groupId,
        'serbianCardsProgress': serbianCardsProgress,
        'englishCardsProgress': englishCardsProgress,
        'writeProgress': writeProgress,
        'peakRetention': peakRetention,
        'recentSessions': recentSessions.map((s) => s.toMap()).toList(),
        'lastSessionDate': lastSessionDate?.toIso8601String(),
      };

  factory GroupProgress.fromMap(Map<dynamic, dynamic> map) {
    final sessionsList = (map['recentSessions'] as List<dynamic>?)
            ?.map((s) => SessionRecord.fromMap(s as Map<dynamic, dynamic>))
            .toList() ??
        [];
    final lastDateStr = map['lastSessionDate'] as String?;
    return GroupProgress(
      groupId: map['groupId'] as String,
      serbianCardsProgress:
          (map['serbianCardsProgress'] as num?)?.toDouble() ?? 0.0,
      englishCardsProgress:
          (map['englishCardsProgress'] as num?)?.toDouble() ?? 0.0,
      writeProgress: (map['writeProgress'] as num?)?.toDouble() ?? 0.0,
      peakRetention: (map['peakRetention'] as num?)?.toDouble() ?? 0.0,
      recentSessions: sessionsList,
      lastSessionDate: lastDateStr != null ? DateTime.parse(lastDateStr) : null,
    );
  }
}

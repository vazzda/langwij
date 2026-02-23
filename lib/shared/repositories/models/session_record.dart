import '../../../features/quiz/quiz_mode.dart';

/// Record of a completed session for progress tracking.
class SessionRecord {
  const SessionRecord({
    required this.date,
    required this.score,
    required this.mode,
  });

  /// When the session was completed.
  final DateTime date;

  /// Score as percentage (0-100).
  final double score;

  /// Which quiz mode was used.
  final QuizMode mode;

  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String(),
        'score': score,
        'mode': mode.name,
      };

  factory SessionRecord.fromMap(Map<dynamic, dynamic> map) {
    return SessionRecord(
      date: DateTime.parse(map['date'] as String),
      score: (map['score'] as num).toDouble(),
      mode: QuizMode.values.firstWhere(
        (m) => m.name == map['mode'],
        orElse: () => QuizMode.write,
      ),
    );
  }
}

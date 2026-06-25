import 'quiz_mode.dart';

class RoundRecord {
  const RoundRecord({
    required this.date,
    required this.score,
    required this.mode,
  });

  final DateTime date;
  final double score;
  final QuizMode mode;

  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String(),
        'score': score,
        'mode': mode.name,
      };

  factory RoundRecord.fromMap(Map<dynamic, dynamic> map) {
    return RoundRecord(
      date: DateTime.parse(map['date'] as String),
      score: (map['score'] as num).toDouble(),
      mode: QuizMode.values.firstWhere(
        (m) => m.name == map['mode'],
        orElse: () => QuizMode.write,
      ),
    );
  }
}

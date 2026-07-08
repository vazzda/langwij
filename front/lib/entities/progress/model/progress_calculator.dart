import 'progress_constants.dart';

class ProgressCalculator {
  const ProgressCalculator._();

  static double applyPracticeDecay({
    required double practice,
    required DateTime? lastPracticeDate,
  }) {
    if (lastPracticeDate == null || practice <= 0) return practice;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(
      lastPracticeDate.year,
      lastPracticeDate.month,
      lastPracticeDate.day,
    );
    final staleDays = today.difference(lastDay).inDays;

    if (staleDays <= 0) return practice;

    final decay = staleDays * ProgressConstants.practiceDecayPerDay;
    return (practice - decay).clamp(
      ProgressConstants.practiceDecayFloor,
      ProgressConstants.practiceMax.toDouble(),
    );
  }

  static double calculateRoundPracticeGain(
    int correctCount,
    int totalCount,
  ) {
    if (totalCount <= 0) return 0.0;
    return ProgressConstants.practiceGainPerRound * correctCount / totalCount;
  }
}

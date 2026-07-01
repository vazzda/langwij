import 'progress_constants.dart';

class ProgressCalculator {
  const ProgressCalculator._();

  static double applyPracticeDecay({
    required double practice,
    required int mastery,
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

    final decay = totalDecayForStaleDays(staleDays, mastery);
    return (practice - decay).clamp(0.0, ProgressConstants.practiceMax.toDouble());
  }

  static int totalDecayForStaleDays(int staleDays, int mastery) {
    if (staleDays <= 0) return 0;

    final tierIndex = mastery.clamp(0, ProgressConstants.masteryDecayCap);
    final tier = ProgressConstants.decaySchedule[tierIndex];

    if (staleDays == 1) return tier[0];
    if (staleDays == 2) return tier[0] + tier[1];
    return tier[0] + tier[1] + (staleDays - 2) * tier[2];
  }
}

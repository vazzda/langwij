import 'dart:math' as math;

import 'package:langwij/shared/app/config/config.dart';
import 'deck_progress.dart';
import 'retention_level.dart';
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

  static double calculateRetention(
    DeckProgress progress,
    DecayFormula formula,
  ) {
    if (progress.recentRounds.isEmpty) {
      return 0.0;
    }

    final now = DateTime.now();
    final halfLife = formula.halfLifeDays.toDouble();
    double totalWeight = 0.0;
    double weightedSum = 0.0;

    for (final round in progress.recentRounds) {
      final daysSince = now.difference(round.date).inHours / 24.0;
      final decay = math.pow(0.5, daysSince / halfLife);
      final weight = decay;
      weightedSum += round.score * weight;
      totalWeight += weight;
    }

    if (totalWeight <= 0) return 0.0;

    final rawRetention = weightedSum / totalWeight;
    final floor = progress.retentionFloor;

    return rawRetention.clamp(floor, 100.0);
  }

  static RetentionLevel getRetentionLevel(
    double retentionPercentage,
    double progressPercentage,
  ) {
    final rawLevel = RetentionLevelExtension.fromPercentage(retentionPercentage);

    RetentionLevel maxLevel;
    if (progressPercentage <= ProgressConstants.retentionCapWeak) {
      maxLevel = RetentionLevel.weak;
    } else if (progressPercentage <= ProgressConstants.retentionCapGood) {
      maxLevel = RetentionLevel.good;
    } else if (progressPercentage <= ProgressConstants.retentionCapStrong) {
      maxLevel = RetentionLevel.strong;
    } else {
      maxLevel = RetentionLevel.super_;
    }

    if (rawLevel.index > maxLevel.index) {
      return maxLevel;
    }
    return rawLevel;
  }

  static bool shouldUpdatePeak(DeckProgress progress, double currentRetention) {
    return currentRetention > progress.peakRetention;
  }
}

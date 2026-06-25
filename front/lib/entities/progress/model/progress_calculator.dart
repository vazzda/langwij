import 'dart:math' as math;

import 'package:langwij/shared/app/config/config.dart';
import 'deck_progress.dart';
import 'retention_level.dart';
import 'progress_constants.dart';

class ProgressCalculator {
  const ProgressCalculator._();

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

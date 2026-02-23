import 'dart:math' as math;

import '../repositories/models/decay_formula.dart';
import '../repositories/models/group_progress.dart';
import '../repositories/models/retention_level.dart';

/// Calculates retention and progress for groups.
class ProgressCalculator {
  const ProgressCalculator._();

  /// Calculate current retention percentage (0-100) for a group.
  /// Uses weighted average of recent sessions with time decay.
  /// Retention cannot drop below floor (half of peak retention).
  static double calculateRetention(
    GroupProgress progress,
    DecayFormula formula,
  ) {
    if (progress.recentSessions.isEmpty) {
      return 0.0;
    }

    final now = DateTime.now();
    final halfLife = formula.halfLifeDays.toDouble();
    double totalWeight = 0.0;
    double weightedSum = 0.0;

    for (final session in progress.recentSessions) {
      final daysSince = now.difference(session.date).inHours / 24.0;
      // Exponential decay: 0.5^(days / halfLife)
      final decay = math.pow(0.5, daysSince / halfLife);
      final weight = decay;
      weightedSum += session.score * weight;
      totalWeight += weight;
    }

    if (totalWeight <= 0) return 0.0;

    final rawRetention = weightedSum / totalWeight;
    final floor = progress.retentionFloor;

    return rawRetention.clamp(floor, 100.0);
  }

  /// Get retention level from percentage, capped by progress.
  /// You can't have high retention on material you haven't covered.
  static RetentionLevel getRetentionLevel(
    double retentionPercentage,
    double progressPercentage,
  ) {
    final rawLevel = RetentionLevelExtension.fromPercentage(retentionPercentage);

    // Cap retention level based on progress
    // 0-20% progress → max Weak
    // 21-40% progress → max Good
    // 41-60% progress → max Strong
    // 61%+ progress → max Super (no cap)
    RetentionLevel maxLevel;
    if (progressPercentage <= 20) {
      maxLevel = RetentionLevel.weak;
    } else if (progressPercentage <= 40) {
      maxLevel = RetentionLevel.good;
    } else if (progressPercentage <= 60) {
      maxLevel = RetentionLevel.strong;
    } else {
      maxLevel = RetentionLevel.super_;
    }

    // Return the lower of raw level and max level
    if (rawLevel.index > maxLevel.index) {
      return maxLevel;
    }
    return rawLevel;
  }

  /// Calculate if peak retention should be updated.
  static bool shouldUpdatePeak(GroupProgress progress, double currentRetention) {
    return currentRetention > progress.peakRetention;
  }
}

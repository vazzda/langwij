/// Retention level based on calculated retention percentage.
enum RetentionLevel {
  /// 0% retention
  none,

  /// 1-25% retention
  weak,

  /// 26-50% retention
  good,

  /// 51-75% retention
  strong,

  /// 76-100% retention
  super_,
}

extension RetentionLevelExtension on RetentionLevel {
  /// Get retention level from percentage (0-100).
  static RetentionLevel fromPercentage(double percentage) {
    if (percentage <= 0) return RetentionLevel.none;
    if (percentage <= 25) return RetentionLevel.weak;
    if (percentage <= 50) return RetentionLevel.good;
    if (percentage <= 75) return RetentionLevel.strong;
    return RetentionLevel.super_;
  }
}

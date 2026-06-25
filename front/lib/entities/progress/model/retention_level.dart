enum RetentionLevel {
  none,
  weak,
  good,
  strong,
  super_,
}

extension RetentionLevelExtension on RetentionLevel {
  static RetentionLevel fromPercentage(double percentage) {
    if (percentage <= 0) return RetentionLevel.none;
    if (percentage <= 25) return RetentionLevel.weak;
    if (percentage <= 50) return RetentionLevel.good;
    if (percentage <= 75) return RetentionLevel.strong;
    return RetentionLevel.super_;
  }
}

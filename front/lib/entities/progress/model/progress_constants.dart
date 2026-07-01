class ProgressConstants {
  ProgressConstants._();

  static const int coveragePickIncrement = 10;
  static const int coverageWriteIncrement = 25;
  static const int coveragePickCap = 50;
  static const int coverageWriteFloor = 50;
  static const int coverageMax = 100;

  static const int practicePerAnswer = 1;
  static const int practiceMax = 100;

  static const int masteryDecayCap = 3;

  // Indexed by min(mastery, masteryDecayCap): [staleDay1, staleDay2, staleDay3+]
  static const List<List<int>> decaySchedule = [
    [5, 10, 20],
    [5, 10, 10],
    [1, 5, 5],
    [1, 1, 1],
  ];

  static const double capNativeShown = 20.0;
  static const double capTargetShown = 40.0;
  static const double capWrite = 80.0;
  static const double capTest = 100.0;
  static const double baseContribution = 10.0;
  static const double retentionCapWeak = 20.0;
  static const double retentionCapGood = 40.0;
  static const double retentionCapStrong = 60.0;
  static const double retentionFloorMultiplier = 0.5;
}

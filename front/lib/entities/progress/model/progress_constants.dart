class ProgressConstants {
  ProgressConstants._();

  static const int coveragePickIncrement = 10;
  static const int coverageWriteIncrement = 25;
  static const int coveragePickCap = 50;
  static const int coverageWriteFloor = 50;
  static const int coverageMax = 100;

  static const int practiceMax = 100;
  static const double practiceGainPerRound = 20.0;
  static const double practiceDecayPerDay = 5.0;
  static const double practiceDecayFloor = 5.0;

  static const double capNativeShown = 20.0;
  static const double capTargetShown = 40.0;
  static const double capWrite = 80.0;
  static const double baseContribution = 10.0;
}

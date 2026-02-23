/// Decay formula options for retention calculation.
/// Each formula has a different half-life for memory decay.
enum DecayFormula {
  /// Slow decay - 14 day half-life. For casual learners.
  relaxed,

  /// Medium decay - 7 day half-life. Balanced approach.
  standard,

  /// Fast decay - 4 day half-life. For active learners.
  intensive,

  /// Very fast decay - 2 day half-life. For immersion/daily practice.
  hardcore,
}

extension DecayFormulaExtension on DecayFormula {
  /// Half-life in days for this decay formula.
  int get halfLifeDays {
    switch (this) {
      case DecayFormula.relaxed:
        return 14;
      case DecayFormula.standard:
        return 7;
      case DecayFormula.intensive:
        return 4;
      case DecayFormula.hardcore:
        return 2;
    }
  }

  /// String key for serialization.
  String get key {
    switch (this) {
      case DecayFormula.relaxed:
        return 'relaxed';
      case DecayFormula.standard:
        return 'standard';
      case DecayFormula.intensive:
        return 'intensive';
      case DecayFormula.hardcore:
        return 'hardcore';
    }
  }

  /// Parse from string key.
  static DecayFormula fromKey(String key) {
    switch (key) {
      case 'relaxed':
        return DecayFormula.relaxed;
      case 'intensive':
        return DecayFormula.intensive;
      case 'hardcore':
        return DecayFormula.hardcore;
      case 'standard':
      default:
        return DecayFormula.standard;
    }
  }
}

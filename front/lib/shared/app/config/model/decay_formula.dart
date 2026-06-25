enum DecayFormula {
  relaxed,
  standard,
  intensive,
  hardcore,
}

extension DecayFormulaExtension on DecayFormula {
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

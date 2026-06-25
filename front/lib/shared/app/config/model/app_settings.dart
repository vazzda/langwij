import 'decay_formula.dart';

class AppSettings {
  const AppSettings({
    this.decayFormula = DecayFormula.standard,
  });

  final DecayFormula decayFormula;

  AppSettings copyWith({
    DecayFormula? decayFormula,
  }) {
    return AppSettings(
      decayFormula: decayFormula ?? this.decayFormula,
    );
  }

  Map<String, dynamic> toMap() => {
        'decayFormula': decayFormula.key,
      };

  factory AppSettings.fromMap(Map<dynamic, dynamic> map) {
    final formulaKey = map['decayFormula'] as String? ?? 'standard';
    return AppSettings(
      decayFormula: DecayFormulaExtension.fromKey(formulaKey),
    );
  }
}

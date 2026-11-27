/// The gender of a noun, as the `gender` field of the translation files
/// codes it.
enum GrammaticalGender {
  masculine('m'),
  feminine('f'),
  neuter('n');

  const GrammaticalGender(this.code);

  /// The code of the gender in the translation files.
  final String code;

  /// The gender that a code of the translation files stands for.
  static GrammaticalGender fromCode(String code) =>
      values.firstWhere((gender) => gender.code == code);
}

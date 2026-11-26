/// A note of plan.json, shown as a message under the pair of chosen
/// languages: a title and the text beneath it. A note is written for the
/// speakers of one language, in that language.
class PlanNote {
  const PlanNote({required this.title, required this.text});

  final String title;
  final String text;

  /// The note a block of plan.json states under the given keys, or none when
  /// the block states no note. A note has both its title and its text; the
  /// validator refuses a block that states only one of them.
  static PlanNote? fromJsonOrNull(
    Map<String, dynamic> json, {
    required String titleKey,
    required String textKey,
  }) {
    final title = json[titleKey] as String?;
    final text = json[textKey] as String?;
    if (title == null || text == null) return null;
    return PlanNote(title: title, text: text);
  }
}

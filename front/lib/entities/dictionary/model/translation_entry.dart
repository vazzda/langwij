class TranslationEntry {
  const TranslationEntry({
    required this.text,
    this.note,
    this.gender,
    this.aspect,
    this.forms,
  });

  final String text;
  final String? note;
  final String? gender;
  final String? aspect;
  final Map<String, String>? forms;

  factory TranslationEntry.fromJson(Map<String, dynamic> json) {
    return TranslationEntry(
      text: json['text'] as String,
      note: json['note'] as String?,
      gender: json['gender'] as String?,
      aspect: json['aspect'] as String?,
      forms: json['forms'] != null
          ? Map<String, String>.from(json['forms'] as Map)
          : null,
    );
  }
}

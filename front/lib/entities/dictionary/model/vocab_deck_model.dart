class VocabDeckModel {
  const VocabDeckModel({
    required this.id,
    required this.termIds,
    this.icon,
  });

  final String id;
  final List<String> termIds;
  final String? icon;

  factory VocabDeckModel.fromJson(Map<String, dynamic> json) {
    return VocabDeckModel(
      id: json['id'] as String,
      termIds: (json['terms'] as List<dynamic>).cast<String>(),
      icon: json['icon'] as String?,
    );
  }
}

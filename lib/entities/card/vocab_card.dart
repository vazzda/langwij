import 'card_model.dart';

/// A vocabulary training card. All vocab cards share a conceptId, nativeText,
/// and optional notes. Subtype determines quiz behaviour.
sealed class VocabCard implements CardModel {
  const VocabCard({
    required this.conceptId,
    required this.nativeText,
    this.nativeNote,
    this.targetNote,
  });

  /// Concept slug from dictionary.json (e.g., "buy", "city").
  final String conceptId;

  @override
  final String nativeText;

  /// Usage note for the native-language side. Show when native is the prompt.
  final String? nativeNote;

  /// Usage note for the target-language side. Show when target is the prompt.
  final String? targetNote;

  /// Unique word ID for progress tracking. One card per concept.
  String get wordId => conceptId;
}

/// A single-answer card: simple verb, noun, adverb, adjective (masculine form), etc.
class SimpleVocabCard extends VocabCard {
  const SimpleVocabCard({
    required super.conceptId,
    required super.nativeText,
    required this.targetText,
    super.nativeNote,
    super.targetNote,
  });

  @override
  final String targetText;

  @override
  String get targetAnswer => targetText;
}

/// An aspect-pair card: requires the user to produce both imperfective and perfective forms.
class PairVocabCard extends VocabCard {
  const PairVocabCard({
    required super.conceptId,
    required super.nativeText,
    required this.imperfectiveText,
    required this.perfectiveText,
    super.nativeNote,
    super.targetNote,
  });

  final String imperfectiveText;
  final String perfectiveText;

  /// Primary form used as MCQ label and MCQ prompt (targetShown).
  @override
  String get targetText => '$imperfectiveText / $perfectiveText';

  /// Canonical answer string used for grading and display.
  @override
  String get targetAnswer => '$imperfectiveText / $perfectiveText';
}

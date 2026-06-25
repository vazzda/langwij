import 'package:langwij/entities/group/group.dart';

sealed class VocabCard implements CardModel {
  const VocabCard({
    required this.termId,
    required this.nativeText,
    this.nativeNote,
    this.targetNote,
  });

  final String termId;

  @override
  final String nativeText;

  final String? nativeNote;
  final String? targetNote;

  String get wordId => termId;
}

class SimpleVocabCard extends VocabCard {
  const SimpleVocabCard({
    required super.termId,
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

class PairVocabCard extends VocabCard {
  const PairVocabCard({
    required super.termId,
    required super.nativeText,
    required this.imperfectiveText,
    required this.perfectiveText,
    super.nativeNote,
    super.targetNote,
  });

  final String imperfectiveText;
  final String perfectiveText;

  @override
  String get targetText => '$imperfectiveText / $perfectiveText';

  @override
  String get targetAnswer => '$imperfectiveText / $perfectiveText';
}

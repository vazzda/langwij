import 'package:langwij/entities/group/group.dart';

sealed class VocabCard implements CardModel {
  const VocabCard({
    required this.termId,
    required this.nativeText,
    required this.pos,
    this.nativeNote,
    this.targetNote,
    this.coca,
  });

  final String termId;
  final String pos;
  final int? coca;

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
    required super.pos,
    required this.targetText,
    super.nativeNote,
    super.targetNote,
    super.coca,
    this.gender,
    this.feminineForm,
    this.neuterForm,
  });

  @override
  final String targetText;
  final String? gender;
  final String? feminineForm;
  final String? neuterForm;

  @override
  String get targetAnswer => targetText;
}

class PairVocabCard extends VocabCard {
  const PairVocabCard({
    required super.termId,
    required super.nativeText,
    required super.pos,
    required this.imperfectiveText,
    required this.perfectiveText,
    super.nativeNote,
    super.targetNote,
    super.coca,
  });

  final String imperfectiveText;
  final String perfectiveText;

  @override
  String get targetText => '$imperfectiveText / $perfectiveText';

  @override
  String get targetAnswer => '$imperfectiveText / $perfectiveText';
}

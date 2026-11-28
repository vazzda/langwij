import 'package:langwij/entities/dictionary/dictionary.dart';
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

  /// The type of the word; absent when the dictionary holds no term for the
  /// card.
  final PartOfSpeech? pos;
  final int? coca;

  @override
  final String nativeText;

  final String? nativeNote;
  final String? targetNote;

  String get wordId => termId;

  String get speechText => targetText;
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
    this.article,
    this.aspect,
    this.genderForms = const [],
  });

  @override
  final String targetText;
  final GrammaticalGender? gender;
  final String? article;
  final VerbAspect? aspect;

  /// Every gender form of a word that changes by gender, the masculine
  /// first; empty for a word of one form. [targetText] is the one of them
  /// that stands for the word.
  final List<String> genderForms;

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

  @override
  String get speechText => '$imperfectiveText, $perfectiveText';
}

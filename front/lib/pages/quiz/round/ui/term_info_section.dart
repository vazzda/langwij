import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/entities/dictionary/dictionary.dart';
import 'package:langwij/features/quiz/model/vocab_card.dart';

/// The facts the dictionary holds about the word of a card, line under line
/// with no gap between the lines: its frequency rank, then its type with
/// what is particular to the word within that type, then the two verbs of an
/// aspect pair.
class TermInfoSection extends StatelessWidget {
  const TermInfoSection({super.key, required this.card});

  static const String _labelValueSeparator = ' ';
  static const String _typeDetailSeparator = ', ';
  static const String _genderFormSeparator = '/';

  final VocabCard card;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final l10n = AppLocalizations.of(context)!;
    final lineStyle = FlesselFonts.contentCaption.copyWith(color: t.fg);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in _linesOfInfo(l10n)) Text(line, style: lineStyle),
      ],
    );
  }

  /// Every line of the section, top to bottom: the frequency rank, the type
  /// line, then the two verbs of an aspect pair.
  List<String> _linesOfInfo(AppLocalizations l10n) {
    final frequencyRank = card.coca;
    final typeLine = _buildTypeLine(l10n);

    return [
      if (frequencyRank != null) l10n.numberWithSign(frequencyRank),
      if (typeLine.isNotEmpty) typeLine,
      ..._linesOfAspectPair(l10n),
    ];
  }

  /// The type of the word and, after a comma each, what is particular to the
  /// word within its type: "Noun, neuter", "Adjective, vruć/vruća/vruće".
  String _buildTypeLine(AppLocalizations l10n) {
    final pos = card.pos;

    return [
      if (pos != null) _nameOfPartOfSpeech(pos, l10n),
      ..._detailsOfType(l10n),
    ].join(_typeDetailSeparator);
  }

  /// What is particular to the word within its type: the gender and the
  /// article of a noun, the aspect of a verb that stands alone, the gender
  /// forms of an adjective. An aspect pair has its own lines instead.
  List<String> _detailsOfType(AppLocalizations l10n) => switch (card) {
        SimpleVocabCard simple => _detailsOfSimpleCard(simple, l10n),
        PairVocabCard() => const [],
      };

  List<String> _detailsOfSimpleCard(
    SimpleVocabCard simple,
    AppLocalizations l10n,
  ) {
    final gender = simple.gender;
    final article = simple.article;
    final aspect = simple.aspect;

    return [
      if (gender != null) _nameOfGender(gender, l10n),
      if (article != null) article,
      if (aspect != null) _nameOfAspect(aspect, l10n),
      if (simple.genderForms.isNotEmpty)
        simple.genderForms.join(_genderFormSeparator),
    ];
  }

  /// Both verbs of an aspect pair, each behind the name of its aspect; no
  /// lines for a word that is not a pair.
  List<String> _linesOfAspectPair(AppLocalizations l10n) => switch (card) {
        SimpleVocabCard() => const [],
        PairVocabCard pair => [
            '${l10n.quiz_aspectImperfective}$_labelValueSeparator'
                '${pair.imperfectiveText}',
            '${l10n.quiz_aspectPerfective}$_labelValueSeparator'
                '${pair.perfectiveText}',
          ],
      };

  String _nameOfPartOfSpeech(PartOfSpeech pos, AppLocalizations l10n) =>
      switch (pos) {
        PartOfSpeech.phrase => l10n.termCard_typePhrase,
        PartOfSpeech.interrogative => l10n.termCard_typeInterrogative,
        PartOfSpeech.pronoun => l10n.termCard_typePronoun,
        PartOfSpeech.preposition => l10n.termCard_typePreposition,
        PartOfSpeech.conjunction => l10n.termCard_typeConjunction,
        PartOfSpeech.numeral => l10n.termCard_typeNumeral,
        PartOfSpeech.verb => l10n.termCard_typeVerb,
        PartOfSpeech.adverb => l10n.termCard_typeAdverb,
        PartOfSpeech.adjective => l10n.termCard_typeAdjective,
        PartOfSpeech.noun => l10n.termCard_typeNoun,
      };

  String _nameOfGender(GrammaticalGender gender, AppLocalizations l10n) =>
      switch (gender) {
        GrammaticalGender.masculine => l10n.termCard_genderMasculine,
        GrammaticalGender.feminine => l10n.termCard_genderFeminine,
        GrammaticalGender.neuter => l10n.termCard_genderNeuter,
      };

  String _nameOfAspect(VerbAspect aspect, AppLocalizations l10n) =>
      switch (aspect) {
        VerbAspect.imperfective => l10n.termCard_aspectImperfective,
        VerbAspect.perfective => l10n.termCard_aspectPerfective,
      };
}

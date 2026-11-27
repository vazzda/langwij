import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/entities/dictionary/dictionary.dart';
import 'package:langwij/features/pronunciation/pronunciation.dart';
import 'package:langwij/features/quiz/model/vocab_card.dart';

import 'term_example.dart';
import 'term_title.dart';

/// What the dictionary holds about the word of a card. Above, two columns:
/// on the left the word, its frequency rank, its type and the specifics of
/// the type; on the right the sound button. Below them, the example.
class TermDetailCard extends ConsumerWidget {
  const TermDetailCard({super.key, required this.card});

  static const String _labelValueSeparator = ' ';
  static const String _genderFormSeparator = ' / ';

  final VocabCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = FlesselThemes.of(context);
    final l10n = AppLocalizations.of(context)!;
    final example = card.targetNote;

    return FlesselCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildWordColumn(t, l10n)),
              const FlesselGap.s(),
              _buildSoundButton(context, ref, l10n),
            ],
          ),
          if (example != null) ...[
            const FlesselGap.s(),
            TermExample(example: example),
          ],
        ],
      ),
    );
  }

  /// The one style of every line that describes the word: its frequency
  /// rank, its type and the specifics of the type.
  TextStyle _descriptionStyle(FlesselThemeData t) =>
      FlesselFonts.contentBody.copyWith(color: t.fg);

  /// The word, then its frequency rank and its type, then the specifics of
  /// the type, one under the other.
  Widget _buildWordColumn(FlesselThemeData t, AppLocalizations l10n) {
    final frequencyRank = card.coca;
    final pos = card.pos;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TermTitle(text: card.targetText),
        if (frequencyRank != null || pos != null) const FlesselGap.xs(),
        if (frequencyRank != null)
          Text(
            l10n.termCard_cocaRank(frequencyRank),
            style: _descriptionStyle(t),
          ),
        if (pos != null)
          Text(_nameOfPartOfSpeech(pos, l10n), style: _descriptionStyle(t)),
        for (final specific in _specificsOfType(l10n)) ...[
          const FlesselGap.xs(),
          Text(specific, style: _descriptionStyle(t)),
        ],
      ],
    );
  }

  Widget _buildSoundButton(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    return Semantics(
      label: l10n.termCard_soundSemantics,
      button: true,
      child: FlesselButton(
        icon: PhosphorIcons.speakerHigh(),
        size: FlesselSize.m,
        surface: FlesselSurface.s21,
        onPressed: () => _pronounce(context, ref, l10n),
      ),
    );
  }

  /// The lines that tell what is particular to the word's type: the gender
  /// and the article of a noun, the aspect of a verb that stands alone, the
  /// gender forms of an adjective, both verbs of an aspect pair.
  List<String> _specificsOfType(AppLocalizations l10n) => switch (card) {
        SimpleVocabCard simple => _specificsOfSimpleCard(simple, l10n),
        PairVocabCard pair => [
            '${l10n.quiz_aspectImperfective}$_labelValueSeparator'
                '${pair.imperfectiveText}',
            '${l10n.quiz_aspectPerfective}$_labelValueSeparator'
                '${pair.perfectiveText}',
          ],
      };

  List<String> _specificsOfSimpleCard(
    SimpleVocabCard simple,
    AppLocalizations l10n,
  ) {
    final gender = simple.gender;
    final article = simple.article;
    final aspect = simple.aspect;
    final feminineForm = simple.feminineForm;
    final neuterForm = simple.neuterForm;

    return [
      if (gender != null) l10n.termCard_gender(_nameOfGender(gender, l10n)),
      if (article != null) l10n.termCard_article(article),
      if (aspect != null) l10n.termCard_aspect(_nameOfAspect(aspect, l10n)),
      if (feminineForm != null || neuterForm != null)
        [
          simple.targetText,
          if (feminineForm != null) feminineForm,
          if (neuterForm != null) neuterForm,
        ].join(_genderFormSeparator),
    ];
  }

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

  Future<void> _pronounce(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final ok = await ref
        .read(PronunciationService.instance)
        .pronounce(card.speechText);
    if (!ok && context.mounted) {
      FlesselSnackBar.show(context, l10n.termCard_soundFailed);
    }
  }
}

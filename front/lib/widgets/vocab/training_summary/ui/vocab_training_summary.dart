import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/l10n/app_localizations.dart';
import '../../deck_card/model/vocab_deck_card_data.dart';
import '../../deck_card/model/vocab_deck_study_phase.dart';
import '../../deck_card/model/vocab_level_data.dart';
import '../../elements/ui/vocab_counted_name_list.dart';
import '../../elements/ui/vocab_mastery_star.dart';
import '../../elements/ui/vocab_mastery_stars.dart';

/// What a summary describes. Its title is drawn as the title of a deck
/// card or as the name in a level header.
enum _TrainingSubject { deck, level }

/// What is about to be trained, shown in the mode sheet above the modes,
/// in a card of its own: its title, its term count with the names it holds
/// (the words of a deck, or the decks of a level), its studied share and,
/// once it is fully studied, its mastery: the practice box beside the
/// title, the count of finished practices, what is left to the next one
/// and the practice share. While it is not fully studied and a test is
/// offered, the test button stands under the studied share.
class LangwijVocabTrainingSummary extends StatelessWidget {
  /// The summary of one deck: its words are listed.
  LangwijVocabTrainingSummary.ofDeck({
    super.key,
    required this.l10n,
    required VocabDeckCardData deck,
    this.onTestTap,
  })  : _subject = _TrainingSubject.deck,
        title = deck.numberedName,
        listedNames = deck.words,
        termCount = deck.cardCount,
        studiedPercent = (deck.coverage ?? 0).toDouble(),
        isFullyStudied = deck.studyPhase == VocabDeckStudyPhase.training,
        practicePercent = deck.practice,
        mastery = deck.mastery;

  /// The summary of one level: its decks are listed by name. The level's
  /// mastery is that of its least mastered deck.
  LangwijVocabTrainingSummary.ofLevel({
    super.key,
    required this.l10n,
    required VocabLevelData level,
  })  : _subject = _TrainingSubject.level,
        title = level.name,
        listedNames = [for (final deck in level.decks) deck.name],
        termCount = level.totalCardCount,
        studiedPercent = level.levelProgress,
        isFullyStudied = level.isEveryDeckFullyStudied,
        practicePercent = level.averagePracticePercent,
        mastery = level.lowestDeckMastery,
        onTestTap = null;

  static const double _fullPercent = 100.0;
  static const FlesselSize _paddingOfContent = FlesselSize.m;
  static const FlesselSize _bottomPaddingWithoutMastery = FlesselSize.xs;

  final AppLocalizations l10n;
  final _TrainingSubject _subject;

  /// The name of the deck or of the level.
  final String title;

  final List<String> listedNames;
  final int termCount;

  /// The studied share, 0 to 100.
  final double studiedPercent;

  /// True once the deck, or every deck of the level, is fully studied; the
  /// practice box and the mastery section show from then on.
  final bool isFullyStudied;

  /// The practice share, 0 to 100.
  final double practicePercent;

  /// How many times the practice was finished.
  final int mastery;

  /// Starts a test of the deck; null when no test is offered, as for a
  /// level.
  final VoidCallback? onTestTap;

  /// What is left of the practice until it is finished once more, 0 to 100.
  int get _percentLeftToNextStar =>
      (_fullPercent - practicePercent).clamp(0.0, _fullPercent).round();

  /// The test button shows while a test is offered and the subject is not
  /// fully studied, so it never stands beside the mastery section.
  bool get _showsTestButton => onTestTap != null && !isFullyStudied;

  /// The content stands off the card's border by the card's regular
  /// padding. Without the mastery section the bottom padding is smaller.
  EdgeInsets get _contentPadding {
    final regularPadding = FlesselLayout.cardPadding(_paddingOfContent);
    final bottomPadding = isFullyStudied
        ? regularPadding
        : FlesselLayout.cardPadding(_bottomPaddingWithoutMastery);

    return EdgeInsets.fromLTRB(
      regularPadding,
      regularPadding,
      regularPadding,
      bottomPadding,
    );
  }

  @override
  Widget build(BuildContext context) {
    // The sheet sets the space under the summary, so the card has no
    // margin of its own. The summary pads its content itself, so the card
    // has no padding of its own either.
    return FlesselCard(
      margin: FlesselSize.none,
      padding: FlesselSize.none,
      child: Padding(
        padding: _contentPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTitleWithPracticeBox(context),
            const FlesselGap.m(),
            LangwijVocabCountedNameList(
              l10n: l10n,
              termCount: termCount,
              names: listedNames,
              length: VocabCountedNameListLength.full,
            ),
            const FlesselGap.l(),
            _buildStudiedSection(context),
            if (isFullyStudied) ...[
              const FlesselGap.l(),
              _buildMasterySection(context),
            ],
          ],
        ),
      ),
    );
  }

  /// The title and, once the subject is fully studied, the practice box at
  /// the end of its line, in the form a deck card shows. The box keeps its
  /// width, so a long title goes on to further lines beside it.
  Widget _buildTitleWithPracticeBox(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildTitle(context)),
        if (isFullyStudied) ...[
          const FlesselGap.s(),
          LangwijVocabMasteryStars(
            finishedPracticeCount: mastery,
            form: VocabMasteryStarsForm.collapsed,
          ),
        ],
      ],
    );
  }

  /// The title in the font the vocabulary list gives it: that of a deck
  /// card's title for a deck, that of a level header's name for a level.
  Widget _buildTitle(BuildContext context) {
    final t = FlesselThemes.of(context);
    final titleFont = switch (_subject) {
      _TrainingSubject.deck => FlesselFonts.displayL,
      _TrainingSubject.level => FlesselFonts.displayXl,
    };

    return Text(title, style: titleFont.copyWith(color: t.fg));
  }

  /// The studied label with the studied share as a percent, as one text:
  /// "Studied: 45%". Directly under it, the bar of the studied share and,
  /// while it shows, the test button.
  Widget _buildStudiedSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${l10n.vocab_studiedLabel} ${studiedPercent.round()}%',
          style: _labelStyleIn(context),
        ),
        _buildProgressBar(
          progressPercent: studiedPercent,
          barVariant: FlesselProgressBarVariant.accent,
        ),
        if (_showsTestButton) ...[
          const FlesselGap.s(),
          _buildTestButton(),
        ],
      ],
    );
  }

  /// The test button, as wide as its label, at the end of its line.
  Widget _buildTestButton() {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: FlesselButton(
        label: l10n.mode_test,
        size: FlesselSize.s,
        onPressed: onTestTap,
      ),
    );
  }

  /// One line with the mastery label, the count of finished practices and
  /// a star at its start, and what is left to the next star at its end:
  /// "Mastery: 7 ★ ... next star in 28%". Directly under it the bar of the
  /// practice share.
  Widget _buildMasterySection(BuildContext context) {
    final labelStyle = _labelStyleIn(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text('${l10n.vocab_masteryLabel} $mastery', style: labelStyle),
            const FlesselGap.xxs(),
            const LangwijVocabMasteryStar(kind: VocabMasteryStarKind.inText),
            const FlesselGap.s(),
            Expanded(
              child: Text(
                l10n.vocab_nextStarIn(_percentLeftToNextStar),
                textAlign: TextAlign.end,
                style: labelStyle,
              ),
            ),
          ],
        ),
        _buildProgressBar(
          progressPercent: practicePercent,
          barVariant: FlesselProgressBarVariant.regular,
        ),
      ],
    );
  }

  /// The font of a section's label: that of the counted list's count.
  TextStyle _labelStyleIn(BuildContext context) {
    return FlesselFonts.contentSAccent
        .copyWith(color: FlesselThemes.of(context).fg);
  }

  Widget _buildProgressBar({
    required double progressPercent,
    required FlesselProgressBarVariant barVariant,
  }) {
    return FlesselProgressBar(
      value: (progressPercent / _fullPercent).clamp(0.0, 1.0),
      mode: FlesselProgressBarMode.detailed,
      variant: barVariant,
    );
  }
}

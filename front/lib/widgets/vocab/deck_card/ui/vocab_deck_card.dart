import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/shared/app/layout/layout.dart';
import 'package:langwij/shared/date_format/date_format.dart';
import 'package:langwij/shared/deck_icons/deck_icons.dart';
import '../model/vocab_deck_card_data.dart';
import '../model/vocab_deck_study_phase.dart';
import '../../elements/ui/vocab_counted_name_list.dart';
import '../../elements/ui/vocab_mastery_stars.dart';
import 'vocab_deck_icon.dart';

class LangwijVocabDeckCard extends StatelessWidget {
  const LangwijVocabDeckCard({
    super.key,
    required this.item,
    required this.l10n,
    required this.onTap,
    this.transparent = true,
  });

  static const double _fullPercent = 100.0;
  static const int _daysSinceLastRoundCountedAsYesterday = 1;

  /// Three quarter turns clockwise stand a left-to-right bar upright with
  /// its start at the bottom, so it fills from the bottom up.
  static const int _quarterTurnsStandingBarWithStartAtBottom = 3;

  final VocabDeckCardData item;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  /// A transparent deck card paints no surface of its own and is hosted on
  /// the card surface, inside a level block. A deck card that is not
  /// transparent paints the card surface itself.
  final bool transparent;

  /// Practice and its finished rounds start counting once the deck is fully
  /// studied; the mastery stars and the practice share of the progress bar
  /// show from then on.
  bool get _isDeckFullyStudied =>
      item.studyPhase == VocabDeckStudyPhase.training;

  /// The studied share of the deck, from 0.0 (nothing) to 1.0 (all of it).
  double get _studiedShare =>
      ((item.coverage ?? 0) / _fullPercent).clamp(0.0, 1.0);

  /// The practice share of the deck, from 0.0 (none) to 1.0 (full).
  double get _practiceShare => (item.practice / _fullPercent).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return FlesselCard(
      variant: transparent ? FlesselCardVariant.transparent : FlesselCardVariant.regular,
      margin: transparent ? FlesselSize.l : FlesselSize.none,
      onTap: item.cardCount > 0 ? onTap : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconWithMasteryStarsBelow(context),
          const FlesselGap.s(),
          Expanded(child: _buildTitleWithDetails(context)),
        ],
      ),
    );
  }

  /// The icon box and, once the deck is fully studied, the collapsed
  /// practice box with the stars of its finished practices, as wide as the
  /// icon box and centred under it. The practice box is drawn a little
  /// higher than its place in the column, so it lies over the icon box's
  /// lower edge.
  Widget _buildIconWithMasteryStarsBelow(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIconWithProgressBar(context),
        if (_isDeckFullyStudied)
          Transform.translate(
            offset: const Offset(0, -LangwijLayout.vocabDeckStarsOverlapOnIcon),
            child: LangwijVocabMasteryStars(
              finishedPracticeCount: item.mastery,
              form: VocabMasteryStarsForm.collapsed,
            ),
          ),
      ],
    );
  }

  /// The icon box, with the progress bar standing to its left once anything
  /// of the deck is studied.
  Widget _buildIconWithProgressBar(BuildContext context) {
    final deckIconName = item.icon;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        LangwijVocabDeckIcon(
          icon: deckIconName != null
              ? DeckIcons.fromString(deckIconName)
              : DeckIcons.fallback,
        ),
        if (_studiedShare > 0) _buildProgressBarFloatingLeftOfIcon(context),
      ],
    );
  }

  /// The deck's progress as the thinnest progress bar, standing left of the
  /// icon box, of a fixed length centred on the box's height and filling
  /// from the bottom up. While the deck is being studied it is the accent
  /// bar and shows the studied share. Once the deck is fully studied the
  /// regular bar takes its place and shows the practice share. The bar
  /// floats outside the card's layout, in the space the deck indent leaves,
  /// so it moves nothing.
  Widget _buildProgressBarFloatingLeftOfIcon(BuildContext context) {
    final barThickness = FlesselThemes.of(context).progressBarHeightS;

    return Positioned(
      top: 0,
      bottom: 0,
      left: -(barThickness + FlesselLayout.gapXs),
      width: barThickness,
      child: Center(
        child: SizedBox(
          width: barThickness,
          height: LangwijLayout.vocabDeckProgressBarLength,
          child: RotatedBox(
            quarterTurns: _quarterTurnsStandingBarWithStartAtBottom,
            child: _isDeckFullyStudied
                ? _buildPracticeBar()
                : _buildStudiedBar(),
          ),
        ),
      ),
    );
  }

  Widget _buildStudiedBar() {
    return FlesselProgressBar(
      value: _studiedShare,
      mode: FlesselProgressBarMode.compact,
      variant: FlesselProgressBarVariant.accent,
    );
  }

  Widget _buildPracticeBar() {
    return FlesselProgressBar(
      value: _practiceShare,
      mode: FlesselProgressBarMode.compact,
      variant: FlesselProgressBarVariant.regular,
    );
  }

  /// The deck title, the term count with the word preview and, once the
  /// deck has had a round, the line on when it was last trained.
  Widget _buildTitleWithDetails(BuildContext context) {
    final lastRoundDate = item.progress?.lastRoundDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDeckTitle(context),
        const FlesselGap.xs(),
        LangwijVocabCountedNameList(
          l10n: l10n,
          termCount: item.cardCount,
          names: item.words,
          length: VocabCountedNameListLength.preview,
        ),
        if (lastRoundDate != null) ...[
          const FlesselGap.s(),
          _buildLastTrainedRow(context, lastRoundDate),
        ],
      ],
    );
  }

  Widget _buildDeckTitle(BuildContext context) {
    final t = FlesselThemes.of(context);

    return Text(
      item.numberedName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: FlesselFonts.displayL.copyWith(color: t.fg),
    );
  }

  Widget _buildLastTrainedRow(BuildContext context, DateTime lastRoundDate) {
    final t = FlesselThemes.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          l10n.vocab_lastTrained,
          style: FlesselFonts.contentXs.copyWith(color: t.fgSecondary),
        ),
        const FlesselGap.xxs(),
        Icon(
          PhosphorIconsFill.circle,
          size: FlesselLayout.iconXxxs,
          color: _freshnessColorOfLastRound(t, lastRoundDate),
        ),
        const FlesselGap.xxs(),
        Text(
          RelativeDateFormat.format(lastRoundDate, l10n).toUpperCase(),
          style: FlesselFonts.contentXsAccent.copyWith(color: t.fg),
        ),
      ],
    );
  }

  /// Today reads as fresh, yesterday as a warning, anything older as stale.
  Color _freshnessColorOfLastRound(
    FlesselThemeData t,
    DateTime lastRoundDate,
  ) {
    final now = DateTime.now();
    final daysSinceLastRound = DateTime(now.year, now.month, now.day)
        .difference(
          DateTime(lastRoundDate.year, lastRoundDate.month, lastRoundDate.day),
        )
        .inDays;

    if (daysSinceLastRound <= 0) return t.surface21.regular.bg.colorValue;
    if (daysSinceLastRound == _daysSinceLastRoundCountedAsYesterday) {
      return t.surface21.accent.bg.colorValue;
    }
    return t.surface21.danger.bg.colorValue;
  }
}

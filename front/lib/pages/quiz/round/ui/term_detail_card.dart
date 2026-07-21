import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/features/quiz/model/vocab_card.dart';

class TermDetailCard extends StatelessWidget {
  const TermDetailCard({super.key, required this.card});

  final VocabCard card;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final l10n = AppLocalizations.of(context)!;

    return FlesselCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _capitalize(card.targetText),
            style: FlesselFonts.contentXxxlAccent.copyWith(color: t.fg),
          ),
          const FlesselGap.s(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.termCard_phoneticPlaceholder,
                style: FlesselFonts.contentBodyAccent.copyWith(
                  color: t.fgSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              if (card.coca != null)
                Text(
                  l10n.termCard_cocaRank(card.coca!),
                  style: FlesselFonts.contentBodyAccent.copyWith(
                    color: t.fgSecondary,
                  ),
                ),
            ],
          ),
          if (card.pos.isNotEmpty) ...[
            const FlesselGap.xs(),
            Text(
              card.pos,
              style: FlesselFonts.contentBodyAccent.copyWith(color: t.fgSecondary),
            ),
          ],
          if (card is SimpleVocabCard) ..._buildSimpleDetails(
            card as SimpleVocabCard,
            l10n,
            t,
          ),
          if (card is PairVocabCard) ..._buildPairDetails(
            card as PairVocabCard,
            l10n,
            t,
          ),
          if (card.targetNote != null) ...[
            const FlesselGap.s(),
            Text.rich(TextSpan(
              children: [
                TextSpan(
                  text: l10n.termCard_example,
                  style: FlesselFonts.contentBodyAccent.copyWith(
                    color: t.fgSecondary,
                  ),
                ),
                TextSpan(
                  text: ' ${card.targetNote!}',
                  style: FlesselFonts.contentBody.copyWith(
                    color: t.fgSecondary,
                  ),
                ),
              ],
            )),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildSimpleDetails(
    SimpleVocabCard simple,
    AppLocalizations l10n,
    FlesselThemeData t,
  ) {
    final widgets = <Widget>[];

    if (simple.gender != null) {
      widgets.add(const FlesselGap.xs());
      widgets.add(Text(
        l10n.termCard_gender(simple.gender!),
        style: FlesselFonts.contentBodyAccent.copyWith(color: t.fgSecondary),
      ));
    }

    if (simple.feminineForm != null || simple.neuterForm != null) {
      final forms = [simple.targetText];
      if (simple.feminineForm != null) forms.add(simple.feminineForm!);
      if (simple.neuterForm != null) forms.add(simple.neuterForm!);
      widgets.add(const FlesselGap.xs());
      widgets.add(Text(
        forms.join(' / '),
        style: FlesselFonts.contentBodyAccent.copyWith(color: t.fgSecondary),
      ));
    }

    return widgets;
  }

  List<Widget> _buildPairDetails(
    PairVocabCard pair,
    AppLocalizations l10n,
    FlesselThemeData t,
  ) {
    return [
      const FlesselGap.xs(),
      Text(
        '${l10n.quiz_aspectImperfective} ${pair.imperfectiveText}',
        style: FlesselFonts.contentBodyAccent.copyWith(color: t.fgSecondary),
      ),
      const FlesselGap.xs(),
      Text(
        '${l10n.quiz_aspectPerfective} ${pair.perfectiveText}',
        style: FlesselFonts.contentBodyAccent.copyWith(color: t.fgSecondary),
      ),
    ];
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

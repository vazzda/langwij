import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/features/pronunciation/pronunciation.dart';
import 'package:langwij/features/quiz/model/vocab_card.dart';

import 'term_example.dart';
import 'term_info_section.dart';
import 'term_title.dart';

/// What the dictionary holds about the word of a card. Above, two columns:
/// on the left the word and under it the info section; on the right the
/// sound button. Below them, the example.
class TermDetailCard extends ConsumerWidget {
  const TermDetailCard({super.key, required this.card});

  final VocabCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              Expanded(child: _buildWordColumn()),
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

  /// The word, and under it the info section.
  Widget _buildWordColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TermTitle(text: card.targetText),
        const FlesselGap.xs(),
        TermInfoSection(card: card),
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

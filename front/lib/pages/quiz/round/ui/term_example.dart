import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/entities/dictionary/dictionary.dart';

/// The example sentence of a term behind its label, in italic; the term's
/// own word, the marked run, stands upright in the accent weight.
class TermExample extends StatelessWidget {
  const TermExample({super.key, required this.example});

  static const String _labelValueSeparator = ' ';

  /// The example as it stands in the translation files, marks included.
  final String example;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final l10n = AppLocalizations.of(context)!;
    final italicStyle =
        FlesselFonts.contentBodyAccentItalic.copyWith(color: t.fg);
    final markedStyle = FlesselFonts.contentBodyAccent.copyWith(color: t.fg);

    return Text.rich(TextSpan(
      children: [
        TextSpan(
          text: '${l10n.termCard_example}$_labelValueSeparator',
          style: italicStyle,
        ),
        for (final segment in TermNoteSegment.splitNoteIntoSegments(example))
          TextSpan(
            text: segment.text,
            style: segment.isMarked ? markedStyle : italicStyle,
          ),
      ],
    ));
  }
}

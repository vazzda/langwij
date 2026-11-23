import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/entities/dictionary/dictionary.dart';

/// The note of a term in a box of its own: one example sentence, with the
/// term's own word, the marked run, in the accent weight. The box takes the
/// theme's note values, so it sits like any other note beside it.
class TermNoteBox extends StatelessWidget {
  const TermNoteBox({super.key, required this.note});

  /// The note as it stands in the translation files, marks included.
  final String note;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final boxColors = t.surface02.regular;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: FlesselLayout.notePaddingH,
        vertical: FlesselLayout.notePaddingV,
      ),
      decoration: BoxDecoration(
        color: boxColors.bg.color,
        gradient: boxColors.bg.gradient,
        borderRadius: BorderRadius.circular(t.noteBorderRadius),
        border: Border.all(color: boxColors.border, width: t.noteBorderWidth),
      ),
      child: Text.rich(TextSpan(children: _buildSpansOfNote(t))),
    );
  }

  /// The note as spans: the marked word stands in the accent weight, the
  /// rest in the regular one.
  List<TextSpan> _buildSpansOfNote(FlesselThemeData t) => [
        for (final segment in TermNoteSegment.splitNoteIntoSegments(note))
          TextSpan(
            text: segment.text,
            style: (segment.isMarked
                    ? FlesselFonts.contentSAccent
                    : FlesselFonts.contentS)
                .copyWith(color: t.fg),
          ),
      ];
}

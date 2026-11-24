import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/l10n/app_localizations.dart';

/// How much of the list is shown.
enum VocabCountedNameListLength {
  /// Always two lines tall: a shorter list leaves the rest empty, a longer
  /// one is cut with an ellipsis.
  preview,

  /// The whole list.
  full,
}

/// A term count followed by the names it covers, as one text:
/// "20 terms: one, two, three".
class LangwijVocabCountedNameList extends StatelessWidget {
  const LangwijVocabCountedNameList({
    super.key,
    required this.l10n,
    required this.termCount,
    required this.names,
    required this.length,
  });

  static const int _previewLineCount = 2;
  static const String _separatorOfCountAndNames = ': ';
  static const String _separatorOfNames = ', ';

  final AppLocalizations l10n;
  final int termCount;
  final List<String> names;
  final VocabCountedNameListLength length;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final namesStyle = FlesselFonts.contentCaption.copyWith(color: t.fg);
    final countWithNames = TextSpan(
      children: [
        TextSpan(
          text: l10n.vocab_termsCount(termCount) + _separatorOfCountAndNames,
          style: FlesselFonts.contentSAccent.copyWith(color: t.fg),
        ),
        TextSpan(text: names.join(_separatorOfNames), style: namesStyle),
      ],
    );

    return switch (length) {
      VocabCountedNameListLength.full => Text.rich(countWithNames),
      VocabCountedNameListLength.preview => Stack(
          children: [
            _buildHeightReservedForPreviewLines(namesStyle),
            Text.rich(
              countWithNames,
              maxLines: _previewLineCount,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
    };
  }

  /// An invisible text of exactly [_previewLineCount] empty lines; it gives
  /// the preview its fixed height.
  Widget _buildHeightReservedForPreviewLines(TextStyle namesStyle) {
    const lineBreak = '\n';

    return ExcludeSemantics(
      child: Text(
        lineBreak * (_previewLineCount - 1),
        maxLines: _previewLineCount,
        style: namesStyle,
      ),
    );
  }
}

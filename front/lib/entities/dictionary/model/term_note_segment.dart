/// One run of a term's note. A marked run is the term's own word inside the
/// example sentence; the cards draw it in a heavier weight.
class TermNoteSegment {
  const TermNoteSegment({required this.text, required this.isMarked});

  /// Opens and closes a marked run in the note text of the translation files:
  /// `I *want* water.`
  static const String markCharacter = '*';

  final String text;
  final bool isMarked;

  /// Splits a note at its marks. The text between a pair of marks is a marked
  /// run. A mark without a partner stays in the text as it was typed, and an
  /// empty run is left out.
  static List<TermNoteSegment> splitNoteIntoSegments(String note) {
    final parts = note.split(markCharacter);
    // An even count of parts means an odd count of marks: the last mark has
    // no partner, so it and the text after it rejoin the run before them.
    final hasMarkWithoutPartner = parts.length.isEven;
    if (hasMarkWithoutPartner) {
      final textAfterLoneMark = parts.removeLast();
      parts.last = '${parts.last}$markCharacter$textAfterLoneMark';
    }

    final segments = <TermNoteSegment>[];
    for (var partIndex = 0; partIndex < parts.length; partIndex++) {
      if (parts[partIndex].isEmpty) continue;
      segments.add(
        TermNoteSegment(text: parts[partIndex], isMarked: partIndex.isOdd),
      );
    }
    return segments;
  }

  @override
  bool operator ==(Object other) =>
      other is TermNoteSegment &&
      other.text == text &&
      other.isMarked == isMarked;

  @override
  int get hashCode => Object.hash(text, isMarked);

  @override
  String toString() => isMarked ? '[$text]' : text;
}

import 'package:flutter_test/flutter_test.dart';
import 'package:langwij/entities/dictionary/dictionary.dart';

TermNoteSegment _plainRun(String text) =>
    TermNoteSegment(text: text, isMarked: false);

TermNoteSegment _markedRun(String text) =>
    TermNoteSegment(text: text, isMarked: true);

void main() {
  group('TermNoteSegment.splitNoteIntoSegments', () {
    test('a note without marks is one plain run', () {
      expect(
        TermNoteSegment.splitNoteIntoSegments('I want water.'),
        [_plainRun('I want water.')],
      );
    });

    test('the text between a pair of marks is a marked run', () {
      expect(
        TermNoteSegment.splitNoteIntoSegments('I *want* water.'),
        [_plainRun('I '), _markedRun('want'), _plainRun(' water.')],
      );
    });

    test('a word in two parts gives two marked runs', () {
      expect(
        TermNoteSegment.splitNoteIntoSegments('*Sviđa* mi *se* ovaj grad.'),
        [
          _markedRun('Sviđa'),
          _plainRun(' mi '),
          _markedRun('se'),
          _plainRun(' ovaj grad.'),
        ],
      );
    });

    test('a mark may open the note', () {
      expect(
        TermNoteSegment.splitNoteIntoSegments('*No*, thank you.'),
        [_markedRun('No'), _plainRun(', thank you.')],
      );
    });

    test('a mark may close the note', () {
      expect(
        TermNoteSegment.splitNoteIntoSegments('Turn *left*'),
        [_plainRun('Turn '), _markedRun('left')],
      );
    });

    test('a lone mark stays in the text as it was typed', () {
      expect(
        TermNoteSegment.splitNoteIntoSegments('5 * 3 is fifteen'),
        [_plainRun('5 * 3 is fifteen')],
      );
    });

    test('a lone mark after a marked run stays in the text', () {
      expect(
        TermNoteSegment.splitNoteIntoSegments('I *want* 2 * water'),
        [_plainRun('I '), _markedRun('want'), _plainRun(' 2 * water')],
      );
    });

    test('an empty note has no runs', () {
      expect(TermNoteSegment.splitNoteIntoSegments(''), isEmpty);
    });
  });
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:langwij/entities/dictionary/dictionary.dart';
import 'package:langwij/features/dev_tools/model/progress_seed.dart';

const String _dictionaryFilePath = 'assets/data/dictionary.json';
const String _levelsFilePath = 'assets/data/levels.json';
const String _fullSeedFilePath = 'assets/seeds/seed_full.json';

const String _deckId = 'some_deck';
const List<String> _fiveTermIds = ['one', 'two', 'three', 'four', 'five'];

DeckProgressSeed _deckSeedWithCoverage(Map<String, dynamic> coverageJson) {
  return DeckProgressSeed.fromJson({'deck_id': _deckId, ...coverageJson});
}

Map<String, dynamic> _seedJsonOfDecks(List<Map<String, dynamic>> decksJson) {
  return {
    'target_lang': 'sr',
    'decks': decksJson,
    'activity': {
      'history_days': 1,
      'correct': 1,
      'wrong': 1,
      'words_per_day': 1,
    },
  };
}

Matcher _throwsSeedFaultNaming(String namedText) {
  return throwsA(
    isA<ProgressSeedException>().having(
      (seedFault) => seedFault.message,
      'message',
      contains(namedText),
    ),
  );
}

Map<String, dynamic> _readJsonFile(String filePath) {
  return jsonDecode(File(filePath).readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  group('DeckProgressSeed.assignCoverageToTerms', () {
    test('one coverage of all terms reaches every term of the deck', () {
      final deckSeed = _deckSeedWithCoverage({'all_terms_coverage': 100});

      expect(
        deckSeed.assignCoverageToTerms(_fiveTermIds),
        {'one': 100, 'two': 100, 'three': 100, 'four': 100, 'five': 100},
      );
    });

    test('counted coverage goes to the first terms, the highest first', () {
      final deckSeed = _deckSeedWithCoverage({
        'term_coverages': {'50': 1, '100': 2},
      });

      expect(
        deckSeed.assignCoverageToTerms(_fiveTermIds),
        {'one': 100, 'two': 100, 'three': 50, 'four': 0, 'five': 0},
      );
    });

    test('a count of more terms than the deck holds is refused', () {
      final deckSeed = _deckSeedWithCoverage({
        'term_coverages': {'100': 4, '50': 2},
      });

      expect(
        () => deckSeed.assignCoverageToTerms(_fiveTermIds),
        _throwsSeedFaultNaming(_deckId),
      );
    });
  });

  group('DeckProgressSeed.fromJson', () {
    test('a deck that states no coverage is refused', () {
      expect(
        () => _deckSeedWithCoverage({}),
        _throwsSeedFaultNaming(_deckId),
      );
    });

    test('a deck that states both kinds of coverage is refused', () {
      expect(
        () => _deckSeedWithCoverage({
          'all_terms_coverage': 100,
          'term_coverages': {'100': 2},
        }),
        _throwsSeedFaultNaming(_deckId),
      );
    });

    test('a coverage above the full one is refused', () {
      expect(
        () => _deckSeedWithCoverage({'all_terms_coverage': 101}),
        _throwsSeedFaultNaming('101'),
      );
    });

    test('a counted coverage that is not a number is refused', () {
      expect(
        () => _deckSeedWithCoverage({
          'term_coverages': {'half': 2},
        }),
        _throwsSeedFaultNaming('half'),
      );
    });

    test('a count of no terms is refused', () {
      expect(
        () => _deckSeedWithCoverage({
          'term_coverages': {'50': 0},
        }),
        _throwsSeedFaultNaming(_deckId),
      );
    });
  });

  group('ProgressSeed', () {
    test('a deck listed twice is refused', () {
      expect(
        () => ProgressSeed.fromJson(
          _seedJsonOfDecks([
            {'deck_id': _deckId, 'all_terms_coverage': 100},
            {'deck_id': _deckId, 'all_terms_coverage': 50},
          ]),
        ),
        _throwsSeedFaultNaming(_deckId),
      );
    });

    test('a deck the app does not hold is refused', () {
      final seed = ProgressSeed.fromJson(
        _seedJsonOfDecks([
          {'deck_id': _deckId, 'all_terms_coverage': 100},
        ]),
      );

      expect(
        () => seed.assignCoverageToTermsOfDecks(const {}),
        _throwsSeedFaultNaming(_deckId),
      );
    });

    test('the studied percent of a deck is the mean coverage of its terms', () {
      final seed = ProgressSeed.fromJson(
        _seedJsonOfDecks([
          {
            'deck_id': _deckId,
            'term_coverages': {'100': 2, '50': 1},
          },
        ]),
      );

      final seededDeckCoverages = seed.assignCoverageToTermsOfDecks(const {
        _deckId: VocabDeckModel(id: _deckId, termIds: _fiveTermIds),
      });

      expect(seededDeckCoverages.single.studiedPercentOfDeck, 50.0);
    });
  });

  test('the full seed fits the decks the app holds', () {
    final dictionary = Dictionary.fromDictionaryAndLevelsJson(
      dictionaryJson: _readJsonFile(_dictionaryFilePath),
      levelsJson: _readJsonFile(_levelsFilePath),
    );
    final seed = ProgressSeed.fromJson(_readJsonFile(_fullSeedFilePath));

    final seededDeckCoverages = seed.assignCoverageToTermsOfDecks(
      dictionary.decksById,
    );

    expect(seededDeckCoverages, hasLength(seed.deckSeeds.length));
  });
}

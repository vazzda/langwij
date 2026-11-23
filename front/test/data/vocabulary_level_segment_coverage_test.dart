import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:langwij/entities/dictionary/dictionary.dart';

const String _dictionaryFilePath = 'assets/data/dictionary.json';
const String _levelsFilePath = 'assets/data/levels.json';

void main() {
  test(
    'every level except the specialized one belongs to a vocabulary segment',
    () {
      final dictionary = Dictionary.fromDictionaryAndLevelsJson(
        dictionaryJson: _readJsonFile(_dictionaryFilePath),
        levelsJson: _readJsonFile(_levelsFilePath),
      );
      final levelIdsListedInSegments = {
        for (final segment in dictionary.vocabularyLevelSegments)
          ...segment.levelIds,
      };

      final levelIdsOutsideEverySegment = dictionary.levels
          .map((level) => level.id)
          .where((levelId) => levelId != Level.specializedLevelId)
          .where((levelId) => !levelIdsListedInSegments.contains(levelId))
          .toList();

      expect(levelIdsOutsideEverySegment, isEmpty);
    },
  );
}

Map<String, dynamic> _readJsonFile(String filePath) {
  return jsonDecode(File(filePath).readAsStringSync()) as Map<String, dynamic>;
}

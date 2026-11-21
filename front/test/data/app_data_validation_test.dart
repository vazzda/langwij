import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:langwij/shared/app/validators/validators.dart';

const String _dataDirectoryPath = 'assets/data';
const String _planFileName = 'plan.json';
const String _dictionaryFileName = 'dictionary.json';
const String _levelsFileName = 'levels.json';
const String _translationsDirectoryName = 'translations';
const String _jsonFileNameSuffix = '.json';

void main() {
  test('the bundled data files pass the start-up validation', () {
    expect(
      () => ConfigValidationService.validateAll(
        planData: _readJsonFileOfDataDirectory(_planFileName),
        dictionaryData: _readJsonFileOfDataDirectory(_dictionaryFileName),
        levelsData: _readJsonFileOfDataDirectory(_levelsFileName),
        translationsByCode: _readTranslationsByLanguageCode(),
      ),
      returnsNormally,
    );
  });
}

Map<String, dynamic> _readJsonFile(File file) {
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

Map<String, dynamic> _readJsonFileOfDataDirectory(String fileName) {
  return _readJsonFile(File('$_dataDirectoryPath/$fileName'));
}

String _fileNameOfFile(File file) => file.uri.pathSegments.last;

Map<String, Map<String, dynamic>> _readTranslationsByLanguageCode() {
  final translationFiles = Directory('$_dataDirectoryPath/$_translationsDirectoryName')
      .listSync()
      .whereType<File>()
      .where((file) => _fileNameOfFile(file).endsWith(_jsonFileNameSuffix));
  return {
    for (final translationFile in translationFiles)
      _fileNameOfFile(translationFile).replaceAll(_jsonFileNameSuffix, ''):
          _readJsonFile(translationFile),
  };
}

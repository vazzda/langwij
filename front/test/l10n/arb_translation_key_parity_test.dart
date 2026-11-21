import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const String _localizationDirectoryPath = 'lib/l10n';
const String _arbFileNamePrefix = 'app_';
const String _arbFileNameSuffix = '.arb';
const String _templateLanguageCode = 'en';
const String _arbMetadataKeyPrefix = '@';
const String _planFilePath = 'assets/data/plan.json';
const String _planLanguagesKey = 'languages';
const String _planLanguageCodeKey = 'code';

void main() {
  test('every translated arb file holds exactly the keys of the template', () {
    final templateMessageKeys = _readMessageKeysOfArbFile(
      _arbFileForLanguageCode(_templateLanguageCode),
    );

    for (final translatedArbFile in _listTranslatedArbFiles()) {
      final translatedMessageKeys = _readMessageKeysOfArbFile(translatedArbFile);

      expect(
        templateMessageKeys.difference(translatedMessageKeys),
        isEmpty,
        reason: '${translatedArbFile.path} lacks keys of the template',
      );
      expect(
        translatedMessageKeys.difference(templateMessageKeys),
        isEmpty,
        reason: '${translatedArbFile.path} holds keys the template does not',
      );
    }
  });

  test('every language of plan.json has an arb file', () {
    for (final languageCode in _readLanguageCodesOfPlanFile()) {
      expect(
        _arbFileForLanguageCode(languageCode).existsSync(),
        isTrue,
        reason: 'plan.json declares "$languageCode" but its arb file is missing',
      );
    }
  });
}

String _arbFileNameForLanguageCode(String languageCode) {
  return '$_arbFileNamePrefix$languageCode$_arbFileNameSuffix';
}

File _arbFileForLanguageCode(String languageCode) {
  return File(
    '$_localizationDirectoryPath/${_arbFileNameForLanguageCode(languageCode)}',
  );
}

String _fileNameOfFile(File file) => file.uri.pathSegments.last;

List<File> _listTranslatedArbFiles() {
  final templateArbFileName = _arbFileNameForLanguageCode(_templateLanguageCode);
  return Directory(_localizationDirectoryPath)
      .listSync()
      .whereType<File>()
      .where((file) => _fileNameOfFile(file).endsWith(_arbFileNameSuffix))
      .where((file) => _fileNameOfFile(file) != templateArbFileName)
      .toList();
}

Set<String> _readMessageKeysOfArbFile(File arbFile) {
  final arbContent = jsonDecode(arbFile.readAsStringSync()) as Map<String, dynamic>;
  return arbContent.keys
      .where((key) => !key.startsWith(_arbMetadataKeyPrefix))
      .toSet();
}

List<String> _readLanguageCodesOfPlanFile() {
  final planContent = jsonDecode(File(_planFilePath).readAsStringSync()) as Map<String, dynamic>;
  final languageEntries = planContent[_planLanguagesKey] as List<dynamic>;
  return [
    for (final languageEntry in languageEntries)
      (languageEntry as Map<String, dynamic>)[_planLanguageCodeKey] as String,
  ];
}

import 'dart:convert';

import 'package:flutter/services.dart';

import '../model/language_entry.dart';
import '../model/level_tier.dart';
import '../model/plan_note.dart';

class PlanRepository {
  static const String _planPath = 'assets/data/plan.json';
  static const String _aiGeneratedLanguageKey = 'aiGenerated';
  static const bool _isAiGeneratedWhenNotStated = false;
  static const String _languageCardTermsKey = 'language_card_terms';
  static const String _nativeNoteTitleKey = 'nativeNoteTitle';
  static const String _nativeNoteTextKey = 'nativeNote';
  static const String _courseNoteTitleKey = 'noteTitle';
  static const String _courseNoteTextKey = 'note';

  Map<String, List<String>>? _cachedCourses;
  Map<String, PlanNote>? _cachedCourseNotes;
  List<String>? _cachedPublicLanguages;
  List<LanguageEntry>? _cachedLanguages;
  List<String>? _cachedLanguageCardTermIds;

  Future<void> _load() async {
    if (_cachedCourses != null) return;
    final json = await rootBundle.loadString(_planPath);
    final data = jsonDecode(json) as Map<String, dynamic>;

    _cachedLanguages = (data['languages'] as List<dynamic>)
        .map((e) {
          final map = e as Map<String, dynamic>;
          return LanguageEntry(
            code: map['code'] as String,
            labelKey: map['labelKey'] as String,
            humanVerified: map['humanVerified'] as int,
            isAiGenerated: map[_aiGeneratedLanguageKey] as bool? ??
                _isAiGeneratedWhenNotStated,
            nativeNote: PlanNote.fromJsonOrNull(
              map,
              titleKey: _nativeNoteTitleKey,
              textKey: _nativeNoteTextKey,
            ),
          );
        })
        .toList();

    _cachedPublicLanguages =
        (data['public_languages'] as List<dynamic>).cast<String>();

    _cachedLanguageCardTermIds =
        (data[_languageCardTermsKey] as List<dynamic>).cast<String>();

    _cachedCourses = {};
    _cachedCourseNotes = {};
    final coursesRaw = data['courses'] as Map<String, dynamic>;
    for (final entry in coursesRaw.entries) {
      final courseMap = entry.value as Map<String, dynamic>;
      final freeList = (courseMap['free'] as List<dynamic>).cast<String>();
      _cachedCourses![entry.key] = freeList;
      final note = PlanNote.fromJsonOrNull(
        courseMap,
        titleKey: _courseNoteTitleKey,
        textKey: _courseNoteTextKey,
      );
      if (note != null) {
        _cachedCourseNotes![entry.key] = note;
      }
    }
  }

  Future<LevelTier> getTier(String courseId, String levelId) async {
    await _load();
    final freeList = _cachedCourses![courseId];
    if (freeList == null) return LevelTier.premium;
    return freeList.contains(levelId) ? LevelTier.free : LevelTier.premium;
  }

  Future<List<String>> getPublicLanguages() async {
    await _load();
    return _cachedPublicLanguages!;
  }

  Future<List<LanguageEntry>> getLanguages() async {
    await _load();
    return _cachedLanguages!;
  }

  /// The ids of the terms whose words the card of a chosen language shows,
  /// in the order they are shown.
  Future<List<String>> getLanguageCardTermIds() async {
    await _load();
    return _cachedLanguageCardTermIds!;
  }

  Future<PlanNote?> getCourseNote(String courseId) async {
    await _load();
    return _cachedCourseNotes![courseId];
  }

  Future<Map<String, LevelTier>> getTiers(
    String courseId,
    List<String> levelIds,
  ) async {
    await _load();
    final freeList = _cachedCourses![courseId] ?? const [];
    return {
      for (final id in levelIds)
        id: freeList.contains(id) ? LevelTier.free : LevelTier.premium,
    };
  }
}

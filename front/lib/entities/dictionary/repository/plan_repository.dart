import 'dart:convert';

import 'package:flutter/services.dart';

import '../model/language_entry.dart';
import '../model/level_tier.dart';

class PlanRepository {
  static const String _planPath = 'assets/data/plan.json';

  Map<String, List<String>>? _cachedCourses;
  Map<String, String>? _cachedCourseNotes;
  List<String>? _cachedPublicLanguages;
  List<LanguageEntry>? _cachedLanguages;
  Set<String>? _cachedUiLanguages;

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
            nativeNote: map['nativeNote'] as String?,
          );
        })
        .toList();

    _cachedPublicLanguages =
        (data['public_languages'] as List<dynamic>).cast<String>();

    _cachedUiLanguages =
        (data['ui_languages'] as List<dynamic>).cast<String>().toSet();

    _cachedCourses = {};
    _cachedCourseNotes = {};
    final coursesRaw = data['courses'] as Map<String, dynamic>;
    for (final entry in coursesRaw.entries) {
      final courseMap = entry.value as Map<String, dynamic>;
      final freeList = (courseMap['free'] as List<dynamic>).cast<String>();
      _cachedCourses![entry.key] = freeList;
      final note = courseMap['note'] as String?;
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

  Future<Set<String>> getUiLanguages() async {
    await _load();
    return _cachedUiLanguages!;
  }

  Future<String?> getCourseNote(String courseId) async {
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

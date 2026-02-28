import 'dart:convert';

import 'package:flutter/services.dart';

import '../../entities/plan/language_entry.dart';
import '../../entities/plan/level_tier.dart';

/// Loads the content access plan from assets and resolves per-level tiers.
///
/// The plan file declares all languages, public/UI subsets, and course tiers.
/// Any level not listed in a course's free list is [LevelTier.premium] by default.
class PlanRepository {
  static const String _planPath = 'assets/data/plan.json';

  Map<String, List<String>>? _cachedCourses;
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
          );
        })
        .toList();

    _cachedPublicLanguages =
        (data['public_languages'] as List<dynamic>).cast<String>();

    _cachedUiLanguages =
        (data['ui_languages'] as List<dynamic>).cast<String>().toSet();

    _cachedCourses = {};
    final coursesRaw = data['courses'] as Map<String, dynamic>;
    for (final entry in coursesRaw.entries) {
      final freeList =
          ((entry.value as Map<String, dynamic>)['free'] as List<dynamic>)
              .cast<String>();
      _cachedCourses![entry.key] = freeList;
    }
  }

  /// Returns the tier for [levelId] within [courseId].
  Future<LevelTier> getTier(String courseId, String levelId) async {
    await _load();
    final freeList = _cachedCourses![courseId];
    if (freeList == null) return LevelTier.premium;
    return freeList.contains(levelId) ? LevelTier.free : LevelTier.premium;
  }

  /// Returns the list of public language codes from the plan.
  Future<List<String>> getPublicLanguages() async {
    await _load();
    return _cachedPublicLanguages!;
  }

  /// Returns all declared languages with their label keys.
  Future<List<LanguageEntry>> getLanguages() async {
    await _load();
    return _cachedLanguages!;
  }

  /// Returns the set of language codes valid for the app UI.
  Future<Set<String>> getUiLanguages() async {
    await _load();
    return _cachedUiLanguages!;
  }

  /// Resolves tiers for all given [levelIds] in one call.
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

import 'dart:convert';

import 'package:flutter/services.dart';

import '../../entities/plan/level_tier.dart';

/// Loads the content access plan from assets and resolves per-level tiers.
///
/// The plan file lists only free level IDs per course. Any level not listed
/// is [LevelTier.premium] by default. Courses not present in the file are
/// fully premium.
class PlanRepository {
  static const String _planPath = 'assets/data/plan.json';

  /// courseId → list of free level IDs.
  Map<String, List<String>>? _cached;

  Future<void> _load() async {
    if (_cached != null) return;
    final json = await rootBundle.loadString(_planPath);
    final data = jsonDecode(json) as Map<String, dynamic>;
    _cached = data.map((courseId, value) {
      final freeList =
          ((value as Map<String, dynamic>)['free'] as List<dynamic>)
              .cast<String>();
      return MapEntry(courseId, freeList);
    });
  }

  /// Returns the tier for [levelId] within [courseId].
  ///
  /// Defaults to [LevelTier.premium] if the course or level is not listed.
  Future<LevelTier> getTier(String courseId, String levelId) async {
    await _load();
    final freeList = _cached![courseId];
    if (freeList == null) return LevelTier.premium;
    return freeList.contains(levelId) ? LevelTier.free : LevelTier.premium;
  }

  /// Resolves tiers for all given [levelIds] in one call.
  Future<Map<String, LevelTier>> getTiers(
    String courseId,
    List<String> levelIds,
  ) async {
    await _load();
    final freeList = _cached![courseId] ?? const [];
    return {
      for (final id in levelIds)
        id: freeList.contains(id) ? LevelTier.free : LevelTier.premium,
    };
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../entities/level/level.dart';
import 'dictionary_provider.dart';
import 'group_progress_provider.dart';

/// Progress for a single level (0.0–100.0), averaged from its groups.
///
/// Groups with no progress contribute 0.0. Returns 0.0 if the level
/// is not found or has no groups.
final levelProgressProvider = Provider.family<double, String>((ref, levelId) {
  final dictionary = ref.watch(dictionaryProvider).valueOrNull;
  if (dictionary == null) return 0.0;

  Level? level;
  for (final l in dictionary.levels) {
    if (l.id == levelId) {
      level = l;
      break;
    }
  }
  if (level == null || level.groupIds.isEmpty) return 0.0;

  final allProgress = ref.watch(groupProgressProvider);
  final total = level.groupIds.fold(
    0.0,
    (sum, gid) => sum + (allProgress[gid]?.totalProgress ?? 0.0),
  );
  return total / level.groupIds.length;
});

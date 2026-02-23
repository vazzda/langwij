import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/repositories/group_progress_repository.dart';
import '../../shared/repositories/models/group_progress.dart';
import '../../features/quiz/quiz_mode.dart';

/// Provider for the group progress repository. Must be overridden in main.dart.
final groupProgressRepositoryProvider = Provider<GroupProgressRepository>((ref) {
  throw UnimplementedError('groupProgressRepositoryProvider must be overridden');
});

/// Notifier that holds all group progress and can update them.
class GroupProgressNotifier extends StateNotifier<Map<String, GroupProgress>> {
  GroupProgressNotifier(this._repository) : super({}) {
    _load();
  }

  final GroupProgressRepository _repository;

  Future<void> _load() async {
    state = await _repository.getAllProgress();
  }

  /// Record a session result and update state.
  Future<void> recordSession({
    required String groupId,
    required double score,
    required QuizMode mode,
  }) async {
    await _repository.recordSession(
      groupId: groupId,
      score: score,
      mode: mode,
    );
    state = await _repository.getAllProgress();
  }

  /// Update peak retention for a group.
  Future<void> updatePeakRetention(String groupId, double retention) async {
    await _repository.updatePeakRetention(groupId, retention);
    state = await _repository.getAllProgress();
  }

  /// Get progress for a specific group from current state.
  GroupProgress getProgress(String groupId) {
    return state[groupId] ?? GroupProgress(groupId: groupId);
  }

  /// Reload from storage.
  Future<void> reload() async {
    await _load();
  }
}

/// Provider for all group progress (groupId → GroupProgress).
final groupProgressProvider =
    StateNotifierProvider<GroupProgressNotifier, Map<String, GroupProgress>>(
  (ref) => GroupProgressNotifier(ref.watch(groupProgressRepositoryProvider)),
);

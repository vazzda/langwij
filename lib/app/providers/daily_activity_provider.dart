import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/repositories/daily_activity_repository.dart';

/// Must be overridden in main.dart with a Database-backed instance.
final dailyActivityRepositoryProvider = Provider<DailyActivityRepository>((ref) {
  throw UnimplementedError('dailyActivityRepositoryProvider must be overridden');
});

/// Today's stats (correct, wrong, distinct words touched). Loaded from storage on first use; updated directly when a session is persisted.
class DailyActivityNotifier extends StateNotifier<AsyncValue<DailyActivityStats>> {
  DailyActivityNotifier(this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    if (!state.hasValue) state = const AsyncValue.loading();
    try {
      final repo = _ref.read(dailyActivityRepositoryProvider);
      final stats = await repo.readToday();
      state = AsyncValue.data(stats);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Set stats directly after persisting a session (avoids read-after-write timing).
  void setStats(DailyActivityStats stats) {
    state = AsyncValue.data(stats);
  }

  /// Reload from storage (e.g. when home screen is shown).
  Future<void> load() async {
    await _load();
  }
}

final dailyActivityProvider =
    StateNotifierProvider<DailyActivityNotifier, AsyncValue<DailyActivityStats>>(
  (ref) => DailyActivityNotifier(ref),
);

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/repositories/test_result_repository.dart';

/// Must be overridden in main.dart with a Database-backed instance.
final testResultRepositoryProvider = Provider<TestResultRepository>((ref) {
  throw UnimplementedError('testResultRepositoryProvider must be overridden');
});

/// Notifier that holds all test results and can update them.
class TestResultsNotifier extends StateNotifier<Map<String, TestResult>> {
  TestResultsNotifier(this._repository) : super({}) {
    _load();
  }

  final TestResultRepository _repository;

  Future<void> _load() async {
    state = await _repository.getAllResults();
  }

  /// Save a test result and update state.
  Future<void> saveResult(String groupId, int percentage) async {
    await _repository.saveResult(groupId, percentage);
    state = await _repository.getAllResults();
  }

  /// Reload from storage.
  Future<void> reload() async {
    await _load();
  }
}

/// Provider for all test results (groupId → TestResult).
final testResultsProvider =
    StateNotifierProvider<TestResultsNotifier, Map<String, TestResult>>(
  (ref) => TestResultsNotifier(ref.watch(testResultRepositoryProvider)),
);

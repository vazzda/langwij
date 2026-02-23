import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/repositories/app_settings_repository.dart';
import '../../shared/repositories/models/app_settings.dart';
import '../../shared/repositories/models/decay_formula.dart';

/// Provider for the app settings repository. Must be overridden in main.dart.
final appSettingsRepositoryProvider = Provider<AppSettingsRepository>((ref) {
  throw UnimplementedError('appSettingsRepositoryProvider must be overridden');
});

/// Notifier that holds app settings and can update them.
class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier(this._repository) : super(const AppSettings()) {
    _load();
  }

  final AppSettingsRepository _repository;

  Future<void> _load() async {
    state = await _repository.getSettings();
  }

  /// Update the decay formula.
  Future<void> setDecayFormula(DecayFormula formula) async {
    await _repository.setDecayFormula(formula);
    state = await _repository.getSettings();
  }

  /// Reload from storage.
  Future<void> reload() async {
    await _load();
  }
}

/// Provider for app settings.
final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>(
  (ref) => AppSettingsNotifier(ref.watch(appSettingsRepositoryProvider)),
);

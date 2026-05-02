import 'dart:ui';

import 'package:flessel/flessel.dart' show FlesselDevGate;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:langwij/shared/lib/constants.dart';

/// Riverpod bridge for [FlesselDevGate.enabled].
///
/// Derives from [FlesselDevGate.enabled] (single source of truth).
/// Consumers use `ref.watch(devSectionEnabledProvider)` for reactive
/// `bool` access without `AsyncValue` wrapping.
final devSectionEnabledProvider =
    NotifierProvider<DevSectionNotifier, bool>(DevSectionNotifier.new);

class DevSectionNotifier extends Notifier<bool> {
  VoidCallback? _listener;

  @override
  bool build() {
    _listener = () {
      state = FlesselDevGate.enabled.value;
    };
    FlesselDevGate.enabled.addListener(_listener!);
    ref.onDispose(() {
      if (_listener != null) {
        FlesselDevGate.enabled.removeListener(_listener!);
      }
    });
    return FlesselDevGate.enabled.value;
  }
}

/// Load dev section enabled state from SharedPreferences.
Future<bool> loadDevSectionEnabled() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(AppConstants.keyDevSectionEnabled) ?? false;
}

/// Save dev section enabled state to SharedPreferences.
Future<void> saveDevSectionEnabled(bool enabled) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(AppConstants.keyDevSectionEnabled, enabled);
}

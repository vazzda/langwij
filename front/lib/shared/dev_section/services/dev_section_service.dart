import 'dart:ui';

import 'package:flessel/flessel.dart' show FlesselDevGate;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyDevSectionEnabled = 'dev_section_enabled';

class DevSectionService {
  static final enabled =
      NotifierProvider<DevSectionNotifier, bool>(DevSectionNotifier.new);

  static Future<bool> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDevSectionEnabled) ?? false;
  }

  static Future<void> save(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDevSectionEnabled, value);
  }
}

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

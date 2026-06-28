import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dev_section_gate_notifier_service.dart';

const _keyDevSectionEnabled = 'dev_section_enabled';

class DevSectionService {
  static final enabled =
      NotifierProvider<DevSectionGateNotifierService, bool>(
    DevSectionGateNotifierService.new,
  );

  static Future<bool> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDevSectionEnabled) ?? false;
  }

  static Future<void> save(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDevSectionEnabled, value);
  }
}

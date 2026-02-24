import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:srpski_card/shared/lib/constants.dart';

/// Developer section enabled state provider.
final devSectionEnabledProvider = StateProvider<bool>((ref) {
  return false;
});

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

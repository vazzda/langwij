import 'package:flessel/flessel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefKey = 'app_theme';

final themeProvider = StateProvider<String>((ref) {
  return FlesselThemeCatalog.defaultId;
});

Future<String> loadAppTheme() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_prefKey) ?? FlesselThemeCatalog.defaultId;
}

Future<void> saveAppTheme(String themeId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_prefKey, themeId);
}

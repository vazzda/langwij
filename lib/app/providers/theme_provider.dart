import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_themes.dart';

const _key = 'app_theme';

/// Current app theme. Default: candidate05.
final themeProvider = StateProvider<AppTheme>((ref) => AppTheme.candidate05);

/// Load saved theme from SharedPreferences.
Future<AppTheme> loadAppTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final value = prefs.getString(_key);
  if (value == null) return AppTheme.candidate05;
  return AppThemeExtension.fromString(value);
}

/// Save theme to SharedPreferences.
Future<void> saveAppTheme(AppTheme theme) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_key, theme.name);
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';

const _prefKey = 'app_theme';

/// App theme selector. Persisted to SharedPreferences via [_prefKey].
/// Maps 1:1 to flessel theme catalog ids via [AppThemeExtension.flesselId].
enum AppTheme {
  theme01,
  theme02,
  theme03,
  theme04,
  theme05,
}

extension AppThemeExtension on AppTheme {
  /// flessel catalog id for this theme.
  String get flesselId {
    switch (this) {
      case AppTheme.theme01:
        return 'theme_01';
      case AppTheme.theme02:
        return 'theme_02';
      case AppTheme.theme03:
        return 'theme_03';
      case AppTheme.theme04:
        return 'theme_04';
      case AppTheme.theme05:
        return 'theme_05';
    }
  }

  String getDisplayName(AppLocalizations l10n) {
    switch (this) {
      case AppTheme.theme01:
        return l10n.theme_01;
      case AppTheme.theme02:
        return l10n.theme_02;
      case AppTheme.theme03:
        return l10n.theme_03;
      case AppTheme.theme04:
        return l10n.theme_04;
      case AppTheme.theme05:
        return l10n.theme_05;
    }
  }

  static AppTheme fromString(String value) {
    switch (value) {
      case 'theme01':
        return AppTheme.theme01;
      case 'theme02':
        return AppTheme.theme02;
      case 'theme03':
        return AppTheme.theme03;
      case 'theme04':
        return AppTheme.theme04;
      case 'theme05':
        return AppTheme.theme05;
      default:
        return AppTheme.theme01;
    }
  }
}

/// Theme selection provider.
final themeProvider = StateProvider<AppTheme>((ref) {
  return AppTheme.theme01;
});

/// Load theme from SharedPreferences.
Future<AppTheme> loadAppTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final value = prefs.getString(_prefKey);
  if (value != null) {
    return AppThemeExtension.fromString(value);
  }
  return AppTheme.theme01;
}

/// Save theme to SharedPreferences.
Future<void> saveAppTheme(AppTheme theme) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_prefKey, theme.name);
}

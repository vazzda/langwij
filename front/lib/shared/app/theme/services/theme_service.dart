import 'package:flessel/flessel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefKey = 'app_theme';

class ThemeService {
  ThemeService(this._ref);
  final Ref _ref;

  static final instance = Provider((ref) => ThemeService(ref));

  static final themeId = StateProvider<String>((ref) {
    return FlesselThemeCatalog.defaultId;
  });

  static Future<String> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKey) ?? FlesselThemeCatalog.defaultId;
  }

  Future<void> setTheme(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, id);
    _ref.read(ThemeService.themeId.notifier).state = id;
  }
}

import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/shared/app/database/database.dart';
import 'package:langwij/shared/app/config/repository/language_settings_repository.dart';
import 'package:langwij/shared/app/validators/validators.dart';
import 'package:langwij/shared/app/theme/services/theme_service.dart';
import 'package:langwij/shared/dev_section/services/dev_section_service.dart';

class AppInitialization {
  const AppInitialization._();

  static late final String savedThemeId;

  static Future<void> run() async {
    WidgetsFlutterBinding.ensureInitialized();

    final db = await DatabaseService.openEagerly();

    final langSettings = await LanguageSettingsRepository(db: db).load();

    await StartupValidator.validate(
      targetLang: langSettings.targetLang,
      nativeLang: langSettings.nativeLang,
    );

    FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);

    savedThemeId = await ThemeService.load();
    await FlesselDevGate.init(
      load: DevSectionService.load,
      save: DevSectionService.save,
    );
  }

  static void removeSplash() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }
}

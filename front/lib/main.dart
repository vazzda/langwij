import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flessel/flessel.dart';

import 'shared/validators/startup_validator.dart';
import 'shared/repositories/daily_activity_repository.dart';
import 'shared/repositories/deck_progress_repository.dart';
import 'shared/repositories/language_settings_repository.dart';
import 'shared/repositories/language_stats_repository.dart';
import 'shared/repositories/app_settings_repository.dart';
import 'l10n/app_localizations.dart';
import 'app/providers/database_provider.dart';
import 'app/providers/daily_activity_provider.dart';
import 'app/providers/deck_progress_provider.dart';
import 'app/providers/language_settings_provider.dart';
import 'app/providers/language_stats_provider.dart';
import 'app/providers/app_settings_provider.dart';
import 'app/providers/dev_section_provider.dart';
import 'app/providers/theme_provider.dart';
import 'app/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // DB first - sqflite uses file system, not rootBundle platform channels.
  final db = await DatabaseProvider.database;

  // Read language settings to know which translations to validate.
  final langSettings = await LanguageSettingsRepository(db: db).load();

  // Validate core configs + active translations only (5 rootBundle calls).
  await StartupValidator.validate(
    targetLang: langSettings.targetLang,
    nativeLang: langSettings.nativeLang,
  );

  FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);

  final savedTheme = await loadAppTheme();
  await FlesselDevGate.init(
    load: loadDevSectionEnabled,
    save: saveDevSectionEnabled,
  );
  final router = createAppRouter();

  runApp(
    ProviderScope(
      overrides: [
        dailyActivityRepositoryProvider.overrideWith(
          (ref) => DailyActivityRepository(db: db),
        ),
        deckProgressRepositoryProvider.overrideWith(
          (ref) => DeckProgressRepository(db: db),
        ),
        languageSettingsRepositoryProvider.overrideWith(
          (ref) => LanguageSettingsRepository(db: db),
        ),
        languageStatsRepositoryProvider.overrideWith(
          (ref) => LanguageStatsRepository(db: db),
        ),
        appSettingsRepositoryProvider.overrideWith(
          (ref) => AppSettingsRepository(db: db),
        ),
        themeProvider.overrideWith((ref) => savedTheme),
      ],
      child: LangwijApp(router: router),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
  });
}

class LangwijApp extends ConsumerWidget {
  const LangwijApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final flesselData = FlesselThemeCatalog.byId(theme.flesselId).data;
    final themeData = FlesselThemes.buildFlutterTheme(flesselData);
    return MaterialApp.router(
      title: 'Langwij',
      theme: themeData,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

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
import 'app/theme/vessel_themes.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();
  debugPrint('[BOOT] ${sw.elapsedMilliseconds}ms — ensureInitialized');
  WidgetsFlutterBinding.ensureInitialized();

  // DB first — sqflite uses file system, not rootBundle platform channels.
  debugPrint('[BOOT] ${sw.elapsedMilliseconds}ms — DB START');
  final db = await DatabaseProvider.database;
  debugPrint('[BOOT] ${sw.elapsedMilliseconds}ms — DB DONE');

  // Read language settings to know which translations to validate.
  debugPrint('[BOOT] ${sw.elapsedMilliseconds}ms — lang settings START');
  final langSettings = await LanguageSettingsRepository(db: db).load();
  debugPrint('[BOOT] ${sw.elapsedMilliseconds}ms — lang settings DONE '
      '(target=${langSettings.targetLang}, native=${langSettings.nativeLang})');

  // Validate core configs + active translations only (5 rootBundle calls).
  debugPrint('[BOOT] ${sw.elapsedMilliseconds}ms — validate START');
  await StartupValidator.validate(
    targetLang: langSettings.targetLang,
    nativeLang: langSettings.nativeLang,
  );
  debugPrint('[BOOT] ${sw.elapsedMilliseconds}ms — validate DONE');

  debugPrint('[BOOT] ${sw.elapsedMilliseconds}ms — preserve START');
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);
  debugPrint('[BOOT] ${sw.elapsedMilliseconds}ms — preserve DONE');

  debugPrint('[BOOT] ${sw.elapsedMilliseconds}ms — theme START');
  final savedTheme = await loadAppTheme();
  debugPrint('[BOOT] ${sw.elapsedMilliseconds}ms — theme DONE');

  debugPrint('[BOOT] ${sw.elapsedMilliseconds}ms — devSection START');
  final savedDevSection = await loadDevSectionEnabled();
  debugPrint('[BOOT] ${sw.elapsedMilliseconds}ms — devSection DONE');

  final router = createAppRouter();

  debugPrint('[BOOT] ${sw.elapsedMilliseconds}ms — runApp');
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
        devSectionEnabledProvider.overrideWith((ref) => savedDevSection),
      ],
      child: SrpskiCardApp(router: router),
    ),
  );

  debugPrint('[BOOT] ${sw.elapsedMilliseconds}ms — postFrameCallback registered');
  WidgetsBinding.instance.addPostFrameCallback((_) {
    debugPrint('[BOOT] ${sw.elapsedMilliseconds}ms — splash remove');
    FlutterNativeSplash.remove();
  });
}

class SrpskiCardApp extends ConsumerWidget {
  const SrpskiCardApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return MaterialApp.router(
      title: 'Srpski Card',
      theme: VesselThemes.getFlutterThemeData(theme),
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

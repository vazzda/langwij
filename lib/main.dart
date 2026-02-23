import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'shared/repositories/daily_activity_repository.dart';
import 'shared/repositories/group_progress_repository.dart';
import 'shared/repositories/app_settings_repository.dart';
import 'l10n/app_localizations.dart';
import 'app/providers/database_provider.dart';
import 'app/providers/daily_activity_provider.dart';
import 'app/providers/group_progress_provider.dart';
import 'app/providers/app_settings_provider.dart';
import 'app/providers/theme_provider.dart';
import 'app/router/app_router.dart';
import 'app/theme/app_themes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);
  final db = await DatabaseProvider.database;
  final savedTheme = await loadAppTheme();
  final router = createAppRouter();
  runApp(
    ProviderScope(
      overrides: [
        dailyActivityRepositoryProvider.overrideWith(
          (ref) => DailyActivityRepository(db: db),
        ),
        groupProgressRepositoryProvider.overrideWith(
          (ref) => GroupProgressRepository(db: db),
        ),
        appSettingsRepositoryProvider.overrideWith(
          (ref) => AppSettingsRepository(db: db),
        ),
        themeProvider.overrideWith((ref) => savedTheme),
      ],
      child: SrpskiCardApp(router: router),
    ),
  );
  WidgetsBinding.instance.addPostFrameCallback((_) {
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
      theme: AppThemes.getFlutterThemeData(theme),
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

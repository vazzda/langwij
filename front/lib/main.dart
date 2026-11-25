import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/shared/app/config/config.dart';
import 'package:langwij/boot/initialization.dart';
import 'package:langwij/boot/router.dart';

Future<void> main() async {
  await AppInitialization.run();

  final router = createAppRouter(
    isLanguageConfigured: AppInitialization.isLanguageConfigured,
  );

  runApp(
    ProviderScope(
      overrides: [
        ConfigService.languageSettingsLoadedAtStartup.overrideWithValue(
          AppInitialization.savedLanguageSettings,
        ),
      ],
      child: LangwijApp(router: router),
    ),
  );

  AppInitialization.removeSplash();
}

class LangwijApp extends ConsumerWidget {
  const LangwijApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = FlesselThemes.buildFlutterTheme(themeLangwij);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: themeData,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      locale: ref.watch(ConfigService.interfaceLocale),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: ConfigService.supportedInterfaceLocales,
    );
  }
}

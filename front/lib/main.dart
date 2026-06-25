import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/shared/app/theme/theme.dart';
import 'package:langwij/boot/initialization.dart';
import 'package:langwij/boot/router.dart';

Future<void> main() async {
  await AppInitialization.run();

  final router = createAppRouter();

  runApp(
    ProviderScope(
      overrides: [
        ThemeService.themeId.overrideWith(
          (ref) => AppInitialization.savedThemeId,
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
    final theme = ref.watch(ThemeService.themeId);
    final flesselData = FlesselThemeCatalog.byId(theme).data;
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

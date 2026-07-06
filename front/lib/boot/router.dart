import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/shared/app/routing/routing.dart';
import 'package:langwij/pages/language/language/ui/language_page.dart';
import 'package:langwij/pages/language/picker/ui/lang_picker_page.dart';
import 'package:langwij/pages/progress/ui/progress_page.dart';
import 'package:langwij/pages/quiz/result/ui/result_page.dart';
import 'package:langwij/pages/quiz/round/ui/round_page.dart';
import 'package:langwij/pages/settings/ui/settings_page.dart';
import 'package:langwij/pages/tools/home/ui/tools_page.dart';
import 'package:langwij/pages/specialized/ui/specialized_vocab_page.dart';
import 'package:langwij/pages/vocab/ui/vocab_deck_list_page.dart';

Page<void> _noTransitionPage(Widget child, GoRouterState state) {
  return NoTransitionPage<void>(
    key: state.pageKey,
    child: child,
  );
}

Page<void> _slidePage(BuildContext context, Widget child, GoRouterState state) {
  final scaffoldBg = FlesselThemes.of(context).scaffoldBackground;
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: Container(
      color: scaffoldBg.colorValue,
      child: child,
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      final slideTween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: Curves.easeInOut),
      );
      final fadeTween = Tween(begin: 0.5, end: 1.0).chain(
        CurveTween(curve: Curves.easeIn),
      );
      return SlideTransition(
        position: animation.drive(slideTween),
        child: FadeTransition(
          opacity: animation.drive(fadeTween),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 150),
    reverseTransitionDuration: const Duration(milliseconds: 150),
  );
}

GoRouter createAppRouter({required bool isLanguageConfigured}) {
  return GoRouter(
    initialLocation: isLanguageConfigured ? AppRoutes.home : AppRoutes.language,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => _noTransitionPage(
          const VocabDeckListPage(),
          state,
        ),
      ),
      GoRoute(
        path: AppRoutes.language,
        pageBuilder: (context, state) => _noTransitionPage(
          const LanguagePage(),
          state,
        ),
      ),
      GoRoute(
        path: AppRoutes.progress,
        pageBuilder: (context, state) => _noTransitionPage(
          const ProgressPage(),
          state,
        ),
      ),
      GoRoute(
        path: AppRoutes.tools,
        pageBuilder: (context, state) => _noTransitionPage(
          const ToolsPage(),
          state,
        ),
      ),
      GoRoute(
        path: AppRoutes.specialized,
        pageBuilder: (context, state) => _noTransitionPage(
          const SpecializedVocabPage(),
          state,
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (context, state) => _noTransitionPage(
          const SettingsPage(),
          state,
        ),
      ),
GoRoute(
        path: AppRoutes.langPicker,
        pageBuilder: (context, state) => _slidePage(
          context,
          LangPickerPage(mode: state.extra as LangPickerMode),
          state,
        ),
      ),
      GoRoute(
        path: AppRoutes.round,
        pageBuilder: (context, state) => _slidePage(
          context,
          const RoundPage(),
          state,
        ),
      ),
      GoRoute(
        path: AppRoutes.result,
        pageBuilder: (context, state) => _slidePage(
          context,
          const ResultPage(),
          state,
        ),
      ),
    ],
    errorBuilder: (context, state) {
      final l10n = AppLocalizations.of(context);
      final message = state.error != null ? '${state.error}' : (l10n?.pageNotFound ?? '');
      return Scaffold(
        body: Center(
          child: Text(message),
        ),
      );
    },
  );
}

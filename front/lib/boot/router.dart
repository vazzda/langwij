import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/shared/app/routing/routing.dart';
import 'package:langwij/pages/vocab/vocab.dart';
import 'package:langwij/pages/quiz/quiz.dart';
import 'package:langwij/pages/language/language.dart';
import 'package:langwij/pages/progress/progress.dart';
import 'package:langwij/pages/tools/tools.dart';
import 'package:langwij/pages/settings/settings.dart';

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

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
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
        path: AppRoutes.settings,
        pageBuilder: (context, state) => _noTransitionPage(
          const SettingsPage(),
          state,
        ),
      ),
      GoRoute(
        path: AppRoutes.conjugations,
        pageBuilder: (context, state) => _noTransitionPage(
          const ConjugationsPage(parent: ParentCategory.conjugations),
          state,
        ),
      ),
      GoRoute(
        path: AppRoutes.agreement,
        pageBuilder: (context, state) => _noTransitionPage(
          const AgreementPage(),
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

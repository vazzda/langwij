import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../pages/agreement_group_list_screen.dart';
import '../../pages/group_list_screen.dart';
import '../../pages/result_screen.dart';
import '../../pages/session_screen.dart';
import '../../pages/settings_screen.dart';
import '../../pages/under_development_screen.dart';

/// Route names/paths.
class AppRoutes {
  static const String home = '/';
  static const String vocabulary = '/vocabulary';
  static const String conjugations = '/conjugations';
  static const String agreement = '/agreement';
  static const String session = '/session';
  static const String result = '/result';
  static const String settings = '/settings';
  static const String language = '/language';
  static const String tools = '/tools';
}

/// No-transition page for tab routes (navbar screens).
Page<void> _noTransitionPage(Widget child, GoRouterState state) {
  return NoTransitionPage<void>(
    key: state.pageKey,
    child: child,
  );
}

/// Slide page for session/result routes.
Page<void> _slidePage(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
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

/// GoRouter config.
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      // Tab routes — no transition
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => _noTransitionPage(
          const GroupListScreen(),
          state,
        ),
      ),
      GoRoute(
        path: AppRoutes.vocabulary,
        pageBuilder: (context, state) => _noTransitionPage(
          const ChildGroupListScreen(parent: ParentCategory.vocabulary),
          state,
        ),
      ),
      GoRoute(
        path: AppRoutes.conjugations,
        pageBuilder: (context, state) => _noTransitionPage(
          const ChildGroupListScreen(parent: ParentCategory.conjugations),
          state,
        ),
      ),
      GoRoute(
        path: AppRoutes.agreement,
        pageBuilder: (context, state) => _noTransitionPage(
          const AgreementGroupListScreen(),
          state,
        ),
      ),
      GoRoute(
        path: AppRoutes.language,
        pageBuilder: (context, state) => _noTransitionPage(
          const UnderDevelopmentScreen(titleKey: 'language'),
          state,
        ),
      ),
      GoRoute(
        path: AppRoutes.tools,
        pageBuilder: (context, state) => _noTransitionPage(
          const UnderDevelopmentScreen(titleKey: 'tools'),
          state,
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (context, state) => _noTransitionPage(
          const SettingsScreen(),
          state,
        ),
      ),
      // Session routes — slide transition
      GoRoute(
        path: AppRoutes.session,
        pageBuilder: (context, state) => _slidePage(
          const SessionScreen(),
          state,
        ),
      ),
      GoRoute(
        path: AppRoutes.result,
        pageBuilder: (context, state) => _slidePage(
          const ResultScreen(),
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

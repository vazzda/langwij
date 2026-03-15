import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../pages/agreement_group_list_screen.dart';
import '../../pages/controls_list_screen.dart';
import '../../pages/group_list_screen.dart';
import '../../pages/lang_picker_screen.dart';
import '../../pages/language_screen.dart';
import '../../pages/result_screen.dart';
import '../../pages/round_screen.dart';
import '../../pages/settings_screen.dart';
import '../../pages/tools_screen.dart';
import '../../pages/vocab_deck_list_screen.dart';
import '../theme/vessel_themes.dart';

/// Route names/paths.
class AppRoutes {
  static const String home = '/';
  static const String conjugations = '/conjugations';
  static const String agreement = '/agreement';
  static const String round = '/round';
  static const String result = '/result';
  static const String language = '/language';
  static const String tools = '/tools';
  static const String settings = '/settings';
  static const String devControls = '/dev-controls';
  static const String langPicker = '/lang-picker';
}

/// No-animation page for tab-level navigation.
Page<void> _noTransitionPage(Widget child, GoRouterState state) {
  return NoTransitionPage<void>(
    key: state.pageKey,
    child: child,
  );
}

/// Slide page for push-style navigation (round, result).
Page<void> _slidePage(BuildContext context, Widget child, GoRouterState state) {
  final scaffoldBg = VesselThemes.of(context).scaffoldBackground;
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: Container(
      color: scaffoldBg,
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

/// GoRouter config. Round and result read from Riverpod.
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      // Tab-level routes — no animation
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => _noTransitionPage(
          const VocabDeckListScreen(),
          state,
        ),
      ),
      GoRoute(
        path: AppRoutes.language,
        pageBuilder: (context, state) => _noTransitionPage(
          const LanguageScreen(),
          state,
        ),
      ),
      GoRoute(
        path: AppRoutes.tools,
        pageBuilder: (context, state) => _noTransitionPage(
          const ToolsScreen(),
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
      // Tool sub-routes — with back button
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
      // Developer routes
      GoRoute(
        path: AppRoutes.devControls,
        pageBuilder: (context, state) => _noTransitionPage(
          const ControlsListScreen(),
          state,
        ),
      ),
      // Push-style routes — slide animation
      GoRoute(
        path: AppRoutes.langPicker,
        pageBuilder: (context, state) => _slidePage(
          context,
          LangPickerScreen(mode: state.extra as LangPickerMode),
          state,
        ),
      ),
      GoRoute(
        path: AppRoutes.round,
        pageBuilder: (context, state) => _slidePage(
          context,
          const RoundScreen(),
          state,
        ),
      ),
      GoRoute(
        path: AppRoutes.result,
        pageBuilder: (context, state) => _slidePage(
          context,
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

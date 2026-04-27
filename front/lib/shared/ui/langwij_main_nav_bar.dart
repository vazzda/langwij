import 'package:flessel/flessel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:langwij/shared/lib/constants.dart';

import '../../app/router/app_router.dart';
import '../../l10n/app_localizations.dart';

/// Langwij's main navigation — items + current-index helpers for
/// [FlesselScaffold]. Maps the four peripheral tabs (Language, Progress,
/// Tools, Settings) to router paths, plus a center FAB for Vocabulary.
/// Absorbs the dev-access secret-tap mechanic on Settings.
class LangwijMainNavBar {
  const LangwijMainNavBar._();

  static List<FlesselNavBarItem> items(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      FlesselNavBarItem(
        icon: PhosphorIconsRegular.globe,
        activeIcon: PhosphorIconsFill.globe,
        tooltip: l10n.navLanguage,
        onTap: () => context.go(AppRoutes.language),
      ),
      FlesselNavBarItem(
        icon: PhosphorIconsRegular.chartLine,
        activeIcon: PhosphorIconsFill.chartLine,
        tooltip: l10n.navProgress,
        onTap: () => context.go(AppRoutes.progress),
      ),
      FlesselNavBarItem(
        icon: PhosphorIconsRegular.puzzlePiece,
        activeIcon: PhosphorIconsFill.puzzlePiece,
        tooltip: l10n.navTools,
        onTap: () => context.go(AppRoutes.tools),
      ),
      FlesselNavBarItem(
        icon: PhosphorIconsRegular.gearSix,
        activeIcon: PhosphorIconsFill.gearSix,
        tooltip: l10n.navSettings,
        onTap: () => context.go(AppRoutes.settings),
        devGate: FlesselDevGateConfig(
          password: AppConstants.devAccessPassword,
          title: l10n.dev_enterPassword,
          unlockLabel: l10n.dev_unlock,
          cancelLabel: l10n.cancel,
          errorMessage: l10n.dev_wrongPassword,
        ),
      ),
    ];
  }

  static Widget fab(BuildContext context) {
    final isActive = GoRouterState.of(context).uri.path == AppRoutes.home;
    return FlesselFab(
      onPressed: () => context.go(AppRoutes.home),
      accented: isActive,
      child: Icon(isActive ? PhosphorIconsFill.books : PhosphorIconsRegular.books),
    );
  }

  static int currentIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    if (path == AppRoutes.language) return 0;
    if (path == AppRoutes.progress) return 1;
    if (path == AppRoutes.tools ||
        path == AppRoutes.conjugations ||
        path == AppRoutes.agreement) {
      return 2;
    }
    if (path == AppRoutes.settings) return 3;
    return -1;
  }
}

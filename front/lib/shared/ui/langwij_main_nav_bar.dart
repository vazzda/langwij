import 'package:flessel/flessel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:langwij/shared/lib/constants.dart';

import '../../app/router/app_router.dart';
import '../../l10n/app_localizations.dart';

/// Langwij's main navigation — items + current-index helpers for
/// [FlesselScaffold]. Maps the four primary tabs (Language, Vocabulary,
/// Tools, Settings) to router paths. Dev gate on Settings is handled by
/// [FlesselDevGate] via the [devGate] property.
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
        icon: PhosphorIconsRegular.books,
        activeIcon: PhosphorIconsFill.books,
        tooltip: l10n.navVocabulary,
        onTap: () => context.go(AppRoutes.home),
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

  static int currentIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    if (path == AppRoutes.language) return 0;
    if (path == AppRoutes.home) return 1;
    if (path == AppRoutes.tools ||
        path == AppRoutes.conjugations ||
        path == AppRoutes.agreement) {
      return 2;
    }
    if (path == AppRoutes.settings) return 3;
    return -1;
  }
}

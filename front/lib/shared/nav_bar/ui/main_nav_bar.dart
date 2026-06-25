import 'package:flessel/flessel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/shared/app/routing/routing.dart';

const _devAccessPasswordHash =
    '875dec89dd3b2300db839f43cb4b8d2b6b316cf88262b6e5bbebaa66a73d6ed8';

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
          passwordHashes: [_devAccessPasswordHash],
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

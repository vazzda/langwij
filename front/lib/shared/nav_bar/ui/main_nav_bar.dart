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
        icon: PhosphorIconsRegular.books,
        activeIcon: PhosphorIconsFill.books,
        tooltip: l10n.navVocabulary,
        onTap: () => context.go(AppRoutes.home),
      ),
      FlesselNavBarItem(
        icon: PhosphorIconsRegular.graduationCap,
        activeIcon: PhosphorIconsFill.graduationCap,
        tooltip: l10n.navSpecialized,
        onTap: () => context.go(AppRoutes.specialized),
      ),
      FlesselNavBarItem(
        icon: PhosphorIconsRegular.puzzlePiece,
        activeIcon: PhosphorIconsFill.puzzlePiece,
        tooltip: l10n.navTools,
        onTap: () => context.go(AppRoutes.tools),
      ),
      FlesselNavBarItem(
        icon: PhosphorIconsRegular.globe,
        activeIcon: PhosphorIconsFill.globe,
        tooltip: l10n.navLanguage,
        onTap: () => context.go(AppRoutes.language),
      ),
    ];
  }

  static FlesselDevGateConfig settingsDevGateConfig(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FlesselDevGateConfig(
      passwordHashes: [_devAccessPasswordHash],
      title: l10n.dev_enterPassword,
      unlockLabel: l10n.dev_unlock,
      cancelLabel: l10n.cancel,
      errorMessage: l10n.dev_wrongPassword,
    );
  }

  static int currentIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    if (path == AppRoutes.home) return 0;
    if (path == AppRoutes.specialized) return 1;
    if (path == AppRoutes.tools ||
        path == AppRoutes.conjugations ||
        path == AppRoutes.agreement) {
      return 2;
    }
    if (path == AppRoutes.language) return 3;
    return -1;
  }
}

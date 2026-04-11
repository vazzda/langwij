import 'package:flessel/flessel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:langwij/shared/lib/constants.dart';

import '../../app/router/app_router.dart';
import '../../l10n/app_localizations.dart';

/// Langwij's main bottom navigation bar — composite over [FlesselNavBar].
/// Maps the four primary tabs (Language, Vocabulary, Tools, Settings) to
/// router paths and absorbs the dev-access secret-tap mechanic on Settings.
class LangwijMainNavBar extends StatelessWidget {
  const LangwijMainNavBar({super.key, this.onDevAccessTapsReached});

  final VoidCallback? onDevAccessTapsReached;

  int _currentIndexFor(String path) {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentPath = GoRouterState.of(context).uri.path;
    return FlesselNavBar(
      size: FlesselSize.s,
      currentIndex: _currentIndexFor(currentPath),
      items: [
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
          secretTapCount: AppConstants.devAccessTapCount,
          onSecretTapsReached: onDevAccessTapsReached,
        ),
      ],
    );
  }
}

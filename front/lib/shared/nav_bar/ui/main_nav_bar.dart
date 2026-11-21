import 'package:flessel/flessel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/shared/nav_bar/model/main_nav_destination.dart';

class LangwijMainNavBar {
  const LangwijMainNavBar._();

  static List<FlesselNavBarItem> items(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      for (final destination in MainNavDestination.values)
        FlesselNavBarItem(
          icon: _outlineIconForDestination(destination),
          activeIcon: _filledIconForDestination(destination),
          tooltip: _tooltipForDestination(destination, l10n),
          label: _captionForDestination(destination, l10n),
          onTap: () => context.go(destination.routePath),
        ),
    ];
  }

  /// Position of the destination shown by the current route, or -1 when the
  /// current route is not a bottom-bar destination.
  static int currentIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    return MainNavDestination.values.indexWhere(
      (destination) => destination.routePath == path,
    );
  }

  static IconData _outlineIconForDestination(MainNavDestination destination) {
    return switch (destination) {
      MainNavDestination.vocabulary => PhosphorIconsRegular.books,
      MainNavDestination.specialized => PhosphorIconsRegular.graduationCap,
      MainNavDestination.tools => PhosphorIconsRegular.puzzlePiece,
      MainNavDestination.language => PhosphorIconsRegular.globe,
    };
  }

  static IconData _filledIconForDestination(MainNavDestination destination) {
    return switch (destination) {
      MainNavDestination.vocabulary => PhosphorIconsFill.books,
      MainNavDestination.specialized => PhosphorIconsFill.graduationCap,
      MainNavDestination.tools => PhosphorIconsFill.puzzlePiece,
      MainNavDestination.language => PhosphorIconsFill.globe,
    };
  }

  static String _tooltipForDestination(
    MainNavDestination destination,
    AppLocalizations l10n,
  ) {
    return switch (destination) {
      MainNavDestination.vocabulary => l10n.navVocabulary,
      MainNavDestination.specialized => l10n.navSpecialized,
      MainNavDestination.tools => l10n.navTools,
      MainNavDestination.language => l10n.navLanguage,
    };
  }

  static String _captionForDestination(
    MainNavDestination destination,
    AppLocalizations l10n,
  ) {
    return switch (destination) {
      MainNavDestination.vocabulary => l10n.navLabelVocabulary,
      MainNavDestination.specialized => l10n.navLabelSpecialized,
      MainNavDestination.tools => l10n.navLabelTools,
      MainNavDestination.language => l10n.navLabelLanguage,
    };
  }
}

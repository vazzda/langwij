import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_themes.dart';
import 'navbar_icon_button.dart';

/// Flat bottom navigation bar with 4 tabs.
/// Active tab is detected from the current route.
class BottomNavBarWidget extends StatelessWidget {
  const BottomNavBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppThemes.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currentPath = GoRouterState.of(context).uri.path;

    final isLanguage = currentPath == AppRoutes.language;
    final isVocabulary = currentPath == AppRoutes.home ||
        currentPath == AppRoutes.vocabulary ||
        currentPath == AppRoutes.conjugations ||
        currentPath == AppRoutes.agreement;
    final isTools = currentPath == AppRoutes.tools;
    final isSettings = currentPath == AppRoutes.settings;

    return Container(
      decoration: BoxDecoration(
        color: t.navbarBackground,
        border: Border(
          top: BorderSide(
            color: t.navbarBorderColor,
            width: t.navbarBorderWidth,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NavBarIconButton(
                icon: Icons.language,
                tooltip: l10n.navLanguage,
                isEnabled: !isLanguage,
                enabledColor: t.navbarIconColor,
                disabledColor: t.navbarDisabledIconColor,
                onPressed: !isLanguage
                    ? () => context.go(AppRoutes.language)
                    : null,
              ),
              NavBarIconButton(
                icon: Icons.menu_book,
                tooltip: l10n.navVocabulary,
                isEnabled: !isVocabulary,
                enabledColor: t.navbarIconColor,
                disabledColor: t.navbarDisabledIconColor,
                onPressed: !isVocabulary
                    ? () => context.go(AppRoutes.home)
                    : null,
              ),
              NavBarIconButton(
                icon: Icons.build,
                tooltip: l10n.navTools,
                isEnabled: !isTools,
                enabledColor: t.navbarIconColor,
                disabledColor: t.navbarDisabledIconColor,
                onPressed: !isTools
                    ? () => context.go(AppRoutes.tools)
                    : null,
              ),
              NavBarIconButton(
                icon: Icons.settings,
                tooltip: l10n.navSettings,
                isEnabled: !isSettings,
                enabledColor: t.navbarIconColor,
                disabledColor: t.navbarDisabledIconColor,
                onPressed: !isSettings
                    ? () => context.go(AppRoutes.settings)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

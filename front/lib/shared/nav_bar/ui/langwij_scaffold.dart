import 'package:flessel/flessel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/shared/app/routing/routing.dart';
import 'package:langwij/shared/nav_bar/ui/main_nav_bar.dart';

class LangwijScaffold extends StatefulWidget {
  static const FlesselSize _navBarSize = FlesselSize.s;

  final Widget child;
  final String? title;
  final VoidCallback? onBackPressed;
  final bool uppercaseTitle;

  const LangwijScaffold({
    super.key,
    required this.child,
    this.title,
    this.onBackPressed,
    this.uppercaseTitle = true,
  });

  static double navbarSpacer(BuildContext context) =>
      FlesselLayout.navbarSpacer(context, size: _navBarSize);

  @override
  State<LangwijScaffold> createState() => _LangwijScaffoldState();
}

class _LangwijScaffoldState extends State<LangwijScaffold> {
  int _settingsDevTapCount = 0;

  void _handleSettingsDevTap() {
    _settingsDevTapCount++;
    if (_settingsDevTapCount >= FlesselDevGate.tapCount) {
      _settingsDevTapCount = 0;
      FlesselDevGate.show(
        context,
        LangwijMainNavBar.settingsDevGateConfig(context),
      );
    }
  }

  List<Widget> _buildAppBarActions() {
    final path = GoRouterState.of(context).uri.path;
    final t = FlesselThemes.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isOnProgress = path == AppRoutes.progress;
    final isOnSettings = path == AppRoutes.settings;

    return [
      FlesselNavBarIcon(
        icon: PhosphorIconsRegular.chartLine,
        activeIcon: PhosphorIconsFill.chartLine,
        tooltip: l10n.navProgress,
        isEnabled: !isOnProgress,
        enabledColor: t.appBarIconColor,
        disabledColor: t.appBarIconColor,
        navbarSize: LangwijScaffold._navBarSize,
        onPressed: () => context.go(AppRoutes.progress),
      ),
      FlesselNavBarIcon(
        icon: PhosphorIconsRegular.gearSix,
        activeIcon: PhosphorIconsFill.gearSix,
        tooltip: l10n.navSettings,
        isEnabled: !isOnSettings,
        enabledColor: t.appBarIconColor,
        disabledColor: t.appBarIconColor,
        navbarSize: LangwijScaffold._navBarSize,
        onPressed: () => context.go(AppRoutes.settings),
        onDisabledTap: _handleSettingsDevTap,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FlesselScaffold(
      title: widget.title,
      uppercaseTitle: widget.uppercaseTitle,
      onBackPressed: widget.onBackPressed,
      appBarActions: _buildAppBarActions(),
      navBarItems: LangwijMainNavBar.items(context),
      navBarCurrentIndex: LangwijMainNavBar.currentIndex(context),
      navBarSize: LangwijScaffold._navBarSize,
      child: widget.child,
    );
  }
}

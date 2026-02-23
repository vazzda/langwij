import 'package:flutter/material.dart';

import '../../../app/theme/app_themes.dart';
import '../bottom_navbar/bottom_navbar_widget.dart';

/// Screen scaffold with themed app bar. No direct colors.
class ScreenLayoutWidget extends StatelessWidget {
  const ScreenLayoutWidget({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.leading,
    this.showBottomNav = false,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBottomNav;

  @override
  Widget build(BuildContext context) {
    final t = AppThemes.of(context);
    return Scaffold(
      backgroundColor: t.scaffoldBackground,
      appBar: AppBar(
        leading: leading,
        title: Text(title.toUpperCase()),
        actions: actions,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(t.appBarBorderWidth),
          child: Container(
            height: t.appBarBorderWidth,
            color: t.appBarBorderColor,
          ),
        ),
      ),
      bottomNavigationBar: showBottomNav ? const BottomNavBarWidget() : null,
      body: SafeArea(child: child),
    );
  }
}

import 'package:flutter/material.dart';

/// Icon button for bottom navbar with explicit enabled/disabled states.
class NavBarIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isEnabled;
  final Color enabledColor;
  final Color disabledColor;
  final VoidCallback? onPressed;
  final VoidCallback? onDisabledTap;

  const NavBarIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.isEnabled,
    required this.enabledColor,
    required this.disabledColor,
    this.onPressed,
    this.onDisabledTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isEnabled ? enabledColor : disabledColor;
    final iconWidget = Icon(icon, size: 28, color: iconColor);

    if (isEnabled && onPressed != null) {
      return Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(24),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: iconWidget,
            ),
          ),
        ),
      );
    }

    if (onDisabledTap != null) {
      return GestureDetector(
        onTap: onDisabledTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: iconWidget,
        ),
      );
    }

    return AbsorbPointer(
      absorbing: true,
      child: Tooltip(
        message: tooltip,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: iconWidget,
        ),
      ),
    );
  }
}

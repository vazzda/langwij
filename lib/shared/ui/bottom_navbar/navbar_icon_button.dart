import 'package:flutter/material.dart';

/// A single icon button in the bottom navigation bar.
class NavBarIconButton extends StatelessWidget {
  const NavBarIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.isEnabled,
    required this.enabledColor,
    required this.disabledColor,
    this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final bool isEnabled;
  final Color enabledColor;
  final Color disabledColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: isEnabled ? enabledColor : disabledColor,
      ),
      tooltip: tooltip,
      onPressed: isEnabled ? null : onPressed,
    );
  }
}

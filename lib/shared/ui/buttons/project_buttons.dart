import 'package:flutter/material.dart';

import '../../../app/theme/app_themes.dart';

/// Primary action button. Filled accent style.
class AccentButton extends StatelessWidget {
  const AccentButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final t = AppThemes.of(context);
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: t.controlAccentBackground,
        foregroundColor: t.controlAccentForeground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.buttonBorderRadius),
          side: BorderSide(color: t.controlBorder, width: t.buttonBorderWidth),
        ),
        textStyle: AppFontStyles.textButton,
      ),
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon!,
                const SizedBox(width: 8),
                Text(label),
              ],
            )
          : Text(label),
    );
  }
}

/// Secondary outlined button. Border only, no fill.
class BaseButton extends StatelessWidget {
  const BaseButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = AppThemes.of(context);
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: t.controlForeground,
        side: BorderSide(color: t.controlBorder, width: t.controlBorderWidth),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.controlBorderRadius),
        ),
        textStyle: AppFontStyles.textButton,
      ),
      child: Text(label),
    );
  }
}

/// Text-only button for cancel/dismiss actions.
class ProjectTextButton extends StatelessWidget {
  const ProjectTextButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = AppThemes.of(context);
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: AppFontStyles.textButton.copyWith(color: t.textPrimary),
      ),
    );
  }
}

/// Text-only button for destructive actions. Danger color.
class DangerTextButton extends StatelessWidget {
  const DangerTextButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = AppThemes.of(context);
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: AppFontStyles.textButton.copyWith(color: t.dangerColor),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:srpski_card/app/theme/app_themes.dart';

/// Label position for labeled controls
enum LabelPosition { left, right }

CheckboxThemeData _checkboxTheme(BuildContext context) {
  final theme = AppThemes.of(context);
  return CheckboxThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(theme.toggleBorderRadius),
    ),
    side: BorderSide(color: theme.textPrimary, width: theme.controlBorderWidth),
    fillColor: WidgetStateProperty.all(theme.controlBackground),
    checkColor: WidgetStateProperty.all(theme.textPrimary),
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
  );
}

SwitchThemeData _switchTheme(BuildContext context) {
  final theme = AppThemes.of(context);
  return SwitchThemeData(
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    thumbColor: WidgetStateProperty.all(theme.controlForeground),
    trackColor: WidgetStateProperty.all(theme.controlBackground),
    trackOutlineColor: WidgetStateProperty.all(theme.controlForeground),
    trackOutlineWidth: WidgetStateProperty.all(theme.controlBorderWidth),
  );
}

// =============================================================================
// BASE CONTROLS (no label)
// =============================================================================

class ProjectCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;

  const ProjectCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(checkboxTheme: _checkboxTheme(context)),
      child: Checkbox(value: value, onChanged: onChanged),
    );
  }
}

class ProjectSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const ProjectSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(switchTheme: _switchTheme(context)),
      child: Switch(value: value, onChanged: onChanged),
    );
  }
}

// =============================================================================
// LABELED CONTROLS
// =============================================================================

class ProjectCheckboxLabeled extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String label;
  final String? subtitle;
  final LabelPosition labelPosition;
  final bool fullWidth;

  const ProjectCheckboxLabeled({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.subtitle,
    this.labelPosition = LabelPosition.right,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemes.of(context);
    final checkbox = ProjectCheckbox(value: value, onChanged: onChanged);

    final labelWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppFontStyles.textControlInput.copyWith(color: theme.controlForeground),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: AppFontStyles.textControlLabel.copyWith(color: theme.controlForeground),
          ),
      ],
    );

    final children = labelPosition == LabelPosition.left
        ? [
            fullWidth ? Expanded(child: labelWidget) : Flexible(child: labelWidget),
            const SizedBox(width: 8),
            checkbox,
          ]
        : [
            checkbox,
            const SizedBox(width: 8),
            fullWidth ? Expanded(child: labelWidget) : Flexible(child: labelWidget),
          ];

    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class ProjectSwitchLabeled extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String label;
  final LabelPosition labelPosition;
  final bool fullWidth;

  const ProjectSwitchLabeled({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.labelPosition = LabelPosition.left,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemes.of(context);
    final switchWidget = ProjectSwitch(value: value, onChanged: onChanged);

    final labelWidget = Text(
      label,
      style: AppFontStyles.textControlInput.copyWith(color: theme.controlForeground),
    );

    final children = labelPosition == LabelPosition.left
        ? [
            fullWidth ? Expanded(child: labelWidget) : Flexible(child: labelWidget),
            const SizedBox(width: 8),
            switchWidget,
          ]
        : [
            switchWidget,
            const SizedBox(width: 8),
            fullWidth ? Expanded(child: labelWidget) : Flexible(child: labelWidget),
          ];

    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: children,
      ),
    );
  }
}

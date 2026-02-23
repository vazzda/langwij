import 'package:flutter/material.dart';

import '../../../app/theme/app_themes.dart';

/// A radio tile matching backbone's ProjectRadioTile pattern.
class ProjectRadioTile<T> extends StatelessWidget {
  const ProjectRadioTile({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.label,
  });

  final T value;
  final T groupValue;
  final ValueChanged<T?>? onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = AppThemes.of(context);
    final isSelected = value == groupValue;

    return RadioListTile<T>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Text(
        label,
        style: isSelected
            ? AppFontStyles.textListItemAccented.copyWith(color: t.textPrimary)
            : AppFontStyles.textListItem.copyWith(color: t.textPrimary),
      ),
      activeColor: t.accentColor,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}

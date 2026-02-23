import 'package:flutter/material.dart';

import '../../../app/theme/app_themes.dart';

/// Single choice chip for mode/count selection. Theme only.
class AppChoiceChip extends StatelessWidget {
  const AppChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final t = AppThemes.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: t.chipSelectedBackground,
      labelStyle: TextStyle(
        color: selected ? t.chipSelectedForeground : t.textPrimary,
      ),
    );
  }
}

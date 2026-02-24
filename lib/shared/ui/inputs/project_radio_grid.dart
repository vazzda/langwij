import 'package:flutter/material.dart';
import 'package:srpski_card/app/theme/app_themes.dart';

/// A single option for ProjectRadioGrid
class ProjectRadioGridOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const ProjectRadioGridOption({
    required this.value,
    required this.label,
    this.icon,
  });
}

/// A grid-based radio selector with configurable columns
class ProjectRadioGrid<T> extends StatelessWidget {
  final List<ProjectRadioGridOption<T>> options;
  final T selectedValue;
  final ValueChanged<T>? onChanged;
  final int columns;
  final double spacing;
  final double runSpacing;

  const ProjectRadioGrid({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.columns = 2,
    this.spacing = 12,
    this.runSpacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemes.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSpacing = spacing * (columns - 1);
        final itemWidth = (constraints.maxWidth - totalSpacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: options.map((option) {
            final isSelected = option.value == selectedValue;
            return _RadioGridItem<T>(
              option: option,
              isSelected: isSelected,
              onTap: onChanged != null ? () => onChanged!(option.value) : null,
              width: itemWidth,
              theme: theme,
            );
          }).toList(),
        );
      },
    );
  }
}

class _RadioGridItem<T> extends StatelessWidget {
  final ProjectRadioGridOption<T> option;
  final bool isSelected;
  final VoidCallback? onTap;
  final double width;
  final AppThemeData theme;

  const _RadioGridItem({
    required this.option,
    required this.isSelected,
    required this.onTap,
    required this.width,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.textPrimary : theme.controlBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? theme.textPrimary : theme.controlBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (option.icon != null) ...[
              Icon(
                option.icon,
                size: 20,
                color: isSelected ? theme.scaffoldBackground : theme.textPrimary,
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                option.label,
                style: AppFontStyles.textControlInput.copyWith(
                  color: isSelected ? theme.scaffoldBackground : theme.textPrimary,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

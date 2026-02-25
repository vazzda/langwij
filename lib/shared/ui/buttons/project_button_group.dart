import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srpski_card/app/theme/app_themes.dart';
import 'package:srpski_card/app/providers/theme_provider.dart';
import 'package:srpski_card/shared/ui/buttons/project_button_styles.dart';

/// Configuration for a single button in a button group
class ProjectButtonGroupItem {
  final IconData? icon;
  final String? label;
  final VoidCallback? onPressed;
  final bool isSelected;

  const ProjectButtonGroupItem({
    this.icon,
    this.label,
    this.onPressed,
    this.isSelected = false,
  }) : assert(icon != null || label != null, 'Either icon or label must be provided');
}

/// A group of buttons that share borders and appear as a single connected unit.
class ProjectButtonGroup extends ConsumerWidget {
  final List<ProjectButtonGroupItem> items;
  final ButtonSize size;
  final bool expanded;

  const ProjectButtonGroup({
    super.key,
    required this.items,
    this.size = ButtonSize.medium,
    this.expanded = false,
  }) : assert(items.length >= 1, 'Button group must have at least 1 item');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppThemes.of(context);
    final appTheme = ref.watch(themeProvider);
    final baseColors = ProjectButtonStyleResolver.resolveColors(
      context,
      theme: appTheme,
      variant: ButtonVariant.base,
    );
    final accentColors = ProjectButtonStyleResolver.resolveColors(
      context,
      theme: appTheme,
      variant: ButtonVariant.accent,
    );

    final borderRadius = theme.buttonBorderRadius;
    final borderWidth = size == ButtonSize.large
        ? theme.buttonBorderWidth * 2
        : theme.buttonBorderWidth;

    return Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      children: List.generate(items.length, (index) {
        final item = items[index];
        final isFirst = index == 0;
        final isLast = index == items.length - 1;
        final colors = item.isSelected ? accentColors : baseColors;

        return expanded
            ? Expanded(child: _buildButton(context, item, isFirst, isLast, colors, borderRadius, borderWidth))
            : _buildButton(context, item, isFirst, isLast, colors, borderRadius, borderWidth);
      }),
    );
  }

  Widget _buildButton(
    BuildContext context,
    ProjectButtonGroupItem item,
    bool isFirst,
    bool isLast,
    ProjectButtonColors colors,
    double borderRadius,
    double borderWidth,
  ) {
    final isEnabled = item.onPressed != null;
    final useFullColors = isEnabled || item.isSelected;
    final bgColor = useFullColors ? colors.background : colors.disabledBackground;
    final fgColor = useFullColors ? colors.foreground : colors.disabledForeground;
    final borderColor = useFullColors ? colors.border : colors.disabledBorder;

    final radius = Radius.circular(borderRadius);
    const noRadius = Radius.zero;

    final borderSide = BorderSide(color: borderColor, width: borderWidth);

    final double minHeight;
    final double hPadding;
    final double iconSize;
    final TextStyle textStyle;

    switch (size) {
      case ButtonSize.small:
        minHeight = 32.0;
        hPadding = 10.0;
        iconSize = 20.0;
        textStyle = AppFontStyles.textButtonSmall;
        break;
      case ButtonSize.medium:
        minHeight = 44.0;
        hPadding = 16.0;
        iconSize = 28.0;
        textStyle = AppFontStyles.textButton;
        break;
      case ButtonSize.large:
        minHeight = 56.0;
        hPadding = 24.0;
        iconSize = 32.0;
        textStyle = AppFontStyles.textButtonLarge;
        break;
    }

    Widget child;
    final iconOnly = item.icon != null && (item.label == null || item.label!.isEmpty);

    if (iconOnly) {
      child = Icon(item.icon, size: iconSize, color: fgColor);
    } else if (item.icon != null && item.label != null && item.label!.isNotEmpty) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, size: iconSize * 0.8, color: fgColor),
          const SizedBox(width: 8),
          Text(item.label!.toUpperCase(), style: textStyle.copyWith(color: fgColor)),
        ],
      );
    } else {
      child = Text(item.label!.toUpperCase(), style: textStyle.copyWith(color: fgColor));
    }

    return GestureDetector(
      onTap: item.onPressed,
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        padding: EdgeInsets.symmetric(
          horizontal: iconOnly ? hPadding * 0.6 : hPadding,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: isFirst ? radius : noRadius,
            bottomLeft: isFirst ? radius : noRadius,
            topRight: isLast ? radius : noRadius,
            bottomRight: isLast ? radius : noRadius,
          ),
          border: Border(
            top: borderSide,
            bottom: borderSide,
            left: isFirst ? borderSide : BorderSide.none,
            right: borderSide,
          ),
        ),
        child: Center(child: child),
      ),
    );
  }
}

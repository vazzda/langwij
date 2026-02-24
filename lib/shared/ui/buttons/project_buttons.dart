import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srpski_card/app/providers/theme_provider.dart';
import 'package:srpski_card/app/theme/app_themes.dart';
import 'package:srpski_card/shared/ui/buttons/project_button_styles.dart';

export 'project_button_styles.dart' show ButtonSize;

class BaseButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final String? label;
  final IconData? icon;
  final ButtonSize size;
  final bool condensed;
  final EdgeInsets margin;

  const BaseButton({
    super.key,
    this.onPressed,
    this.label,
    this.icon,
    this.size = ButtonSize.medium,
    this.condensed = false,
    this.margin = const EdgeInsets.symmetric(horizontal: 4),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final colors = ProjectButtonStyleResolver.resolveColors(
      context,
      theme: theme,
      variant: ButtonVariant.base,
    );
    final iconOnly = icon != null && (label == null || label!.isEmpty);
    final hasIconAndText = icon != null && label != null && label!.isNotEmpty;
    final iconSize = iconOnly
        ? ProjectButtonStyleResolver.getIconOnlySize(size)
        : ProjectButtonStyleResolver.getIconWithTextSize(size);
    final effectiveMargin = condensed
        ? EdgeInsets.symmetric(horizontal: margin.horizontal / 4)
        : margin;

    final themeData = AppThemes.getThemeData(theme);
    final button = OutlinedButton(
      onPressed: onPressed,
      style: ProjectButtonStyleResolver.style(
        context: context,
        colors: colors,
        iconOnly: iconOnly,
        hasIconAndText: hasIconAndText,
        size: size,
        condensed: condensed,
        variant: ButtonVariant.base,
      ),
      child: _buildChild(iconOnly, iconSize),
    );

    Widget result = button;
    if (themeData.componentShadow != null) {
      result = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(themeData.buttonBorderRadius),
          boxShadow: themeData.componentShadow,
        ),
        child: result,
      );
    }

    return effectiveMargin == EdgeInsets.zero
        ? result
        : Padding(padding: effectiveMargin, child: result);
  }

  Widget _buildChild(bool iconOnly, double iconSize) {
    final iconWidget = icon != null ? Icon(icon, size: iconSize) : null;
    if (iconOnly) return iconWidget!;
    if (iconWidget != null && label != null && label!.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [iconWidget, const SizedBox(width: 8), Text(label!.toUpperCase())],
      );
    }
    return Text((label ?? '').toUpperCase());
  }
}

class AccentButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final String? label;
  final IconData? icon;
  final ButtonSize size;
  final bool condensed;
  final EdgeInsets margin;

  const AccentButton({
    super.key,
    this.onPressed,
    this.label,
    this.icon,
    this.size = ButtonSize.medium,
    this.condensed = false,
    this.margin = const EdgeInsets.symmetric(horizontal: 4),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final colors = ProjectButtonStyleResolver.resolveColors(
      context,
      theme: theme,
      variant: ButtonVariant.accent,
    );
    final iconOnly = icon != null && (label == null || label!.isEmpty);
    final hasIconAndText = icon != null && label != null && label!.isNotEmpty;
    final iconSize = iconOnly
        ? ProjectButtonStyleResolver.getIconOnlySize(size)
        : ProjectButtonStyleResolver.getIconWithTextSize(size);
    final effectiveMargin = condensed
        ? EdgeInsets.symmetric(horizontal: margin.horizontal / 4)
        : margin;

    final themeData = AppThemes.getThemeData(theme);
    final button = OutlinedButton(
      onPressed: onPressed,
      style: ProjectButtonStyleResolver.style(
        context: context,
        colors: colors,
        iconOnly: iconOnly,
        hasIconAndText: hasIconAndText,
        size: size,
        condensed: condensed,
        variant: ButtonVariant.accent,
      ),
      child: _buildChild(iconOnly, iconSize),
    );

    Widget result = button;
    if (themeData.componentShadow != null) {
      result = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(themeData.buttonBorderRadius),
          boxShadow: themeData.componentShadow,
        ),
        child: result,
      );
    }

    return effectiveMargin == EdgeInsets.zero
        ? result
        : Padding(padding: effectiveMargin, child: result);
  }

  Widget _buildChild(bool iconOnly, double iconSize) {
    final iconWidget = icon != null ? Icon(icon, size: iconSize) : null;
    if (iconOnly) return iconWidget!;
    if (iconWidget != null && label != null && label!.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [iconWidget, const SizedBox(width: 8), Text(label!.toUpperCase())],
      );
    }
    return Text((label ?? '').toUpperCase());
  }
}

class DangerButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final String? label;
  final IconData? icon;
  final ButtonSize size;
  final bool condensed;
  final EdgeInsets margin;

  const DangerButton({
    super.key,
    this.onPressed,
    this.label,
    this.icon,
    this.size = ButtonSize.medium,
    this.condensed = false,
    this.margin = const EdgeInsets.symmetric(horizontal: 4),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final colors = ProjectButtonStyleResolver.resolveColors(
      context,
      theme: theme,
      variant: ButtonVariant.danger,
    );
    final iconOnly = icon != null && (label == null || label!.isEmpty);
    final hasIconAndText = icon != null && label != null && label!.isNotEmpty;
    final iconSize = iconOnly
        ? ProjectButtonStyleResolver.getIconOnlySize(size)
        : ProjectButtonStyleResolver.getIconWithTextSize(size);
    final effectiveMargin = condensed
        ? EdgeInsets.symmetric(horizontal: margin.horizontal / 4)
        : margin;

    final themeData = AppThemes.getThemeData(theme);
    final button = OutlinedButton(
      onPressed: onPressed,
      style: ProjectButtonStyleResolver.style(
        context: context,
        colors: colors,
        iconOnly: iconOnly,
        hasIconAndText: hasIconAndText,
        size: size,
        condensed: condensed,
        variant: ButtonVariant.danger,
      ),
      child: _buildChild(iconOnly, iconSize),
    );

    Widget result = button;
    if (themeData.componentShadow != null) {
      result = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(themeData.buttonBorderRadius),
          boxShadow: themeData.componentShadow,
        ),
        child: result,
      );
    }

    return effectiveMargin == EdgeInsets.zero
        ? result
        : Padding(padding: effectiveMargin, child: result);
  }

  Widget _buildChild(bool iconOnly, double iconSize) {
    final iconWidget = icon != null ? Icon(icon, size: iconSize) : null;
    if (iconOnly) return iconWidget!;
    if (iconWidget != null && label != null && label!.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [iconWidget, const SizedBox(width: 8), Text(label!.toUpperCase())],
      );
    }
    return Text((label ?? '').toUpperCase());
  }
}

class AccentTextButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final String? label;
  final IconData? icon;
  final ButtonSize size;
  final bool condensed;
  final EdgeInsets margin;

  const AccentTextButton({
    super.key,
    this.onPressed,
    this.label,
    this.icon,
    this.size = ButtonSize.medium,
    this.condensed = false,
    this.margin = const EdgeInsets.symmetric(horizontal: 4),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final colors = ProjectButtonStyleResolver.resolveColors(
      context,
      theme: theme,
      variant: ButtonVariant.textAccent,
    );
    final iconOnly = icon != null && (label == null || label!.isEmpty);
    final hasIconAndText = icon != null && label != null && label!.isNotEmpty;
    final iconSize = iconOnly
        ? ProjectButtonStyleResolver.getIconOnlySize(size)
        : ProjectButtonStyleResolver.getIconWithTextSize(size);
    final effectiveMargin = condensed
        ? EdgeInsets.symmetric(horizontal: margin.horizontal / 4)
        : margin;

    final button = OutlinedButton(
      onPressed: onPressed,
      style: ProjectButtonStyleResolver.style(
        context: context,
        colors: colors,
        iconOnly: iconOnly,
        hasIconAndText: hasIconAndText,
        size: size,
        condensed: condensed,
        variant: ButtonVariant.textAccent,
      ),
      child: _buildChild(iconOnly, iconSize),
    );

    return effectiveMargin == EdgeInsets.zero
        ? button
        : Padding(padding: effectiveMargin, child: button);
  }

  Widget _buildChild(bool iconOnly, double iconSize) {
    final iconWidget = icon != null ? Icon(icon, size: iconSize) : null;
    if (iconOnly) return iconWidget!;
    if (iconWidget != null && label != null && label!.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [iconWidget, const SizedBox(width: 8), Text(label!.toUpperCase())],
      );
    }
    return Text((label ?? '').toUpperCase());
  }
}

class ProjectTextButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final String? label;
  final IconData? icon;
  final ButtonSize size;
  final bool condensed;
  final EdgeInsets margin;

  const ProjectTextButton({
    super.key,
    this.onPressed,
    this.label,
    this.icon,
    this.size = ButtonSize.medium,
    this.condensed = false,
    this.margin = const EdgeInsets.symmetric(horizontal: 4),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final colors = ProjectButtonStyleResolver.resolveColors(
      context,
      theme: theme,
      variant: ButtonVariant.text,
    );
    final iconOnly = icon != null && (label == null || label!.isEmpty);
    final hasIconAndText = icon != null && label != null && label!.isNotEmpty;
    final iconSize = iconOnly
        ? ProjectButtonStyleResolver.getIconOnlySize(size)
        : ProjectButtonStyleResolver.getIconWithTextSize(size);
    final effectiveMargin = condensed
        ? EdgeInsets.symmetric(horizontal: margin.horizontal / 4)
        : margin;

    final button = OutlinedButton(
      onPressed: onPressed,
      style: ProjectButtonStyleResolver.style(
        context: context,
        colors: colors,
        iconOnly: iconOnly,
        hasIconAndText: hasIconAndText,
        size: size,
        condensed: condensed,
        variant: ButtonVariant.text,
      ),
      child: _buildChild(iconOnly, iconSize),
    );

    return effectiveMargin == EdgeInsets.zero
        ? button
        : Padding(padding: effectiveMargin, child: button);
  }

  Widget _buildChild(bool iconOnly, double iconSize) {
    final iconWidget = icon != null ? Icon(icon, size: iconSize) : null;
    if (iconOnly) return iconWidget!;
    if (iconWidget != null && label != null && label!.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [iconWidget, const SizedBox(width: 8), Text(label!.toUpperCase())],
      );
    }
    return Text((label ?? '').toUpperCase());
  }
}

class DangerTextButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final String? label;
  final IconData? icon;
  final ButtonSize size;
  final bool condensed;
  final EdgeInsets margin;

  const DangerTextButton({
    super.key,
    this.onPressed,
    this.label,
    this.icon,
    this.size = ButtonSize.medium,
    this.condensed = false,
    this.margin = const EdgeInsets.symmetric(horizontal: 4),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final colors = ProjectButtonStyleResolver.resolveColors(
      context,
      theme: theme,
      variant: ButtonVariant.textDanger,
    );
    final iconOnly = icon != null && (label == null || label!.isEmpty);
    final hasIconAndText = icon != null && label != null && label!.isNotEmpty;
    final iconSize = iconOnly
        ? ProjectButtonStyleResolver.getIconOnlySize(size)
        : ProjectButtonStyleResolver.getIconWithTextSize(size);
    final effectiveMargin = condensed
        ? EdgeInsets.symmetric(horizontal: margin.horizontal / 4)
        : margin;

    final button = OutlinedButton(
      onPressed: onPressed,
      style: ProjectButtonStyleResolver.style(
        context: context,
        colors: colors,
        iconOnly: iconOnly,
        hasIconAndText: hasIconAndText,
        size: size,
        condensed: condensed,
        variant: ButtonVariant.textDanger,
      ),
      child: _buildChild(iconOnly, iconSize),
    );

    return effectiveMargin == EdgeInsets.zero
        ? button
        : Padding(padding: effectiveMargin, child: button);
  }

  Widget _buildChild(bool iconOnly, double iconSize) {
    final iconWidget = icon != null ? Icon(icon, size: iconSize) : null;
    if (iconOnly) return iconWidget!;
    if (iconWidget != null && label != null && label!.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [iconWidget, const SizedBox(width: 8), Text(label!.toUpperCase())],
      );
    }
    return Text((label ?? '').toUpperCase());
  }
}

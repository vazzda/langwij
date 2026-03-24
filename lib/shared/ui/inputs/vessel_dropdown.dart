import 'package:flutter/material.dart';

import '../../../app/theme/vessel_themes.dart';

/// A themed dropdown selector. Matches VesselTextInput styling.
///
/// Uses [DropdownMenu] internally for proper popup sizing (doesn't stretch
/// to screen edges like [DropdownButtonFormField]).
///
/// [T] must implement equality (used to match [initialSelection] against
/// item values).
class VesselDropdown<T> extends StatelessWidget {
  const VesselDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint,
    this.expandedInsets,
  });

  /// Dropdown items with value and display label.
  final List<VesselDropdownItem<T>> items;

  /// Currently selected value.
  final T value;

  /// Called when a new value is selected.
  final ValueChanged<T> onChanged;

  /// Optional floating label above the field.
  final String? label;

  /// Hint text shown when no value is selected.
  final String? hint;

  /// Insets for the expanded menu relative to the field.
  /// Defaults to [EdgeInsets.zero] (same width as field).
  final EdgeInsets? expandedInsets;

  @override
  Widget build(BuildContext context) {
    final t = VesselThemes.of(context);

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(t.controlBorderRadius),
      borderSide: BorderSide(color: t.controlBorder, width: t.controlBorderWidth),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(t.controlBorderRadius),
      borderSide: BorderSide(color: t.accentColor, width: t.controlBorderWidth),
    );

    return LayoutBuilder(
      builder: (context, constraints) => DropdownMenu<T>(
        initialSelection: value,
        onSelected: (v) {
          if (v != null) onChanged(v);
        },
        label: label != null ? Text(label!) : null,
        hintText: hint,
        expandedInsets: expandedInsets ?? EdgeInsets.zero,
        width: constraints.maxWidth,
        textStyle: VesselFonts.textFormInput.copyWith(color: t.inputForeground),
        trailingIcon: Icon(Icons.arrow_drop_down, color: t.controlForeground),
        selectedTrailingIcon: Icon(Icons.arrow_drop_up, color: t.controlForeground),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(t.inputBackground),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(t.controlBorderRadius),
              side: BorderSide(color: t.controlBorder, width: t.controlBorderWidth),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: t.inputBackground,
          filled: true,
          border: border,
          enabledBorder: border,
          focusedBorder: focusedBorder,
        ),
        dropdownMenuEntries: items
            .map((item) => DropdownMenuEntry<T>(
                  value: item.value,
                  label: item.label,
                  style: ButtonStyle(
                    textStyle: WidgetStatePropertyAll(
                      VesselFonts.textFormInput.copyWith(color: t.inputForeground),
                    ),
                    foregroundColor: WidgetStatePropertyAll(t.inputForeground),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

/// A single item in a [VesselDropdown].
class VesselDropdownItem<T> {
  const VesselDropdownItem({required this.value, required this.label});

  final T value;
  final String label;
}

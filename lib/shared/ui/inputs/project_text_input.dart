import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_themes.dart';

/// Text input field using theme. No hardcoded colors.
class ProjectTextInput extends StatelessWidget {
  const ProjectTextInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.onSubmitted,
    this.autofocus = false,
    this.textInputAction = TextInputAction.done,
    this.keyboardType,
    this.inputFormatters,
    this.autocorrect = true,
    this.enableSuggestions = true,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool autocorrect;
  final bool enableSuggestions;

  @override
  Widget build(BuildContext context) {
    final t = AppThemes.of(context);
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        fillColor: t.controlBackground,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(t.controlBorderRadius),
          borderSide: BorderSide(color: t.controlBorder, width: t.controlBorderWidth),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(t.controlBorderRadius),
          borderSide: BorderSide(color: t.controlBorder, width: t.controlBorderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(t.controlBorderRadius),
          borderSide: BorderSide(color: t.accentColor, width: t.controlBorderWidth),
        ),
      ),
      onSubmitted: onSubmitted,
      autofocus: autofocus,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      style: AppFontStyles.textFormInput.copyWith(color: t.controlForeground),
    );
  }
}

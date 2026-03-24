import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/vessel_themes.dart';

/// Text input field using theme. No hardcoded colors.
class VesselTextInput extends StatelessWidget {
  const VesselTextInput({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.onSubmitted,
    this.autofocus = false,
    this.textInputAction = TextInputAction.done,
    this.keyboardType,
    this.inputFormatters,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool autocorrect;
  final bool enableSuggestions;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;

  @override
  Widget build(BuildContext context) {
    final t = VesselThemes.of(context);
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        fillColor: t.inputBackground,
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
      maxLines: maxLines,
      minLines: minLines,
      onSubmitted: onSubmitted,
      autofocus: autofocus,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      obscureText: obscureText,
      style: VesselFonts.textFormInput.copyWith(color: t.inputForeground),
    );
  }
}

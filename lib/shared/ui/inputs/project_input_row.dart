import 'package:flutter/material.dart';
import 'package:srpski_card/app/theme/app_themes.dart';
import 'package:srpski_card/shared/ui/inputs/project_input_styles.dart';

/// A single field configuration for ProjectInputRow
class ProjectInputRowField {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;

  const ProjectInputRowField({
    required this.label,
    this.hint,
    this.controller,
    this.onChanged,
    this.keyboardType = TextInputType.text,
  });
}

/// A horizontal row of labeled input fields with equal spacing
class ProjectInputRow extends StatelessWidget {
  final List<ProjectInputRowField> fields;
  final double spacing;
  final bool exclusive;

  const ProjectInputRow({
    super.key,
    required this.fields,
    this.spacing = 12,
    this.exclusive = false,
  });

  void _clearOtherFields(int activeIndex) {
    for (int i = 0; i < fields.length; i++) {
      if (i != activeIndex && fields[i].controller != null) {
        fields[i].controller!.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < fields.length; i++) ...[
          Expanded(
            child: _InputField(
              field: fields[i],
              onFocusGained: exclusive ? () => _clearOtherFields(i) : null,
            ),
          ),
          if (i < fields.length - 1) SizedBox(width: spacing),
        ],
      ],
    );
  }
}

class _InputField extends StatefulWidget {
  final ProjectInputRowField field;
  final VoidCallback? onFocusGained;

  const _InputField({
    required this.field,
    this.onFocusGained,
  });

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && !_hasFocus) {
      _hasFocus = true;
      widget.onFocusGained?.call();
    } else if (!_focusNode.hasFocus) {
      _hasFocus = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemes.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.field.label,
          style: AppFontStyles.textControlLabel.copyWith(color: theme.textSecondary),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: widget.field.controller,
          focusNode: _focusNode,
          onChanged: widget.field.onChanged,
          keyboardType: widget.field.keyboardType,
          style: ProjectInputStyles.textStyle(context),
          decoration: ProjectInputStyles.decoration(
            context: context,
            hint: widget.field.hint,
          ),
        ),
      ],
    );
  }
}

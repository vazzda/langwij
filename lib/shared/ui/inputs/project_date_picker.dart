import 'package:flutter/material.dart';
import 'package:srpski_card/app/theme/app_themes.dart';

/// A project-wide date picker control
class ProjectDatePicker extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final String? placeholder;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;

  const ProjectDatePicker({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.placeholder,
    this.firstDate,
    this.lastDate,
    this.initialDate,
  });

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _showPicker(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? selectedDate ?? now,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemes.of(context);
    final hasValue = selectedDate != null;
    final displayText = hasValue ? _formatDate(selectedDate!) : (placeholder ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppFontStyles.textBodyAccent.copyWith(color: theme.textPrimary),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => _showPicker(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.controlBackground,
              border: Border.all(color: theme.controlBorder, width: theme.controlBorderWidth),
              borderRadius: BorderRadius.circular(theme.controlBorderRadius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  displayText,
                  style: AppFontStyles.textControlInput.copyWith(
                    color: hasValue ? theme.controlForeground : theme.textSecondary,
                  ),
                ),
                Icon(Icons.calendar_today, color: theme.controlForeground, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

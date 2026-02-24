import 'package:flutter/material.dart';
import 'package:srpski_card/app/theme/app_themes.dart';
import 'package:srpski_card/shared/ui/bottom_sheet/project_bottom_sheet.dart';

/// A project-wide hour picker control
class ProjectHourPicker extends StatelessWidget {
  final String label;
  final String? description;
  final int selectedHour;
  final ValueChanged<int> onHourSelected;

  const ProjectHourPicker({
    super.key,
    required this.label,
    this.description,
    required this.selectedHour,
    required this.onHourSelected,
  });

  String _formatHour(int hour) {
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  Future<void> _showPicker(BuildContext context) async {
    final picked = await showProjectBottomSheet<int>(
      context: context,
      builder: (context) => _HourPickerSheet(selectedHour: selectedHour),
    );

    if (picked != null) {
      onHourSelected(picked);
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
          label,
          style: AppFontStyles.textBodyAccent.copyWith(color: theme.textPrimary),
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description!,
            style: AppFontStyles.textCaption.copyWith(color: theme.textSecondary),
          ),
        ],
        const SizedBox(height: 8),
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
                  _formatHour(selectedHour),
                  style: AppFontStyles.textControlInput.copyWith(color: theme.controlForeground),
                ),
                Icon(Icons.schedule, color: theme.controlForeground, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HourPickerSheet extends StatelessWidget {
  final int selectedHour;

  const _HourPickerSheet({required this.selectedHour});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemes.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.textSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 24,
              itemBuilder: (context, index) {
                final isSelected = index == selectedHour;
                return GestureDetector(
                  onTap: () => Navigator.of(context).pop(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? theme.accentColor : theme.controlBackground,
                      border: Border.all(
                        color: isSelected ? theme.accentColor : theme.controlBorder,
                        width: theme.controlBorderWidth,
                      ),
                      borderRadius: BorderRadius.circular(theme.controlBorderRadius),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index.toString().padLeft(2, '0')}:00',
                      style: AppFontStyles.textControlInput.copyWith(
                        color: isSelected ? theme.displayBackground : theme.controlForeground,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

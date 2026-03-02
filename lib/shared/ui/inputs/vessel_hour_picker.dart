import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:srpski_card/app/layout/vessel_layout.dart';
import 'package:srpski_card/app/theme/vessel_themes.dart';
import 'package:srpski_card/shared/ui/bottom_sheet/vessel_bottom_sheet.dart';
import 'package:srpski_card/shared/ui/gap/vessel_gap.dart';

/// A project-wide hour picker control
class VesselHourPicker extends StatelessWidget {
  final String label;
  final String? description;
  final int selectedHour;
  final ValueChanged<int> onHourSelected;

  const VesselHourPicker({
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
    final picked = await showVesselBottomSheet<int>(
      context: context,
      builder: (context) => _HourPickerSheet(selectedHour: selectedHour),
    );

    if (picked != null) {
      onHourSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = VesselThemes.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: VesselFonts.textBodyAccent.copyWith(color: theme.textPrimary),
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description!,
            style: VesselFonts.textCaption.copyWith(color: theme.textSecondary),
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
                  style: VesselFonts.textControlInput.copyWith(color: theme.controlForeground),
                ),
                Icon(PhosphorIconsRegular.clock, color: theme.controlForeground, size: 20),
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
    final theme = VesselThemes.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: theme.textSecondary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const VesselGap.l(),
        SizedBox(
          height: 300,
          child: GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.5,
              crossAxisSpacing: VesselLayout.gapS,
              mainAxisSpacing: VesselLayout.gapS,
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
                    style: VesselFonts.textControlInput.copyWith(
                      color: isSelected ? theme.displayBackground : theme.controlForeground,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

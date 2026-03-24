import 'package:flutter/material.dart';

import '../../../app/theme/vessel_themes.dart';
import '../../../entities/card/card_model.dart';
import '../../../l10n/app_localizations.dart';
import '../buttons/vessel_buttons.dart';
import '../gap/vessel_gap.dart';
import '../inputs/vessel_dropdown.dart';
import '../inputs/vessel_text_input.dart';
import 'bug_report_type.dart';
import 'vessel_bottom_sheet.dart';

/// Opens a bug report bottom sheet for a specific card.
///
/// [card] — the card being reported (shown as context in the sheet).
/// Submit is a no-op for now; both buttons close the sheet.
Future<void> showBugReportSheet(
  BuildContext context, {
  required CardModel card,
}) {
  return showVesselBottomSheet(
    context: context,
    builder: (context) => _BugReportSheetContent(card: card),
  );
}

class _BugReportSheetContent extends StatefulWidget {
  const _BugReportSheetContent({required this.card});

  final CardModel card;

  @override
  State<_BugReportSheetContent> createState() => _BugReportSheetContentState();
}

class _BugReportSheetContentState extends State<_BugReportSheetContent> {
  BugReportType _selectedType = BugReportType.badTranslation;
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = VesselThemes.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.bugReport_title,
          style: VesselFonts.textSheetTitle.copyWith(color: t.textPrimary),
        ),
        const VesselGap.m(),
        // Card context
        Text(
          '${widget.card.targetAnswer} → ${widget.card.nativeText}',
          style: VesselFonts.textBodyAccent.copyWith(color: t.textPrimary),
        ),
        const VesselGap.m(),
        // Bug type selector
        VesselDropdown<BugReportType>(
          value: _selectedType,
          onChanged: (v) => setState(() => _selectedType = v),
          items: [
            VesselDropdownItem(
              value: BugReportType.badTranslation,
              label: l10n.bugReport_typeBadTranslation,
            ),
            VesselDropdownItem(
              value: BugReportType.uiBug,
              label: l10n.bugReport_typeUiBug,
            ),
          ],
        ),
        const VesselGap.m(),
        // Message textarea
        VesselTextInput(
          controller: _messageController,
          hint: l10n.bugReport_messagePlaceholder,
          maxLines: 4,
          minLines: 3,
          textInputAction: TextInputAction.newline,
          keyboardType: TextInputType.multiline,
        ),
        const VesselGap.l(),
        // Action buttons
        Row(
          children: [
            Expanded(
              child: VesselButton(
                label: l10n.cancel,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const VesselGap.hm(),
            Expanded(
              child: VesselAccentButton(
                label: l10n.bugReport_submit,
                onPressed: () {
                  // No-op for now. Persistence comes later.
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

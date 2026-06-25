import 'package:flessel/flessel.dart';
import 'package:flutter/material.dart';

import 'package:langwij/l10n/app_localizations.dart';
import '../model/bug_report_type.dart';

Future<void> showLangwijBugReportSheet(
  BuildContext context, {
  required String targetText,
  required String nativeText,
}) {
  return showFlesselBottomSheet<void>(
    context: context,
    builder: (_) => _LangwijBugReportForm(
      targetText: targetText,
      nativeText: nativeText,
    ),
  );
}

class _LangwijBugReportForm extends StatefulWidget {
  const _LangwijBugReportForm({
    required this.targetText,
    required this.nativeText,
  });

  final String targetText;
  final String nativeText;

  @override
  State<_LangwijBugReportForm> createState() => _LangwijBugReportFormState();
}

class _LangwijBugReportFormState extends State<_LangwijBugReportForm> {
  BugReportType _selectedType = BugReportType.badTranslation;
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.bugReport_title,
          style: FlesselFonts.contentTitle.copyWith(color: t.fg),
        ),
        const FlesselGap.m(),
        Text(
          '${widget.targetText} → ${widget.nativeText}',
          style: FlesselFonts.contentBodyAccent.copyWith(color: t.fg),
        ),
        const FlesselGap.m(),
        FlesselDropdown<BugReportType>(
          value: _selectedType,
          onChanged: (v) => setState(() => _selectedType = v),
          expanded: true,
          items: [
            FlesselDropdownItem(
              value: BugReportType.badTranslation,
              label: l10n.bugReport_typeBadTranslation,
            ),
            FlesselDropdownItem(
              value: BugReportType.uiBug,
              label: l10n.bugReport_typeUiBug,
            ),
          ],
        ),
        const FlesselGap.m(),
        FlesselTextInput(
          controller: _messageController,
          hint: l10n.bugReport_messagePlaceholder,
          maxLines: 4,
          minLines: 3,
          keyboardType: TextInputType.multiline,
        ),
        const FlesselGap.l(),
        Row(
          children: [
            Expanded(
              child: FlesselButton(
                label: l10n.cancel,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const FlesselGap.m(),
            Expanded(
              child: FlesselButton(
                variant: FlesselVariant.accent,
                label: l10n.bugReport_submit,
                onPressed: () {
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

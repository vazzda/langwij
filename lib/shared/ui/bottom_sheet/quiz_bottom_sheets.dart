import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../features/quiz/quiz_mode.dart';
import '../../../app/theme/app_themes.dart';
import '../buttons/project_buttons.dart';
import 'project_bottom_sheet.dart';

/// Result of mode selection: the quiz mode and whether it's a test.
class ModeSelection {
  const ModeSelection({required this.mode, required this.isTest});

  final QuizMode mode;
  final bool isTest;
}

/// Shows mode selection bottom sheet with TRAIN and TESTING sections.
/// [showAllModes] - if true, shows all 3 train modes; if false, shows only WRITING.
/// Returns [ModeSelection] or null if dismissed.
Future<ModeSelection?> showModeBottomSheet(
  BuildContext context,
  AppLocalizations l10n, {
  bool showAllModes = true,
}) {
  final t = AppThemes.of(context);
  return showProjectBottomSheet<ModeSelection>(
    context: context,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            l10n.chooseMode,
            style: AppFontStyles.textSheetTitle.copyWith(color: t.textPrimary),
          ),
        ),
        // TRAIN header
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            l10n.trainHeader,
            style: AppFontStyles.textControlLabel.copyWith(color: t.textSecondary),
          ),
        ),
        // Train buttons
        if (showAllModes) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: BaseButton(
              label: l10n.modeEngCards,
              onPressed: () => Navigator.of(context).pop(
                const ModeSelection(mode: QuizMode.serbianShown, isTest: false),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: BaseButton(
              label: l10n.modeSrpskiCards,
              onPressed: () => Navigator.of(context).pop(
                const ModeSelection(mode: QuizMode.englishShown, isTest: false),
              ),
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: BaseButton(
            label: l10n.modeWriting,
            onPressed: () => Navigator.of(context).pop(
              const ModeSelection(mode: QuizMode.write, isTest: false),
            ),
          ),
        ),
        // TESTING header
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            l10n.testHeader,
            style: AppFontStyles.textControlLabel.copyWith(color: t.textSecondary),
          ),
        ),
        // Test button
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AccentButton(
            label: l10n.modeTest,
            onPressed: () => Navigator.of(context).pop(
              const ModeSelection(mode: QuizMode.write, isTest: true),
            ),
          ),
        ),
        // Cancel
        ProjectTextButton(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}

/// Shows question count selection bottom sheet.
/// [totalCount] - total cards available in the group.
/// Returns selected count or null if dismissed.
///
/// Options shown based on totalCount:
/// - totalCount > 10: "5", "10", "ALL (N)"
/// - totalCount > 5: "5", "ALL (N)"
/// - totalCount <= 5: returns totalCount immediately (no sheet shown)
/// - totalCount <= 0: returns null (invalid)
Future<int?> showCountBottomSheet(
  BuildContext context,
  AppLocalizations l10n, {
  required int totalCount,
}) async {
  // No cards available
  if (totalCount <= 0) return null;

  // 5 or fewer cards - skip selection, use all
  if (totalCount <= 5) return totalCount;

  // Build options based on total
  final counts = <int>[];
  final labels = <String>[];

  // Always show 5
  counts.add(5);
  labels.add(l10n.questions5);

  // Show 10 if we have more than 10
  if (totalCount > 10) {
    counts.add(10);
    labels.add(l10n.questions10);
  }

  // Always show ALL
  counts.add(totalCount);
  labels.add(l10n.questionsAll(totalCount));

  final t = AppThemes.of(context);
  return showProjectBottomSheet<int>(
    context: context,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            l10n.chooseQuestionsCount,
            style: AppFontStyles.textSheetTitle.copyWith(color: t.textPrimary),
          ),
        ),
        ...List.generate(counts.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: BaseButton(
              label: labels[i],
              onPressed: () => Navigator.of(context).pop(counts[i]),
            ),
          );
        }),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ProjectTextButton(
            label: l10n.cancel,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    ),
  );
}

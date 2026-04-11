import 'package:country_flags/country_flags.dart';
import 'package:flessel/flessel.dart';
import 'package:flutter/material.dart';

import '../../../entities/language/lang_codes.dart';
import '../../../features/quiz/mode_selection.dart';
import '../../../features/quiz/quiz_mode.dart';
import '../../../l10n/app_localizations.dart';
import '../layout/langwij_layout.dart';

/// Shows mode selection bottom sheet with GUESSING and WRITING sections.
///
/// [showAllModes] — if true, shows both sections; if false, shows only WRITING.
/// [targetLangCode] — language code for the target (learning) language.
/// [nativeLangCode] — language code for the native language. Ignored when
/// [showAllModes] is false.
/// [nativeLangName] / [targetLangName] — display names for guessing tiles.
/// Ignored when [showAllModes] is false.
///
/// Returns [ModeSelection] or null if dismissed.
Future<ModeSelection?> showLangwijModeSelectionSheet(
  BuildContext context,
  AppLocalizations l10n, {
  bool showAllModes = true,
  required String targetLangCode,
  String nativeLangCode = '',
  String nativeLangName = '',
  String targetLangName = '',
}) {
  final t = FlesselThemes.of(context);
  return showFlesselBottomSheet<ModeSelection>(
    context: context,
    builder: (context) => ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: LangwijLayout.quizSheetMinHeight,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showAllModes) ...[
            Text(
              l10n.mode_guessingHeader.toUpperCase(),
              style: FlesselFonts.contentXlAccent
                  .copyWith(color: t.textSecondary),
            ),
            const FlesselGap.s(),
            _ModeTileRow(
              tiles: [
                _ModeTileData(
                  label: l10n.mode_langCards(nativeLangName),
                  langCode: nativeLangCode,
                  typeIcon: PhosphorIconsRegular.cards,
                  isAccent: false,
                  onTap: () => Navigator.of(context).pop(
                    const ModeSelection(
                        mode: QuizMode.nativeShown, isTest: false),
                  ),
                ),
                _ModeTileData(
                  label: l10n.mode_langCards(targetLangName),
                  langCode: targetLangCode,
                  typeIcon: PhosphorIconsRegular.cards,
                  isAccent: false,
                  onTap: () => Navigator.of(context).pop(
                    const ModeSelection(
                        mode: QuizMode.targetShown, isTest: false),
                  ),
                ),
              ],
            ),
            const FlesselGap.l(),
          ],
          Text(
            l10n.mode_writingHeader.toUpperCase(),
            style: FlesselFonts.contentXlAccent
                .copyWith(color: t.textSecondary),
          ),
          const FlesselGap.s(),
          _ModeTileRow(
            tiles: [
              _ModeTileData(
                label: l10n.mode_training,
                langCode: targetLangCode,
                typeIcon: PhosphorIconsRegular.pencilSimpleLine,
                isAccent: false,
                onTap: () => Navigator.of(context).pop(
                  const ModeSelection(mode: QuizMode.write, isTest: false),
                ),
              ),
              _ModeTileData(
                label: l10n.mode_test,
                langCode: targetLangCode,
                typeIcon: PhosphorIconsRegular.pencilSimpleLine,
                isAccent: true,
                onTap: () => Navigator.of(context).pop(
                  const ModeSelection(mode: QuizMode.write, isTest: true),
                ),
              ),
            ],
          ),
          const FlesselGap.l(),
          FlesselTextButton(
            label: l10n.cancel,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    ),
  );
}

/// Shows question count selection bottom sheet.
/// [totalCount] — total cards available in the group.
/// Returns selected count or null if dismissed.
///
/// Options shown based on totalCount:
/// - totalCount > 10: "5", "10", "ALL (N)"
/// - totalCount > 5: "5", "ALL (N)"
/// - totalCount <= 5: returns totalCount immediately (no sheet shown)
/// - totalCount <= 0: returns null (invalid)
Future<int?> showLangwijQuestionCountSheet(
  BuildContext context,
  AppLocalizations l10n, {
  required int totalCount,
}) async {
  if (totalCount <= 0) return null;
  if (totalCount <= 5) return totalCount;

  final counts = <int>[];
  final labels = <String>[];

  counts.add(5);
  labels.add(l10n.questions5);

  if (totalCount > 10) {
    counts.add(10);
    labels.add(l10n.questions10);
  }

  counts.add(totalCount);
  labels.add(l10n.questionsAll(totalCount));

  final t = FlesselThemes.of(context);
  final lastIndex = counts.length - 1;

  final icons = <IconData>[
    PhosphorIconsRegular.chartPieSlice,
    if (counts.length > 2) PhosphorIconsRegular.chartPie,
    PhosphorIconsFill.chartPolar,
  ];

  return showFlesselBottomSheet<int>(
    context: context,
    builder: (context) => ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: LangwijLayout.quizSheetMinHeight,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.chooseQuestionsCount.toUpperCase(),
            style: FlesselFonts.contentXlAccent
                .copyWith(color: t.textSecondary),
          ),
          const FlesselGap.l(),
          _CountTileGrid(
            counts: counts,
            labels: labels,
            icons: icons,
            accentIndex: lastIndex,
            onSelect: (value) => Navigator.of(context).pop(value),
          ),
          const FlesselGap.l(),
          FlesselTextButton(
            label: l10n.cancel,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Internal tile data
// ---------------------------------------------------------------------------

class _ModeTileData {
  const _ModeTileData({
    required this.label,
    required this.langCode,
    required this.typeIcon,
    required this.isAccent,
    required this.onTap,
  });

  final String label;
  final String langCode;
  final IconData typeIcon;
  final bool isAccent;
  final VoidCallback onTap;
}

// ---------------------------------------------------------------------------
// Row of two tiles filling available width
// ---------------------------------------------------------------------------

class _ModeTileRow extends StatelessWidget {
  const _ModeTileRow({required this.tiles});

  final List<_ModeTileData> tiles;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth =
            (constraints.maxWidth - FlesselLayout.gapM) / 2;
        return Row(
          children: [
            SizedBox(width: tileWidth, child: _ModeTile(data: tiles[0])),
            const FlesselGap.m(),
            SizedBox(width: tileWidth, child: _ModeTile(data: tiles[1])),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Single mode tile: icon row (flag + type icon) then label
// ---------------------------------------------------------------------------

class _ModeTile extends StatelessWidget {
  const _ModeTile({required this.data});

  final _ModeTileData data;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final fg = data.isAccent ? t.tileAccentForeground : t.textPrimary;
    final countryCode = LangCodes.flagCountryCode(data.langCode);

    return FlesselTile(
      accent: data.isAccent,
      onTap: data.onTap,
      child: Padding(
        padding: const EdgeInsets.all(FlesselLayout.gapM),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (countryCode != null) ...[
                  CountryFlag.fromCountryCode(
                    countryCode,
                    theme: const ImageTheme(
                      width: LangwijLayout.modeTileFlagWidth,
                      height: LangwijLayout.modeTileFlagHeight,
                      shape: RoundedRectangle(
                          LangwijLayout.modeTileFlagBorderRadius),
                    ),
                  ),
                  const FlesselGap.s(),
                ],
                PhosphorIcon(
                  data.typeIcon,
                  size: LangwijLayout.modeTileIconSize,
                  color: fg,
                ),
              ],
            ),
            const FlesselGap.s(),
            Text(
              data.label,
              style: FlesselFonts.contentMAccent.copyWith(color: fg),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Count tile grid: rows of 2, left-aligned
// ---------------------------------------------------------------------------

class _CountTileGrid extends StatelessWidget {
  const _CountTileGrid({
    required this.counts,
    required this.labels,
    required this.icons,
    required this.accentIndex,
    required this.onSelect,
  });

  final List<int> counts;
  final List<String> labels;
  final List<IconData> icons;
  final int accentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth =
            (constraints.maxWidth - FlesselLayout.gapM) / 2;
        final rows = <Widget>[];

        for (var i = 0; i < counts.length; i += 2) {
          final row = <Widget>[
            SizedBox(
              width: tileWidth,
              child: _CountTile(
                label: labels[i],
                icon: icons[i],
                isAccent: i == accentIndex,
                onTap: () => onSelect(counts[i]),
              ),
            ),
          ];
          if (i + 1 < counts.length) {
            row.add(const FlesselGap.m());
            row.add(
              SizedBox(
                width: tileWidth,
                child: _CountTile(
                  label: labels[i + 1],
                  icon: icons[i + 1],
                  isAccent: (i + 1) == accentIndex,
                  onTap: () => onSelect(counts[i + 1]),
                ),
              ),
            );
          }
          if (rows.isNotEmpty) rows.add(const FlesselGap.m());
          rows.add(Row(children: row));
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Single count tile: icon then label
// ---------------------------------------------------------------------------

class _CountTile extends StatelessWidget {
  const _CountTile({
    required this.label,
    required this.icon,
    required this.isAccent,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isAccent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final fg = isAccent ? t.tileAccentForeground : t.textPrimary;

    return FlesselTile(
      accent: isAccent,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(FlesselLayout.gapM),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhosphorIcon(
              icon,
              size: LangwijLayout.modeTileIconSize,
              color: fg,
            ),
            const FlesselGap.s(),
            Text(
              label,
              style: FlesselFonts.contentMAccent.copyWith(color: fg),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

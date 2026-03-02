import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../app/layout/vessel_layout.dart';
import '../../../app/theme/vessel_themes.dart';
import '../../../entities/language/lang_codes.dart';
import '../../../features/quiz/quiz_mode.dart';
import '../../../l10n/app_localizations.dart';
import '../buttons/vessel_buttons.dart';
import '../gap/vessel_gap.dart';
import 'vessel_bottom_sheet.dart';

/// Result of mode selection: the quiz mode and whether it's a test.
class ModeSelection {
  const ModeSelection({required this.mode, required this.isTest});

  final QuizMode mode;
  final bool isTest;
}

/// Shows mode selection bottom sheet with GUESSING and WRITING sections.
///
/// [showAllModes] — if true, shows both sections; if false, shows only WRITING.
/// [targetLangCode] — language code for the target (learning) language. Used
/// for flag display on target guessing tile and both writing tiles.
/// [nativeLangCode] — language code for the native language. Used for flag
/// on native guessing tile. Ignored when [showAllModes] is false.
/// [nativeLangName] / [targetLangName] — resolved display names for
/// guessing tile labels. Ignored when [showAllModes] is false.
///
/// Returns [ModeSelection] or null if dismissed.
Future<ModeSelection?> showModeBottomSheet(
  BuildContext context,
  AppLocalizations l10n, {
  bool showAllModes = true,
  required String targetLangCode,
  String nativeLangCode = '',
  String nativeLangName = '',
  String targetLangName = '',
}) {
  final t = VesselThemes.of(context);
  return showVesselBottomSheet<ModeSelection>(
    context: context,
    builder: (context) => ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: VesselLayout.modeSheetMinHeight,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // GUESSING section
          if (showAllModes) ...[
          Text(
            l10n.mode_guessingHeader.toUpperCase(),
            style: VesselFonts.textModeTileSectionHeader
                .copyWith(color: t.textSecondary),
          ),
          const VesselGap.s(),
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
          const VesselGap.l(),
        ],
        // WRITING section
        Text(
          l10n.mode_writingHeader.toUpperCase(),
          style: VesselFonts.textModeTileSectionHeader
              .copyWith(color: t.textSecondary),
        ),
        const VesselGap.s(),
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
        const VesselGap.l(),
        // Cancel
        VesselTextButton(
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
            (constraints.maxWidth - VesselLayout.modeTileGap) / 2;
        return Row(
          children: [
            _ModeTile(data: tiles[0], width: tileWidth),
            const SizedBox(width: VesselLayout.modeTileGap),
            _ModeTile(data: tiles[1], width: tileWidth),
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
  const _ModeTile({required this.data, required this.width});

  final _ModeTileData data;
  final double width;

  @override
  Widget build(BuildContext context) {
    final t = VesselThemes.of(context);

    final bg =
        data.isAccent ? t.modeTileAccentBackground : t.modeTileBackground;
    final fg =
        data.isAccent ? t.modeTileAccentForeground : t.modeTileForeground;
    final border =
        data.isAccent ? t.modeTileAccentBorderColor : t.modeTileBorderColor;

    final countryCode = LangCodes.flagCountryCode(data.langCode);

    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(VesselLayout.gapM),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(t.tileBorderRadius),
          border: Border.all(color: border, width: t.tileBorderWidth),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon row: flag + type icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (countryCode != null) ...[
                  CountryFlag.fromCountryCode(
                    countryCode,
                    theme: ImageTheme(
                      width: VesselLayout.modeTileFlagWidth,
                      height: VesselLayout.modeTileFlagHeight,
                      shape: RoundedRectangle(
                          VesselLayout.modeTileFlagBorderRadius),
                    ),
                  ),
                  const VesselGap.hs(),
                ],
                PhosphorIcon(
                  data.typeIcon,
                  size: VesselLayout.modeTileIconSize,
                  color: fg,
                ),
              ],
            ),
            const VesselGap.s(),
            // Label
            Text(
              data.label,
              style: VesselFonts.textModeTileLabel.copyWith(color: fg),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
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

  final t = VesselThemes.of(context);
  // Last item (ALL) is always accent
  final lastIndex = counts.length - 1;

  // Icons: partial amounts get pie slice/pie, ALL gets filled crosshair
  final icons = <IconData>[
    PhosphorIconsRegular.chartPieSlice,
    if (counts.length > 2) PhosphorIconsRegular.chartPie,
    PhosphorIconsFill.chartPolar,
  ];

  return showVesselBottomSheet<int>(
    context: context,
    builder: (context) => ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: VesselLayout.modeSheetMinHeight,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.chooseQuestionsCount.toUpperCase(),
            style: VesselFonts.textModeTileSectionHeader.copyWith(color: t.textSecondary),
          ),
          const VesselGap.l(),
          _CountTileGrid(
            counts: counts,
            labels: labels,
            icons: icons,
            accentIndex: lastIndex,
            onSelect: (value) => Navigator.of(context).pop(value),
          ),
          const VesselGap.l(),
          VesselTextButton(
            label: l10n.cancel,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    ),
  );
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
            (constraints.maxWidth - VesselLayout.modeTileGap) / 2;
        final rows = <Widget>[];

        for (var i = 0; i < counts.length; i += 2) {
          final row = <Widget>[
            _CountTile(
              label: labels[i],
              icon: icons[i],
              isAccent: i == accentIndex,
              width: tileWidth,
              onTap: () => onSelect(counts[i]),
            ),
          ];
          if (i + 1 < counts.length) {
            row.add(const SizedBox(width: VesselLayout.modeTileGap));
            row.add(
              _CountTile(
                label: labels[i + 1],
                icon: icons[i + 1],
                isAccent: (i + 1) == accentIndex,
                width: tileWidth,
                onTap: () => onSelect(counts[i + 1]),
              ),
            );
          }
          if (rows.isNotEmpty) rows.add(const VesselGap.m());
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
// Single count tile: label only, mode tile styling
// ---------------------------------------------------------------------------

class _CountTile extends StatelessWidget {
  const _CountTile({
    required this.label,
    required this.icon,
    required this.isAccent,
    required this.width,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isAccent;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = VesselThemes.of(context);

    final bg = isAccent ? t.modeTileAccentBackground : t.modeTileBackground;
    final fg = isAccent ? t.modeTileAccentForeground : t.modeTileForeground;
    final border =
        isAccent ? t.modeTileAccentBorderColor : t.modeTileBorderColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(VesselLayout.gapM),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(t.tileBorderRadius),
          border: Border.all(color: border, width: t.tileBorderWidth),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhosphorIcon(
              icon,
              size: VesselLayout.modeTileIconSize,
              color: fg,
            ),
            const VesselGap.s(),
            Text(
              label,
              style: VesselFonts.textModeTileLabel.copyWith(color: fg),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

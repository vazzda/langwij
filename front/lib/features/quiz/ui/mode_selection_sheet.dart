import 'package:flessel/flessel.dart';
import 'package:flutter/material.dart';

import 'package:langwij/shared/app/config/config.dart';
import 'package:langwij/entities/progress/progress.dart';
import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/shared/app/layout/layout.dart';
import 'package:langwij/shared/flag/ui/flag.dart';
import '../model/mode_selection.dart';

/// [summaryBuilder] builds the description of what is about to be trained;
/// it stands above the modes. It is handed the action that starts a test,
/// or null when [enableTest] is false, and shows the test button itself.
/// [nativeLangName] and [targetLangName] are read by nothing since
/// the guessing tiles lost their label; they stay while the tiles of flags
/// alone are on trial.
Future<ModeSelection?> showLangwijModeSelectionSheet(
  BuildContext context,
  AppLocalizations l10n, {
  bool showAllModes = true,
  bool enableTest = true,
  required String targetLangCode,
  String nativeLangCode = '',
  String nativeLangName = '',
  String targetLangName = '',
  Widget Function(VoidCallback? onTestTap)? summaryBuilder,
}) {
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
          if (summaryBuilder != null) ...[
            summaryBuilder(
              enableTest
                  ? () => Navigator.of(context).pop(
                        const ModeSelection(
                            mode: QuizMode.write, isTest: true),
                      )
                  : null,
            ),
            const FlesselGap.l(),
          ],
          _ModeSectionTitle(text: l10n.mode_training),
          const FlesselGap.s(),
          _ModeTileRow(
            tiles: [
              if (showAllModes) ...[
                _ModeTileData(
                  title: l10n.mode_guessingHeader,
                  icon: PhosphorIconsRegular.cards,
                  parts: [
                    _ModeTileFlag(targetLangCode),
                    const _ModeTileArrowToAnswer(),
                    _ModeTileFlag(nativeLangCode),
                  ],
                  onTap: () => Navigator.of(context).pop(
                    const ModeSelection(
                        mode: QuizMode.targetShown, isTest: false),
                  ),
                ),
                _ModeTileData(
                  title: l10n.mode_guessingHeader,
                  icon: PhosphorIconsRegular.cards,
                  parts: [
                    _ModeTileFlag(nativeLangCode),
                    const _ModeTileArrowToAnswer(),
                    _ModeTileFlag(targetLangCode),
                  ],
                  onTap: () => Navigator.of(context).pop(
                    const ModeSelection(
                        mode: QuizMode.nativeShown, isTest: false),
                  ),
                ),
              ],
              _ModeTileData(
                title: l10n.mode_writingHeader,
                icon: PhosphorIconsRegular.pencilSimpleLine,
                parts: [
                  _ModeTileFlag(nativeLangCode),
                  const _ModeTileArrowToAnswer(),
                  _ModeTileFlag(targetLangCode),
                ],
                onTap: () => Navigator.of(context).pop(
                  const ModeSelection(mode: QuizMode.write, isTest: false),
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

Future<int?> showLangwijQuestionCountSheet(
  BuildContext context,
  AppLocalizations l10n, {
  required int totalCount,
  bool showAll = true,
}) async {
  if (totalCount <= 0) return null;
  if (totalCount <= 5 && showAll) return totalCount;

  final counts = <int>[];
  final labels = <String>[];
  final icons = <IconData>[];

  counts.add(5);
  labels.add(l10n.questions5);
  icons.add(PhosphorIconsRegular.chartPieSlice);

  if (totalCount > 10) {
    counts.add(10);
    labels.add(l10n.questions10);
    icons.add(PhosphorIconsRegular.chartPie);
  }

  if (totalCount > 20) {
    counts.add(20);
    labels.add(l10n.questions20);
    icons.add(PhosphorIconsFill.chartPie);
  }

  if (showAll) {
    counts.add(totalCount);
    labels.add(l10n.questionsAll(totalCount));
    icons.add(PhosphorIconsFill.chartPolar);
  }

  final t = FlesselThemes.of(context);
  final lastIndex = counts.length - 1;

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
                .copyWith(color: t.fgSecondary),
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

/// The title of the section of modes, in the font and colour of a level
/// name in the vocabulary list.
class _ModeSectionTitle extends StatelessWidget {
  const _ModeSectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);

    return Text(text, style: FlesselFonts.displayXl.copyWith(color: t.fg));
  }
}

/// One of the parts a mode tile shows under its title.
sealed class _ModeTilePart {
  const _ModeTilePart();
}

/// The flag of a language. A language that has no flag shows nothing.
final class _ModeTileFlag extends _ModeTilePart {
  const _ModeTileFlag(this.langCode);

  final String langCode;
}

/// The arrow from the flag of the cards down to the flag of the answers.
final class _ModeTileArrowToAnswer extends _ModeTilePart {
  const _ModeTileArrowToAnswer();
}

class _ModeTileData {
  const _ModeTileData({
    required this.icon,
    required this.title,
    required this.parts,
    required this.onTap,
  });

  /// The icon above the title.
  final IconData icon;

  final String title;

  /// What the tile shows under its title, from top to bottom.
  final List<_ModeTilePart> parts;

  final VoidCallback onTap;
}

/// A row of mode tiles. Each tile is as wide as one of three tiles sharing
/// the row with gaps between them, and all are as tall as the tallest.
class _ModeTileRow extends StatelessWidget {
  const _ModeTileRow({required this.tiles});

  static const int _tileCountSharingRowWidth = 3;

  final List<_ModeTileData> tiles;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final widthOfGapsBetweenTiles =
            FlesselLayout.gapM * (_tileCountSharingRowWidth - 1);
        final tileWidth = (constraints.maxWidth - widthOfGapsBetweenTiles) /
            _tileCountSharingRowWidth;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var tileIndex = 0;
                  tileIndex < tiles.length;
                  tileIndex++) ...[
                if (tileIndex > 0) const FlesselGap.m(),
                SizedBox(
                  width: tileWidth,
                  child: _ModeTile(data: tiles[tileIndex]),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({required this.data});

  /// Every mode tile stands on the promo surface in its success variant.
  static const FlesselSurface _surface = FlesselSurface.s21;
  static const FlesselVariant _variant = FlesselVariant.success;

  static const FlesselSize _paddingAroundContent = FlesselSize.s;
  static const double _arrowToAnswerSize = FlesselLayout.iconL;

  /// The icon is as high as a flag, so the rows of a tile keep one rhythm.
  static const double _iconSize = LangwijLayout.modeTileFlagHeight;

  final _ModeTileData data;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final fg = t.surfaceOf(_surface).resolve(_variant).fg;

    // The library's tile stands on the tile surface only, so a mode tile is
    // drawn as a card on its own surface.
    return FlesselCard(
      surface: _surface,
      colorVariant: _variant,
      padding: _paddingAroundContent,
      margin: FlesselSize.none,
      onTap: data.onTap,
      child: _buildIconAndTitleAboveParts(fg),
    );
  }

  /// The icon, the title under it, then the parts from top to bottom: a
  /// gap under the title and a smaller one between the other neighbours.
  /// A part that shows nothing is left out.
  Widget _buildIconAndTitleAboveParts(Color fg) {
    final shownParts = [
      for (final part in data.parts)
        if (_buildPartOrNull(part, fg) case final shownPart?) shownPart,
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PhosphorIcon(data.icon, size: _iconSize, color: fg),
        const FlesselGap.xs(),
        Text(
          data.title,
          style: FlesselFonts.contentMAccent.copyWith(color: fg),
          textAlign: TextAlign.center,
        ),
        for (var partIndex = 0; partIndex < shownParts.length; partIndex++) ...[
          if (partIndex == 0) const FlesselGap.s() else const FlesselGap.xs(),
          shownParts[partIndex],
        ],
      ],
    );
  }

  /// Null for the flag of a language that has none.
  Widget? _buildPartOrNull(_ModeTilePart part, Color fg) {
    return switch (part) {
      _ModeTileFlag(:final langCode) =>
        switch (LangCodes.flagCountryCode(langCode)) {
          final countryCode? => LangwijFlag(
              countryCode: countryCode,
              size: LangwijFlagSize.medium,
            ),
          null => null,
        },
      _ModeTileArrowToAnswer() => PhosphorIcon(
          PhosphorIconsRegular.arrowDown,
          size: _arrowToAnswerSize,
          color: fg,
        ),
    };
  }
}

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
    final fg = isAccent ? t.surface02.accent.fg : t.fg;

    return FlesselTile(
      variant: isAccent ? FlesselVariant.accent : FlesselVariant.regular,
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

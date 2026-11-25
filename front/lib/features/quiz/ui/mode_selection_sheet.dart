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
          _OptionTileGrid(
            tiles: [
              if (showAllModes) ...[
                _OptionTileData(
                  title: l10n.mode_guessingHeader,
                  icon: PhosphorIconsRegular.cards,
                  parts: [
                    _OptionTileFlag(targetLangCode),
                    const _OptionTileArrowToAnswer(),
                    _OptionTileFlag(nativeLangCode),
                  ],
                  onTap: () => Navigator.of(context).pop(
                    const ModeSelection(
                        mode: QuizMode.targetShown, isTest: false),
                  ),
                ),
                _OptionTileData(
                  title: l10n.mode_guessingHeader,
                  icon: PhosphorIconsRegular.cards,
                  parts: [
                    _OptionTileFlag(nativeLangCode),
                    const _OptionTileArrowToAnswer(),
                    _OptionTileFlag(targetLangCode),
                  ],
                  onTap: () => Navigator.of(context).pop(
                    const ModeSelection(
                        mode: QuizMode.nativeShown, isTest: false),
                  ),
                ),
              ],
              _OptionTileData(
                title: l10n.mode_writingHeader,
                icon: PhosphorIconsRegular.pencilSimpleLine,
                parts: [
                  _OptionTileFlag(nativeLangCode),
                  const _OptionTileArrowToAnswer(),
                  _OptionTileFlag(targetLangCode),
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

  return showFlesselBottomSheet<int>(
    context: context,
    title: l10n.chooseQuestionsCount,
    builder: (context) => ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: LangwijLayout.quizSheetMinHeight,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _OptionTileGrid(
            tiles: [
              for (var index = 0; index < counts.length; index++)
                _OptionTileData(
                  icon: icons[index],
                  title: labels[index],
                  parts: const [],
                  onTap: () => Navigator.of(context).pop(counts[index]),
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

/// One of the parts an option tile shows under its title.
sealed class _OptionTilePart {
  const _OptionTilePart();
}

/// The flag of a language. A language that has no flag shows nothing.
final class _OptionTileFlag extends _OptionTilePart {
  const _OptionTileFlag(this.langCode);

  final String langCode;
}

/// The arrow from the flag of the cards down to the flag of the answers.
final class _OptionTileArrowToAnswer extends _OptionTilePart {
  const _OptionTileArrowToAnswer();
}

/// One option of a quiz sheet: a mode of the mode sheet, or a count of the
/// question-count sheet.
class _OptionTileData {
  const _OptionTileData({
    required this.icon,
    required this.title,
    required this.parts,
    required this.onTap,
  });

  /// The icon above the title.
  final IconData icon;

  final String title;

  /// What the tile shows under its title, from top to bottom; nothing for
  /// a tile of icon and title alone.
  final List<_OptionTilePart> parts;

  final VoidCallback onTap;
}

/// A grid of option tiles, three to a row. Each tile is as wide as one of
/// three tiles sharing a row with gaps between them, so a row of fewer
/// tiles keeps them at that width from its start. The tiles of one row are
/// as tall as the tallest of them.
class _OptionTileGrid extends StatelessWidget {
  const _OptionTileGrid({required this.tiles});

  static const int _tileCountInRow = 3;

  final List<_OptionTileData> tiles;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final widthOfGapsBetweenTiles =
            FlesselLayout.gapM * (_tileCountInRow - 1);
        final tileWidth = (constraints.maxWidth - widthOfGapsBetweenTiles) /
            _tileCountInRow;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var rowStart = 0;
                rowStart < tiles.length;
                rowStart += _tileCountInRow) ...[
              if (rowStart > 0) const FlesselGap.m(),
              _buildRow(
                tiles.skip(rowStart).take(_tileCountInRow).toList(),
                tileWidth,
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildRow(List<_OptionTileData> tilesOfRow, double tileWidth) {
    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var tileIndex = 0;
              tileIndex < tilesOfRow.length;
              tileIndex++) ...[
            if (tileIndex > 0) const FlesselGap.m(),
            SizedBox(
              width: tileWidth,
              child: _OptionTile(data: tilesOfRow[tileIndex]),
            ),
          ],
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.data});

  /// Every option tile stands on the promo surface in its success variant.
  static const FlesselSurface _surface = FlesselSurface.s21;
  static const FlesselVariant _variant = FlesselVariant.success;

  static const FlesselSize _paddingAroundContent = FlesselSize.s;
  static const double _arrowToAnswerSize = FlesselLayout.iconL;

  /// The icon is as high as a flag, so the rows of a tile keep one rhythm.
  static const double _iconSize = LangwijLayout.modeTileFlagHeight;

  final _OptionTileData data;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final fg = t.surfaceOf(_surface).resolve(_variant).fg;

    // The library's tile stands on the tile surface only, so an option tile
    // is drawn as a card on its own surface.
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
  Widget? _buildPartOrNull(_OptionTilePart part, Color fg) {
    return switch (part) {
      _OptionTileFlag(:final langCode) =>
        switch (LangCodes.flagCountryCode(langCode)) {
          final countryCode? => LangwijFlag(
              countryCode: countryCode,
              size: LangwijFlagSize.medium,
            ),
          null => null,
        },
      _OptionTileArrowToAnswer() => PhosphorIcon(
          PhosphorIconsRegular.arrowDown,
          size: _arrowToAnswerSize,
          color: fg,
        ),
    };
  }
}

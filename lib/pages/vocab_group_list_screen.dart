import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../app/providers/app_settings_provider.dart';
import '../app/providers/dictionary_provider.dart';
import '../app/providers/group_progress_provider.dart';
import '../app/providers/groups_provider.dart';
import '../app/providers/plan_provider.dart';
import '../app/router/app_router.dart';
import '../app/theme/app_themes.dart';
import '../entities/group/vocab_group_model.dart';
import '../entities/language/dictionary.dart';
import '../entities/language/language_pack.dart';
import '../entities/level/level.dart';
import '../entities/plan/level_tier.dart';
import '../features/quiz/session_notifier.dart';
import '../shared/repositories/models/group_progress.dart';
import '../shared/repositories/models/retention_level.dart';
import '../app/providers/daily_activity_provider.dart';
import '../shared/repositories/daily_activity_repository.dart';
import '../shared/ui/bottom_sheet/quiz_bottom_sheets.dart';
import '../shared/ui/buttons/project_buttons.dart';
import '../shared/ui/card/project_card.dart';
import '../shared/ui/progress_bar/project_progress_bar.dart';
import '../shared/ui/tile/project_tile.dart';
import '../shared/ui/screen_layout/screen_layout_widget.dart';
import 'package:srpski_card/shared/lib/progress_calculator.dart';
import 'group_list_screen.dart'
    show retentionColor, retentionLabel, formatRelativeDate;

// ---------------------------------------------------------------------------
// Layout constants — all numeric dimensions in one place for easy finetuning
// ---------------------------------------------------------------------------

abstract class _Layout {
  // Screen list
  static const double listPadding = 16.0;
  static const double dailyCardBottomGap = 12.0;
  static const double levelCardBottomGap = 16.0;

  // Daily activity card
  static const double dailyCardTitleGap = 4.0;

  // Level card internal spacing
  static const double levelCardPadding = 16.0;
  static const double headerToProgressGap = 8.0;
  static const double progressSpacingAfter = 12.0;
  static const double descSpacingAfter = 8.0;
  static const double tilesToStatsGap = 12.0;

  // Tile content — Positioned offsets
  static const double tileNameTop = 8.0;
  static const double tileNameLeft = 8.0;
  static const double tileNameRight = 8.0;
  static const double tileCountTop = 54.0;
  static const double tileCountLeft = 8.0;
  static const double tileCountRight = 8.0;
  static const double tilePctBottom = 8.0;
  static const double tilePctRight = 8.0;

  // Stats row chips
  static const double chipPaddingH = 6.0;
  static const double chipPaddingV = 4.0;
  static const double chipSpacing = 4.0;
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class VocabGroupListScreen extends ConsumerStatefulWidget {
  const VocabGroupListScreen({super.key});

  @override
  ConsumerState<VocabGroupListScreen> createState() =>
      _VocabGroupListScreenState();
}

class _VocabGroupListScreenState extends ConsumerState<VocabGroupListScreen> {
  final _scrollController = ScrollController();
  double? _pendingScrollOffset;
  bool _scrollRestored = false;

  @override
  void initState() {
    super.initState();
    _pendingScrollOffset = ref.read(scrollOffsetToRestoreProvider);
    if (_pendingScrollOffset != null) {
      Future(() {
        if (mounted) {
          ref.read(scrollOffsetToRestoreProvider.notifier).state = null;
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _restoreScrollPosition() {
    if (_pendingScrollOffset == null || _scrollRestored) return;
    _scrollRestored = true;
    final offset = _pendingScrollOffset!;
    _pendingScrollOffset = null;
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      _scrollController.jumpTo(offset.clamp(0.0, maxScroll));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final asyncDict = ref.watch(dictionaryProvider);
    final asyncTarget = ref.watch(targetPackProvider);
    final asyncNative = ref.watch(nativePackProvider);
    final allProgress = ref.watch(groupProgressProvider);
    final settings = ref.watch(appSettingsProvider);
    final asyncStats = ref.watch(dailyActivityProvider);
    final levelTiers = ref.watch(levelTiersProvider).valueOrNull ?? {};

    if (asyncDict.hasValue &&
        _pendingScrollOffset != null &&
        !_scrollRestored) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _restoreScrollPosition();
      });
    }

    final dictionary = asyncDict.valueOrNull;
    final targetPack = asyncTarget.valueOrNull;
    final nativePack = asyncNative.valueOrNull;

    if (dictionary == null || targetPack == null || nativePack == null) {
      final hasError =
          asyncDict.hasError || asyncTarget.hasError || asyncNative.hasError;
      return ScreenLayoutWidget(
        title: l10n.navVocabulary,
        showBottomNav: true,
        child: Center(
          child: hasError
              ? Text(l10n.loadError)
              : const CircularProgressIndicator(),
        ),
      );
    }

    final levels = _buildLevels(
      dictionary: dictionary,
      nativePack: nativePack,
      targetPack: targetPack,
      allProgress: allProgress,
      levelTiers: levelTiers,
      settings: settings,
    );

    return ScreenLayoutWidget(
      title: l10n.navVocabulary,
      showBottomNav: true,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(_Layout.listPadding),
        itemCount: levels.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(
                bottom: _Layout.dailyCardBottomGap,
              ),
              child: _DailyActivityCard(asyncStats: asyncStats, l10n: l10n),
            );
          }
          final level = levels[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: _Layout.levelCardBottomGap),
            child: _LevelCard(
              item: level,
              l10n: l10n,
              onGroupTap: (group, cardCount) => _onGroupTap(
                context,
                group,
                dictionary,
                targetPack,
                nativePack,
                cardCount,
                l10n,
              ),
            ),
          );
        },
      ),
    );
  }

  List<_LevelData> _buildLevels({
    required Dictionary dictionary,
    required LanguagePack nativePack,
    required LanguagePack targetPack,
    required Map<String, GroupProgress> allProgress,
    required Map<String, LevelTier> levelTiers,
    required dynamic settings,
  }) {
    final groupsById = dictionary.groupsById;
    final result = <_LevelData>[];

    for (final level in dictionary.levels) {
      final tier = levelTiers[level.id] ?? LevelTier.premium;
      final levelName = nativePack.levelMeta[level.id]?.name ?? level.id;
      final levelDesc = nativePack.levelMeta[level.id]?.description;

      final groups = <_GroupTileData>[];
      for (final groupId in level.groupIds) {
        final group = groupsById[groupId];
        if (group == null) continue;

        final cardCount = _countCards(group, targetPack, nativePack);
        final progress = allProgress[groupId];
        final groupName = nativePack.groupMeta[groupId]?.name ?? group.id;
        final retention = progress != null
            ? ProgressCalculator.calculateRetention(
                progress,
                settings.decayFormula,
              )
            : 0.0;
        final percentage =
            progress != null && progress.recentSessions.isNotEmpty
            ? progress.totalProgress.round()
            : null;

        groups.add(
          _GroupTileData(
            group: group,
            name: groupName,
            cardCount: cardCount,
            percentage: percentage,
            progress: progress,
            retention: retention,
          ),
        );
      }

      final levelProgress = _computeLevelProgress(groups);
      final latestDate = _computeLatestDate(groups);
      final strengthLevel = _computeStrengthLevel(
        groups,
        levelProgress,
        settings,
      );

      result.add(
        _LevelData(
          level: level,
          name: levelName,
          description: levelDesc,
          tier: tier,
          levelProgress: levelProgress,
          groups: groups,
          latestDate: latestDate,
          strengthLevel: strengthLevel,
        ),
      );
    }

    return result;
  }

  double _computeLevelProgress(List<_GroupTileData> groups) {
    if (groups.isEmpty) return 0.0;
    final total = groups.fold(
      0.0,
      (sum, g) => sum + (g.progress?.totalProgress ?? 0.0),
    );
    return total / groups.length;
  }

  DateTime? _computeLatestDate(List<_GroupTileData> groups) {
    DateTime? latest;
    for (final g in groups) {
      final d = g.progress?.lastSessionDate;
      if (d != null && (latest == null || d.isAfter(latest))) {
        latest = d;
      }
    }
    return latest;
  }

  RetentionLevel _computeStrengthLevel(
    List<_GroupTileData> groups,
    double levelProgress,
    dynamic settings,
  ) {
    final withSessions = groups
        .where(
          (g) => g.progress != null && g.progress!.recentSessions.isNotEmpty,
        )
        .toList();
    if (withSessions.isEmpty) return RetentionLevel.none;
    final avgRetention =
        withSessions.map((g) => g.retention).reduce((a, b) => a + b) /
        withSessions.length;
    return ProgressCalculator.getRetentionLevel(avgRetention, levelProgress);
  }

  int _countCards(
    VocabGroupModel group,
    LanguagePack target,
    LanguagePack native,
  ) {
    int count = 0;
    for (final cid in group.conceptIds) {
      if (target.translations.containsKey(cid) &&
          native.translations.containsKey(cid)) {
        count++;
      }
    }
    return count;
  }

  Future<void> _onGroupTap(
    BuildContext context,
    VocabGroupModel group,
    Dictionary dictionary,
    LanguagePack targetPack,
    LanguagePack nativePack,
    int cardCount,
    AppLocalizations l10n,
  ) async {
    if (cardCount <= 0) return;

    final selection = await showModeBottomSheet(context, l10n);
    if (selection == null || !context.mounted) return;

    final selectedCount = await showCountBottomSheet(
      context,
      l10n,
      totalCount: cardCount,
    );
    if (selectedCount == null || !context.mounted) return;

    final scrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;

    ref
        .read(sessionProvider.notifier)
        .startVocab(
          group: group,
          targetPack: targetPack,
          nativePack: nativePack,
          mode: selection.mode,
          questionCount: selectedCount,
          originRoute: AppRoutes.home,
          originScrollOffset: scrollOffset,
        );
    if (context.mounted) context.go(AppRoutes.session);
  }
}

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

class _GroupTileData {
  _GroupTileData({
    required this.group,
    required this.name,
    required this.cardCount,
    required this.retention,
    this.percentage,
    this.progress,
  });

  final VocabGroupModel group;
  final String name;
  final int cardCount;
  final int? percentage; // null = no sessions yet
  final GroupProgress? progress;
  final double retention;
}

class _LevelData {
  _LevelData({
    required this.level,
    required this.name,
    required this.tier,
    required this.levelProgress,
    required this.groups,
    required this.strengthLevel,
    this.description,
    this.latestDate,
  });

  final Level level;
  final String name;
  final String? description;
  final LevelTier tier;
  final double levelProgress; // 0–100
  final List<_GroupTileData> groups;
  final DateTime? latestDate;
  final RetentionLevel strengthLevel;
}

// ---------------------------------------------------------------------------
// Level card
// ---------------------------------------------------------------------------

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.item,
    required this.l10n,
    required this.onGroupTap,
  });

  final _LevelData item;
  final AppLocalizations l10n;
  final void Function(VocabGroupModel group, int cardCount) onGroupTap;

  @override
  Widget build(BuildContext context) {
    final t = AppThemes.of(context);
    final isPremium = item.tier == LevelTier.premium;

    return ProjectCard(
      padding: const EdgeInsets.all(_Layout.levelCardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: AppFontStyles.textContentHeader.copyWith(
                    color: t.textPrimary,
                  ),
                ),
              ),
              if (isPremium)
                Icon(Icons.lock_outline, size: 16, color: t.textSecondary),
            ],
          ),
          const SizedBox(height: _Layout.headerToProgressGap),
          // Progress bar
          ProjectProgressBar(
            value: (item.levelProgress / 100.0).clamp(0.0, 1.0),
          ),
          const SizedBox(height: _Layout.progressSpacingAfter),
          // Optional description
          if (item.description != null) ...[
            Text(
              item.description!,
              style: AppFontStyles.textCaption.copyWith(color: t.textSecondary),
            ),
            const SizedBox(height: _Layout.descSpacingAfter),
          ],
          // Group tiles
          LayoutBuilder(
            builder: (context, constraints) {
              final t = AppThemes.of(context);
              final n =
                  ((constraints.maxWidth + t.tileGap) /
                          (t.tileMinWidth + t.tileGap))
                      .floor()
                      .clamp(1, 100);
              final tileWidth =
                  (constraints.maxWidth - t.tileGap * (n - 1)) / n;
              return Wrap(
                spacing: t.tileGap,
                runSpacing: t.tileGap,
                children: item.groups
                    .map(
                      (g) => _GroupTile(
                        item: g,
                        l10n: l10n,
                        width: tileWidth,
                        onTap: () => onGroupTap(g.group, g.cardCount),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: _Layout.tilesToStatsGap),
          // Level stats row
          _LevelStatsRow(item: item, l10n: l10n),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Group tile
// ---------------------------------------------------------------------------

class _GroupTile extends StatelessWidget {
  const _GroupTile({
    required this.item,
    required this.l10n,
    required this.width,
    required this.onTap,
  });

  final _GroupTileData item;
  final AppLocalizations l10n;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppThemes.of(context);

    return SizedBox(
      width: width,
      height: t.tileHeight,
      child: ProjectTile(
        onTap: item.cardCount > 0 ? onTap : null,
        child: Stack(
          children: [
            Positioned(
              top: _Layout.tileNameTop,
              left: _Layout.tileNameLeft,
              right: _Layout.tileNameRight,
              child: Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    AppFontStyles.textCaption.copyWith(color: t.tileForeground),
              ),
            ),
            Positioned(
              top: _Layout.tileCountTop,
              left: _Layout.tileCountLeft,
              right: _Layout.tileCountRight,
              child: Text(
                l10n.wordsCount(item.cardCount),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    AppFontStyles.textCaption.copyWith(color: t.tileForeground),
              ),
            ),
            if (item.percentage != null)
              Positioned(
                bottom: _Layout.tilePctBottom,
                right: _Layout.tilePctRight,
                child: Text(
                  '${item.percentage}%',
                  style: AppFontStyles.textProgressChip
                      .copyWith(color: t.tileForeground),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Level stats row
// ---------------------------------------------------------------------------

class _LevelStatsRow extends StatelessWidget {
  const _LevelStatsRow({required this.item, required this.l10n});

  final _LevelData item;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final t = AppThemes.of(context);
    final dateText = item.latestDate != null
        ? formatRelativeDate(item.latestDate!, l10n)
        : '-';
    final levelColor = retentionColor(item.strengthLevel, t);
    final levelLabel = retentionLabel(item.strengthLevel, l10n);

    const chipPadding = EdgeInsets.symmetric(
      horizontal: _Layout.chipPaddingH,
      vertical: _Layout.chipPaddingV,
    );
    final outlineChipStyle = AppFontStyles.textProgressChip.copyWith(
      color: t.textPrimary,
    );
    final filledChipStyle = AppFontStyles.textProgressChip.copyWith(
      color: t.retentionText,
    );

    return Row(
      children: [
        Container(
          padding: chipPadding,
          decoration: BoxDecoration(
            color: t.cardBackground,
            border: Border.all(color: t.textPrimary, width: t.cardBorderWidth),
            borderRadius: BorderRadius.circular(t.badgeBorderRadius),
          ),
          child: Text(dateText, style: outlineChipStyle),
        ),
        const SizedBox(width: _Layout.chipSpacing),
        Container(
          padding: chipPadding,
          decoration: BoxDecoration(
            color: levelColor,
            border: Border.all(color: t.textPrimary, width: t.cardBorderWidth),
            borderRadius: BorderRadius.circular(t.badgeBorderRadius),
          ),
          child: Text(levelLabel, style: filledChipStyle),
        ),
        const Spacer(),
        AccentButton(
          label: l10n.vocab_train,
          onPressed: null,
          size: ButtonSize.small,
          margin: EdgeInsets.zero,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Daily activity card
// ---------------------------------------------------------------------------

class _DailyActivityCard extends StatelessWidget {
  const _DailyActivityCard({required this.asyncStats, required this.l10n});

  final AsyncValue<DailyActivityStats> asyncStats;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final t = AppThemes.of(context);
    return ProjectCard(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.dailyActivityTitle,
              style: AppFontStyles.textListItem.copyWith(color: t.textPrimary),
            ),
            const SizedBox(height: _Layout.dailyCardTitleGap),
            asyncStats.when(
              data: (stats) {
                final isEmpty =
                    stats.correct == 0 &&
                    stats.wrong == 0 &&
                    stats.wordsTouched == 0;
                return Text(
                  isEmpty
                      ? l10n.dailyActivityEmpty
                      : '${l10n.correctCount(stats.correct)} · ${l10n.wrongCount(stats.wrong)} · ${l10n.wordsCount(stats.wordsTouched)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyles.textCaption.copyWith(
                    color: t.textSecondary,
                  ),
                );
              },
              loading: () => Text(
                l10n.dailyActivityEmpty,
                style: AppFontStyles.textCaption.copyWith(
                  color: t.textSecondary,
                ),
              ),
              // ignore: unnecessary_underscores
              error: (_, __) => Text(
                l10n.dailyActivityEmpty,
                style: AppFontStyles.textCaption.copyWith(
                  color: t.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

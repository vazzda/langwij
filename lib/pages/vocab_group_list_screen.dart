import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../app/providers/app_settings_provider.dart';
import '../app/providers/dictionary_provider.dart';
import '../app/providers/group_progress_provider.dart';
import '../app/providers/groups_provider.dart';
import '../app/providers/level_progress_provider.dart';
import '../app/providers/plan_provider.dart';
import '../app/router/app_router.dart';
import '../app/theme/app_themes.dart';
import '../entities/group/vocab_group_model.dart';
import '../entities/language/dictionary.dart';
import '../entities/language/language_pack.dart';
import '../entities/level/level.dart';
import '../entities/plan/level_tier.dart';
import '../features/quiz/session_notifier.dart';
import 'package:srpski_card/shared/lib/progress_calculator.dart';
import '../shared/repositories/models/group_progress.dart';
import '../app/providers/daily_activity_provider.dart';
import '../shared/repositories/daily_activity_repository.dart';
import '../shared/ui/bottom_sheet/quiz_bottom_sheets.dart';
import '../shared/ui/card/project_card.dart';
import '../shared/ui/progress_bar/project_progress_bar.dart';
import '../shared/ui/screen_layout/screen_layout_widget.dart';
import 'group_list_screen.dart' show retentionColor, retentionLabel, formatRelativeDate;

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

    // Build flat list items: [dailyCard, levelHeader, group, group, ..., levelHeader, ...]
    final items = _buildItems(
      dictionary: dictionary,
      nativePack: nativePack,
      targetPack: targetPack,
      allProgress: allProgress,
      levelTiers: levelTiers,
      l10n: l10n,
      settings: settings,
    );

    return ScreenLayoutWidget(
      title: l10n.navVocabulary,
      showBottomNav: true,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _DailyActivityCard(asyncStats: asyncStats, l10n: l10n),
            );
          }
          final item = items[index - 1];
          return switch (item) {
            _LevelHeaderItem() => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _LevelHeader(
                  item: item,
                  levelProgress:
                      ref.watch(levelProgressProvider(item.level.id)),
                ),
              ),
            _GroupItem() => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _VocabGroupTile(
                  item: item,
                  l10n: l10n,
                  onTap: () => _onGroupTap(
                    context,
                    item.group,
                    dictionary,
                    targetPack,
                    nativePack,
                    item.cardCount,
                    l10n,
                  ),
                ),
              ),
          };
        },
      ),
    );
  }

  List<_ListItem> _buildItems({
    required Dictionary dictionary,
    required LanguagePack nativePack,
    required LanguagePack targetPack,
    required Map<String, GroupProgress> allProgress,
    required Map<String, LevelTier> levelTiers,
    required AppLocalizations l10n,
    required dynamic settings,
  }) {
    final groupsById = dictionary.groupsById;
    final items = <_ListItem>[];

    double getRetention(String groupId) {
      final progress = allProgress[groupId];
      if (progress == null) return 0.0;
      return ProgressCalculator.calculateRetention(
          progress, settings.decayFormula);
    }

    for (final level in dictionary.levels) {
      final tier = levelTiers[level.id] ?? LevelTier.premium;
      final levelName =
          nativePack.levelMeta[level.id]?.name ?? level.id;

      items.add(_LevelHeaderItem(
        level: level,
        name: levelName,
        tier: tier,
      ));

      for (final groupId in level.groupIds) {
        final group = groupsById[groupId];
        if (group == null) continue;

        final cardCount = _countCards(group, targetPack, nativePack);
        final progress = allProgress[groupId];
        final groupName =
            nativePack.groupMeta[groupId]?.name ?? group.id;
        final groupDesc = nativePack.groupMeta[groupId]?.description;

        items.add(_GroupItem(
          group: group,
          cardCount: cardCount,
          progress: progress,
          retention: getRetention(groupId),
          name: groupName,
          description: groupDesc,
        ));
      }
    }

    return items;
  }

  int _countCards(
      VocabGroupModel group, LanguagePack target, LanguagePack native) {
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

    final scrollOffset =
        _scrollController.hasClients ? _scrollController.offset : 0.0;

    ref.read(sessionProvider.notifier).startVocab(
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
// List item types
// ---------------------------------------------------------------------------

sealed class _ListItem {}

class _LevelHeaderItem extends _ListItem {
  _LevelHeaderItem({
    required this.level,
    required this.name,
    required this.tier,
  });

  final Level level;
  final String name;
  final LevelTier tier;
}

class _GroupItem extends _ListItem {
  _GroupItem({
    required this.group,
    required this.cardCount,
    required this.name,
    required this.retention,
    this.progress,
    this.description,
  });

  final VocabGroupModel group;
  final int cardCount;
  final String name;
  final String? description;
  final GroupProgress? progress;
  final double retention;
}

// ---------------------------------------------------------------------------
// Level header widget
// ---------------------------------------------------------------------------

class _LevelHeader extends ConsumerWidget {
  const _LevelHeader({required this.item, required this.levelProgress});

  final _LevelHeaderItem item;
  final double levelProgress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppThemes.of(context);
    final isPremium = item.tier == LevelTier.premium;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: AppFontStyles.textContentHeader
                      .copyWith(color: t.textPrimary),
                ),
              ),
              if (isPremium)
                Icon(Icons.lock_outline, size: 16, color: t.textSecondary),
            ],
          ),
          const SizedBox(height: 6),
          ProjectProgressBar(
            value: (levelProgress / 100.0).clamp(0.0, 1.0),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Group tile widget
// ---------------------------------------------------------------------------

class _VocabGroupTile extends StatelessWidget {
  const _VocabGroupTile({
    required this.item,
    required this.l10n,
    required this.onTap,
  });

  final _GroupItem item;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppThemes.of(context);
    final showBadge =
        item.progress != null && item.progress!.recentSessions.isNotEmpty;

    return ProjectCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.name,
                        style: AppFontStyles.textListItem
                            .copyWith(color: t.textPrimary),
                      ),
                      if (item.description != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppFontStyles.textCaption
                              .copyWith(color: t.textSecondary),
                        ),
                      ],
                      const SizedBox(height: 2),
                      Text(
                        l10n.wordsCount(item.cardCount),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyles.textCaption
                            .copyWith(color: t.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
          if (showBadge)
            Positioned(
              top: 0,
              right: 0,
              child: _ProgressBadge(
                progress: item.progress!,
                retention: item.retention,
                l10n: l10n,
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Progress badge (unchanged)
// ---------------------------------------------------------------------------

class _ProgressBadge extends StatelessWidget {
  const _ProgressBadge({
    required this.progress,
    required this.retention,
    required this.l10n,
  });

  final GroupProgress progress;
  final double retention;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final t = AppThemes.of(context);
    final percentage = progress.totalProgress.round();
    final level = ProgressCalculator.getRetentionLevel(
      retention,
      progress.totalProgress,
    );
    final levelColor = retentionColor(level, t);
    final levelLabel = retentionLabel(level, l10n);
    final dateText = progress.lastSessionDate != null
        ? formatRelativeDate(progress.lastSessionDate!, l10n)
        : '-';

    const chipPadding = EdgeInsets.symmetric(horizontal: 6, vertical: 4);
    final outlinedChipStyle = AppFontStyles.textProgressChip.copyWith(
      color: t.textPrimary,
    );
    final filledChipStyle = AppFontStyles.textProgressChip.copyWith(
      color: t.retentionText,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: chipPadding,
          decoration: BoxDecoration(
            color: t.cardBackground,
            border: Border.all(
              color: t.textPrimary,
              width: t.cardBorderWidth,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
            ),
          ),
          child: Text('$percentage%', style: outlinedChipStyle),
        ),
        const SizedBox(width: 4),
        Container(
          padding: chipPadding,
          decoration: BoxDecoration(
            color: t.cardBackground,
            border: Border.all(
              color: t.textPrimary,
              width: t.cardBorderWidth,
            ),
          ),
          child: Text(dateText, style: outlinedChipStyle),
        ),
        const SizedBox(width: 4),
        Container(
          padding: chipPadding,
          decoration: BoxDecoration(
            color: levelColor,
            border: Border.all(
              color: t.textPrimary,
              width: t.cardBorderWidth,
            ),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(10),
            ),
          ),
          child: Text(levelLabel, style: filledChipStyle),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Daily activity card (unchanged)
// ---------------------------------------------------------------------------

class _DailyActivityCard extends StatelessWidget {
  const _DailyActivityCard({
    required this.asyncStats,
    required this.l10n,
  });

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
            const SizedBox(height: 4),
            asyncStats.when(
              data: (stats) {
                final isEmpty = stats.correct == 0 &&
                    stats.wrong == 0 &&
                    stats.wordsTouched == 0;
                return Text(
                  isEmpty
                      ? l10n.dailyActivityEmpty
                      : '${l10n.correctCount(stats.correct)} · ${l10n.wrongCount(stats.wrong)} · ${l10n.wordsCount(stats.wordsTouched)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      AppFontStyles.textCaption.copyWith(color: t.textSecondary),
                );
              },
              loading: () => Text(
                l10n.dailyActivityEmpty,
                style:
                    AppFontStyles.textCaption.copyWith(color: t.textSecondary),
              ),
              // ignore: unnecessary_underscores
              error: (_, __) => Text(
                l10n.dailyActivityEmpty,
                style:
                    AppFontStyles.textCaption.copyWith(color: t.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

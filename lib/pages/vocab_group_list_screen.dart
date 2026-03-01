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
import '../entities/group/vocab_group_model.dart';
import '../entities/language/dictionary.dart';
import '../entities/language/lang_entry.dart';
import '../entities/language/language_pack.dart';
import '../entities/plan/level_tier.dart';
import '../features/quiz/session_notifier.dart';
import '../features/vocab/services/level_fold_notifier.dart';
import '../features/vocab/widgets/vocab_daily_activity_card.dart';
import '../features/vocab/widgets/vocab_layout.dart';
import '../features/vocab/widgets/vocab_level_card.dart';
import '../features/vocab/widgets/vocab_tile_data.dart';
import '../shared/repositories/models/group_progress.dart';
import '../shared/repositories/models/retention_level.dart';
import '../app/providers/daily_activity_provider.dart';
import '../shared/ui/bottom_sheet/quiz_bottom_sheets.dart';
import '../shared/ui/screen_layout/screen_layout_widget.dart';
import 'package:srpski_card/shared/lib/progress_calculator.dart';

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
    final foldOverrides = ref.watch(levelFoldOverridesProvider);

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

    final firstLevelId = dictionary.levels.first.id;
    final lastLevelId = dictionary.levels.last.id;

    return ScreenLayoutWidget(
      title: l10n.navVocabulary,
      showBottomNav: true,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(VocabLayout.listPadding),
        itemCount: levels.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(
                bottom: VocabLayout.dailyCardBottomGap,
              ),
              child: VocabDailyActivityCard(asyncStats: asyncStats, l10n: l10n),
            );
          }
          final level = levels[index - 1];
          final levelId = level.level.id;
          final isExpanded = _isLevelExpanded(
            levelId: levelId,
            firstLevelId: firstLevelId,
            lastLevelId: lastLevelId,
            overrides: foldOverrides,
          );
          return Padding(
            padding: const EdgeInsets.only(bottom: VocabLayout.levelCardBottomGap),
            child: VocabLevelCard(
              item: level,
              l10n: l10n,
              isExpanded: isExpanded,
              onToggle: () => ref
                  .read(levelFoldOverridesProvider.notifier)
                  .toggle(levelId, currentlyExpanded: isExpanded),
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

  List<VocabLevelData> _buildLevels({
    required Dictionary dictionary,
    required LanguagePack nativePack,
    required LanguagePack targetPack,
    required Map<String, GroupProgress> allProgress,
    required Map<String, LevelTier> levelTiers,
    required dynamic settings,
  }) {
    final groupsById = dictionary.groupsById;
    final result = <VocabLevelData>[];

    for (final level in dictionary.levels) {
      final tier = levelTiers[level.id] ?? LevelTier.premium;
      final levelName = nativePack.levelMeta[level.id]?.name ?? level.id;
      final levelDesc = nativePack.levelMeta[level.id]?.description;

      final groups = <VocabGroupTileData>[];
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
        final words = <String>[];
        for (final cid in group.conceptIds) {
          final entry = targetPack.translations[cid];
          if (entry == null) continue;
          if (entry is SimpleEntry) {
            words.add(entry.text);
          } else if (entry is AspectPairEntry) {
            words.add(entry.imperfective);
          } else if (entry is AdjectiveEntry) {
            words.add(entry.m);
          }
        }

        groups.add(
          VocabGroupTileData(
            group: group,
            name: groupName,
            cardCount: cardCount,
            words: words,
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
        VocabLevelData(
          level: level,
          name: levelName,
          description: levelDesc,
          tier: tier,
          levelProgress: levelProgress,
          groups: groups,
          latestDate: latestDate,
          strengthLevel: strengthLevel,
          totalCardCount: groups.fold(0, (s, g) => s + g.cardCount),
        ),
      );
    }

    return result;
  }

  double _computeLevelProgress(List<VocabGroupTileData> groups) {
    if (groups.isEmpty) return 0.0;
    final total = groups.fold(
      0.0,
      (sum, g) => sum + (g.progress?.totalProgress ?? 0.0),
    );
    return total / groups.length;
  }

  DateTime? _computeLatestDate(List<VocabGroupTileData> groups) {
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
    List<VocabGroupTileData> groups,
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

/// Computes whether a level should be expanded, respecting user overrides.
  /// Default: first and last levels are open. User toggle overrides everything.
  bool _isLevelExpanded({
    required String levelId,
    required String firstLevelId,
    required String lastLevelId,
    required Map<String, bool> overrides,
  }) {
    if (overrides.containsKey(levelId)) return overrides[levelId]!;
    if (levelId == firstLevelId) return true;
    if (levelId == lastLevelId) return true;
    return false;
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

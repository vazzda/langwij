import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../entities/language/lang_codes.dart';
import '../l10n/app_localizations.dart';
import '../entities/group/group_model.dart';
import '../shared/repositories/models/deck_progress.dart';
import '../shared/repositories/models/retention_level.dart';
import '../features/quiz/round_notifier.dart';
import '../app/providers/app_settings_provider.dart';
import '../app/providers/deck_progress_provider.dart';
import '../app/providers/groups_provider.dart';
import '../app/router/app_router.dart';
import '../shared/ui/langwij_main_nav_bar.dart';
import '../shared/ui/bottom_sheet/langwij_quiz_bottom_sheets.dart';
import 'package:langwij/shared/lib/group_label.dart';
import 'package:flessel/flessel.dart';
import 'package:langwij/shared/lib/progress_calculator.dart';

enum ParentCategory { vocabulary, conjugations }

/// Returns relative date string for progress badge.
String formatRelativeDate(DateTime date, AppLocalizations l10n) {
  final now = DateTime.now();
  final diff = now.difference(date);
  final days = diff.inDays;

  if (days == 0) {
    return l10n.relativeDateToday;
  } else if (days == 1) {
    return l10n.relativeDateYesterday;
  } else if (days < 30) {
    return l10n.relativeDateDays(days);
  } else if (days < 365) {
    final months = (days / 30).floor();
    return l10n.relativeDateMonths(months);
  } else {
    final years = (days / 365).floor();
    return l10n.relativeDateYears(years);
  }
}

/// Returns localized label for a retention level.
String retentionLabel(RetentionLevel level, AppLocalizations l10n) {
  switch (level) {
    case RetentionLevel.none:
      return l10n.retentionNone;
    case RetentionLevel.weak:
      return l10n.retentionWeak;
    case RetentionLevel.good:
      return l10n.retentionGood;
    case RetentionLevel.strong:
      return l10n.retentionStrong;
    case RetentionLevel.super_:
      return l10n.retentionSuper;
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({
    required this.group,
    required this.l10n,
    required this.onTap,
    this.progress,
    this.retention = 0.0,
  });

  final GroupModel group;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final DeckProgress? progress;
  final double retention;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final label = groupLabel(l10n, group.labelKey);
    final count = wordCount(group);
    final preview = groupPreviewText(group);
    final countText = preview.isNotEmpty
        ? l10n.wordsCountWithPreview(count, preview)
        : l10n.wordsCount(count);

    // Show badge if there's any progress
    final showBadge = progress != null && progress!.recentRounds.isNotEmpty;

    return FlesselCard(
      onTap: onTap,
      padding: FlesselSize.xxs,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.all(FlesselLayout.screenPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(label, style: FlesselFonts.contentM.copyWith(color: t.textPrimary)),
                          const FlesselGap.xxs(),
                          Text(
                            countText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FlesselFonts.contentS.copyWith(color: t.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    // Space reserved for badge
                    const FlesselGap.l(),
                  ],
                ),
              ),
              // Progress badge (if any rounds done)
              if (showBadge)
                Positioned(
                  top: 0,
                  right: 0,
                  child: _ProgressBadge(
                    progress: progress!,
                    retention: retention,
                    l10n: l10n,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ProgressBadge extends StatelessWidget {
  const _ProgressBadge({
    required this.progress,
    required this.retention,
    required this.l10n,
  });

  final DeckProgress progress;
  final double retention;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final percentage = progress.totalProgress.round();
    final level = ProgressCalculator.getRetentionLevel(
      retention,
      progress.totalProgress,
    );
    final levelLabel = retentionLabel(level, l10n);
    final dateText = progress.lastRoundDate != null
        ? formatRelativeDate(progress.lastRoundDate!, l10n)
        : '-';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlesselTag(label: '$percentage%'),
        const FlesselGap.xs(),
        FlesselTag(label: dateText),
        const FlesselGap.xs(),
        FlesselTag(label: levelLabel),
      ],
    );
  }
}

class ChildGroupListScreen extends ConsumerStatefulWidget {
  const ChildGroupListScreen({super.key, required this.parent});

  final ParentCategory parent;

  @override
  ConsumerState<ChildGroupListScreen> createState() =>
      _ChildGroupListScreenState();
}

class _ChildGroupListScreenState extends ConsumerState<ChildGroupListScreen> {
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
    final t = FlesselThemes.of(context);
    final asyncGroups = ref.watch(groupsProvider);
    final allProgress = ref.watch(deckProgressProvider);
    final settings = ref.watch(appSettingsProvider);
    final title = widget.parent == ParentCategory.vocabulary
        ? l10n.parentVocabulary
        : l10n.parentConjugations;
    final filterType = widget.parent == ParentCategory.vocabulary
        ? GroupType.words
        : GroupType.endings;

    // When data loads and we have a pending scroll, schedule restore
    if (asyncGroups.hasValue &&
        _pendingScrollOffset != null &&
        !_scrollRestored) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _restoreScrollPosition();
      });
    }

    // Helper to get retention for a group
    double getRetention(String groupId) {
      final progress = allProgress[groupId];
      if (progress == null) return 0.0;
      return ProgressCalculator.calculateRetention(
          progress, settings.decayFormula);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go(AppRoutes.tools);
      },
      child: FlesselScaffold(
        title: title,
        uppercaseTitle: true,
        bottomNavBar: const LangwijMainNavBar(),
        onBackPressed: () => context.go(AppRoutes.tools),
        child: asyncGroups.when(
          data: (groups) {
            final childGroups = groups
                .where((g) => g.type == filterType)
                .toList();
            if (filterType == GroupType.endings) {
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(FlesselLayout.screenPadding),
                itemCount: childGroups.length,
                itemBuilder: (context, index) {
                  final group = childGroups[index];
                  final progress = allProgress[group.id];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: FlesselLayout.listItemGap),
                    child: _GroupTile(
                      group: group,
                      l10n: l10n,
                      progress: progress,
                      retention: getRetention(group.id),
                      onTap: () => _onGroupTap(context, group, l10n),
                    ),
                  );
                },
              );
            }
            // Vocabulary: sectioned list with headers
            const sectionIds = [
              [
                'basic_verbs_01',
                'basic_verbs_02',
                'basic_verbs_03',
                'basic_verbs_04',
                'basic_verbs_05',
                'basic_verbs_06',
                'basic_verbs_07',
                'basic_verbs_08',
                'basic_verbs_09',
                'basic_verbs_10',
                'basic_verbs_11',
              ],
              [
                'adverbs_of_time',
                'prepositions',
                'demonstrative_pronouns',
                'relative_direction',
                'degree_quantity',
              ],
              [
                'people',
                'places',
                'daily_items_objects',
                'time_nature',
                'abstract_concepts',
              ],
              [
                'general_qualities',
                'people_emotions',
                'senses_feelings',
                'colors',
              ],
            ];
            final sectionHeaders = [
              l10n.groupWords,
              l10n.vocabSectionSettingWords,
              l10n.vocabSectionBasicNouns,
              l10n.vocabSectionBasicAdjectives,
            ];
            final idToGroup = {for (final g in childGroups) g.id: g};
            final items = <Object>[];
            for (var i = 0; i < sectionHeaders.length; i++) {
              items.add(sectionHeaders[i]);
              for (final id in sectionIds[i]) {
                final group = idToGroup[id];
                if (group != null) items.add(group);
              }
            }
            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(FlesselLayout.screenPadding),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                if (item is String) {
                  return Padding(
                    padding: EdgeInsets.only(
                      top: index == 0 ? 0 : FlesselLayout.listItemGap,
                      bottom: FlesselLayout.listItemGapSmall,
                    ),
                    child: Text(
                      item,
                      style: FlesselFonts.contentXxlAccent.copyWith(color: t.textPrimary),
                    ),
                  );
                }
                final group = item as GroupModel;
                final progress = allProgress[group.id];
                return Padding(
                  padding: const EdgeInsets.only(bottom: FlesselLayout.listItemGap),
                  child: _GroupTile(
                    group: group,
                    l10n: l10n,
                    progress: progress,
                    retention: getRetention(group.id),
                    onTap: () => _onGroupTap(context, group, l10n),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: FlesselSpinner()),
          error: (e, st) => Center(child: Text(l10n.loadError)),
        ),
      ),
    );
  }

  Future<void> _onGroupTap(
    BuildContext context,
    GroupModel group,
    AppLocalizations l10n,
  ) async {
    final totalCards = group.cards.length;

    // No cards available
    if (totalCards <= 0) return;

    ref.read(selectedGroupProvider.notifier).state = group;

    final selection = await showLangwijModeSelectionSheet(
      context, l10n,
      showAllModes: false,
      targetLangCode: LangCodes.serbian,
    );
    if (selection == null || !context.mounted) return;

    // Test mode uses all cards — skip count selection
    final int selectedCount;
    if (selection.isTest) {
      selectedCount = totalCards;
    } else {
      final picked = await showLangwijQuestionCountSheet(
        context,
        l10n,
        totalCount: totalCards,
      );
      if (picked == null || !context.mounted) return;
      selectedCount = picked;
    }

    final originRoute = AppRoutes.conjugations;
    final scrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;

    ref.read(roundProvider.notifier).start(
          group: group,
          mode: selection.mode,
          questionCount: selectedCount,
          originRoute: originRoute,
          originScrollOffset: scrollOffset,
        );
    if (context.mounted) context.go(AppRoutes.round);
  }
}

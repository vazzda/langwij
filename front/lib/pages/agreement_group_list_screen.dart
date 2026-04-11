import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../entities/language/lang_codes.dart';
import '../l10n/app_localizations.dart';
import '../entities/group/group_model.dart';
import '../shared/repositories/models/deck_progress.dart';
import '../features/quiz/round_notifier.dart';
import '../app/providers/app_settings_provider.dart';
import '../app/providers/deck_progress_provider.dart';
import '../app/providers/groups_provider.dart';
import '../app/router/app_router.dart';
import '../shared/ui/langwij_main_nav_bar.dart';
import '../shared/ui/bottom_sheet/langwij_quiz_bottom_sheets.dart';
import 'package:langwij/shared/lib/group_label.dart';
import 'package:langwij/shared/lib/progress_calculator.dart';
import 'package:flessel/flessel.dart';
import 'group_list_screen.dart' show formatRelativeDate, retentionLabel;

/// Screen to select an adjective group for an agreement round.
class AgreementGroupListScreen extends ConsumerStatefulWidget {
  const AgreementGroupListScreen({super.key});

  @override
  ConsumerState<AgreementGroupListScreen> createState() => _AgreementGroupListScreenState();
}

class _AgreementGroupListScreenState extends ConsumerState<AgreementGroupListScreen> {
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

    // When data loads and we have a pending scroll, schedule restore
    if (asyncGroups.hasValue && _pendingScrollOffset != null && !_scrollRestored) {
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
        title: l10n.parentAgreement,
        uppercaseTitle: true,
        bottomNavBar: const LangwijMainNavBar(),
        onBackPressed: () => context.go(AppRoutes.tools),
        child: asyncGroups.when(
          data: (groups) {
            final adjectiveGroupsList = adjectiveGroups(groups);
            if (adjectiveGroupsList.isEmpty) {
              return Center(
                child: Text(
                  l10n.loadError,
                  style: FlesselFonts.contentM.copyWith(color: t.textPrimary),
                ),
              );
            }
            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(FlesselLayout.screenPadding),
              itemCount: adjectiveGroupsList.length,
              itemBuilder: (context, index) {
                final group = adjectiveGroupsList[index];
                final groupId = 'agreement:${group.id}';
                final progress = allProgress[groupId];
                return Padding(
                  padding: const EdgeInsets.only(bottom: FlesselLayout.listItemGap),
                  child: _AgreementGroupTile(
                    group: group,
                    l10n: l10n,
                    progress: progress,
                    retention: getRetention(groupId),
                    onTap: () => _onGroupTap(context, group, groups, l10n),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: FlesselSpinner()),
          error: (e, st) => Center(
            child: Text(l10n.loadError),
          ),
        ),
      ),
    );
  }

  Future<void> _onGroupTap(
    BuildContext context,
    GroupModel group,
    List<GroupModel> allGroups,
    AppLocalizations l10n,
  ) async {
    final totalCards = group.cards.length;

    // No cards available
    if (totalCards <= 0) return;

    // Agreement only supports writing mode
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

    final scrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;

    ref.read(roundProvider.notifier).startAgreement(
          adjectiveGroup: group,
          allGroups: allGroups,
          mode: selection.mode,
          questionCount: selectedCount,
          originRoute: AppRoutes.agreement,
          originScrollOffset: scrollOffset,
        );
    if (context.mounted) context.go(AppRoutes.round);
  }
}

class _AgreementGroupTile extends StatelessWidget {
  const _AgreementGroupTile({
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
      child: Stack(
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
                      Text(
                        label,
                        style: FlesselFonts.contentM.copyWith(color: t.textPrimary),
                      ),
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

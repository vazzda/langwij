import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/entities/group/group.dart';
import 'package:langwij/entities/progress/progress.dart';
import 'package:langwij/features/quiz/quiz.dart';
import 'package:langwij/features/quiz/ui/mode_selection_sheet.dart';
import 'package:langwij/shared/app/config/config.dart';
import 'package:langwij/shared/app/routing/routing.dart';
import 'package:langwij/shared/date_format/date_format.dart';
import 'package:langwij/shared/nav_bar/ui/main_nav_bar.dart';
import 'package:langwij/l10n/app_localizations_ext.dart';
import '../../conjugations/ui/conjugations_page.dart' show retentionLabel;

class AgreementPage extends ConsumerStatefulWidget {
  const AgreementPage({super.key});

  @override
  ConsumerState<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends ConsumerState<AgreementPage> {
  final _scrollController = ScrollController();
  double? _pendingScrollOffset;
  bool _scrollRestored = false;

  @override
  void initState() {
    super.initState();
    _pendingScrollOffset = ref.read(QuizService.scrollOffsetToRestore);
    if (_pendingScrollOffset != null) {
      Future(() {
        if (mounted) {
          ref.read(QuizService.instance).clearScrollOffset();
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
    final asyncGroups = ref.watch(GroupService.groups);
    final asyncProgress = ref.watch(ProgressService.allDeckProgress);
    final asyncSettings = ref.watch(ConfigService.appSettings);
    final allProgress = asyncProgress.valueOrNull ?? {};
    final settings = asyncSettings.valueOrNull;

    if (asyncGroups.hasValue && _pendingScrollOffset != null && !_scrollRestored) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _restoreScrollPosition();
      });
    }

    double getRetention(String groupId) {
      final progress = allProgress[groupId];
      if (progress == null || settings == null) return 0.0;
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
        navBarItems: LangwijMainNavBar.items(context),
        navBarCurrentIndex: LangwijMainNavBar.currentIndex(context),
        notchedNavBar: true,
        navBarSize: FlesselSize.s,
        floatingActionButton: LangwijMainNavBar.fab(context),
        onBackPressed: () => context.go(AppRoutes.tools),
        child: asyncGroups.when(
          data: (groups) {
            final adjectiveGroupsList = GroupService.adjectiveGroups(groups);
            if (adjectiveGroupsList.isEmpty) {
              return Center(
                child: Text(
                  l10n.loadError,
                  style: FlesselFonts.contentM.copyWith(color: t.fg),
                ),
              );
            }
            return ListView.builder(
              controller: _scrollController,
              padding: FlesselLayout.screenPaddingInsets(context).copyWith(
                bottom: FlesselLayout.screenPaddingInsets(context).bottom + FlesselLayout.navbarSpacer(context),
              ),
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
    if (totalCards <= 0) return;

    final selection = await showLangwijModeSelectionSheet(
      context, l10n,
      showAllModes: false,
      targetLangCode: LangCodes.serbian,
    );
    if (selection == null || !context.mounted) return;

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

    ref.read(QuizService.round.notifier).startAgreement(
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
    final label = l10n.groupLabel(group.labelKey);
    final count = wordCount(group);
    final preview = GroupService.groupPreviewText(group);
    final countText = preview.isNotEmpty
        ? l10n.wordsCountWithPreview(count, preview)
        : l10n.wordsCount(count);

    final showBadge = progress != null && progress!.recentRounds.isNotEmpty;

    return FlesselCard(
      onTap: onTap,
      padding: FlesselSize.xxs,
      child: Stack(
        children: [
          Padding(
            padding: FlesselLayout.screenPaddingInsets(context),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: FlesselFonts.contentM.copyWith(color: t.fg),
                      ),
                      const FlesselGap.xxs(),
                      Text(
                        countText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FlesselFonts.contentS.copyWith(color: t.fgSecondary),
                      ),
                    ],
                  ),
                ),
                const FlesselGap.l(),
              ],
            ),
          ),
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
        ? RelativeDateFormat.format(progress.lastRoundDate!, l10n)
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

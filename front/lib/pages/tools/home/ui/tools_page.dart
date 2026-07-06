import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/l10n/app_localizations_ext.dart';
import 'package:langwij/entities/group/group.dart';
import 'package:langwij/entities/progress/progress.dart';
import 'package:langwij/features/quiz/quiz.dart';
import 'package:langwij/features/quiz/ui/mode_selection_sheet.dart';
import 'package:langwij/shared/app/config/config.dart';
import 'package:langwij/shared/app/routing/routing.dart';
import 'package:langwij/shared/nav_bar/ui/langwij_scaffold.dart';
import 'package:langwij/widgets/drill/group_card/model/drill_group_card_data.dart';
import 'package:langwij/widgets/drill/group_card/model/drill_level_data.dart';
import 'package:langwij/widgets/drill/level_card/ui/drill_level_card.dart';

const _conjugationsLevelId = 'tool_conjugations';
const _agreementLevelId = 'tool_agreement';

class ToolsPage extends ConsumerStatefulWidget {
  const ToolsPage({super.key});

  @override
  ConsumerState<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends ConsumerState<ToolsPage> {
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
    final asyncLangSettings = ref.watch(ConfigService.languageSettings);
    final langSettings = asyncLangSettings.valueOrNull;
    final foldOverrides =
        ref.watch(ConfigService.levelFoldOverrides).valueOrNull ?? {};

    if (langSettings == null) {
      return LangwijScaffold(
        title: l10n.navTools,
        child: const Center(child: FlesselSpinner()),
      );
    }

    if (asyncGroups.hasValue &&
        _pendingScrollOffset != null &&
        !_scrollRestored) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _restoreScrollPosition();
      });
    }

    final allProgress = asyncProgress.valueOrNull ?? {};

    return LangwijScaffold(
      title: l10n.navTools,
      child: asyncGroups.when(
        data: (groups) {
          final levels = _buildLevels(
            groups: groups,
            allProgress: allProgress,
            l10n: l10n,
          );

          if (levels.isEmpty) {
            return Center(
              child: Text(
                l10n.tools_emptyState,
                style: FlesselFonts.contentM.copyWith(color: t.fgSecondary),
              ),
            );
          }

          return ListView.separated(
            controller: _scrollController,
            padding: FlesselLayout.screenPaddingInsets(context).copyWith(
              bottom: FlesselLayout.screenPaddingInsets(context).bottom +
                  LangwijScaffold.navbarSpacer(context),
            ),
            itemCount: levels.length,
            separatorBuilder: (_, _) => const FlesselGap.m(),
            itemBuilder: (context, index) {
              final level = levels[index];
              final isExpanded = foldOverrides[level.id] ?? false;
              return LangwijDrillLevelCard(
                item: level,
                l10n: l10n,
                isExpanded: isExpanded,
                onToggle: () =>
                    ref.read(ConfigService.instance).toggleLevelFold(
                          level.id,
                          currentlyExpanded: isExpanded,
                        ),
                onGroupTap: (groupData) => _onGroupTap(
                  context,
                  groupData,
                  groups,
                  level.id,
                  l10n,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: FlesselSpinner()),
        error: (e, st) => Center(child: Text(l10n.loadError)),
      ),
    );
  }

  List<DrillLevelData> _buildLevels({
    required List<GroupModel> groups,
    required Map<String, DeckProgress> allProgress,
    required AppLocalizations l10n,
  }) {
    final levels = <DrillLevelData>[];

    final conjugationGroups =
        groups.where((g) => g.type == GroupType.endings).toList();
    if (conjugationGroups.isNotEmpty) {
      levels.add(_buildLevel(
        id: _conjugationsLevelId,
        name: l10n.tools_conjugations,
        groups: conjugationGroups,
        allProgress: allProgress,
        isAgreement: false,
        l10n: l10n,
      ));
    }

    final adjectiveGroups = GroupService.adjectiveGroups(groups);
    if (adjectiveGroups.isNotEmpty) {
      levels.add(_buildLevel(
        id: _agreementLevelId,
        name: l10n.tools_agreement,
        groups: adjectiveGroups,
        allProgress: allProgress,
        isAgreement: true,
        l10n: l10n,
      ));
    }

    return levels;
  }

  DrillLevelData _buildLevel({
    required String id,
    required String name,
    required List<GroupModel> groups,
    required Map<String, DeckProgress> allProgress,
    required bool isAgreement,
    required AppLocalizations l10n,
  }) {
    final groupCards = <DrillGroupCardData>[];

    for (final group in groups) {
      final progressId = isAgreement ? 'agreement:${group.id}' : group.id;
      final progress = allProgress[progressId];
      final count = wordCount(group);
      final preview = GroupService.groupPreviewText(group);
      final words = preview.isNotEmpty ? [preview] : <String>[];
      final coverage = progress != null && progress.totalProgress > 0
          ? progress.totalProgress.round()
          : null;

      groupCards.add(DrillGroupCardData(
        group: group,
        name: l10n.groupLabel(group.labelKey),
        cardCount: count,
        words: words,
        coverage: coverage,
        progress: progress,
      ));
    }

    return DrillLevelData(
      id: id,
      name: name,
      groups: groupCards,
    );
  }

  Future<void> _onGroupTap(
    BuildContext context,
    DrillGroupCardData groupData,
    List<GroupModel> allGroups,
    String levelId,
    AppLocalizations l10n,
  ) async {
    final group = groupData.group;
    final totalCards = group.cards.length;
    if (totalCards <= 0) return;

    final selectedCount = await showLangwijQuestionCountSheet(
      context,
      l10n,
      totalCount: totalCards,
    );
    if (selectedCount == null || !context.mounted) return;

    final scrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;

    if (levelId == _agreementLevelId) {
      ref.read(QuizService.round.notifier).startAgreement(
            adjectiveGroup: group,
            allGroups: allGroups,
            mode: QuizMode.write,
            questionCount: selectedCount,
            originRoute: AppRoutes.tools,
            originScrollOffset: scrollOffset,
          );
    } else {
      ref.read(QuizService.instance).selectGroup(group);
      ref.read(QuizService.round.notifier).start(
            group: group,
            mode: QuizMode.write,
            questionCount: selectedCount,
            originRoute: AppRoutes.tools,
            originScrollOffset: scrollOffset,
          );
    }
    if (context.mounted) context.go(AppRoutes.round);
  }
}

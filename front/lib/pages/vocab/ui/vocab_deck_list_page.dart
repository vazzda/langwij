import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/l10n/app_localizations_ext.dart';
import 'package:langwij/entities/dictionary/dictionary.dart';
import 'package:langwij/entities/progress/progress.dart';
import 'package:langwij/features/quiz/quiz.dart';
import 'package:langwij/shared/app/routing/routing.dart';
import 'package:langwij/shared/nav_bar/ui/langwij_scaffold.dart';
import 'package:langwij/features/quiz/ui/mode_selection_sheet.dart';
import 'package:langwij/widgets/vocab/level_accordion/ui/vocab_level_accordion.dart';
import 'package:langwij/widgets/vocab/segment_section/ui/vocab_segment_section.dart';
import 'package:langwij/widgets/vocab/vocab.dart';

import '../service/vocab_page_service.dart';

class VocabDeckListPage extends ConsumerStatefulWidget {
  const VocabDeckListPage({super.key});

  @override
  ConsumerState<VocabDeckListPage> createState() =>
      _VocabDeckListPageState();
}

class _VocabDeckListPageState extends ConsumerState<VocabDeckListPage> {
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
    final asyncDict = ref.watch(DictionaryService.dictionary);
    final asyncTarget = ref.watch(DictionaryService.targetPack);
    final asyncNative = ref.watch(DictionaryService.nativePack);
    final asyncProgress = ref.watch(ProgressService.allDeckProgress);
    final asyncFoldState = ref.watch(VocabPageService.foldState);
    final levelTiers = ref.watch(DictionaryService.levelTiers).valueOrNull ?? {};

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
    final foldState = asyncFoldState.valueOrNull;

    if (dictionary == null ||
        targetPack == null ||
        nativePack == null ||
        foldState == null) {
      return _buildLoadingScaffold(
        l10n,
        hasError: asyncDict.hasError ||
            asyncTarget.hasError ||
            asyncNative.hasError ||
            asyncFoldState.hasError,
      );
    }

    return LangwijScaffold(
      title: l10n.navVocabulary,
      child: _buildSegmentSectionList(
        l10n: l10n,
        dictionary: dictionary,
        targetPack: targetPack,
        nativePack: nativePack,
        deckProgressByDeckId: asyncProgress.valueOrNull ?? {},
        levelTierByLevelId: levelTiers,
        unfoldedSegmentId: foldState.unfoldedSegmentId,
        unfoldedLevelId: foldState.unfoldedLevelId,
      ),
    );
  }

  Widget _buildLoadingScaffold(
    AppLocalizations l10n, {
    required bool hasError,
  }) {
    return LangwijScaffold(
      title: l10n.navVocabulary,
      child: Center(
        child: hasError ? Text(l10n.loadError) : const FlesselSpinner(),
      ),
    );
  }

  Widget _buildSegmentSectionList({
    required AppLocalizations l10n,
    required Dictionary dictionary,
    required LanguagePack targetPack,
    required LanguagePack nativePack,
    required Map<String, DeckProgress> deckProgressByDeckId,
    required Map<String, LevelTier> levelTierByLevelId,
    required String? unfoldedSegmentId,
    required String? unfoldedLevelId,
  }) {
    final segmentSections = VocabPageService.buildVocabSegmentSections(
      dictionary: dictionary,
      targetPack: targetPack,
      nativePack: nativePack,
      deckProgressByDeckId: deckProgressByDeckId,
      levelTierByLevelId: levelTierByLevelId,
    );

    return ListView.separated(
      controller: _scrollController,
      padding: _listPaddingClearOfNavigationBar(),
      itemCount: segmentSections.length,
      separatorBuilder: (_, _) => const FlesselGap.m(),
      itemBuilder: (context, index) {
        final segmentSection = segmentSections[index];
        final segmentId = segmentSection.segmentId;
        return LangwijVocabSegmentSection(
          item: segmentSection,
          isExpanded: segmentId == unfoldedSegmentId,
          onHeaderTap: () => ref
              .read(VocabPageService.foldState.notifier)
              .toggleSegmentFold(segmentId),
          expandedContent: _buildLevelAccordion(
            levels: segmentSection.levels,
            unfoldedLevelId: unfoldedLevelId,
            l10n: l10n,
            dictionary: dictionary,
            targetPack: targetPack,
            nativePack: nativePack,
            deckProgressByDeckId: deckProgressByDeckId,
          ),
        );
      },
    );
  }

  EdgeInsets _listPaddingClearOfNavigationBar() {
    final screenPadding = FlesselLayout.screenPaddingInsets(context);
    return screenPadding.copyWith(
      bottom: screenPadding.bottom + LangwijScaffold.navbarSpacer(context),
    );
  }

  Widget _buildLevelAccordion({
    required List<VocabLevelData> levels,
    required String? unfoldedLevelId,
    required AppLocalizations l10n,
    required Dictionary dictionary,
    required LanguagePack targetPack,
    required LanguagePack nativePack,
    required Map<String, DeckProgress> deckProgressByDeckId,
  }) {
    return LangwijVocabLevelAccordion(
      levels: levels,
      unfoldedLevelId: unfoldedLevelId,
      l10n: l10n,
      onLevelHeaderTap: (level) => ref
          .read(VocabPageService.foldState.notifier)
          .toggleLevelFold(level.level.id),
      onDeckTap: (deck, cardCount) => _onDeckTap(
        context,
        deck,
        dictionary,
        targetPack,
        nativePack,
        cardCount,
        l10n,
      ),
      onLevelTrainTap: (level) => _onTrainTap(
        context,
        level,
        dictionary,
        targetPack,
        nativePack,
        deckProgressByDeckId,
        l10n,
        AppRoutes.home,
      ),
    );
  }

  Future<void> _onTrainTap(
    BuildContext context,
    VocabLevelData level,
    Dictionary dictionary,
    LanguagePack targetPack,
    LanguagePack nativePack,
    Map<String, DeckProgress> allProgress,
    AppLocalizations l10n,
    String originRoute,
  ) async {
    final pool = <({VocabDeckModel deck, double practice})>[];
    for (final d in level.decks) {
      final progress = allProgress[d.deck.id];
      final practice = progress?.practice ?? 0.0;
      if (practice < ProgressConstants.practiceMax) {
        pool.add((deck: d.deck, practice: practice));
      }
    }

    final useAll = pool.isNotEmpty;
    final deckSource = pool.isNotEmpty ? pool : level.decks.map(
      (d) => (deck: d.deck, practice: allProgress[d.deck.id]?.practice ?? 0.0),
    ).toList();

    int totalTerms = 0;
    for (final entry in deckSource) {
      totalTerms +=
          VocabLevelDataBuilderService.countTermsTranslatedInBothLanguagePacks(
        deck: entry.deck,
        targetPack: targetPack,
        nativePack: nativePack,
      );
    }
    if (totalTerms <= 0) return;

    final selection = await showLangwijModeSelectionSheet(
      context,
      l10n,
      enableTest: false,
      targetLangCode: targetPack.code,
      nativeLangCode: nativePack.code,
      nativeLangName: l10n.langLabel(nativePack.labelKey),
      targetLangName: l10n.langLabel(targetPack.labelKey),
    );
    if (selection == null || !context.mounted) return;

    final int selectedCount;
    if (selection.isTest) {
      selectedCount = totalTerms;
    } else {
      final picked = await showLangwijQuestionCountSheet(
        context,
        l10n,
        totalCount: totalTerms,
        showAll: useAll,
      );
      if (picked == null || !context.mounted) return;
      selectedCount = picked;
    }

    final scrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;

    final levelName = nativePack.levelMeta[level.level.id]?.name ?? level.level.id;

    ref.read(QuizService.round.notifier).startLevelTraining(
      deckPool: deckSource.toList(),
      targetPack: targetPack,
      nativePack: nativePack,
      mode: selection.mode,
      questionCount: selectedCount,
      levelId: level.level.id,
      levelName: levelName,
      originRoute: originRoute,
      originScrollOffset: scrollOffset,
      terms: dictionary.terms,
    );
    if (context.mounted) context.go(AppRoutes.round);
  }

  Future<void> _onDeckTap(
    BuildContext context,
    VocabDeckModel deck,
    Dictionary dictionary,
    LanguagePack targetPack,
    LanguagePack nativePack,
    int cardCount,
    AppLocalizations l10n,
  ) async {
    if (cardCount <= 0) return;

    final allProgress = ref.read(ProgressService.allDeckProgress).valueOrNull ?? {};
    final deckCoverage = allProgress[deck.id]?.progress ?? 0.0;

    final selection = await showLangwijModeSelectionSheet(
      context,
      l10n,
      enableTest: deckCoverage < ProgressConstants.coverageMax,
      targetLangCode: targetPack.code,
      nativeLangCode: nativePack.code,
      nativeLangName: l10n.langLabel(nativePack.labelKey),
      targetLangName: l10n.langLabel(targetPack.labelKey),
    );
    if (selection == null || !context.mounted) return;

    final int selectedCount;
    if (selection.isTest) {
      selectedCount = cardCount;
    } else {
      final picked = await showLangwijQuestionCountSheet(
        context,
        l10n,
        totalCount: cardCount,
      );
      if (picked == null || !context.mounted) return;
      selectedCount = picked;
    }

    final scrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;

    ref
        .read(QuizService.round.notifier)
        .startVocab(
          deck: deck,
          targetPack: targetPack,
          nativePack: nativePack,
          mode: selection.mode,
          questionCount: selectedCount,
          originRoute: AppRoutes.home,
          originScrollOffset: scrollOffset,
          isTest: selection.isTest,
          terms: dictionary.terms,
        );
    if (context.mounted) context.go(AppRoutes.round);
  }
}

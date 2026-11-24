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
import 'package:langwij/widgets/vocab/deck_card/ui/vocab_deck_card.dart';
import 'package:langwij/widgets/vocab/training_summary/ui/vocab_training_summary.dart';
import 'package:langwij/widgets/vocab/vocab.dart';

class SpecializedVocabPage extends ConsumerStatefulWidget {
  const SpecializedVocabPage({super.key});

  @override
  ConsumerState<SpecializedVocabPage> createState() =>
      _SpecializedVocabPageState();
}

class _SpecializedVocabPageState extends ConsumerState<SpecializedVocabPage> {
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
    final allProgress = asyncProgress.valueOrNull ?? {};

    if (dictionary == null || targetPack == null || nativePack == null) {
      final hasError =
          asyncDict.hasError || asyncTarget.hasError || asyncNative.hasError;
      return LangwijScaffold(
        title: l10n.navSpecialized,
        child: Center(
          child: hasError
              ? Text(l10n.loadError)
              : const FlesselSpinner(),
        ),
      );
    }

    final specializedLevel = _findSpecializedLevel(dictionary);
    if (specializedLevel == null) {
      return LangwijScaffold(
        title: l10n.navSpecialized,
        child: Center(child: Text(l10n.loadError)),
      );
    }

    final levelData = VocabLevelDataBuilderService.buildVocabLevelData(
      level: specializedLevel,
      decksByDeckId: dictionary.decksById,
      targetPack: targetPack,
      nativePack: nativePack,
      deckProgressByDeckId: allProgress,
      deckNumberByDeckId: const {},
      levelTier: levelTiers[specializedLevel.id] ?? LevelTier.premium,
    );

    final title = nativePack.levelMeta[specializedLevel.id]?.name
        ?? l10n.navSpecialized;

    final decks = levelData.decks;

    return LangwijScaffold(
      title: title,
      child: ListView.separated(
        controller: _scrollController,
        padding: FlesselLayout.screenPaddingInsets(context).copyWith(
          bottom: FlesselLayout.screenPaddingInsets(context).bottom + LangwijScaffold.navbarSpacer(context),
        ),
        itemCount: decks.length,
        separatorBuilder: (_, _) => const FlesselGap.m(),
        itemBuilder: (context, index) {
          final deck = decks[index];
          return LangwijVocabDeckCard(
            item: deck,
            l10n: l10n,
            transparent: false,
            onTap: () => _onDeckTap(
              context,
              deck,
              dictionary,
              targetPack,
              nativePack,
              l10n,
            ),
          );
        },
      ),
    );
  }

  Level? _findSpecializedLevel(Dictionary dictionary) {
    for (final level in dictionary.levels) {
      if (level.id == Level.specializedLevelId) return level;
    }
    return null;
  }

  Future<void> _onDeckTap(
    BuildContext context,
    VocabDeckCardData deckCard,
    Dictionary dictionary,
    LanguagePack targetPack,
    LanguagePack nativePack,
    AppLocalizations l10n,
  ) async {
    final deck = deckCard.deck;
    final cardCount = deckCard.cardCount;
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
      summaryBuilder: (onTestTap) => LangwijVocabTrainingSummary.ofDeck(
        l10n: l10n,
        deck: deckCard,
        onTestTap: onTestTap,
      ),
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
          originRoute: AppRoutes.specialized,
          originScrollOffset: scrollOffset,
          isTest: selection.isTest,
          terms: dictionary.terms,
        );
    if (context.mounted) context.go(AppRoutes.round);
  }
}

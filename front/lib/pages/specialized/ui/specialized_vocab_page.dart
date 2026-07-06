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

    final levelData = _buildLevelData(
      level: specializedLevel,
      dictionary: dictionary,
      nativePack: nativePack,
      targetPack: targetPack,
      allProgress: allProgress,
      levelTiers: levelTiers,
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
              deck.deck,
              dictionary,
              targetPack,
              nativePack,
              deck.cardCount,
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

  VocabLevelData _buildLevelData({
    required Level level,
    required Dictionary dictionary,
    required LanguagePack nativePack,
    required LanguagePack targetPack,
    required Map<String, DeckProgress> allProgress,
    required Map<String, LevelTier> levelTiers,
  }) {
    final decksById = dictionary.decksById;
    final tier = levelTiers[level.id] ?? LevelTier.premium;
    final levelName = nativePack.levelMeta[level.id]?.name ?? level.id;
    final levelDesc = nativePack.levelMeta[level.id]?.description;

    final decks = <VocabDeckCardData>[];
    for (final deckId in level.deckIds) {
      final deck = decksById[deckId];
      if (deck == null) continue;

      final cardCount = _countCards(deck, targetPack, nativePack);
      final progress = allProgress[deckId];
      final deckName = nativePack.deckMeta[deckId]?.name ?? deck.id;
      final practice = progress?.practice ?? 0.0;
      final mastery = progress?.mastery ?? 0;
      final coverage =
          progress != null && progress.totalProgress > 0
          ? progress.totalProgress.round()
          : null;
      final words = <String>[];
      for (final cid in deck.termIds) {
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

      decks.add(
        VocabDeckCardData(
          deck: deck,
          name: deckName,
          icon: deck.icon,
          cardCount: cardCount,
          words: words,
          coverage: coverage,
          progress: progress,
          practice: practice,
          mastery: mastery,
        ),
      );
    }

    final levelProgress = _computeLevelProgress(decks);
    final latestDate = _computeLatestDate(decks);

    return VocabLevelData(
      level: level,
      name: levelName,
      description: levelDesc,
      tier: tier,
      levelProgress: levelProgress,
      decks: decks,
      latestDate: latestDate,
      totalCardCount: decks.fold(0, (s, g) => s + g.cardCount),
    );
  }

  double _computeLevelProgress(List<VocabDeckCardData> decks) {
    if (decks.isEmpty) return 0.0;
    final total = decks.fold(
      0.0,
      (sum, g) => sum + (g.progress?.totalProgress ?? 0.0),
    );
    return total / decks.length;
  }

  DateTime? _computeLatestDate(List<VocabDeckCardData> decks) {
    DateTime? latest;
    for (final g in decks) {
      final d = g.progress?.lastRoundDate;
      if (d != null && (latest == null || d.isAfter(latest))) {
        latest = d;
      }
    }
    return latest;
  }

  int _countCards(
    VocabDeckModel deck,
    LanguagePack target,
    LanguagePack native,
  ) {
    int count = 0;
    for (final cid in deck.termIds) {
      if (target.translations.containsKey(cid) &&
          native.translations.containsKey(cid)) {
        count++;
      }
    }
    return count;
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
          originRoute: AppRoutes.specialized,
          originScrollOffset: scrollOffset,
          isTest: selection.isTest,
        );
    if (context.mounted) context.go(AppRoutes.round);
  }
}

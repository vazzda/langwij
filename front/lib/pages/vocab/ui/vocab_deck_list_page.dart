import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/l10n/app_localizations_ext.dart';
import 'package:langwij/entities/dictionary/dictionary.dart';
import 'package:langwij/entities/progress/progress.dart';
import 'package:langwij/features/quiz/quiz.dart';
import 'package:langwij/shared/app/config/config.dart';
import 'package:langwij/shared/app/routing/routing.dart';
import 'package:langwij/shared/nav_bar/ui/main_nav_bar.dart';
import 'package:langwij/features/quiz/ui/mode_selection_sheet.dart';
import 'package:langwij/widgets/vocab/level_card/vocab_level_card.dart';
import 'package:langwij/widgets/vocab/vocab.dart';

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
    final asyncSettings = ref.watch(ConfigService.appSettings);
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
    final settings = asyncSettings.valueOrNull;
    final foldOverrides = ref.watch(ConfigService.levelFoldOverrides).valueOrNull ?? {};

    if (dictionary == null || targetPack == null || nativePack == null || settings == null) {
      final hasError =
          asyncDict.hasError || asyncTarget.hasError || asyncNative.hasError;
      return FlesselScaffold(
        title: l10n.navVocabulary,
        uppercaseTitle: true,
        navBarItems: LangwijMainNavBar.items(context),
        navBarCurrentIndex: LangwijMainNavBar.currentIndex(context),
        notchedNavBar: true,
        navBarSize: FlesselSize.s,
        floatingActionButton: LangwijMainNavBar.fab(context),
        child: Center(
          child: hasError
              ? Text(l10n.loadError)
              : const FlesselSpinner(),
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

    return FlesselScaffold(
      title: l10n.navVocabulary,
      uppercaseTitle: true,
      navBarItems: LangwijMainNavBar.items(context),
      navBarCurrentIndex: LangwijMainNavBar.currentIndex(context),
      notchedNavBar: true,
      navBarSize: FlesselSize.s,
      floatingActionButton: LangwijMainNavBar.fab(context),
      child: ListView.separated(
        controller: _scrollController,
        padding: FlesselLayout.screenPaddingInsets(context).copyWith(
          bottom: FlesselLayout.screenPaddingInsets(context).bottom + FlesselLayout.navbarSpacer(context),
        ),
        itemCount: levels.length,
        separatorBuilder: (_, _) => const FlesselGap.m(),
        itemBuilder: (context, index) {
          final level = levels[index];
          final levelId = level.level.id;
          final isExpanded = _isLevelExpanded(
            levelId: levelId,
            firstLevelId: firstLevelId,
            lastLevelId: lastLevelId,
            overrides: foldOverrides,
          );
          return LangwijVocabLevelCard(
            item: level,
            l10n: l10n,
            isExpanded: isExpanded,
            onToggle: () => ref.read(ConfigService.instance).toggleLevelFold(
              levelId,
              currentlyExpanded: isExpanded,
            ),
            onDeckTap: (deck, cardCount) => _onDeckTap(
              context,
              deck,
              dictionary,
              targetPack,
              nativePack,
              cardCount,
              l10n,
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
    required Map<String, DeckProgress> allProgress,
    required Map<String, LevelTier> levelTiers,
    required AppSettings settings,
  }) {
    final decksById = dictionary.decksById;
    final result = <VocabLevelData>[];

    for (final level in dictionary.levels) {
      final tier = levelTiers[level.id] ?? LevelTier.premium;
      final levelName = nativePack.levelMeta[level.id]?.name ?? level.id;
      final levelDesc = nativePack.levelMeta[level.id]?.description;

      final decks = <VocabDeckTileData>[];
      for (final deckId in level.deckIds) {
        final deck = decksById[deckId];
        if (deck == null) continue;

        final cardCount = _countCards(deck, targetPack, nativePack);
        final progress = allProgress[deckId];
        final deckName = nativePack.deckMeta[deckId]?.name ?? deck.id;
        final retention = progress != null
            ? ProgressCalculator.calculateRetention(
                progress,
                settings.decayFormula,
              )
            : 0.0;
        final percentage =
            progress != null && progress.recentRounds.isNotEmpty
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
          VocabDeckTileData(
            deck: deck,
            name: deckName,
            icon: deck.icon,
            cardCount: cardCount,
            words: words,
            percentage: percentage,
            progress: progress,
            retention: retention,
          ),
        );
      }

      final levelProgress = _computeLevelProgress(decks);
      final latestDate = _computeLatestDate(decks);
      final strengthLevel = _computeStrengthLevel(
        decks,
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
          decks: decks,
          latestDate: latestDate,
          strengthLevel: strengthLevel,
          totalCardCount: decks.fold(0, (s, g) => s + g.cardCount),
        ),
      );
    }

    return result;
  }

  double _computeLevelProgress(List<VocabDeckTileData> decks) {
    if (decks.isEmpty) return 0.0;
    final total = decks.fold(
      0.0,
      (sum, g) => sum + (g.progress?.totalProgress ?? 0.0),
    );
    return total / decks.length;
  }

  DateTime? _computeLatestDate(List<VocabDeckTileData> decks) {
    DateTime? latest;
    for (final g in decks) {
      final d = g.progress?.lastRoundDate;
      if (d != null && (latest == null || d.isAfter(latest))) {
        latest = d;
      }
    }
    return latest;
  }

  RetentionLevel _computeStrengthLevel(
    List<VocabDeckTileData> decks,
    double levelProgress,
    AppSettings settings,
  ) {
    final withRounds = decks
        .where(
          (g) => g.progress != null && g.progress!.recentRounds.isNotEmpty,
        )
        .toList();
    if (withRounds.isEmpty) return RetentionLevel.none;
    final avgRetention =
        withRounds.map((g) => g.retention).reduce((a, b) => a + b) /
        withRounds.length;
    return ProgressCalculator.getRetentionLevel(avgRetention, levelProgress);
  }

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

    final selection = await showLangwijModeSelectionSheet(
      context,
      l10n,
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
        );
    if (context.mounted) context.go(AppRoutes.round);
  }
}

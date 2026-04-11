import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_ext.dart';
import '../app/providers/app_settings_provider.dart';
import '../app/providers/dictionary_provider.dart';
import '../app/providers/deck_progress_provider.dart';
import '../app/providers/groups_provider.dart';
import '../app/providers/plan_provider.dart';
import '../app/router/app_router.dart';
import '../entities/deck/vocab_deck_model.dart';
import '../entities/language/dictionary.dart';
import '../entities/language/lang_entry.dart';
import '../entities/language/language_pack.dart';
import '../entities/plan/level_tier.dart';
import '../features/quiz/round_notifier.dart';
import '../features/vocab/services/level_fold_notifier.dart';
import '../features/vocab/widgets/langwij_vocab_daily_activity_card.dart';
import '../features/vocab/widgets/langwij_vocab_level_card.dart';
import '../features/vocab/widgets/vocab_deck_tile_data.dart';
import '../shared/repositories/models/deck_progress.dart';
import '../shared/repositories/models/retention_level.dart';
import '../app/providers/daily_activity_provider.dart';
import '../shared/ui/bottom_sheet/langwij_quiz_bottom_sheets.dart';
import '../shared/ui/langwij_main_nav_bar.dart';
import 'package:flessel/flessel.dart';
import 'package:langwij/shared/lib/progress_calculator.dart';

class VocabDeckListScreen extends ConsumerStatefulWidget {
  const VocabDeckListScreen({super.key});

  @override
  ConsumerState<VocabDeckListScreen> createState() =>
      _VocabDeckListScreenState();
}

class _VocabDeckListScreenState extends ConsumerState<VocabDeckListScreen> {
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
    final allProgress = ref.watch(deckProgressProvider);
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
      return FlesselScaffold(
        title: l10n.navVocabulary,
        uppercaseTitle: true,
        bottomNavBar: const LangwijMainNavBar(),
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
      bottomNavBar: const LangwijMainNavBar(),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(FlesselLayout.screenPadding),
        itemCount: levels.length + 1,
        separatorBuilder: (_, _) => const FlesselGap.m(),
        itemBuilder: (context, index) {
          if (index == 0) {
            return LangwijVocabDailyActivityCard(
              asyncStats: asyncStats,
              l10n: l10n,
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
          return LangwijVocabLevelCard(
            item: level,
            l10n: l10n,
            isExpanded: isExpanded,
            onToggle: () => ref
                .read(levelFoldOverridesProvider.notifier)
                .toggle(levelId, currentlyExpanded: isExpanded),
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
    required dynamic settings,
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
    dynamic settings,
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

    // Test mode uses all terms — skip count selection
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
        .read(roundProvider.notifier)
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

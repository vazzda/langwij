import 'package:langwij/entities/dictionary/dictionary.dart';
import 'package:langwij/entities/progress/progress.dart';

import '../model/vocab_deck_card_data.dart';
import '../model/vocab_deck_study_phase.dart';
import '../model/vocab_level_data.dart';

/// Builds the display data of one vocabulary level and of its decks from the
/// dictionary, the two language packs and the stored deck progress.
class VocabLevelDataBuilderService {
  VocabLevelDataBuilderService._();

  static VocabLevelData buildVocabLevelData({
    required Level level,
    required Map<String, VocabDeckModel> decksByDeckId,
    required LanguagePack targetPack,
    required LanguagePack nativePack,
    required Map<String, DeckProgress> deckProgressByDeckId,
    required Map<String, int> deckNumberByDeckId,
    required LevelTier levelTier,
  }) {
    final deckCards = <VocabDeckCardData>[];
    for (final deckId in level.deckIds) {
      final deck = decksByDeckId[deckId];
      if (deck == null) continue;
      deckCards.add(
        _buildVocabDeckCardData(
          deck: deck,
          targetPack: targetPack,
          nativePack: nativePack,
          deckProgress: deckProgressByDeckId[deckId],
          deckNumber: deckNumberByDeckId[deckId],
        ),
      );
    }

    final levelMeta = nativePack.levelMeta[level.id];
    final isEveryDeckFullyStudied = _isEveryDeckFullyStudied(deckCards);
    return VocabLevelData(
      level: level,
      name: levelMeta?.name ?? level.id,
      description: levelMeta?.description,
      tier: levelTier,
      levelProgress: _averageStudiedPercentOfDecks(deckCards),
      decks: deckCards,
      latestDate: _latestRoundDateOfDecks(deckCards),
      totalCardCount: _totalCardCountOfDecks(deckCards),
      isEveryDeckFullyStudied: isEveryDeckFullyStudied,
      lowestDeckMastery: _lowestMasteryOfDecks(deckCards),
      averagePracticePercent: isEveryDeckFullyStudied
          ? _averagePracticePercentOfDecks(deckCards)
          : 0.0,
    );
  }

  /// A term makes a card only when both language packs translate it.
  static int countTermsTranslatedInBothLanguagePacks({
    required VocabDeckModel deck,
    required LanguagePack targetPack,
    required LanguagePack nativePack,
  }) {
    return deck.termIds
        .where(
          (termId) =>
              targetPack.translations.containsKey(termId) &&
              nativePack.translations.containsKey(termId),
        )
        .length;
  }

  static VocabDeckCardData _buildVocabDeckCardData({
    required VocabDeckModel deck,
    required LanguagePack targetPack,
    required LanguagePack nativePack,
    required DeckProgress? deckProgress,
    required int? deckNumber,
  }) {
    final studiedPercent = _studiedPercentOrNullWhenNotStarted(deckProgress);
    final practicePercent = deckProgress?.practice ?? 0.0;
    final mastery = deckProgress?.mastery ?? 0;
    return VocabDeckCardData(
      deck: deck,
      name: nativePack.deckMeta[deck.id]?.name ?? deck.id,
      deckNumber: deckNumber,
      icon: deck.icon,
      cardCount: countTermsTranslatedInBothLanguagePacks(
        deck: deck,
        targetPack: targetPack,
        nativePack: nativePack,
      ),
      words: _collectPreviewWordsOfDeck(deck, targetPack),
      coverage: studiedPercent,
      progress: deckProgress,
      practice: practicePercent,
      mastery: mastery,
      studyPhase: _resolveStudyPhase(studiedPercent),
    );
  }

  static VocabDeckStudyPhase _resolveStudyPhase(int? studiedPercent) {
    if (studiedPercent == null || studiedPercent <= 0) {
      return VocabDeckStudyPhase.notStarted;
    }
    if (studiedPercent < ProgressConstants.coverageMax) {
      return VocabDeckStudyPhase.studying;
    }
    return VocabDeckStudyPhase.training;
  }

  static int? _studiedPercentOrNullWhenNotStarted(DeckProgress? deckProgress) {
    if (deckProgress == null || deckProgress.totalProgress <= 0) return null;
    return deckProgress.totalProgress.round();
  }

  static List<String> _collectPreviewWordsOfDeck(
    VocabDeckModel deck,
    LanguagePack targetPack,
  ) {
    final previewWords = <String>[];
    for (final termId in deck.termIds) {
      final targetEntry = targetPack.translations[termId];
      if (targetEntry == null) continue;
      previewWords.add(targetEntry.headword);
    }
    return previewWords;
  }

  static double _averageStudiedPercentOfDecks(
    List<VocabDeckCardData> deckCards,
  ) {
    if (deckCards.isEmpty) return 0.0;
    final studiedPercentSum = deckCards.fold(
      0.0,
      (sum, deckCard) => sum + (deckCard.progress?.totalProgress ?? 0.0),
    );
    return studiedPercentSum / deckCards.length;
  }

  static DateTime? _latestRoundDateOfDecks(List<VocabDeckCardData> deckCards) {
    DateTime? latestRoundDate;
    for (final deckCard in deckCards) {
      final lastRoundDate = deckCard.progress?.lastRoundDate;
      if (lastRoundDate == null) continue;
      if (latestRoundDate == null || lastRoundDate.isAfter(latestRoundDate)) {
        latestRoundDate = lastRoundDate;
      }
    }
    return latestRoundDate;
  }

  static int _totalCardCountOfDecks(List<VocabDeckCardData> deckCards) {
    return deckCards.fold(0, (sum, deckCard) => sum + deckCard.cardCount);
  }

  static bool _isEveryDeckFullyStudied(List<VocabDeckCardData> deckCards) {
    return deckCards.isNotEmpty &&
        deckCards.every(
          (deckCard) =>
              deckCard.coverage != null &&
              deckCard.coverage! >= ProgressConstants.coverageMax,
        );
  }

  static int _lowestMasteryOfDecks(List<VocabDeckCardData> deckCards) {
    if (deckCards.isEmpty) return 0;
    return deckCards
        .map((deckCard) => deckCard.mastery)
        .reduce(
          (lowestMastery, mastery) =>
              mastery < lowestMastery ? mastery : lowestMastery,
        );
  }

  static double _averagePracticePercentOfDecks(
    List<VocabDeckCardData> deckCards,
  ) {
    if (deckCards.isEmpty) return 0.0;
    final practicePercentSum = deckCards.fold(
      0.0,
      (sum, deckCard) => sum + deckCard.practice,
    );
    return practicePercentSum / deckCards.length;
  }
}

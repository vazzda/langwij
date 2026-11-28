import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:langwij/entities/dictionary/dictionary.dart';
import 'package:langwij/entities/progress/progress.dart';
import 'package:langwij/widgets/vocab/vocab.dart';

import '../model/vocab_fold_state.dart';
import 'vocab_fold_state_notifier_service.dart';

/// The main vocabulary screen's state and display data: which segment and
/// level are unfolded, and the segment sections with their levels.
class VocabPageService {
  VocabPageService._();

  /// Which segment and which level are unfolded, for this app run. Changed
  /// through its notifier: `toggleSegmentFold`, `toggleLevelFold`.
  static final foldState =
      AsyncNotifierProvider<VocabFoldStateNotifierService, VocabFoldState>(
    VocabFoldStateNotifierService.new,
  );

  static List<VocabSegmentSectionData> buildVocabSegmentSections({
    required Dictionary dictionary,
    required LanguagePack targetPack,
    required LanguagePack nativePack,
    required Map<String, DeckProgress> deckProgressByDeckId,
    required Map<String, LevelTier> levelTierByLevelId,
  }) {
    final decksByDeckId = dictionary.decksById;
    final levelsByLevelId = {
      for (final level in dictionary.levels) level.id: level,
    };
    final deckNumberByDeckId = _numberDecksInScreenOrder(
      segments: dictionary.vocabularyLevelSegments,
      levelsByLevelId: levelsByLevelId,
    );

    return [
      for (final segment in dictionary.vocabularyLevelSegments)
        VocabSegmentSectionData(
          segmentId: segment.id,
          name: nativePack.vocabularyLevelSegmentMeta[segment.id]?.name ??
              segment.id,
          intro: nativePack.vocabularyLevelSegmentMeta[segment.id]?.intro,
          levels: [
            for (final levelId in segment.levelIds)
              if (levelsByLevelId[levelId] case final level?)
                VocabLevelDataBuilderService.buildVocabLevelData(
                  level: level,
                  decksByDeckId: decksByDeckId,
                  targetPack: targetPack,
                  nativePack: nativePack,
                  deckProgressByDeckId: deckProgressByDeckId,
                  deckNumberByDeckId: deckNumberByDeckId,
                  levelTier:
                      levelTierByLevelId[level.id] ?? LevelTier.premium,
                ),
          ],
        ),
    ];
  }

  /// Numbers the decks from 1 in the order the screen lists them: segment by
  /// segment, level by level, deck by deck.
  static Map<String, int> _numberDecksInScreenOrder({
    required List<VocabularyLevelSegment> segments,
    required Map<String, Level> levelsByLevelId,
  }) {
    final deckNumberByDeckId = <String, int>{};
    for (final segment in segments) {
      for (final levelId in segment.levelIds) {
        final deckIdsOfLevel =
            levelsByLevelId[levelId]?.deckIds ?? const <String>[];
        for (final deckId in deckIdsOfLevel) {
          deckNumberByDeckId[deckId] = deckNumberByDeckId.length + 1;
        }
      }
    }
    return deckNumberByDeckId;
  }
}

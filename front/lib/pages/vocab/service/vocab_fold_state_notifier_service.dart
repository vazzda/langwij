import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:langwij/entities/dictionary/dictionary.dart';
import 'package:langwij/entities/progress/progress.dart';
import 'package:langwij/shared/app/config/config.dart';

import '../model/vocab_fold_state.dart';

/// Holds the fold state of the main vocabulary screen for one app run.
///
/// The state starts from the training history: the segment and level of the
/// deck trained last, or the first segment and its first level while nothing
/// was trained. It is worked out once and then changes only by the
/// learner's taps, so a finished round does not rearrange the screen.
class VocabFoldStateNotifierService extends AsyncNotifier<VocabFoldState> {
  @override
  Future<VocabFoldState> build() async {
    _startOverWhenTargetLanguageChanges();
    return _foldStateFromTrainingHistory(
      dictionary: await ref.read(DictionaryService.dictionary.future),
      deckProgressByDeckId:
          await ref.read(ProgressService.allDeckProgress.future),
    );
  }

  /// Every target language has its own training history.
  void _startOverWhenTargetLanguageChanges() {
    ref.watch(
      ConfigService.languageSettings.select(
        (languageSettings) => languageSettings.valueOrNull?.targetLang,
      ),
    );
  }

  /// Folds the tapped segment when it is the unfolded one. Otherwise unfolds
  /// it, which folds the segment unfolded before, so at most one is unfolded.
  /// A segment being unfolded always opens on its last trained level, or on
  /// its first level while none was trained.
  Future<void> toggleSegmentFold(String tappedSegmentId) async {
    final currentFoldState = await future;

    if (tappedSegmentId == currentFoldState.unfoldedSegmentId) {
      state = AsyncData(
        VocabFoldState(
          unfoldedSegmentId: null,
          unfoldedLevelId: currentFoldState.unfoldedLevelId,
        ),
      );
      return;
    }

    final dictionary = await ref.read(DictionaryService.dictionary.future);
    final deckProgressByDeckId =
        await ref.read(ProgressService.allDeckProgress.future);
    state = AsyncData(
      VocabFoldState(
        unfoldedSegmentId: tappedSegmentId,
        unfoldedLevelId: _levelIdToUnfoldWhenSegmentIsUnfolded(
          segmentId: tappedSegmentId,
          dictionary: dictionary,
          deckProgressByDeckId: deckProgressByDeckId,
        ),
      ),
    );
  }

  /// Folds the tapped level when it is the unfolded one. Otherwise unfolds
  /// it, which folds the level unfolded before, so at most one is unfolded.
  Future<void> toggleLevelFold(String tappedLevelId) async {
    final currentFoldState = await future;
    final isTappedLevelUnfolded =
        tappedLevelId == currentFoldState.unfoldedLevelId;
    state = AsyncData(
      VocabFoldState(
        unfoldedSegmentId: currentFoldState.unfoldedSegmentId,
        unfoldedLevelId: isTappedLevelUnfolded ? null : tappedLevelId,
      ),
    );
  }

  /// The segment and level holding the deck trained last. While no deck of
  /// any segment was trained: the first segment and its first level.
  static VocabFoldState _foldStateFromTrainingHistory({
    required Dictionary dictionary,
    required Map<String, DeckProgress> deckProgressByDeckId,
  }) {
    final segments = dictionary.vocabularyLevelSegments;
    final levelsByLevelId = _levelsByLevelId(dictionary);

    String? lastTrainedSegmentId;
    ({String levelId, DateTime lastRoundDate})? lastTrainedLevel;
    for (final segment in segments) {
      final lastTrainedLevelOfSegment = _lastTrainedLevelOfSegment(
        segment: segment,
        levelsByLevelId: levelsByLevelId,
        deckProgressByDeckId: deckProgressByDeckId,
      );
      if (lastTrainedLevelOfSegment == null) continue;
      if (lastTrainedLevel == null ||
          lastTrainedLevelOfSegment.lastRoundDate.isAfter(
            lastTrainedLevel.lastRoundDate,
          )) {
        lastTrainedLevel = lastTrainedLevelOfSegment;
        lastTrainedSegmentId = segment.id;
      }
    }

    if (lastTrainedLevel == null) {
      final firstSegment = segments.firstOrNull;
      return VocabFoldState(
        unfoldedSegmentId: firstSegment?.id,
        unfoldedLevelId: firstSegment?.levelIds.firstOrNull,
      );
    }
    return VocabFoldState(
      unfoldedSegmentId: lastTrainedSegmentId,
      unfoldedLevelId: lastTrainedLevel.levelId,
    );
  }

  /// The last trained level of the segment, or its first level while none of
  /// its decks was trained.
  static String? _levelIdToUnfoldWhenSegmentIsUnfolded({
    required String segmentId,
    required Dictionary dictionary,
    required Map<String, DeckProgress> deckProgressByDeckId,
  }) {
    final segment = dictionary.vocabularyLevelSegments
        .where((segment) => segment.id == segmentId)
        .firstOrNull;
    if (segment == null) return null;

    final lastTrainedLevel = _lastTrainedLevelOfSegment(
      segment: segment,
      levelsByLevelId: _levelsByLevelId(dictionary),
      deckProgressByDeckId: deckProgressByDeckId,
    );
    return lastTrainedLevel?.levelId ?? segment.levelIds.firstOrNull;
  }

  /// The level of the segment holding the deck with the most recent round,
  /// with the date of that round; null while no deck of the segment has had
  /// a round.
  static ({String levelId, DateTime lastRoundDate})? _lastTrainedLevelOfSegment({
    required VocabularyLevelSegment segment,
    required Map<String, Level> levelsByLevelId,
    required Map<String, DeckProgress> deckProgressByDeckId,
  }) {
    ({String levelId, DateTime lastRoundDate})? lastTrainedLevel;

    for (final levelId in segment.levelIds) {
      final deckIdsOfLevel =
          levelsByLevelId[levelId]?.deckIds ?? const <String>[];
      for (final deckId in deckIdsOfLevel) {
        final lastRoundDate = deckProgressByDeckId[deckId]?.lastRoundDate;
        if (lastRoundDate == null) continue;
        if (lastTrainedLevel == null ||
            lastRoundDate.isAfter(lastTrainedLevel.lastRoundDate)) {
          lastTrainedLevel = (levelId: levelId, lastRoundDate: lastRoundDate);
        }
      }
    }
    return lastTrainedLevel;
  }

  static Map<String, Level> _levelsByLevelId(Dictionary dictionary) {
    return {for (final level in dictionary.levels) level.id: level};
  }
}

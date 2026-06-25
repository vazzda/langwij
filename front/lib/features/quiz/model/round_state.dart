import 'package:langwij/entities/group/group.dart';
import 'missed_entry.dart';
import 'package:langwij/entities/progress/progress.dart';
import 'round_type.dart';

class RoundState {
  const RoundState({
    required this.deckId,
    required this.mode,
    required this.requestedCount,
    required this.roundType,
    required this.originRoute,
    this.originScrollOffset = 0.0,
    this.adjectiveGroupId,
    this.deckName,
    this.isTest = false,
    this.totalDeckTerms = 0,
    this.queue = const [],
    this.allCards,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.firstPassCorrect = 0,
    this.attemptedCardIds = const {},
    this.missedEntries = const [],
    this.correctEntries = const [],
    this.roundWordIds = const {},
  });

  final String deckId;
  final QuizMode mode;
  final int requestedCount;
  final RoundType roundType;
  final String originRoute;
  final double originScrollOffset;
  final String? adjectiveGroupId;
  final String? deckName;
  final bool isTest;
  final int totalDeckTerms;
  final List<CardModel> queue;
  final List<CardModel>? allCards;
  final int correctCount;
  final int wrongCount;
  final int firstPassCorrect;
  final Set<String> attemptedCardIds;
  final List<MissedEntry> missedEntries;
  final List<CardModel> correctEntries;
  final Set<String> roundWordIds;

  CardModel? get currentCard => queue.isNotEmpty ? queue.first : null;
  bool get isFinished => queue.isEmpty;
  int get roundTermCount => roundWordIds.length;

  RoundState copyWith({
    List<CardModel>? queue,
    int? correctCount,
    int? wrongCount,
    int? firstPassCorrect,
    Set<String>? attemptedCardIds,
    List<MissedEntry>? missedEntries,
    List<CardModel>? correctEntries,
    Set<String>? roundWordIds,
  }) {
    return RoundState(
      deckId: deckId,
      mode: mode,
      requestedCount: requestedCount,
      roundType: roundType,
      originRoute: originRoute,
      originScrollOffset: originScrollOffset,
      adjectiveGroupId: adjectiveGroupId,
      deckName: deckName,
      isTest: isTest,
      totalDeckTerms: totalDeckTerms,
      queue: queue ?? this.queue,
      allCards: allCards,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      firstPassCorrect: firstPassCorrect ?? this.firstPassCorrect,
      attemptedCardIds: attemptedCardIds ?? this.attemptedCardIds,
      missedEntries: missedEntries ?? this.missedEntries,
      correctEntries: correctEntries ?? this.correctEntries,
      roundWordIds: roundWordIds ?? this.roundWordIds,
    );
  }
}

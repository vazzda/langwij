import '../../entities/card/card_model.dart';
import 'quiz_mode.dart';

/// Type of round (for title, "Again", and options).
enum RoundType { vocabulary, conjugations, agreement }

/// One missed card; in Write mode [userTypedAnswer] is what the user wrongly typed.
class MissedEntry {
  const MissedEntry({required this.card, this.userTypedAnswer});

  final CardModel card;
  /// Non-null only in Write mode when we recorded the wrong typed answer.
  final String? userTypedAnswer;
}

/// State of an active or finished quiz round.
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
  /// Route to navigate back to when round ends or is cancelled.
  final String originRoute;
  /// Scroll offset to restore when navigating back to origin.
  final double originScrollOffset;
  /// For agreement rounds: the adjective group id (without "agreement:" prefix).
  final String? adjectiveGroupId;
  /// Resolved deck name for round title display (from meta system).
  final String? deckName;

  /// Whether this is a test round (direct score → progress, ratchet only).
  final bool isTest;

  /// Total terms in the deck (for coverage calculation).
  final int totalDeckTerms;

  /// Remaining cards to answer (front = current). Wrong answers are moved to end.
  final List<CardModel> queue;

  /// All cards generated for this round (for MCQ option pool).
  /// Set for vocab rounds; null for legacy/agreement rounds (which use group.cards).
  final List<CardModel>? allCards;

  final int correctCount;
  final int wrongCount;

  /// Cards answered correctly on first attempt (for test scoring).
  final int firstPassCorrect;

  /// Card IDs that have been attempted at least once (for first-pass detection).
  final Set<String> attemptedCardIds;

  /// Entries that were answered wrong (for review at end). Write mode stores userTypedAnswer.
  final List<MissedEntry> missedEntries;

  /// Cards answered correctly on first attempt (for review at end).
  final List<CardModel> correctEntries;

  /// Distinct word IDs in this round (for daily "words touched").
  final Set<String> roundWordIds;

  CardModel? get currentCard => queue.isNotEmpty ? queue.first : null;

  bool get isFinished => queue.isEmpty;

  /// Number of unique terms in this round (for coverage calculation).
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

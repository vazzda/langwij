import '../../entities/card/card_model.dart';
import 'quiz_mode.dart';

/// Type of session (for title, "Again", and options).
enum SessionType { vocabulary, conjugations, agreement }

/// One missed card; in Write mode [userTypedAnswer] is what the user wrongly typed.
class MissedEntry {
  const MissedEntry({required this.card, this.userTypedAnswer});

  final CardModel card;
  /// Non-null only in Write mode when we recorded the wrong typed answer.
  final String? userTypedAnswer;
}

/// State of an active or finished quiz session.
class SessionState {
  const SessionState({
    required this.groupId,
    required this.mode,
    required this.requestedCount,
    required this.sessionType,
    required this.originRoute,
    this.originScrollOffset = 0.0,
    this.adjectiveGroupId,
    this.groupName,
    this.queue = const [],
    this.allCards,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.missedEntries = const [],
    this.sessionWordIds = const {},
  });

  final String groupId;
  final QuizMode mode;
  final int requestedCount;
  final SessionType sessionType;
  /// Route to navigate back to when session ends or is cancelled.
  final String originRoute;
  /// Scroll offset to restore when navigating back to origin.
  final double originScrollOffset;
  /// For agreement sessions: the adjective group id (without "agreement:" prefix).
  final String? adjectiveGroupId;
  /// Resolved group name for session title display (from meta system).
  final String? groupName;

  /// Remaining cards to answer (front = current). Wrong answers are moved to end.
  final List<CardModel> queue;

  /// All cards generated for this session (for MCQ option pool).
  /// Set for vocab sessions; null for legacy/agreement sessions (which use group.cards).
  final List<CardModel>? allCards;

  final int correctCount;
  final int wrongCount;

  /// Entries that were answered wrong (for review at end). Write mode stores userTypedAnswer.
  final List<MissedEntry> missedEntries;

  /// Distinct word IDs in this session (for daily "words touched").
  final Set<String> sessionWordIds;

  CardModel? get currentCard => queue.isNotEmpty ? queue.first : null;

  bool get isFinished => queue.isEmpty;

  SessionState copyWith({
    List<CardModel>? queue,
    int? correctCount,
    int? wrongCount,
    List<MissedEntry>? missedEntries,
    Set<String>? sessionWordIds,
  }) {
    return SessionState(
      groupId: groupId,
      mode: mode,
      requestedCount: requestedCount,
      sessionType: sessionType,
      originRoute: originRoute,
      originScrollOffset: originScrollOffset,
      adjectiveGroupId: adjectiveGroupId,
      groupName: groupName,
      queue: queue ?? this.queue,
      allCards: allCards,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      missedEntries: missedEntries ?? this.missedEntries,
      sessionWordIds: sessionWordIds ?? this.sessionWordIds,
    );
  }
}

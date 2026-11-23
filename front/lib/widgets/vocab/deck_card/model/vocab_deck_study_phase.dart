/// Where the learner stands with one vocabulary deck.
enum VocabDeckStudyPhase {
  /// Nothing of the deck is studied yet.
  notStarted,

  /// A part of the deck is studied.
  studying,

  /// The deck is fully studied and is kept up by training.
  training,
}

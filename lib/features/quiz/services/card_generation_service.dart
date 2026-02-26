import '../../../entities/card/vocab_card.dart';
import '../../../entities/group/vocab_group_model.dart';
import '../../../entities/language/lang_entry.dart';
import '../../../entities/language/language_pack.dart';

/// Generates VocabCards by joining a group's concepts with target + native translations.
class CardGenerationService {
  /// Build a list of VocabCards for a vocabulary group.
  ///
  /// One VocabCard per concept. Entry type determines card subtype:
  ///   [AspectPairEntry] → [PairVocabCard] (two-input write quiz)
  ///   [SimpleEntry] / [AdjectiveEntry] → [SimpleVocabCard]
  ///
  /// Skips concepts missing from either pack.
  List<VocabCard> buildCards({
    required VocabGroupModel group,
    required LanguagePack targetPack,
    required LanguagePack nativePack,
  }) {
    final cards = <VocabCard>[];

    for (final conceptId in group.conceptIds) {
      final targetEntry = targetPack.translations[conceptId];
      final nativeEntry = nativePack.translations[conceptId];
      if (targetEntry == null || nativeEntry == null) continue;

      final nativeText = _nativeText(nativeEntry);
      final nativeNote = nativeEntry.note;

      switch (targetEntry) {
        case AspectPairEntry(
            :final imperfective,
            :final perfective,
            :final note,
          ):
          cards.add(PairVocabCard(
            conceptId: conceptId,
            nativeText: nativeText,
            imperfectiveText: imperfective,
            perfectiveText: perfective,
            nativeNote: nativeNote,
            targetNote: note,
          ));

        case SimpleEntry(:final text, :final note):
          cards.add(SimpleVocabCard(
            conceptId: conceptId,
            nativeText: nativeText,
            targetText: text,
            nativeNote: nativeNote,
            targetNote: note,
          ));

        case AdjectiveEntry(:final m, :final note):
          cards.add(SimpleVocabCard(
            conceptId: conceptId,
            nativeText: nativeText,
            targetText: m,
            nativeNote: nativeNote,
            targetNote: note,
          ));
      }
    }

    return cards;
  }

  /// Returns the primary display text for the native side of a card.
  String _nativeText(LangEntry entry) => switch (entry) {
        SimpleEntry(:final text) => text,
        AspectPairEntry(:final imperfective, :final perfective) =>
          '$imperfective / $perfective',
        AdjectiveEntry(:final m) => m,
      };
}

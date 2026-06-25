import 'package:langwij/entities/dictionary/dictionary.dart';
import '../model/vocab_card.dart';

class CardGenerationService {
  List<VocabCard> buildCards({
    required VocabDeckModel deck,
    required LanguagePack targetPack,
    required LanguagePack nativePack,
  }) {
    final cards = <VocabCard>[];

    for (final termId in deck.termIds) {
      final targetEntry = targetPack.translations[termId];
      final nativeEntry = nativePack.translations[termId];
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
            termId: termId,
            nativeText: nativeText,
            imperfectiveText: imperfective,
            perfectiveText: perfective,
            nativeNote: nativeNote,
            targetNote: note,
          ));

        case SimpleEntry(:final text, :final note):
          cards.add(SimpleVocabCard(
            termId: termId,
            nativeText: nativeText,
            targetText: text,
            nativeNote: nativeNote,
            targetNote: note,
          ));

        case AdjectiveEntry(:final m, :final note):
          cards.add(SimpleVocabCard(
            termId: termId,
            nativeText: nativeText,
            targetText: m,
            nativeNote: nativeNote,
            targetNote: note,
          ));
      }
    }

    return cards;
  }

  String _nativeText(LangEntry entry) => switch (entry) {
        SimpleEntry(:final text) => text,
        AspectPairEntry(:final imperfective, :final perfective) =>
          '$imperfective / $perfective',
        AdjectiveEntry(:final m) => m,
      };
}

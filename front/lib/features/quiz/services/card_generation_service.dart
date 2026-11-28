import 'package:langwij/entities/dictionary/dictionary.dart';
import '../model/vocab_card.dart';

class CardGenerationService {
  List<VocabCard> buildCards({
    required VocabDeckModel deck,
    required LanguagePack targetPack,
    required LanguagePack nativePack,
    required Map<String, Term> terms,
  }) {
    final cards = <VocabCard>[];

    for (final termId in deck.termIds) {
      final targetEntry = targetPack.translations[termId];
      final nativeEntry = nativePack.translations[termId];
      if (targetEntry == null || nativeEntry == null) continue;

      final nativeText = _nativeText(nativeEntry);
      final nativeNote = nativeEntry.note;
      final term = terms[termId];
      final pos = term?.pos;
      final coca = term?.coca;

      switch (targetEntry) {
        case AspectPairEntry(
            :final imperfective,
            :final perfective,
            :final note,
          ):
          cards.add(PairVocabCard(
            termId: termId,
            nativeText: nativeText,
            pos: pos,
            coca: coca,
            imperfectiveText: imperfective,
            perfectiveText: perfective,
            nativeNote: nativeNote,
            targetNote: note,
          ));

        case SimpleEntry(
            :final text,
            :final note,
            :final gender,
            :final article,
            :final aspect,
          ):
          cards.add(SimpleVocabCard(
            termId: termId,
            nativeText: nativeText,
            pos: pos,
            coca: coca,
            targetText: text,
            nativeNote: nativeNote,
            targetNote: note,
            gender: gender,
            article: article,
            aspect: aspect,
          ));

        case GenderFormsEntry(:final headword, :final forms, :final note):
          cards.add(SimpleVocabCard(
            termId: termId,
            nativeText: nativeText,
            pos: pos,
            coca: coca,
            targetText: headword,
            nativeNote: nativeNote,
            targetNote: note,
            genderForms: forms,
          ));
      }
    }

    return cards;
  }

  String _nativeText(LangEntry entry) => switch (entry) {
        SimpleEntry(:final text) => text,
        AspectPairEntry(:final imperfective, :final perfective) =>
          '$imperfective / $perfective',
        GenderFormsEntry(:final headword) => headword,
      };
}

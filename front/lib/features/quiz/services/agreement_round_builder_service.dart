import 'dart:math';

import 'package:langwij/entities/group/group.dart';

class AgreementRoundBuilderService {
  const AgreementRoundBuilderService._();

  static ({List<CardModel> queue, Set<String> wordIds}) buildAgreementQueue({
    required GroupModel adjectiveGroup,
    required List<GroupModel> nounGroups,
    required int count,
    required Random random,
  }) {
    final adjectives = adjectiveGroup.cards
        .whereType<AdjectiveCard>()
        .toList();
    final nounsByGender = <String, List<NounCard>>{
      'm': [],
      'f': [],
      'n': [],
    };
    for (final group in nounGroups) {
      for (final card in group.cards) {
        if (card is NounCard) {
          nounsByGender[card.gender]!.add(card);
        }
      }
    }
    final gendersWithNouns = ['m', 'f', 'n']
        .where((g) => nounsByGender[g]!.isNotEmpty)
        .toList();
    if (gendersWithNouns.isEmpty || adjectives.isEmpty) {
      return (queue: <CardModel>[], wordIds: <String>{});
    }
    final roundGender = gendersWithNouns[random.nextInt(gendersWithNouns.length)];
    final nouns = nounsByGender[roundGender]!;
    final queue = <CardModel>[];
    final wordIds = <String>{};
    for (var i = 0; i < count; i++) {
      final adj = adjectives[random.nextInt(adjectives.length)];
      final noun = nouns[random.nextInt(nouns.length)];
      final target = '${adj.formForGender(roundGender)} ${noun.targetText}';
      final native = '${adj.nativeText} ${noun.nativeText}';
      queue.add(PhraseCard(targetText: target, nativeText: native));
      wordIds.add('agreement:${adjectiveGroup.id}:$i');
    }
    return (queue: queue, wordIds: wordIds);
  }
}
